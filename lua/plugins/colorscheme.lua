return {
  { 
    "ellisonleao/gruvbox.nvim",
	-- lazy = false,
	-- priority = 1000,
	config = function() 
	  vim.o.background = "dark" -- or "light" for light mode
	  vim.cmd([[colorscheme gruvbox]])
	end
  },
  
  {
    "folke/tokyonight.nvim",
    --lazy = false,
    --priority = 1000,
    opts = {},
  },
  {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
	opts = {
	  plugins = { -- Uncomment the plugins that you use to highlight them
        -- Available plugins:
        -- "dap",
        -- "dashboard",
         "gitsigns",
        -- "hop",
        -- "indent-blankline",
        -- "lspsaga",
        -- "mini",
        -- "neogit",
        -- "neorg",
        "nvim-cmp",
        -- "nvim-navic",
        -- "nvim-tree",
         "nvim-web-devicons",
        -- "sneak",
         "telescope",
        -- "trouble",
         "which-key",
      },
	},
    config = function() 
	  vim.o.background = "dark"
	  vim.g.material_style = "darker"
	  vim.cmd([[colorscheme material]])
	end
  },
}