# notes.nvim

- [Installation](#installation)
  * [Using lazy.nvim (Recommended)](#using-lazynvim-recommended)
  * [Using packer.nvim](#using-packernvim)
- [Example Usage](#example-usage)
- [Type of notes](#type-of-notes)
  * [Book Notes](#book-notes)
  * [Daily Notes](#daily-notes)
  * [Custom Types](#custom-types)
- [Other features](#other-features)
  * [Templating](#templating)
    * [Template Variables](#template-variables)
  * [Environment-Specific Configurations](#environment-specific-configurations)

`notes.nvim` is a Neovim plugin designed to enhance your note-taking workflow. It provides organized note management for books, daily notes, and custom note types, enabling quick access and streamlined note creation.

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
    },
    opts = {
      books_dir = "~/Documents/Notes/Books/",
      dailies_dir = "~/Documents/Notes/DailyNotes/",
      templates = {
        daily = "~/Documents/Notes/Templates/daily.md",
        book = "~/Documents/Notes/Templates/book.md",
      },
      custom_types = {
        {
          name = "Meeting",
          dir = "~/Documents/Notes/Meetings/",
          template = "~/Documents/Notes/Templates/meeting.md",
          filename = "${date}-Meeting-${title}",
        },
      },
      environments = {
        {
          key = 'PRIVATE',
          dailies_dir = '~/private/Dailynotes/',
          templates = {
            daily = '~/private/templates/daily.md',
          },
        },
      },
    },
  },
```

* `books_dir`: The directory where your book notes are stored. Defaults to `~/notes/books`.
* `dailies_dir`: The directory where your daily notes are stored. Defaults to `~/notes/dailies`.
* `custom_types`: A table of custom note types.
* `environments`: See [Environment-Specific Configurations](#environment-specific-configurations)


## Type of notes

### Book Notes

Book notes are organized into directories, with each directory representing a book. Inside each book directory, there is a main note file named after the directory and additional note files.

* `:NotesOpenBook`: Opens a picker to select and open a book's main note file.
* `:NotesAddNoteToBook`: Opens a picker to select a book, then prompts for a new note name. Creates a new note file and adds a wiki-style link to it in the main book file.

### Daily Notes

Daily notes are stored in files named in the format `YYYY-MM-DD.md`.

* `:NotesOpenDailies`: Opens a picker to browse daily notes.
* `:NotesOpenYesterdayNote`: Opens or creates yesterday's daily note.
* `:NotesOpenTodayNote`: Opens or creates today's daily note.
* `:NotesOpenTomorrowNote`: Opens or creates tomorrow's daily note.

### Custom Types

Custom note types can be defined in the `custom_types` table in the configuration. Each custom type can have its own directory, template, and filename pattern.

* `:NotesOpen<TypeName>`: Opens a picker to browse notes of the specified type. Replace `<TypeName>` with the name of your custom type (e.g., `:NotesOpenMeeting`).
* `:NotesCreate<TypeName>`: Prompts for a title and optional date, then creates a note of the specified type. Replace `<TypeName>` with the name of your custom type (e.g., `:NotesCreateMeeting`).

**Filename Variables:**

* `${title}`: The title of the note.
* `${date}`: The date of the note (YYYY-MM-DD). If `${date}` is used in the `filename` pattern, the user will be prompted for a date.

**Template Variables:**

The following template variables are available for use in your custom templates:

* **Daily Notes:**
    * `{{date}}`: The current date inтрибут-MM-DD format.
    * `{{current_time}}`: The current time in HH:MM format.
* **Book Notes:**
    * `{{book_title}}`: The title of the book.
    * `{{start_date}}`: The start date inтрибут-MM-DD format.
* **Custom Types:**
    * `{{<lowercase_type_name>_title}}`: The title of the note. Replace `<lowercase_type_name>` with the lowercase name of your custom type (e.g., `{{meeting_title}}`).
    * `{{date}}`: The date of the note inтрибут-MM-DD format.

## Other features

### Templating

`notes.nvim` supports templating for note creation, allowing for consistent formatting. By default, the plugin provides internal templates. Users can customize these by specifying their own template file paths in the `opts.templates` configuration. If a user-defined template is not found, the plugin will gracefully fall back to the default internal template, notifying the user of the fallback. This ensures that note creation remains functional even if custom templates are missing.

### Environment-Specific Configurations

To facilitate note management across different environments (e.g., work and private devices), `notes.nvim` enables environment-specific configurations. Users can define multiple environment configurations within the `opts.environments` table. Each environment is associated with an environment variable key. When Neovim starts, the plugin checks for the presence of these environment variables. If a match is found, the plugin merges the environment-specific settings with the main configuration, effectively overwriting any conflicting settings. For example, you can have a `PRIVATE` environment with its own directories and templates and a `WORK` environment with different settings. If the `PRIVATE` environment variable is set, the plugin will use the private settings. The first matching environment will always be selected.

```lua
opts = {
  books_dir = '~/work/Books/',
  dailies_dir = '~/work/Dailynotes/',
  templates = {
    daily = '~/work/templates/daily.md',
    book = '~/work/templates/book.md',
  },
  environments = {
    {
      key = 'PRIVATE',
      dailies_dir = '~/private/Dailynotes/',
      templates = {
        daily = '~/private/templates/daily.md',
      },
    },
  },
},
```
