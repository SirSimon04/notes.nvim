local M = {}
local vim_ui = vim.ui
local io = io
local path = require 'plenary.path'
local utils = require 'notes.utils' -- Import utils module
local vim = vim

local config = {}

function M.setup(opts)
  config = opts
  vim.api.nvim_create_user_command('NotesOpenBook', M.open_book, {})
  vim.api.nvim_create_user_command('NotesAddNoteToBook', M.add_note_to_book, {})
  vim.api.nvim_create_user_command('NotesCreateBook', M.create_book, {})
end

function M.open_book()
  local book_dirs = get_subdirectories(config.books_dir)

  local book_files = {}
  for _, book_dir in ipairs(book_dirs) do
    if book_dir then
      local full_path = config.books_dir .. book_dir .. '/' .. book_dir .. '.md'

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
  local book_dirs = get_subdirectories(config.books_dir)

  local book_files = {}
  for _, book_dir in ipairs(book_dirs) do
    if book_dir then
      local full_path = config.books_dir .. book_dir .. '/' .. book_dir .. '.md'
      local book_file = path:new(full_path)
      if book_file and book_file:exists() then
        table.insert(book_files, { path = config.books_dir .. book_dir, name = book_dir }) -- Store directory path
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

function M.create_book()
  vim_ui.input({ prompt = 'New Book Name: ' }, function(book_name)
    if not book_name or book_name == '' then
      return -- Cancelled
    end

    local book_dir_path = path:new(config.books_dir .. book_name)
    local book_file_path = path:new(book_dir_path .. '/' .. book_name .. '.md')

    -- Create the directory using os.execute
    local cmd = 'mkdir -p "' .. book_dir_path:absolute() .. '"'
    local ok, err = os.execute(cmd)
    if ok ~= 0 then
      vim.notify('Failed to create directory: ' .. (err or 'unknown'), vim.log.levels.ERROR)
      return
    end

    -- Create the file using os.execute
    local fileCmd = 'touch "' .. book_file_path:absolute() .. '"'
    local fileOk, fileErr = os.execute(fileCmd)
    if fileOk ~= 0 then
      vim.notify('Failed to create file: ' .. (fileErr or 'unknown'), vim.log.levels.ERROR)
      return
    end

    local template_content = utils.load_template('book', config) -- Load template
    if template_content then
      local variables = {
        book_title = book_name,
        start_date = vim.fn.strftime('%Y-%m-%d'),
        finish_date = "YYYY-MM-DD",
      }
      local note_content = utils.replace_template_variables(template_content, variables) -- Replace variables

      -- Write the H1 and open the file
      local fileHandle, writeErr = io.open(book_file_path:absolute(), 'w')
      if fileHandle then
        fileHandle:write(note_content) -- Write template content
        fileHandle:close()
        vim.cmd('edit ' .. book_file_path:absolute())
      else
        vim.notify('Failed to write to file: ' .. (writeErr or 'unknown'), vim.log.levels.ERROR)
      end
    else
      vim.notify('Failed to load book template', vim.log.levels.ERROR)
    end
  end)
end

function get_subdirectories(dir_path)
  local cmd = 'find ' .. dir_path .. ' -mindepth 1 -maxdepth 1 -type d -exec basename {} \\;'
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
