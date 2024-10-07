local set = vim.opt
--General Settings--
set.number = true -- shows line numbers
set.mouse = "a" -- Allows mouse use
set.wrap = true -- wraps lines
set.showmatch = true -- Shows matching brackets
set.showcmd = true -- Shows partial commands in status line
set.autowrite = true --Saves before commands like :make & :next
set.hidden = false --Shows abandoned buffers
set.backspace = "indent,eol,start" --Makes backspace work properly
set.autoindent = true -- Automatically formats indenting if applicable
set.filetype = "on" --Enable syntax support for programming lanuages
set.syntax = "on" -- Enables syntax highlighting if applicable
set.ruler = true --Always show current position
set.cursorline = true --Underlines current line
set.cursorcolumn = true --Highlights current column
set.background = "dark" --"Light" makes text darker and vice versa
vim.cmd"colorscheme gruvbox" --Enables Gruvbox theming
vim.cmd"hi Normal ctermfg=white" 

--Search settings--
set.incsearch = true --Search as you type
set.smartcase = true --Prioritise matching cases when searching
set.ignorecase = true --Search regardless of casing
set.hlsearch = true --Highlight search results

--Advanced Settings--
    --Set Tab Size to 4 Spaces--
    set.tabstop = 4
    set.softtabstop = 4
    set.shiftwidth = 4
    set.expandtab = true

    --Enables UNIX Fileformat & Language Encoding--
    set.fileformat = "unix"
    set.encoding = "utf-8"

    --Enables Autocomplete (CTRL + N To Activate)--
    set.wildmode = "longest,list,full"

    --Forces Split Pages To The Right--
    set.splitright = true
    
    --Disables Auto Commenting On New Line--
    vim.cmd"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o"
    
    --Resets Cursor to Underline on Exit--
    vim.cmd"autocmd VimLeave * set guicursor=a:hor100"
