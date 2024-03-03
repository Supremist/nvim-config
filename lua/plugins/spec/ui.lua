local rainbow_highlights = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}

local rainbow_dim_highlights = {
  "RainbowDimRed",
  "RainbowDimYellow",
  "RainbowDimBlue",
  "RainbowDimOrange",
  "RainbowDimGreen",
  "RainbowDimViolet",
  "RainbowDimCyan",
}

return {
  { "rainbow-delimiters.nvim",
    event = "VeryLazy",
    reloadable = true,
    opts = {
      strategy = {
        [""] = "global",
        vim = "local"
      },
      query = {
        [""] = "rainbow-delimiters",
      },
      highlight = rainbow_highlights
    },
    config = function(_, opts)
      local rd = require("rainbow-delimiters")
      local strats = {}
      for key, val in pairs(opts.strategy) do
        if type(val) == "string" then
          strats[key] = rd.strategy[val]
        else
          strats[key] = val
        end
      end
      opts.strategy = strats
      require("rainbow-delimiters.setup").setup(opts)
    end
  },

  { "indent-blankline.nvim",
    event = "VeryLazy",
    reloadable = true,
    opts = {
      indent = { highlight = rainbow_dim_highlights},
      scope = { enabled = false},
    },
  },

  { "folke/noice.nvim",
    event = "VeryLazy",
    deactivate = function(plugin)
      require("noice").disable()
    end,
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      cmdline = {
        view = "cmdline",
      },
      routes = {
        -- {
        --   filter = {
        --     event = "msg_show",
        --     any = {
        --       { find = "%d+L, %d+B" },
        --       { find = "; after #%d+" },
        --       { find = "; before #%d+" },
        --     },
        --   },
        --   view = "mini",
        -- },
        {
          view = "split",
          filter = { event = "msg_show", min_height = 2 },
          opts = {replace = true, merge = true},
        },
        -- {
        --   view = "cmdline_output",
        --   filter = { event = "msg_show", find = "^REDIRECT:"},
        --
        --   opts = {merge = true},
        -- },
      },
      presets = {
        bottom_search = true,
        -- command_palette = true,
        long_message_to_split = true,
        -- inc_rename = true,
        -- cmdline_output_to_split = true,
      },
      views = {
        split = {
          enter = true,
        },
        -- cmdline_output = {
        --    format = {"{message}"},
        -- },
        mini = {
          timeout = 6000,
        },
      },
    },
  },

  { "lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- local icons = require("lazyvim.config").icons

      vim.o.laststatus = vim.g.lualine_laststatus

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          -- lualine_c = {
          --   Util.lualine.root_dir(),
          --   {
          --     "diagnostics",
          --     symbols = {
          --       error = icons.diagnostics.Error,
          --       warn = icons.diagnostics.Warn,
          --       info = icons.diagnostics.Info,
          --       hint = icons.diagnostics.Hint,
          --     },
          --   },
          --   { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          --   { Util.lualine.pretty_path() },
          -- },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              -- color = Util.ui.fg("Statement"),
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              -- color = Util.ui.fg("Constant"),
            },
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
              -- color = Util.ui.fg("Debug"),
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              -- color = Util.ui.fg("Special"),
            },
            -- {
            --   "diff",
            --   symbols = {
            --     added = icons.git.added,
            --     modified = icons.git.modified,
            --     removed = icons.git.removed,
            --   },
            --   source = function()
            --     local gitsigns = vim.b.gitsigns_status_dict
            --     if gitsigns then
            --       return {
            --         added = gitsigns.added,
            --         modified = gitsigns.changed,
            --         removed = gitsigns.removed,
            --       }
            --     end
            --   end,
            -- },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree", "lazy" },
      }
    end,
  },
}
