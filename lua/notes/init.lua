local M = {}

local dailies = require("notes.book_notes")
local meetings = require("notes.daily_notes")
local book_notes = require("notes.meeting_notes")
local vim = vim

local default_opts = {
  dailies_dir = "~/Documents/Obsidian/test-vault-plugin/Dailynotes/",
  books_dir = "~/Documents/Obsidian/test-vault-plugin/Books/",
  meetings_dir = "~/Documents/Obsidian/test-vault-plugin/Meetingnotes/",
  templates = {
    daily = "",
    meeting = "",
    book = "",
  },
}

local config = {}

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", default_opts, opts)
  config.dailies_dir = vim.fn.expand(config.dailies_dir)
  config.books_dir = vim.fn.expand(config.books_dir)
  config.meetings_dir = vim.fn.expand(config.meetings_dir)

  dailies.setup(config)
  meetings.setup(config)
  book_notes.setup(config)
end

return M
