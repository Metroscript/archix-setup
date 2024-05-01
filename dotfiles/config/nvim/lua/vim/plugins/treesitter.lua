require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { 
        "bash",
        "lua"
    },
    ignore_install = {""}, -- Parsers to Never Install
    sync_install = true, -- Install "Ensure_Installed" Parsers in Sync
    auto_install = true, -- Installs Missing Parsers Upon Entering Buffer

    highlight = {
        enable = true, -- Disabling Turns off Syntax Highliting
        disable = {""} -- Specific Languages to Disable
    },

    indent = {
        enable = true -- Enable Auto-Indentation
    }
}
