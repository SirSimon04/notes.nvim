local M = {}
local vim = vim
local vim_ui = vim.ui
local os_time = os.time
local os_date = os.date
local io = io
local path = require("plenary.path")
local utils = require("notes.utils")

function M.setup(config)
  for _, custom_type in ipairs(config.custom_types) do
    local open_command = "NotesOpen" .. custom_type.name
    local create_command = "NotesCreate" .. custom_type.name

    -- Create directory if it doesn't exist
    local dir_path = vim.fn.expand(custom_type.dir)
    if not path:new(dir_path):exists() then
      vim.fn.mkdir(dir_path, "p")
    end

    -- Update config.templates (only if template is provided)
    if custom_type.template and custom_type.template ~= "" then
      local template_name = custom_type.template:match("([^/]+)%.md$")
      config.templates[template_name] = vim.fn.expand(custom_type.template)
    end

    -- Open command
    vim.api.nvim_create_user_command(open_command, function()
      if custom_type.folder_based then
        open_folder_based_notes(custom_type, config)
      else
        open_single_file_notes(custom_type)
      end
    end, {})

    -- Create command
    vim.api.nvim_create_user_command(create_command, function()
      if custom_type.folder_based then
        create_folder_based_note(custom_type, config)
      else
        create_single_file_note(custom_type, config)
      end
    end, {})

    if custom_type.folder_based then
      local add_note_command = "NotesAddNoteTo" .. custom_type.name
      vim.api.nvim_create_user_command(add_note_command, function()
        add_note_to_folder_based_note(custom_type, config)
      end, {})
    end
  end
end

-- Helper Functions for Folder-Based Notes

function open_folder_based_notes(custom_type, config)
  local note_dirs = get_subdirectories(vim.fn.expand(custom_type.dir))

  local note_files = {}
  for _, note_dir in ipairs(note_dirs) do
    if note_dir then
      local full_path = vim.fn.expand(custom_type.dir) .. "/" .. note_dir .. "/" .. note_dir .. ".md"
      local note_file = path:new(full_path)
      if note_file and note_file:exists() then
        table.insert(note_files, { path = full_path, name = note_dir })
      end
    end
  end

  local display_names = {}
  local path_map = {}
  for _, note in ipairs(note_files) do
    table.insert(display_names, note.name)
    path_map[note.name] = note.path
  end

  vim_ui.select(display_names, { prompt = "Select " .. custom_type.name .. ":" }, function(ok, choice)
    if ok and choice then
      vim.cmd("edit " .. path_map[display_names[choice]])
    end
  end)
end

function add_note_to_folder_based_note(custom_type, config)
  local note_dirs = get_subdirectories(vim.fn.expand(custom_type.dir))

  local note_files = {}
  for _, note_dir in ipairs(note_dirs) do
    if note_dir then
      local full_path = vim.fn.expand(custom_type.dir) .. "/" .. note_dir .. "/" .. note_dir .. ".md"
      local note_file = path:new(full_path)
      if note_file and note_file:exists() then
        table.insert(note_files, { path = vim.fn.expand(custom_type.dir) .. "/" .. note_dir, name = note_dir })
      end
    end
  end

  local display_names = {}
  local path_map = {}
  for _, note in ipairs(note_files) do
    table.insert(display_names, note.name)
    path_map[note.name] = note.path
  end

  vim_ui.select(display_names, { prompt = "Select " .. custom_type.name .. " to add note to:" }, function(ok, choice)
    if ok and choice then
      local note_dir_path = path_map[display_names[choice]]
      vim_ui.input({ prompt = "New Note Name: " }, function(new_note_name)
        if new_note_name and new_note_name ~= "" then
          local main_note_name = display_names[choice]
          local new_number = 1
          if custom_type.numbered then
            new_number = get_next_number(note_dir_path)
          end
          local new_note_path = path:new(note_dir_path, string.format("%03d-%s.md", new_number, new_note_name))
          local main_note_path = path:new(note_dir_path .. "/" .. main_note_name .. ".md")

          local new_note_file = io.open(new_note_path:absolute(), "w")
          if new_note_file then
            new_note_file:close()
          else
            vim.notify("Failed to create new note: " .. new_note_path:absolute(), vim.log.levels.ERROR)
            return
          end

          local main_note_file = io.open(main_note_path:absolute(), "a")
          if main_note_file then
            main_note_file:write("\n[[" .. string.format("%03d-%s", new_number, new_note_name) .. "]]")
            main_note_file:close()
            vim.cmd("edit " .. new_note_path:absolute())
          else
            vim.notify("Failed to update main note file: " .. main_note_path:absolute(), vim.log.levels.ERROR)
          end
        end
      end)
    end
  end)
end

function create_folder_based_note(custom_type, config)
  vim_ui.input({ prompt = "New " .. custom_type.name .. " Name: " }, function(note_name)
    if not note_name or note_name == "" then
      return -- Cancelled
    end

    local note_dir_path = path:new(vim.fn.expand(custom_type.dir), note_name)
    local note_file_path = path:new(note_dir_path, note_name .. ".md")

    -- Create the directory using os.execute
    local cmd = 'mkdir -p "' .. note_dir_path:absolute() .. '"'
    local ok, err = os.execute(cmd)
    if ok ~= 0 then
      vim.notify("Failed to create directory: " .. (err or "unknown"), vim.log.levels.ERROR)
      return
    end

    -- Create the file using os.execute
    local fileCmd = 'touch "' .. note_file_path:absolute() .. '"'
    local fileOk, fileErr = os.execute(fileCmd)
    if fileOk ~= 0 then
      vim.notify("Failed to create file: " .. (fileErr or "unknown"), vim.log.levels.ERROR)
      return
    end

    local template_content
    if custom_type.template and custom_type.template ~= "" then
      local template_name = custom_type.template:match("([^/]+)%.md$")
      template_content = utils.load_template(template_name, config)
    else
      -- Find the directory where utils.lua is located using debug.getinfo
      local info = debug.getinfo(utils.load_template, "S")
      if info and info.source then
        local utils_path = info.source:sub(2) -- Remove leading '@'
        local module_dir = path:new(utils_path):parent():absolute() -- Go up two levels
        local error_template_path = module_dir .. "/templates/error.md"

        vim.notify("Module Dir: " .. module_dir, vim.log.levels.DEBUG)
        vim.notify("Error Template Path: " .. error_template_path, vim.log.levels.DEBUG)

        local error_file, error_err = io.open(error_template_path, "r")
        if error_file then
          template_content = error_file:read("*a")
          error_file:close()
          vim.notify("No template provided, using error template.", vim.log.levels.WARN)
        else
          vim.notify("No template provided and error template not found. Error: " .. (error_err or "unknown"), vim.log.levels.ERROR)
          return
        end
      else
        vim.notify("Failed to locate utils.lua directory.", vim.log.levels.ERROR)
        return
      end
    end

    if template_content then
      local template_variables = {
        [custom_type.name:lower() .. "_title"] = note_name,
        start_date = vim.fn.strftime("%Y-%m-%d"),
        filename = note_name,
      }
      local note_content = utils.replace_template_variables(template_content, template_variables)

      local fileHandle, writeErr = io.open(note_file_path:absolute(), "w")
      if fileHandle then
        fileHandle:write(note_content)
        fileHandle:close()
        vim.cmd("edit " .. note_file_path:absolute())
      else
        vim.notify("Failed to write to file: " .. (writeErr or "unknown"), vim.log.levels.ERROR)
      end
    end
  end)
end

-- Helper Functions for Single-File Notes

function open_single_file_notes(custom_type)
  local snacks = require("snacks.picker")
  snacks.smart({
    cwd = vim.fn.expand(custom_type.dir),
    multi = { "files" },
    title = custom_type.name .. " notes",
    sort = function(a, b)
      return a.file > b.file
    end,
  })
end

function create_single_file_note(custom_type, config)
  local variables = {}

  -- Get title
  vim_ui.input({ prompt = custom_type.name .. " Title: " }, function(title)
    if not title or title == "" then
      return -- Cancelled
    end
    variables.title = title

    -- Get date if needed
    local filename_pattern = custom_type.filename or "${date}-${title}"
    if filename_pattern:match("${date}") then
      vim_ui.input({ prompt = "Date (YYYY-MM-DD, integer, or empty for today): " }, function(date_input)
        local date_str
        if not date_input or date_input == "" then
          date_str = os_date "%Y-%m-%d" -- Today's date
        else
          local num_days = tonumber(date_input)
          if num_days then
            local future_time = os_time() + (num_days * 86400) -- 86400 seconds in a day
            date_str = os_date("%Y-%m-%d", future_time)
          else
            if date_input:match "^%d%d%d%d%-%d%d%-%d%d$" then
              date_str = date_input
            else
              vim.notify("Invalid date format", vim.log.levels.ERROR)
              return
            end
          end
        end
        variables.date = date_str

        -- Create filename
        local filename = filename_pattern:gsub("${title}", variables.title):gsub("${date}", variables.date) .. ".md"
        local full_path = path:new(vim.fn.expand(custom_type.dir) .. filename)

        local template_content = utils.load_template(custom_type.template:match("([^/]+)%.md$"), config)
        if template_content then
          local template_variables = {
            [custom_type.name:lower() .. "_title"] = variables.title,
            date = variables.date,
          }
          local note_content = utils.replace_template_variables(template_content, template_variables, filename)

          local file, err = io.open(full_path:absolute(), "w")
          if file then
            file:write(note_content)
            file:close()
            vim.cmd("edit " .. full_path:absolute())
          else
            vim.notify("Failed to create file: " .. full_path:absolute() .. " - " .. (err or "unknown"), vim.log.levels.ERROR)
          end
        else
          vim.notify("Failed to load " .. custom_type.name .. " template", vim.log.levels.ERROR)
        end
      end)
    else
      -- Create filename without date prompt
      local filename = filename_pattern:gsub("${title}", variables.title) .. ".md"
      local full_path = path:new(vim.fn.expand(custom_type.dir) .. filename)

      local template_content = utils.load_template(custom_type.template:match("([^/]+)%.md$"), config)
      if template_content then
        local template_variables = {
          [custom_type.name:lower() .. "_title"] = variables.title,
          date = os_date("%Y-%m-%d"),
        }
        local note_content = utils.replace_template_variables(template_content, template_variables, filename)

        local file, err = io.open(full_path:absolute(), "w")
        if file then
          file:write(note_content)
          file:close()
          vim.cmd("edit " .. full_path:absolute())
        else
          vim.notify("Failed to create file: " .. full_path:absolute() .. " - " .. (err or "unknown"), vim.log.levels.ERROR)
        end
      else
        vim.notify("Failed to load " .. custom_type.name .. " template", vim.log.levels.ERROR)
      end
    end
  end)
end

-- Helper Function
function get_subdirectories(dir_path)
  local cmd = 'find ' .. dir_path .. ' -mindepth 1 -maxdepth 1 -type d -exec basename {} \\;'
  local file, err = io.popen(cmd)
  if not file then
    vim.notify('Error executing find: ' .. (err or 'unknown'), vim.log.levels.ERROR)
    return {}
  end

  local subdirs = {}
  for line in file:lines() do
    table.insert(subdirs, line)
  end
  local ok, close_err = file:close()
  if not ok then
    vim.notify('Error closing find: ' .. (close_err or 'unknown'), vim.log.levels.ERROR)
  end
  return subdirs
end

-- Helper Function to get next number
function get_next_number(dir_path)
  local max_num = 0
  local dir_iter, err = vim.fs.dir(dir_path)
  if err then
    vim.notify("Error reading directory: " .. (err or "unknown"), vim.log.levels.ERROR)
    return 1 -- Return 1 on error to avoid breaking the function
  end
  if dir_iter then
    for file in dir_iter do
      local num = tonumber(file:match("^%d+"))
      if num and num > max_num then
        max_num = num
      end
    end
  end
  return max_num + 1
end

return M
