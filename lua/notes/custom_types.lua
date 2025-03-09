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

    -- Open command
    vim.api.nvim_create_user_command(open_command, function()
      local snacks = require("snacks.picker")
      snacks.smart({
        cwd = vim.fn.expand(custom_type.dir),
        multi = { "files" },
        title = custom_type.name .. " notes",
        sort = function(a, b)
          return a.file > b.file
        end,
      })
    end, {})

    -- Create command
    vim.api.nvim_create_user_command(create_command, function()
      vim_ui.input({ prompt = custom_type.name .. " Name: " }, function(note_name)
        if not note_name or note_name == "" then
          return -- Cancelled
        end
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

          local file_name = date_str .. "-" .. note_name .. ".md"
          local full_path = path:new(vim.fn.expand(custom_type.dir) .. file_name)

          local template_content = utils.load_template(custom_type.template:match("([^/]+)%.md$"), config)
          if template_content then
            local variables = {
              [custom_type.name:lower() .. "_name"] = note_name,
              date = date_str,
            }
            local note_content = utils.replace_template_variables(template_content, variables)

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
      end)
    end, {})
  end
end

return M
