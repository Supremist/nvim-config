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
        mappings = require("config.keymaps").telescope_mappings:reshape({"mode", "lhs"}, {1, "rhs"}),
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
      local maps = require("config.keymaps").which_key_groups:to_whichkey()
      wk.setup(opts)
      wk.register(maps)
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
      local mappings = require("config.keymaps").plugins["neoscroll.nvim"]:reshape({"lhs"}, {1, "rhs"})
      require("neoscroll.config").set_mappings(mappings)
    end,
  },

  { "Comment.nvim",
    reloadable = true,
    opts = {},
    config = function(_, opts)
      for _, keymap in ipairs(require("config.keymaps").plugins["Comment.nvim"].list) do
        local path = vim.split(keymap.rhs, ".", {plain = true})
        require("core.tbl").set(opts, path, keymap.lhs)
      end
      require("Comment").setup(opts)
    end,
  },

  { "mini.ai",
    reloadable = true,
    opts = {
      n_lines = 500,
      mappings = {},
      custom_textobjects = {},
    },
    config = function(_, opts)
      local ai = require "mini.ai"
      local keymaps = require "config.keymaps"
      local resolve = {}
      local ts = {}
      local whk_maps = {}

      function resolve.treesitter(dir, lhs, args)
        ts[lhs] = ts[lhs] or {{}}
        ts[lhs][1][dir] = args[1]
        ts[lhs][2] = args[2]
      end
      function resolve.mappings(dir, lhs, args, map)
        opts.mappings[args[1]] = map.lhs
      end
      function resolve.table(dir, lhs, args)
        opts.custom_textobjects[lhs] = args
      end
      for _, map in ipairs(require("config.keymaps").plugins["mini.ai"].list) do
        local dir = map.lhs:sub(1, 1)
        local lhs = map.lhs:sub(2, -1)
        local args = vim.deepcopy(map.rhs)
        local method = table.remove(args, 1)
        resolve[method](dir, lhs, args, map)
        if method ~= "mappings" then
          whk_maps[dir] = whk_maps[dir] or {}
          whk_maps[dir][lhs] = map.desc
        end
      end
      for key, args in pairs(ts) do
        opts.custom_textobjects[key] = ai.gen_spec.treesitter(args[1], args[2])
      end

      ai.setup(opts)
      for _, dir in ipairs({"around", "inside"}) do
        local key = opts.mappings[dir]
        local proto = vim.tbl_extend("force", keymaps.get_builtin_textobjects(dir), whk_maps[key])
        whk_maps[key] = vim.deepcopy(proto)
        for _, pos in ipairs({"_next", "_last"}) do
          whk_maps[key][opts.mappings[dir..pos]:sub(2,-1)] = vim.deepcopy(proto)
        end
      end
      -- register all text objects with which-key
      require("core.aucmd").on_plugin_load("which-key.nvim", function()
        whk_maps.mode = {"x", "o"}
        vim.print(whk_maps)
        require("which-key").register(whk_maps)
      end)
    end,
  },
}
