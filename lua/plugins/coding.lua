
local M = {
  -- snippets
  { "LuaSnip",
    reloadable = true,
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  { "friendly-snippets",
    optional = true,
    reloadable = true,
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

   -- auto completion
  { "nvim-cmp",
    event = "InsertEnter",
    reloadable = true,
    opts = {
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      formatting = {
        -- format = function(_, item)
        -- local icons = require("lazyvim.config").icons.kinds
        -- if icons[item.kind] then
        -- item.kind = icons[item.kind] .. item.kind
        -- end
        -- return item
        -- end,
      },
      experimental = {
        native_menu = false,
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "crates"},
      },
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true }) -- TODO move this
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      table.insert(defaults.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
      opts.sorting = defaults.sorting
      opts.mapping = require("config.keymaps").cmp_mappings(cmp)
      opts.sources = cmp.config.sources(opts.sources)
      cmp.setup(opts)
    end,
  },

  {
    "crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = true },
      },
    },
  },

  { "rustaceanvim",
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust.
            checkOnSave = true,
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      if vim.fn.executable("rust-analyzer") == 0 then
        vim.print(
          "ERROR: **rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/"
        )
      end
    end,
  },

  { "Comment.nvim",
    reloadable = true,
    opts = {},
    -- TODO add "JoosepAlviste/nvim-ts-context-commentstring"
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
        whk_maps = require("core.tbl").flatten2(whk_maps, function(k,v)
          if type(v) == "string" then
            return true, {table.concat(k), desc=v}
          end
        end)
        whk_maps.mode = {"x", "o"}
        require("which-key").add(whk_maps)
      end)
    end,
  },

  { "nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- treesitter integration
      disable_filetype = { "TelescopePrompt" },
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
      },
    }
  },

  { "guess-indent.nvim",
    event = "BufRead",
    opts = {
      auto_cmd = true,  -- Set to false to disable automatic execution
      override_editorconfig = false, -- Set to true to override settings set by .editorconfig
      filetype_exclude = {  -- A list of filetypes for which the auto command gets disabled
        "netrw",
        "tutor",
      },
      buftype_exclude = {  -- A list of buffer types for which the auto command gets disabled
        "help",
        "nofile",
        "terminal",
        "prompt",
      },
    }
  },
}

local cmp_patch = require("core.mod").patch("cmp", {mapping = {}})
function cmp_patch.mapping.complete_or_select(dir, opts)
  return function()
    local cmp = require("cmp")
    if cmp.visible() then
      cmp["select_"..dir.."_item"](opts)
    else
      cmp.complete()
    end
  end
end

return require("core.plugin_spec").spec(M)
