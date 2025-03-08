# notes.nvim

`notes.nvim` is a Neovim plugin designed to enhance your note-taking workflow. It provides organized note management for books, daily notes, and general note-taking, enabling quick access and streamlined note creation.

## Installation

### Using lazy.nvim (Recommended)
```lua
{
  "SirSimon04/notes.nvim",
  lazy = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("notes").setup({})
  end,
}
```

### Using packer.nvim
```lua
use({
  "SirSimon04/notes.nvim",
  requires = { { "nvim-lua/plenary.nvim" } },
  opt = true,
  config = function()
    require("notes").setup({})
  end,
})
```

## Example Usage

```lua
  {
    'SirSimon04/notes.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = true,
    keys = {
      { '<leader>od', '<cmd>NotesOpenDailies<CR>', desc = 'Open Dailies' },
      { '<leader>oy', '<cmd>NotesOpenYesterdayNote<CR>', desc = 'Open Yesterday Note' },
      { '<leader>ot', '<cmd>NotesOpenTodayNote<CR>', desc = 'Open Today Note' },
      { '<leader>oz', '<cmd>NotesOpenTomorrowNote<CR>', desc = 'Open Tomorrow Note' },
      { '<leader>obo', '<cmd>NotesOpenBook<CR>', desc = 'Open Book' },
      { '<leader>oba', '<cmd>NotesAddNoteToBook<CR>', desc = 'Add Note to Book' },
      { '<leader>omo', '<cmd>NotesOpenMeetingNote<CR>', desc = 'Open Meeting Note' },
      { '<leader>omc', '<cmd>NotesCreateMeetingNote<CR>', desc = 'Create Meeting Note' },
    },
    opts = {
      books_dir = "~/Documents/Notes/Books/",
      dailies_dir = "~/Documents/Notes/DailyNotes/",
      meetings_dir = "~/Documents/Notes/Meetings/"
    },
  },
```

* `books_dir`: The directory where your book notes are stored. Defaults to `~/notes/books`.
* `dailies_dir`: The directory where your daily notes are stored. Defaults to `~/notes/dailies`.
* `meetings_dir`: The directory where your meeting notes are stored. Defaults to `~/notes/dailies`.

## Book Notes

Book notes are organized into directories, with each directory representing a book. Inside each book directory, there is a main note file named after the directory and additional note files.

* `:NotesOpenBook`: Opens a picker to select and open a book's main note file.
* `:NotesAddNoteToBook`: Opens a picker to select a book, then prompts for a new note name. Creates a new note file and adds a wiki-style link to it in the main book file.

## Daily Notes

Daily notes are stored in files named in the format `YYYY-MM-DD.md`.

* `:NotesOpenDailies`: Opens a picker to browse daily notes.
* `:NotesOpenYesterdayNote`: Opens or creates yesterday's daily note.
* `:NotesOpenTodayNote`: Opens or creates today's daily note.
* `:NotesOpenTomorrowNote`: Opens or creates tomorrow's daily note.

## Meeting Notes
Meeting notes are stored in files named in the format `YYYY-MM-DD-MeetingName.md`.

* `:NotesOpenMeetingNote`: Opens a picker to browse meeting notes.
* `:NotesCreateMeetingNote`: Prompts for a meeting name and date (YYYY-MM-DD, integer for future days, or empty for today), then creates a meeting note file.
