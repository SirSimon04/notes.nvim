local M = {}
local snacks = require 'snacks.picker'
local os_date = os.date
local os_time = os.time
local io = io
local path = require 'plenary.path'
local utils = require 'notes.utils' -- Import utils module
local vim = vim

local config = {}

function M.setup(opts)
  config = opts

  vim.api.nvim_create_user_command('NotesOpenDailies', M.open_dailies, {})
  vim.api.nvim_create_user_command('NotesOpenYesterdayNote', function()
    M.open_daily_note 'yesterday'
  end, {})
  vim.api.nvim_create_user_command('NotesOpenTodayNote', function()
    M.open_daily_note 'today'
  end, {})
  vim.api.nvim_create_user_command('NotesOpenTomorrowNote', function()
    M.open_daily_note 'tomorrow'
  end, {})
end

function M.open_dailies()
  snacks.smart {
    cwd = config.dailies_dir,
    multi = { 'files' },
    title = 'Daily notes',
    sort = function(a, b)
      return a.file > b.file
    end,
  }
end

function M.open_daily_note(day)
  local date_offset = 0
  if day == 'yesterday' then
    date_offset = -1
  elseif day == 'tomorrow' then
    date_offset = 1
  elseif day ~= 'today' then
    vim.notify('Invalid day: ' .. day, vim.log.levels.ERROR)
    return
  end

  local target_time = os_time() + (date_offset * 86400)
  local date_str = os_date('%Y-%m-%d', target_time)
  local file_name = date_str .. '.md'
  local full_path = path:new(config.dailies_dir .. file_name)

  if not full_path:exists() then
    local template_content = utils.load_template('daily', config) -- Load template
    if template_content then
      local variables = {
        date = date_str,
        current_time = vim.fn.strftime('%H:%M'),
      }
      local note_content = utils.replace_template_variables(template_content, variables) -- Replace variables

      local file, err = io.open(full_path:absolute(), 'w')
      if file then
        file:write(note_content) -- Write template content
        file:close()
      else
        vim.notify('Failed to create file: ' .. full_path:absolute() .. ' - ' .. (err or 'unknown'), vim.log.levels.ERROR)
        return
      end
    else
      vim.notify('Failed to load daily template', vim.log.levels.ERROR)
      return
    end
  end

  vim.cmd('edit ' .. full_path:absolute())
end

return M
