local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


local plugins = {
    { --Status Bar 
        'nvim-lualine/lualine.nvim',
        dependencies = {'nvim-tree/nvim-web-devicons'},
        config = function() require('vim.plugins.lualine') end
    },
    { -- Tabs
        'romgrk/barbar.nvim',
        dependencies = {
        'nvim-tree/nvim-web-devicons',
        'lewis6991/gitsigns.nvim'
        },
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {}
    },
    { -- Syntax Highlighting
    "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function () 
            local configs = require("nvim-treesitter.configs")
        end
    },
    { -- Show Indents
        "lukas-reineke/indent-blankline.nvim", 
        main = "ibl", 
        opts = {} 
    },
    { -- Autorepairs
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true

    },
    { --Completions
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
   --         "hrsh7th/cmp-nvim-lsp"
        },
    },
    { --Snippets
	    "L3MON4D3/LuaSnip",
	    version = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
	    --build = "make install_jsregexp"
    },
    { -- LSP
        "neovim/nvim-lspconfig",
        dependencies = { 
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig"
        }
    }
}

require("lazy").setup(plugins, opts)
