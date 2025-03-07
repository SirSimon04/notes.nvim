-- ~/.config/nvim/lua/my_notes/daily_notes.lua

local M = {}
local snacks = require 'snacks.picker'
local os_date = os.date
local os_time = os.time
local io = io
local path = require 'plenary.path'

local daily_notes_dir = vim.fn.expand '~/Documents/Obsidian/test-vault-plugin/Dailynotes/'

function M.open_dailies()
  snacks.smart {
    cwd = daily_notes_dir,
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
  local full_path = path:new(daily_notes_dir .. file_name)

  if not full_path:exists() then
    local file = io.open(full_path:absolute(), 'w')
    if file then
      file:close()
    else
      vim.notify('Failed to create file: ' .. full_path:absolute(), vim.log.levels.ERROR)
      return
    end
  end

  vim.cmd('edit ' .. full_path:absolute())
end

return M
