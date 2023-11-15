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
    opts = {
      completion = {
        completeopt = "menu,menuone,noinsert",
        keyword_length = 3,
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
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true }) -- TODO move this
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      table.insert(defaults.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
      opts.sorting = defaults.sorting
      cmp.mapping.complete_or_select = function(dir, opt)
        return function()
          if cmp.visible() then
            cmp["select_"..dir.."_item"](opt)
          else
            cmp.complete()
          end
        end
      end
      opts.mapping = require("config.keymaps").cmp_mappings(cmp)
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      })
      cmp.setup(opts)
    end,
  },
}
