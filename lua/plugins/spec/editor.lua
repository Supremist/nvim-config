local optional = require("core.mod").optional

return {

  -- file explorer
  { "neo-tree.nvim",
    cmd = "Neotree",

    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      commands = {
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    },
    config = function(_, opts)
      local tbl = require("core.tbl")
      local opts_patch = {}
      for source, val in pairs(require("config.keymaps").neo_tree) do
        opts_patch[source] = {window = {mappings = val}}
      end
      tbl.deep_update(opts_patch, opts_patch.global)
      opts_patch.global = nil
      tbl.deep_update(opts, opts_patch)
      require("neo-tree").setup(opts)
      require("core.aucmd").add_cmd("TermClose", "*lazygit", function()
        optional("neo-tree.sources.git_status").refresh()
      end)
    end,
  },

  -- search/replace in multiple files
  -- {
    -- "nvim-pack/nvim-spectre",
    -- cmd = "Spectre",
    -- opts = { open_cmd = "noswapfile vnew" },
    -- -- stylua: ignore
    -- keys = {
      -- { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    -- },
  -- },

  -- fuzzy finder
  { "telescope.nvim",
    cmd = "Telescope",

    reloadable = true,
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = require("config.keymaps").telescope_mappings,
      },
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
        }
      }
    },
  },

  { "telescope-fzf-native.nvim",
    config = function ()
      require("core.aucmd").on_plugin_load("telescope.nvim", function()
        require("telescope").load_extension("fzf")
      end)
    end
  },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  { "which-key.nvim",
    event = "VeryLazy",
    reloadable = true,
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      local K = require("core.keymaps")
      opts.key_labels = K.key_labels()
      local maps, map_opts = K.to_which_key_spec(require("config.keymaps").which_key_groups)
      wk.setup(opts)
      wk.register(maps, map_opts)
    end,
  },

  -- git signs highlights text that has changed since the list
  -- git commit, and also lets you interactively stage & unstage
  -- hunks in a commit.
  { "gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = require("config.keymaps").attach_gitsigns
    },
  },

  -- Automatically highlights other instances of the word under your cursor.
  -- This works with LSP, Treesitter, and regexp matching to find the other
  -- instances.
  { "vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    reloadable = true,
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  { "neoscroll.nvim",
    reloadable = true,
    opts = {
      respect_scrolloff = true,
      mappings = {},
    },
    config = function(_, opts)
      require("neoscroll").setup(opts)
      local mapping = {}
      local parse = require("core.keymaps").parse
      for _, map in pairs(parse(require("config.keymaps").plugins["neoscroll.nvim"])) do
        mapping[map.lhs] = map.rhs
      end
      require("neoscroll.config").set_mappings(mapping)
    end,
  },

}
