local C = require("nightfox.lib.color")
local Shade = require("nightfox.lib.shade")


local M = {}

local bg = C("#1d1f21")
local fg = C("#b4c3d4") -- Original #a9b7c6

-- stylua: ignore
local pal = {
  black   = Shade.new("#282828", 0.15, -0.15),
  red     = {bright = "#cc8c8c", base = "#cc6666", dim = "#8c4646"},
  green   = {bright = "#afbf7e", base = "#a5c261", dim = "#6a8759"},
  yellow  = {bright = "#ffff00", base = "#ffc66d", dim = "#bc9458"},
  blue    = {bright = "#a6a8ff", base = "#6897bb", dim = "#8888c6"},
  magenta = {bright = "#bf91bb", base = "#9876aa", dim = "#9f3895"},
  cyan    = {bright = "#6fafbd", base = "#20999d", dim = "#688b8a"},
  white   = Shade.new("#dfdfe0", 0.15, -0.15),
  orange  = {bright = "#dd985e", base = "#cb7832", dim = "#a85b1d"},
  pink    = {bright = "#ffc6a6", base = "#a3685a", dim = "#a3685a"},

  comment = bg:blend(fg, 0.4):to_css(),

  bg0     = bg:brighten(-4):to_css(), -- Dark bg (status line and float)
  bg1     = bg:to_css(), -- Default bg
  bg2     = bg:brighten(6):to_css(), -- Lighter bg (colorcolm folds)
  bg3     = bg:brighten(12):to_css(), -- Lighter bg (cursor line)
  bg4     = bg:brighten(24):to_css(), -- Conceal, border fg

  fg0     = fg:brighten(6):to_css(), -- Lighter fg
  fg1     = fg:to_css(), -- Default fg
  fg2     = fg:brighten(-24):to_css(), -- Darker fg (status line)
  fg3     = fg:brighten(-48):to_css(), -- Darker fg (line numbers, fold colums)

  sel0    = "#2a2a2a", -- Popup bg, visual selection bg
  sel1    = "#525253", -- Popup sel bg, search bg
}

-- palette.sel0 = bg:blend(C(palette.white.base), 0.1):to_css()
-- palette.sel1 = bg:blend(C(palette.white.base), 0.3):to_css()

local spec = {
  bg0  = pal.bg0,  -- Dark bg (status line and float)
  bg1  = pal.bg1,  -- Default bg
  bg2  = pal.bg2,  -- Lighter bg (colorcolm folds)
  bg3  = pal.bg3,  -- Lighter bg (cursor line)
  bg4  = pal.bg4,  -- Conceal, border fg

  fg0  = pal.fg0,  -- Lighter fg
  fg1  = pal.fg1,  -- Default fg
  fg2  = pal.fg2,  -- Darker fg (status line)
  fg3  = pal.fg3,  -- Darker fg (line numbers, fold colums)

  sel0 = pal.sel0, -- Popup bg, visual selection bg
  sel1 = pal.sel1, -- Popup sel bg, search bg
}

spec.syntax = {
  bracket     = spec.fg2,           -- Brackets and Punctuation
  builtin0    = pal.orange.dim,       -- Builtin variable
  builtin1    = pal.blue.dim,    -- Builtin type
  builtin2    = pal.orange.bright,  -- Builtin const
  builtin3    = pal.pink.bright,     -- Builtin func
  namespace   = pal.magenta.bright,
  delimiter   = pal.pink.base,
  comment     = pal.comment,        -- Comment
  conditional = pal.orange.base, -- Conditional and loop
  const       = pal.red.base,  -- Constants, imports and booleans
  dep         = spec.fg3,           -- Deprecated
  field       = pal.yellow.dim,      -- Field
  func        = pal.yellow.base,    -- Functions and Titles
  ident       = pal.red.bright,      -- Identifiers. Unused now, @deprecated
  keyword     = pal.orange.base,   -- Keywords
  number      = pal.blue.base,    -- Numbers
  operator    = pal.cyan.dim,           -- Operators
  preproc     = pal.blue.bright,    -- PreProc
  regex       = pal.yellow.bright,  -- Regex
  statement   = pal.pink.base,   -- Statements
  string      = pal.green.base,     -- Strings
  type        = pal.magenta.base,    -- Types
  variable    = spec.fg1,     -- Variables
  parameter   = pal.white.base,

  typeParam   = pal.cyan.base,
  literal     = pal.green.dim, -- Used for doc string also
}

spec.diag = {
  error = pal.red.base,
  warn  = pal.yellow.base,
  info  = pal.blue.base,
  hint  = pal.orange.base,
}

spec.diag_bg = {
  error = C(spec.bg1):blend(C(spec.diag.error), 0.15):to_css(),
  warn  = C(spec.bg1):blend(C(spec.diag.warn), 0.15):to_css(),
  info  = C(spec.bg1):blend(C(spec.diag.info), 0.15):to_css(),
  hint  = C(spec.bg1):blend(C(spec.diag.hint), 0.15):to_css(),
}

spec.diff = {
  add    = C(spec.bg1):blend(C(pal.green.dim), 0.15):to_css(),
  delete = C(spec.bg1):blend(C(pal.red.dim), 0.15):to_css(),
  change = C(spec.bg1):blend(C(pal.blue.dim), 0.15):to_css(),
  text   = C(spec.bg1):blend(C(pal.cyan.dim), 0.3):to_css(),
}

spec.git = {
  add      = pal.green.base,
  removed  = pal.red.base,
  changed  = pal.yellow.base,
  conflict = pal.orange.base,
  ignored  = pal.comment,
}

local syn = spec.syntax

local group = {
  ["@namespace"] = {fg = syn.namespace },
  ["@tag.delimiter"] = {fg = syn.delimiter},
  ["@punctuation.special"] = {fg = syn.delimiter},
  ["@function.builtin"] = {fg = syn.builtin3},
  Boolean = {fg = syn.builtin2 },
  ["@function.macro"] = {link = "Macro"},
  ["@keyword.return"] = {link = "Keyword"},
  ["@keyword.operator"] = {link = "Keyword"},
  ["@type.qualifier"] = {link = "Keyword"},
  StorageClass = {link = "Keyword"},
  ["@exception"] = {link = "Exception"},
  ["@text.literal"] = {fg = syn.literal},
  ["@constructor"] = {fg = syn.type},
  ["@parameter"] = {fg = syn.parameter},
  ["@comment.documentation"] = {fg = syn.literal},
  diffLine = {fg = syn.info}, -- ???

  ["@lsp.mod.virtual"] = {style = "italic"},
  ["@lsp.mod.declaration"] = {style = "bold"},
  ["@lsp.mod.usedAsMutableReference"] = {style = "italic"},
  ["@lsp.type.typeParameter"] = {fg = syn.typeParam},
  ["@lsp.type.enummember"] = {fg = syn.namespace, style = "italic"},
  ["@lsp.typemod.operator.userDefined"] = {fg = pal.cyan.bright},
}

  -- stylua: ignore stop

function M.get_options(theme_name)
  return {
    palettes = {[theme_name] = pal},
    specs = {[theme_name] = spec},
	groups = {[theme_name] = group}
  }
end

function M.current_file_path()
  return debug.getinfo(1, "S").source:sub(2, -1)
end

function M.reload(name)
  name = name or "nightfox.nvim"
  local plugin = require("lazy.core.config").plugins[name]
  require("lazy").reload({plugins = {plugin}})
end

function M.interactive()
  local api = vim.api
  local augroup = api.nvim_create_augroup("NightfoxInteractiveAugroup", {clear = true})
  api.nvim_create_autocmd("BufWritePost", {group = augroup, buffer = api.nvim_get_current_buf(),
    callback = function(id, event, group, match, buf, file, data)
      M.reload()
      vim.cmd([[doautoall ColorScheme]])
      -- return true -- to delete autocmd
    end
  })
end

return M
