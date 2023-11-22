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
    opts = {
      indent = { highlight = rainbow_dim_highlights},
      scope = { enabled = false},
    },
  },
}
