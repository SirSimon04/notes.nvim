local M = {}
local snacks = require 'snacks.picker'
local vim_ui = vim.ui
local os_time = os.time
local os_date = os.date
local io = io
local path = require 'plenary.path'
local utils = require 'notes.utils' -- Import utils module
local vim = vim

local config = {}

function M.setup(opts)
  config = opts

  vim.api.nvim_create_user_command('NotesOpenMeetingNote', M.open_meeting_note, {})
  vim.api.nvim_create_user_command('NotesCreateMeetingNote', M.create_meeting_note, {})
end

function M.open_meeting_note()
  snacks.smart {
    cwd = config.meetings_dir,
    multi = { 'files' },
    title = 'Meeting notes',
    sort = function(a, b)
      return a.file > b.file
    end,
  }
end

function M.create_meeting_note()
  vim_ui.input({ prompt = 'Meeting Name: ' }, function(meeting_name)
    if not meeting_name or meeting_name == '' then
      return -- Cancelled
    end
    vim_ui.input({ prompt = 'Date (YYYY-MM-DD, integer, or empty for today): ' }, function(date_input)
      local date_str
      if not date_input or date_input == '' then
        date_str = os_date '%Y-%m-%d' -- Today's date
      else
        local num_days = tonumber(date_input)
        if num_days then
          local future_time = os_time() + (num_days * 86400) -- 86400 seconds in a day
          date_str = os_date('%Y-%m-%d', future_time)
        else
          if date_input:match '^%d%d%d%d%-%d%d%-%d%d$' then
            date_str = date_input
          else
            vim.notify('Invalid date format', vim.log.levels.ERROR)
            return
          end
        end
      end

      local file_name = date_str .. '-' .. meeting_name .. '.md'
      local full_path = path:new(config.meetings_dir .. file_name)

      local template_content = utils.load_template('meeting.tpl') -- Load template
      if template_content then
        local variables = {
          meeting_name = meeting_name,
          date = date_str,
        }
        local note_content = utils.replace_template_variables(template_content, variables) -- Replace variables

        local file, err = io.open(full_path:absolute(), 'w')
        if file then
          file:write(note_content) -- Write template content
          file:close()
          vim.cmd('edit ' .. full_path:absolute())
        else
          vim.notify('Failed to create file: ' .. full_path:absolute() .. ' - ' .. (err or 'unknown'), vim.log.levels.ERROR)
        end
      else
        vim.notify('Failed to load meeting template', vim.log.levels.ERROR)
      end
    end)
  end)
end

return M
