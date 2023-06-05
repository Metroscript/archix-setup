local bind = vim.keymap.set
--Keybinds--
    --QOL--
    --Bind 'jj' to escape--
    bind({"i", "v"}, "jj", "<esc>")
    
    --Bind Undo/Redo to 'CTRL + z' & 'CTRL + y'
    bind({"n", "v"}, "<C-z>", "U")
    bind({"n", "v"}, "<C-y>", "<C-R>")

    --WIP Simple Split Tab Gen & Closing With 'CTRL + t' & 'CTRL + q'
    --bind({"n", "i"}, {"<silent>, <C-t>"}, "split<CR>")
  --  bind({"n", "i"}, {"<silent>, <C-q>"}, "close<CR>")

    --Simplify Split Tab Navigation--
    bind("n", "<C-h>", "<C-w>h")
    bind("n", "<C-j>", "<C-w>j")
    bind("n", "<C-k>", "<C-w>k")
    bind("n", "<C-l>", "<C-w>l")

    --Clipboard Copy & Paste Settings--
   -- if ("$XDG_SESSION_TYPE == X11")
    --    vim.opt.clipboard = "unnamedplus"
     --   bind("v", "<C-c>", [["+y]])
     --  bind({"n", "i", "v"}, "<C-v>", [["+P]])
      --  else
       --     bind("v", "<C-c>", [[y:call system("wl-copy", @")<cr>]])
         --   bind({"n", "v", "i"}, "<C-v>", [[:let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p {silent = true}]])
    --end
    vim.cmd[[
    if ("$XDG_SESSION_TYPE == X11")
        set clipboard=unnamedplus
        vmap <C-c> "+y
        map <C-v> "+P
        vmap <C-v> "+P
    else
        map <silent> <C-c> y:call system("wl-copy", @")<cr>
        map <silent> <C-v> :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p
        vmap <silent> <C-v> :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p
    endif
    ]]
