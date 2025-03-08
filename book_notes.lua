-- ~/.config/nvim/lua/my_notes/book_notes.lua

local M = {}
local vim_ui = vim.ui
local io = io
local path = require 'plenary.path'

local books_dir = vim.fn.expand '~/Documents/Obsidian/test-vault-plugin/Books/' -- Adjust as needed

function M.open_book()
  local book_dirs = get_subdirectories(books_dir)

  local book_files = {}
  for _, book_dir in ipairs(book_dirs) do
    if book_dir then
      local full_path = books_dir .. book_dir .. '/' .. book_dir .. '.md'

      local book_file = path:new(full_path)

      if book_file and book_file:exists() then
        table.insert(book_files, { path = full_path, name = book_dir })
      end
    end
  end

  local display_names = {}
  local path_map = {}
  for _, book in ipairs(book_files) do
    table.insert(display_names, book.name)
    path_map[book.name] = book.path
  end

  vim_ui.select(display_names, {
    prompt = 'Select Book:',
  }, function(ok, choice)
    if ok and choice then
      vim.cmd('edit ' .. path_map[display_names[choice]])
    end
  end)
end

function M.add_note_to_book()
  local book_dirs = get_subdirectories(books_dir)

  local book_files = {}
  for _, book_dir in ipairs(book_dirs) do
    if book_dir then
      local full_path = books_dir .. book_dir .. '/' .. book_dir .. '.md'
      local book_file = path:new(full_path)
      if book_file and book_file:exists() then
        table.insert(book_files, { path = books_dir .. book_dir, name = book_dir }) -- Store directory path
      end
    end
  end

  local display_names = {}
  local path_map = {}
  for _, book in ipairs(book_files) do
    table.insert(display_names, book.name)
    path_map[book.name] = book.path
  end

  vim_ui.select(display_names, {
    prompt = 'Select Book to add note to:',
  }, function(ok, choice)
    if ok and choice then
      local book_dir_path = path_map[display_names[choice]]
      vim_ui.input({ prompt = 'New Note Name: ' }, function(note_name)
        if note_name and note_name ~= '' then
          local book_name = display_names[choice]
          local new_note_path = path:new(book_dir_path .. '/' .. book_name .. '-' .. note_name .. '.md')
          local main_book_path = path:new(book_dir_path .. '/' .. book_name .. '.md')

          local new_note_file = io.open(new_note_path:absolute(), 'w')
          if new_note_file then
            new_note_file:close()
          else
            vim.notify('Failed to create new note: ' .. new_note_path:absolute(), vim.log.levels.ERROR)
            return
          end

          local main_book_file = io.open(main_book_path:absolute(), 'a')
          if main_book_file then
            main_book_file:write('\n[[' .. book_name .. '-' .. note_name .. ']]\n')
            main_book_file:close()
            vim.cmd('edit ' .. new_note_path:absolute())
          else
            vim.notify('Failed to update main book file: ' .. main_book_path:absolute(), vim.log.levels.ERROR)
          end
        end
      end)
    end
  end)
end

function get_subdirectories(dir_path)
  local cmd = 'find ' .. dir_path .. ' -mindepth 1 -maxdepth 1 -type d -exec basename {} \\;'
  vim.notify(cmd)
  local file, err = io.popen(cmd)
  if not file then
    vim.notify('Error executing find: ' .. (err or 'unknown'), vim.log.levels.ERROR)
    return {}
  end

  local subdirs = {}
  for line in file:lines() do
    table.insert(subdirs, line)
  end
  local ok, close_err = file:close()
  if not ok then
    vim.notify('Error closing find: ' .. (close_err or 'unknown'), vim.log.levels.ERROR)
  end
  return subdirs
end

return M
