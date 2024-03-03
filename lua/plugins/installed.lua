-- This file contains instalation data for all plugins. Used by lazy.nvim
-- Each plugin entry may contain fields, required for locating correct plugin version.
-- Such as: dir, url, name, dev, main, branch, tag, commit, version, pin, submodules
-- Entries may also contain fields, required for loading.
-- Such as: lazy, priority, enabled, cond, module, build, dependencies

-- local plugins need to be explicitly configured with dir
-- { dir = "~/projects/secret.nvim" },

-- you can use a custom url to fetch a plugin
-- { url = "git@github.com:folke/noice.nvim.git" },

-- local plugins can also be configure with the dev option.
-- This will use {config.dev.path}/noice.nvim/ instead of fetching it from Github
-- With the dev option, you can easily switch between the local and installed version of a plugin
-- { "folke/noice.nvim", dev = true },


require("core.main").on_lazy_spec_load()

return {
  -- snippets
  { "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },

  -- auto completion
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- code commenting
  { "numToStr/Comment.nvim" },

  -- lspconfig
  { "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- only if "hrsh7th/nvim-cmp"
    },
  },
  { "p00f/clangd_extensions.nvim" },

  -- file explorer
  { "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- optional
      "MunifTanjim/nui.nvim",
    },
  },

  -- prettier cmdline, better :messages, replcae :h more-prompt
  { "folke/noice.nvim", dev = true,
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- "rcarriga/nvim-notify",
    },
  },

  { "nvim-lualine/lualine.nvim",
   dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- fuzzy finder
  { "nvim-telescope/telescope.nvim",
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      { "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
  },
  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific
  -- location.
  { "folke/flash.nvim" },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  { "folke/which-key.nvim" },

  -- git signs highlights text that has changed since the list
  -- git commit, and also lets you interactively stage & unstage
  -- hunks in a commit.
  { "lewis6991/gitsigns.nvim" },

  -- Automatically highlights other instances of the word under your cursor.
  -- This works with LSP, Treesitter, and regexp matching to find the other
  -- instances.
  { "RRethy/vim-illuminate" },

  -- buffer remove
  { "echasnovski/mini.bufremove" },
  { "echasnovski/mini.ai" },

  { "karb94/neoscroll.nvim" },

  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" },
    },
  },

  -- indent
  { "NMAC427/guess-indent.nvim" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl" },
  { "HiPhish/rainbow-delimiters.nvim" },
  { "windwp/nvim-autopairs" },

  {
    "iamcco/markdown-preview.nvim",
    -- build = "cd app && yarn install",
    build = function() vim.fn["mkdp#util#install"]() end,
  },
}
