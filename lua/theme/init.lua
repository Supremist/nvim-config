local M = {}
local H = {}

function H.has_integration(s)
  return true
end

local tomorrow_night_palette = {
    base00 = '#1d1f21',
	base01 = '#282a2e',
	base02 = '#373b41',
	base03 = '#969896',
    base04 = '#b4b7b4',
	base05 = '#c5c8c6',
	base06 = '#e0e0e0',
	base07 = '#ffffff',
    base08 = '#cc6666',
	base09 = '#de935f',
	base0A = '#f0c674',
	base0B = '#b5bd68',
    base0C = '#8abeb7',
	base0D = '#81a2be',
	base0E = '#b294bb',
	base0F = '#a3685a',
}

function M.spec_from_base16(p)
  return {
    bg = {
	  calm = p.base01, -- used for status bars, line numbers and folding marks
	  default = p.base00,
	  accent = p.base07, -- not often used
	  selection = p.base02,
	},
	comment = p.base03,

	fg = {
	  calm = p.base04, -- used for status bars
	  default = p.base05,
	  accent = p.base06, -- not often used
	},

	variable = p.base08, -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
	constant = p.base09, -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
	class = p.base0A,    -- Classes, Markup Bold, Search Text Background
	string = p.base0B,   -- Strings, Inherited Class, Markup Code, Diff Inserted
	support = p.base0C,  -- Support, Regular Expressions, Escape Characters, Markup Quotes
	func =  p.base0D,    -- Functions, Methods, Attribute IDs, Headings
	keyword = p.base0E,  -- Keywords, Storage, Selector, Markup Italic, Diff Changed
	delimiter = p.base0F, -- Deprecated, Opening/Closing Embedded Language Tags
	
	red = p.base08,
	orange = p.base09,
	yellow = p.base0A,
	green = p.base0B,
	cyan = p.base0C,
	blue = p.base0D,
	purple = p.base0E,
	brown = p.base0F,
	
  }
end
  
function M.setup(opts)
  local hi = function (name, opts) 
    vim.api.nvim_set_hl(0, name, opts)
  end
  local p = M.spec_from_base16(tomorrow_night_palette)

 hi('ColorColumn',    {      bg=p.bg.calm,          })
  hi('Conceal',        {fg=p.func,                })
  hi('CurSearch',      {fg=p.bg.calm, bg=p.constant,          })
  hi('Cursor',         {fg=p.bg.default, bg=p.fg.default,          })
  hi('CursorColumn',   {      bg=p.bg.calm,          })
  hi('CursorIM',       {fg=p.bg.default, bg=p.fg.default,          })
  hi('CursorLine',     {      bg=p.bg.calm,          })
  hi('CursorLineFold', {fg=p.support, bg=p.bg.calm,          })
  hi('CursorLineNr',   {fg=p.fg.calm, bg=p.bg.calm,          })
  hi('CursorLineSign', {fg=p.comment, bg=p.bg.calm,          })
  hi('DiffAdd',        {fg=p.string, bg=p.bg.calm,          })
  -- Differs from base16-vim, but according to general style guide
  hi('DiffChange',     {fg=p.keyword, bg=p.bg.calm,          })
  hi('DiffDelete',     {fg=p.variable, bg=p.bg.calm,          })
  hi('DiffText',       {fg=p.func, bg=p.bg.calm,          })
  hi('Directory',      {fg=p.func,                })
  hi('EndOfBuffer',    {fg=p.comment,                })
  hi('ErrorMsg',       {fg=p.variable, bg=p.bg.default,          })
  hi('FoldColumn',     {fg=p.support, bg=p.bg.calm,          })
  hi('Folded',         {fg=p.comment, bg=p.bg.calm,          })
  hi('IncSearch',      {fg=p.bg.calm, bg=p.constant,          })
  hi('lCursor',        {fg=p.bg.default, bg=p.fg.default,          })
  hi('LineNr',         {fg=p.comment, bg=p.bg.calm,          })
  hi('LineNrAbove',    {fg=p.comment, bg=p.bg.calm,          })
  hi('LineNrBelow',    {fg=p.comment, bg=p.bg.calm,          })
  -- Slight difference from base16, where `bg=base03` is used. This makes
  -- it possible to comfortably see this highlighting in comments.
  hi('MatchParen',     {      bg=p.bg.selection,          })
  hi('ModeMsg',        {fg=p.string,                })
  hi('MoreMsg',        {fg=p.string,                })
  hi('MsgArea',        {fg=p.fg.default, bg=p.bg.default,          })
  hi('MsgSeparator',   {fg=p.fg.calm, bg=p.bg.selection,          })
  hi('NonText',        {fg=p.comment,                })
  hi('Normal',         {fg=p.fg.default, bg=p.bg.default,          })
  hi('NormalFloat',    {fg=p.fg.default, bg=p.bg.calm,          })
  hi('NormalNC',       {fg=p.fg.default, bg=p.bg.default,          })
  hi('PMenu',          {fg=p.fg.default, bg=p.bg.calm,          })
  hi('PMenuSbar',      {      bg=p.bg.selection,          })
  hi('PMenuSel',       {fg=p.bg.calm, bg=p.fg.default,          })
  hi('PMenuThumb',     {      bg=p.bg.accent,          })
  hi('Question',       {fg=p.func,                })
  hi('QuickFixLine',   {      bg=p.bg.calm,          })
  hi('Search',         {fg=p.bg.calm, bg=p.class,          })
  hi('SignColumn',     {fg=p.comment, bg=p.bg.calm,          })
  hi('SpecialKey',     {fg=p.comment,                })
  hi('SpellBad',       {            undercurl=true, sp=p.variable})
  hi('SpellCap',       {            undercurl=true, sp=p.func})
  hi('SpellLocal',     {            undercurl=true, sp=p.support})
  hi('SpellRare',      {            undercurl=true, sp=p.keyword})
  hi('StatusLine',     {fg=p.fg.calm, bg=p.bg.selection,          })
  hi('StatusLineNC',   {fg=p.comment, bg=p.bg.calm,          })
  hi('Substitute',     {fg=p.bg.calm, bg=p.class,          })
  hi('TabLine',        {fg=p.comment, bg=p.bg.calm,          })
  hi('TabLineFill',    {fg=p.comment, bg=p.bg.calm,          })
  hi('TabLineSel',     {fg=p.string, bg=p.bg.calm,          })
  hi('TermCursor',     {            reverse=true,   })
  hi('TermCursorNC',   {            reverse=true,   })
  hi('Title',          {fg=p.func,                })
  hi('VertSplit',      {fg=p.bg.selection, bg=p.bg.selection,          })
  hi('Visual',         {      bg=p.bg.selection,          })
  hi('VisualNOS',      {fg=p.variable,                })
  hi('WarningMsg',     {fg=p.variable,                })
  hi('Whitespace',     {fg=p.comment,                })
  hi('WildMenu',       {fg=p.variable, bg=p.class,          })
  hi('WinBar',         {fg=p.fg.calm, bg=p.bg.selection,          })
  hi('WinBarNC',       {fg=p.comment, bg=p.bg.calm,          })
  hi('WinSeparator',   {fg=p.bg.selection, bg=p.bg.selection,          })

  -- Standard syntax (affects treesitter)
  hi('Boolean',        {fg=p.constant,        })
  hi('Character',      {fg=p.variable,        })
  hi('Comment',        {fg=p.comment,        })
  hi('Conditional',    {fg=p.keyword,        })
  hi('Constant',       {fg=p.constant,        })
  hi('Debug',          {fg=p.variable,        })
  hi('Define',         {fg=p.keyword,        })
  hi('Delimiter',      {fg=p.delimiter,        })
  hi('Error',          {fg=p.bg.default, bg=p.variable,  })
  hi('Exception',      {fg=p.variable,        })
  hi('Float',          {fg=p.constant,        })
  hi('Function',       {fg=p.func,        })
  hi('Identifier',     {fg=p.variable,        })
  hi('Ignore',         {fg=p.support,        })
  hi('Include',        {fg=p.func,        })
  hi('Keyword',        {fg=p.keyword,        })
  hi('Label',          {fg=p.class,        })
  hi('Macro',          {fg=p.variable,        })
  hi('Number',         {fg=p.constant,        })
  hi('Operator',       {fg=p.fg.default,        })
  hi('PreCondit',      {fg=p.class,        })
  hi('PreProc',        {fg=p.class,        })
  hi('Repeat',         {fg=p.class,        })
  hi('Special',        {fg=p.support,        })
  hi('SpecialChar',    {fg=p.delimiter,        })
  hi('SpecialComment', {fg=p.support,        })
  hi('Statement',      {fg=p.variable,        })
  hi('StorageClass',   {fg=p.class,        })
  hi('String',         {fg=p.string,        })
  hi('Structure',      {fg=p.keyword,        })
  hi('Tag',            {fg=p.class,        })
  hi('Todo',           {fg=p.class, bg=p.bg.calm,  })
  hi('Type',           {fg=p.class,        })
  hi('Typedef',        {fg=p.class,        })

  -- Other from 'base16-vim'
  hi('Bold',       {       bold=true,      })
  hi('Italic',     {       italic=true,    })
  hi('TooLong',    {fg=p.variable,           })
  hi('Underlined', {       underline=true, })

  -- Git diff
  hi('DiffAdded',   {fg=p.string, bg=p.bg.default,  })
  hi('DiffFile',    {fg=p.variable, bg=p.bg.default,  })
  hi('DiffLine',    {fg=p.func, bg=p.bg.default,  })
  hi('DiffNewFile', {link='DiffAdded'})
  hi('DiffRemoved', {link='DiffFile'})

  -- Git commit
  hi('gitcommitBranch',        {fg=p.constant,  bold=true, })
  hi('gitcommitComment',       {link='Comment'})
  hi('gitcommitDiscarded',     {link='Comment'})
  hi('gitcommitDiscardedFile', {fg=p.variable,  bold=true, })
  hi('gitcommitDiscardedType', {fg=p.func,      })
  hi('gitcommitHeader',        {fg=p.keyword,      })
  hi('gitcommitOverflow',      {fg=p.variable,      })
  hi('gitcommitSelected',      {link='Comment'})
  hi('gitcommitSelectedFile',  {fg=p.string,  bold=true, })
  hi('gitcommitSelectedType',  {link='gitcommitDiscardedType'})
  hi('gitcommitSummary',       {fg=p.string,      })
  hi('gitcommitUnmergedFile',  {link='gitcommitDiscardedFile'})
  hi('gitcommitUnmergedType',  {link='gitcommitDiscardedType'})
  hi('gitcommitUntracked',     {link='Comment'})
  hi('gitcommitUntrackedFile', {fg=p.class,      })

  -- Built-in diagnostic
  hi('DiagnosticError', {fg=p.variable,   })
  hi('DiagnosticHint',  {fg=p.func,   })
  hi('DiagnosticInfo',  {fg=p.support,   })
  hi('DiagnosticOk',    {fg=p.string,   })
  hi('DiagnosticWarn',  {fg=p.keyword,   })

  hi('DiagnosticFloatingError', {fg=p.variable, bg=p.bg.calm,  })
  hi('DiagnosticFloatingHint',  {fg=p.func, bg=p.bg.calm,  })
  hi('DiagnosticFloatingInfo',  {fg=p.support, bg=p.bg.calm,  })
  hi('DiagnosticFloatingOk',    {fg=p.string, bg=p.bg.calm,  })
  hi('DiagnosticFloatingWarn',  {fg=p.keyword, bg=p.bg.calm,  })

  hi('DiagnosticSignError', {link='DiagnosticFloatingError'})
  hi('DiagnosticSignHint',  {link='DiagnosticFloatingHint'})
  hi('DiagnosticSignInfo',  {link='DiagnosticFloatingInfo'})
  hi('DiagnosticSignOk',    {link='DiagnosticFloatingOk'})
  hi('DiagnosticSignWarn',  {link='DiagnosticFloatingWarn'})

  hi('DiagnosticUnderlineError', {  underline=true, sp=p.variable})
  hi('DiagnosticUnderlineHint',  {  underline=true, sp=p.func})
  hi('DiagnosticUnderlineInfo',  {  underline=true, sp=p.support})
  hi('DiagnosticUnderlineOk',    {  underline=true, sp=p.string})
  hi('DiagnosticUnderlineWarn',  {  underline=true, sp=p.keyword})

  -- Built-in LSP
  hi('LspReferenceText',  { bg=p.bg.selection,  })
  hi('LspReferenceRead',  {link='LspReferenceText'})
  hi('LspReferenceWrite', {link='LspReferenceText'})

  hi('LspSignatureActiveParameter', {link='LspReferenceText'})

  hi('LspCodeLens',          {link='Comment'})
  hi('LspCodeLensSeparator', {link='Comment'})

  -- Tree-sitter
	-- Sources:
	-- - `:h treesitter-highlight-groups`
	-- - https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights
	-- Included only those differing from default links
	hi('@keyword.return', {fg=p.variable,   })
	hi('@symbol',         {fg=p.keyword,   })
	hi('@variable',       {fg=p.fg.default,   })

	hi('@text.strong',   {  bold=true,          })
	hi('@text.emphasis', {  italic=true,        })
	hi('@text.strike',   {  strikethrough=true, })

  -- Semantic tokens
    -- Source: `:h lsp-semantic-highlight`
    -- Included only those differing from default links
    hi('@lsp.type.variable',      {fg=p.fg.default,   })

    hi('@lsp.mod.defaultLibrary', {link='Special'})
    hi('@lsp.mod.deprecated',     {fg=p.variable,   })

 
  if H.has_integration('folke/lazy.nvim') then
    hi('LazyButton',       { bg=p.bg.calm,     })
    hi('LazyButtonActive', { bg=p.bg.selection,     })
    hi('LazyDimmed',       {link='Comment'})
    hi('LazyH1',           { bg=p.bg.selection, bold=true, })
  end

  if H.has_integration('folke/noice.nvim') then
    hi('NoiceCmdlinePopupBorder', {fg=p.func,   })
    hi('NoiceConfirmBorder',      {fg=p.keyword,   })
  end

  -- folke/trouble.nvim
  -- if H.has_integration('folke/trouble.nvim') then
    -- hi('TroubleCount',           {fg=p.string,  bold=true, })
    -- hi('TroubleFoldIcon',        {fg=p.fg.default,      })
    -- hi('TroubleIndent',          {fg=p.bg.selection,      })
    -- hi('TroubleLocation',        {fg=p.fg.calm,      })
    -- hi('TroubleSignError',       {link='DiagnosticError'})
    -- hi('TroubleSignHint',        {link='DiagnosticHint'})
    -- hi('TroubleSignInformation', {link='DiagnosticInfo'})
    -- hi('TroubleSignOther',       {link='DiagnosticInfo'})
    -- hi('TroubleSignWarning',     {link='DiagnosticWarn'})
    -- hi('TroubleText',            {fg=p.fg.default,      })
    -- hi('TroubleTextError',       {link='TroubleText'})
    -- hi('TroubleTextHint',        {link='TroubleText'})
    -- hi('TroubleTextInformation', {link='TroubleText'})
    -- hi('TroubleTextWarning',     {link='TroubleText'})
  -- end

  -- folke/todo-comments.nvim
  -- Everything works correctly out of the box

  if H.has_integration('folke/which-key.nvim') then
    hi('WhichKey',          {fg=p.func,        })
    hi('WhichKeyDesc',      {fg=p.fg.default,        })
    hi('WhichKeyFloat',     {fg=p.fg.default, bg=p.bg.calm,  })
    hi('WhichKeyGroup',     {fg=p.keyword,        })
    hi('WhichKeySeparator', {fg=p.string, bg=p.bg.calm,  })
    hi('WhichKeyValue',     {fg=p.comment,        })
  end

  if H.has_integration('hrsh7th/nvim-cmp') then
    hi('CmpItemAbbr',           {fg=p.fg.default,           })
    hi('CmpItemAbbrDeprecated', {fg=p.comment,           })
    hi('CmpItemAbbrMatch',      {fg=p.class,       bold=true, })
    hi('CmpItemAbbrMatchFuzzy', {fg=p.class,       bold=true, })
    hi('CmpItemKind',           {fg=p.delimiter, bg=p.bg.calm,     })
    hi('CmpItemMenu',           {fg=p.fg.default, bg=p.bg.calm,     })

    hi('CmpItemKindClass',         {link='Type'})
    hi('CmpItemKindColor',         {link='Special'})
    hi('CmpItemKindConstant',      {link='Constant'})
    hi('CmpItemKindConstructor',   {link='Type'})
    hi('CmpItemKindEnum',          {link='Structure'})
    hi('CmpItemKindEnumMember',    {link='Structure'})
    hi('CmpItemKindEvent',         {link='Exception'})
    hi('CmpItemKindField',         {link='Structure'})
    hi('CmpItemKindFile',          {link='Tag'})
    hi('CmpItemKindFolder',        {link='Directory'})
    hi('CmpItemKindFunction',      {link='Function'})
    hi('CmpItemKindInterface',     {link='Structure'})
    hi('CmpItemKindKeyword',       {link='Keyword'})
    hi('CmpItemKindMethod',        {link='Function'})
    hi('CmpItemKindModule',        {link='Structure'})
    hi('CmpItemKindOperator',      {link='Operator'})
    hi('CmpItemKindProperty',      {link='Structure'})
    hi('CmpItemKindReference',     {link='Tag'})
    hi('CmpItemKindSnippet',       {link='Special'})
    hi('CmpItemKindStruct',        {link='Structure'})
    hi('CmpItemKindText',          {link='Statement'})
    hi('CmpItemKindTypeParameter', {link='Type'})
    hi('CmpItemKindUnit',          {link='Special'})
    hi('CmpItemKindValue',         {link='Identifier'})
    hi('CmpItemKindVariable',      {link='Delimiter'})
  end


  if H.has_integration('lewis6991/gitsigns.nvim') then
    hi('GitSignsAdd',             {fg=p.string, bg=p.bg.calm,  })
    hi('GitSignsAddLn',           {link='GitSignsAdd'})
    hi('GitSignsAddInline',       {link='GitSignsAdd'})

    hi('GitSignsChange',          {fg=p.keyword, bg=p.bg.calm,  })
    hi('GitSignsChangeLn',        {link='GitSignsChange'})
    hi('GitSignsChangeInline',    {link='GitSignsChange'})

    hi('GitSignsDelete',          {fg=p.variable, bg=p.bg.calm,  })
    hi('GitSignsDeleteLn',        {link='GitSignsDelete'})
    hi('GitSignsDeleteInline',    {link='GitSignsDelete'})

    hi('GitSignsUntracked',       {fg=p.func, bg=p.bg.calm,  })
    hi('GitSignsUntrackedLn',     {link='GitSignsUntracked'})
    hi('GitSignsUntrackedInline', {link='GitSignsUntracked'})
  end

  if H.has_integration('nvim-neo-tree/neo-tree.nvim') then
    hi('NeoTreeDimText',              {fg=p.comment,           })
    hi('NeoTreeDotfile',              {fg=p.fg.calm,           })
    hi('NeoTreeFadeText1',            {link='NeoTreeDimText'})
    hi('NeoTreeFadeText2',            {fg=p.bg.selection,           })
    hi('NeoTreeGitAdded',             {fg=p.string,           })
    hi('NeoTreeGitConflict',          {fg=p.variable,       bold=true, })
    hi('NeoTreeGitDeleted',           {fg=p.variable,           })
    hi('NeoTreeGitModified',          {fg=p.keyword,           })
    hi('NeoTreeGitUnstaged',          {fg=p.variable,           })
    hi('NeoTreeGitUntracked',         {fg=p.class,           })
    hi('NeoTreeMessage',              {fg=p.fg.default, bg=p.bg.calm,     })
    hi('NeoTreeModified',             {fg=p.bg.accent,           })
    hi('NeoTreeRootName',             {fg=p.func,       bold=true, })
    hi('NeoTreeTabInactive',          {fg=p.fg.calm,           })
    hi('NeoTreeTabSeparatorActive',   {fg=p.comment, bg=p.bg.selection,     })
    hi('NeoTreeTabSeparatorInactive', {fg=p.bg.calm, bg=p.bg.calm,     })
  end

  if H.has_integration('nvim-telescope/telescope.nvim') then
    hi('TelescopeBorder',         {fg=p.delimiter,           })
    hi('TelescopeMatching',       {fg=p.class,           })
    hi('TelescopeMultiSelection', {      bg=p.bg.calm, bold=true, })
    hi('TelescopeSelection',      {      bg=p.bg.calm, bold=true, })
  end

  -- Terminal colors
  vim.g.terminal_color_0 = p.bg.default
  vim.g.terminal_color_1 = p.variable
  vim.g.terminal_color_2 = p.string
  vim.g.terminal_color_3 = p.class
  vim.g.terminal_color_4 = p.func
  vim.g.terminal_color_5 = p.keyword
  vim.g.terminal_color_6 = p.support
  vim.g.terminal_color_7 = p.fg.default
  vim.g.terminal_color_8 = p.comment
  vim.g.terminal_color_9 = p.variable
  vim.g.terminal_color_10 = p.string
  vim.g.terminal_color_11 = p.class
  vim.g.terminal_color_12 = p.func
  vim.g.terminal_color_13 = p.keyword
  vim.g.terminal_color_14 = p.support
  vim.g.terminal_color_15 = p.bg.accent
 
end

return M