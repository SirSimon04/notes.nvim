local M = {}
local dailies = require("notes.daily_notes")
local book_notes = require("notes.book_notes")
local custom_types = require("notes.custom_types")
local vim = vim
local os = os

local default_opts = {
  dailies_dir = "~/notes/daily/",
  books_dir = "~/notes/books/",
  templates = {
    daily = "",
    book = "",
  },
  environments = {}, -- Default empty environments
  custom_types = {},
}

local config = {}

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", default_opts, opts)

  -- Check for environment overrides
  if config.environments and #config.environments > 0 then
    for _, env in ipairs(config.environments) do
      if os.getenv(env.key) then
        config = vim.tbl_deep_extend("force", config, env)
        break -- Apply the first matching environment
      end
    end
  end

  config.dailies_dir = vim.fn.expand(config.dailies_dir)
  config.books_dir = vim.fn.expand(config.books_dir)
  config.templates.daily = vim.fn.expand(config.templates.daily)
  config.templates.book = vim.fn.expand(config.templates.book)

  dailies.setup(config)
  book_notes.setup(config)

  custom_types.setup(config) -- Add this line
end

return M
