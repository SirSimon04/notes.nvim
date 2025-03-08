local M = {}
local snacks = require 'snacks.picker'
local vim_ui = vim.ui
local os_time = os.time
local os_date = os.date
local io = io
local path = require 'plenary.path'

local config = {}

function M.setup(opts)
  config = opts

  vim.api.nvim_create_user_command('OpenMeetingNote', M.open_meeting_note, {})
  vim.api.nvim_create_user_command('CreateMeetingNote', M.create_meeting_note, {})
end

function M.open_meeting_note()
  vim.notify 'Opening meeting notes'
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

      -- Create the file
      local file = io.open(full_path:absolute(), 'w')
      if file then
        file:close()
        vim.cmd('edit ' .. full_path:absolute())
      else
        vim.notify('Failed to create file: ' .. full_path:absolute(), vim.log.levels.ERROR)
      end
    end)
  end)
end

return M
