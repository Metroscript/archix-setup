local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
    {
        'romgrk/barbar.nvim',
        dependencies = {'nvim-tree/nvim-web-devicons'}
    },
    {
        'williamboman/mason.nvim',
        run = 'MasonUpdate',
        config = function() require('vim.plugins.mason') end
    },
    {
        'vimwiki/vimwiki',
        config = function() require('vim.plugins.vimwiki') end
    },
    {
        'nvim-tree/nvim-tree.lua',
        config = function() require('vim.plugins.nvim-tree') end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSupdate',
        config = function() require('vim.plugins.treesitter') end
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {'nvim-tree/nvim-web-devicons'},
        config = function() require('vim.plugins.lualine') end
    },
    
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        dependencies = { {'nvim-lua/plenary.nvim'} },
        config = function() require('vim.plugins.telescope') end
    },
    {
	
	    "L3MON4D3/LuaSnip",
	    version = "1.*", 
	    build = "make install_jsregexp"
    }
}

local opts = {}

require("lazy").setup(plugins, opts)
