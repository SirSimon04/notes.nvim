local M = {}

local config = {
  books_dir = '~/notes/books',
  dailies_dir = '~/notes/dailies',
  meetings_dir = '~/notes/meetings',
}

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend('force', config, opts)
  -- config.books_dir = vim.fn.expand(config.books_dir)
  -- config.dailies_dir = vim.fn.expand(config.dailies_dir)

  require('notes.book_notes').setup(config)
  require('notes.dailies').setup(config)
  require('notes.meetings').setup(config)
end

return M
