local M = {}
local meeting_notes = require 'my_notes.meeting_notes'
local daily_notes = require 'my_notes.daily_notes'
local book_notes = require 'my_notes.book_notes'

function M.setup()
  vim.api.nvim_create_user_command('OpenMeetingNote', meeting_notes.open_meeting_note, {})
  vim.api.nvim_create_user_command('CreateMeetingNote', meeting_notes.create_meeting_note, {})

  vim.api.nvim_create_user_command('OpenDailies', daily_notes.open_dailies, {})
  vim.api.nvim_create_user_command('OpenYesterdayNote', function()
    daily_notes.open_daily_note 'yesterday'
  end, {})
  vim.api.nvim_create_user_command('OpenTodayNote', function()
    daily_notes.open_daily_note 'today'
  end, {})
  vim.api.nvim_create_user_command('OpenTomorrowNote', function()
    daily_notes.open_daily_note 'tomorrow'
  end, {})

  vim.api.nvim_create_user_command('OpenBook', book_notes.open_book, {})
  vim.api.nvim_create_user_command('AddNoteToBook', book_notes.add_note_to_book, {})

  vim.keymap.set('n', '<leader>om', meeting_notes.open_meeting_note, { desc = 'Open Meeting Note' })
  vim.keymap.set('n', '<leader>oc', meeting_notes.create_meeting_note, { desc = 'Create Meeting Note' })
  vim.keymap.set('n', '<leader>od', daily_notes.open_dailies, { desc = 'Open Dailies' })
  vim.keymap.set('n', '<leader>oy', function()
    daily_notes.open_daily_note 'yesterday'
  end, { desc = 'Open Yesterday Note' })
  vim.keymap.set('n', '<leader>ot', function()
    daily_notes.open_daily_note 'today'
  end, { desc = 'Open Today Note' })
  vim.keymap.set('n', '<leader>on', function()
    daily_notes.open_daily_note 'tomorrow'
  end, { desc = 'Open Tomorrow Note' })

  vim.keymap.set('n', '<leader>obo', book_notes.open_book, { desc = 'Open Book' })
  vim.keymap.set('n', '<leader>oba', book_notes.add_note_to_book, { desc = 'Add Note to Book' })

  --   vim.keymap.set('n', '<leader>ob', book_notes.open_book, { desc = 'Open Book' })
  --   vim.keymap.set('n', '<leader>oa', book_notes.add_note_to_book, { desc = 'Add Note to Book' })
  --
  -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
  -- vim.keymap.set('n', '<leader>ot',  { desc = 'Go to previous [D]iagnostic message' })
  --         { '<leader>od', '<cmd>ObsidianDailies<cr>', desc = 'Open dailies picker' },
  --
  --       { '<leader>ot', '<cmd>ObsidianToday<cr>', desc = "Open/create today's note" },
  --       { '<leader>om', '<cmd>ObsidianTomorrow<cr>', desc = "Open/create tomorrow's note" },
  --       { '<leader>oy', '<cmd>ObsidianYesterday<cr>', desc = "Open/create yesterday's note" },
end

return M
