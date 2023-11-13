return {
  -- snippets
  { "LuaSnip",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  { "friendly-snippets",
    optional = true,
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

   -- auto completion
  { "nvim-cmp",
    event = "InsertEnter",
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      table.insert(defaults.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = require("config.keymaps").cmp_mappings(cmp),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
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
        sorting = defaults.sorting,
      }
    end,
  },
}
