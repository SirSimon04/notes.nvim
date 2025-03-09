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

    -- Update config.templates
    local template_name = custom_type.template:match("([^/]+)%.md$")
    config.templates[template_name] = vim.fn.expand(custom_type.template)

    -- Open command
    vim.api.nvim_create_user_command(open_command, function()
      local snacks = require("snacks.picker")
      snacks.smart({
        cwd = dir_path,
        multi = { "files" },
        title = custom_type.name .. " notes",
        sort = function(a, b)
          return a.file > b.file
        end,
      })
    end, {})

    -- Create command
    vim.api.nvim_create_user_command(create_command, function()
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
            local full_path = path:new(dir_path .. filename)

            local template_content = utils.load_template(template_name, config) -- Use the updated config.templates
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
          local full_path = path:new(dir_path .. filename)

          local template_content = utils.load_template(template_name, config) -- Use the updated config.templates
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
    end, {})
  end
end

return M
