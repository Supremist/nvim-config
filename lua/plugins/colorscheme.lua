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
  
  -- {
    -- "folke/tokyonight.nvim",
    -- -- lazy = false,
    -- -- priority = 1000,
    -- opts = {},
  -- },
  {
    "marko-cerovac/material.nvim",
    -- lazy = false,
    -- priority = 1000,
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
  
  -- { "nightfox.nvim",
    -- dir = "D:/workspace/nightfox.nvim",
    -- lazy = false,
	-- priority = 1000,
	-- config = function() 
	  -- vim.o.background = "dark"
	  -- vim.cmd([[colorscheme carbonfox]])
	-- end
  -- },
  
  -- { "myfox",
    -- dir = "D:/workspace/myfox",
    -- lazy = false,
	-- priority = 1001,
	-- config = function() 
	  -- -- vim.o.background = "dark"
	  -- -- vim.cmd([[colorscheme tomorrow-night]])
	-- end
  -- },
  
  {"EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
	opts = function(plug, opts)
	  local C = require("nightfox.lib.color")
      local Shade = require("nightfox.lib.shade")
	  return {
	    palettes = {
	      carbonfox = {
		    bg1 = "#ff0000"
		  }
	    }
	  }
	end,
	config = function(plugin, opts)
	  require("nightfox").setup(opts)
	  vim.cmd([[colorscheme carbonfox]])
	end,
  },
  
  { "NvChad/nvim-colorizer.lua",
    lazy = false,
	opts = {
	  filetypes = { "*" },
	}
  },
  
}