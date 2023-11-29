-- This file contains instalation data for all plugins. Used by lazy.nvim
-- Each plugin entry may contain fields, required for locating correct plugin version.
-- Such as: dir, url, name, dev, main, branch, tag, commit, version, pin, submodules
-- Entries may also contain fields, required for loading.
-- Such as: lazy, priority, enabled, cond, module, build, dependencies

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

  -- fuzzy finder
  { "nvim-telescope/telescope.nvim",
    commit = vim.fn.has("nvim-0.9.0") == 0 and "057ee0f8783" or nil,
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
  },
  { "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
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

  { "karb94/neoscroll.nvim" },

  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    -- dependencies = {
      -- {
        -- "nvim-treesitter/nvim-treesitter-textobjects",
        -- init = function()
          -- -- disable rtp plugin, as we only need its queries for mini.ai
          -- -- In case other textobject modules are enabled, we will load them
          -- -- once nvim-treesitter is loaded
          -- require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        -- end,
      -- },
    -- },
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl" },
  { "HiPhish/rainbow-delimiters.nvim" },
}
