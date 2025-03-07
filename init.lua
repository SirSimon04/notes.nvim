local M = {}
local meeting_notes = require 'my_notes.meeting_notes'

function M.setup()
  vim.api.nvim_create_user_command('OpenMeetingNote', meeting_notes.open_meeting_note, {})
  vim.api.nvim_create_user_command('CreateMeetingNote', meeting_notes.create_meeting_note, {})

  vim.api.nvim_create_user_command('OpenDailies', require('my_notes.daily_notes').open_dailies, {})
  vim.api.nvim_create_user_command('OpenYesterdayNote', function()
    require('my_notes.daily_notes').open_daily_note 'yesterday'
  end, {})
  vim.api.nvim_create_user_command('OpenTodayNote', function()
    require('my_notes.daily_notes').open_daily_note 'today'
  end, {})
  vim.api.nvim_create_user_command('OpenTomorrowNote', function()
    require('my_notes.daily_notes').open_daily_note 'tomorrow'
  end, {})

  vim.api.nvim_create_user_command('OpenBook', require('my_notes.book_notes').open_book, {})
  vim.api.nvim_create_user_command('AddNoteToBook', require('my_notes.book_notes').add_note_to_book, {})
end

return M
