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
	green = p.base0B,
	
  }
end


function M.setup(opts)
  local hi = function (name, opts) 
    vim.api.nvim_set_hl(0, name, opts)
  end
  local p = tomorrow_night_palette

  hi('ColorColumn',    {      bg=p.base01,          })
  hi('Conceal',        {fg=p.base0D,                })
  hi('CurSearch',      {fg=p.base01, bg=p.base09,          })
  hi('Cursor',         {fg=p.base00, bg=p.base05,          })
  hi('CursorColumn',   {      bg=p.base01,          })
  hi('CursorIM',       {fg=p.base00, bg=p.base05,          })
  hi('CursorLine',     {      bg=p.base01,          })
  hi('CursorLineFold', {fg=p.base0C, bg=p.base01,          })
  hi('CursorLineNr',   {fg=p.base04, bg=p.base01,          })
  hi('CursorLineSign', {fg=p.base03, bg=p.base01,          })
  hi('DiffAdd',        {fg=p.base0B, bg=p.base01,          })
  -- Differs from base16-vim, but according to general style guide
  hi('DiffChange',     {fg=p.base0E, bg=p.base01,          })
  hi('DiffDelete',     {fg=p.base08, bg=p.base01,          })
  hi('DiffText',       {fg=p.base0D, bg=p.base01,          })
  hi('Directory',      {fg=p.base0D,                })
  hi('EndOfBuffer',    {fg=p.base03,                })
  hi('ErrorMsg',       {fg=p.base08, bg=p.base00,          })
  hi('FoldColumn',     {fg=p.base0C, bg=p.base01,          })
  hi('Folded',         {fg=p.base03, bg=p.base01,          })
  hi('IncSearch',      {fg=p.base01, bg=p.base09,          })
  hi('lCursor',        {fg=p.base00, bg=p.base05,          })
  hi('LineNr',         {fg=p.base03, bg=p.base01,          })
  hi('LineNrAbove',    {fg=p.base03, bg=p.base01,          })
  hi('LineNrBelow',    {fg=p.base03, bg=p.base01,          })
  -- Slight difference from base16, where `bg=base03` is used. This makes
  -- it possible to comfortably see this highlighting in comments.
  hi('MatchParen',     {      bg=p.base02,          })
  hi('ModeMsg',        {fg=p.base0B,                })
  hi('MoreMsg',        {fg=p.base0B,                })
  hi('MsgArea',        {fg=p.base05, bg=p.base00,          })
  hi('MsgSeparator',   {fg=p.base04, bg=p.base02,          })
  hi('NonText',        {fg=p.base03,                })
  hi('Normal',         {fg=p.base05, bg=p.base00,          })
  hi('NormalFloat',    {fg=p.base05, bg=p.base01,          })
  hi('NormalNC',       {fg=p.base05, bg=p.base00,          })
  hi('PMenu',          {fg=p.base05, bg=p.base01,          })
  hi('PMenuSbar',      {      bg=p.base02,          })
  hi('PMenuSel',       {fg=p.base01, bg=p.base05,          })
  hi('PMenuThumb',     {      bg=p.base07,          })
  hi('Question',       {fg=p.base0D,                })
  hi('QuickFixLine',   {      bg=p.base01,          })
  hi('Search',         {fg=p.base01, bg=p.base0A,          })
  hi('SignColumn',     {fg=p.base03, bg=p.base01,          })
  hi('SpecialKey',     {fg=p.base03,                })
  hi('SpellBad',       {            undercurl=true, sp=p.base08})
  hi('SpellCap',       {            undercurl=true, sp=p.base0D})
  hi('SpellLocal',     {            undercurl=true, sp=p.base0C})
  hi('SpellRare',      {            undercurl=true, sp=p.base0E})
  hi('StatusLine',     {fg=p.base04, bg=p.base02,          })
  hi('StatusLineNC',   {fg=p.base03, bg=p.base01,          })
  hi('Substitute',     {fg=p.base01, bg=p.base0A,          })
  hi('TabLine',        {fg=p.base03, bg=p.base01,          })
  hi('TabLineFill',    {fg=p.base03, bg=p.base01,          })
  hi('TabLineSel',     {fg=p.base0B, bg=p.base01,          })
  hi('TermCursor',     {            reverse=true,   })
  hi('TermCursorNC',   {            reverse=true,   })
  hi('Title',          {fg=p.base0D,                })
  hi('VertSplit',      {fg=p.base02, bg=p.base02,          })
  hi('Visual',         {      bg=p.base02,          })
  hi('VisualNOS',      {fg=p.base08,                })
  hi('WarningMsg',     {fg=p.base08,                })
  hi('Whitespace',     {fg=p.base03,                })
  hi('WildMenu',       {fg=p.base08, bg=p.base0A,          })
  hi('WinBar',         {fg=p.base04, bg=p.base02,          })
  hi('WinBarNC',       {fg=p.base03, bg=p.base01,          })
  hi('WinSeparator',   {fg=p.base02, bg=p.base02,          })

  -- Standard syntax (affects treesitter)
  hi('Boolean',        {fg=p.base09,        })
  hi('Character',      {fg=p.base08,        })
  hi('Comment',        {fg=p.base03,        })
  hi('Conditional',    {fg=p.base0E,        })
  hi('Constant',       {fg=p.base09,        })
  hi('Debug',          {fg=p.base08,        })
  hi('Define',         {fg=p.base0E,        })
  hi('Delimiter',      {fg=p.base0F,        })
  hi('Error',          {fg=p.base00, bg=p.base08,  })
  hi('Exception',      {fg=p.base08,        })
  hi('Float',          {fg=p.base09,        })
  hi('Function',       {fg=p.base0D,        })
  hi('Identifier',     {fg=p.base08,        })
  hi('Ignore',         {fg=p.base0C,        })
  hi('Include',        {fg=p.base0D,        })
  hi('Keyword',        {fg=p.base0E,        })
  hi('Label',          {fg=p.base0A,        })
  hi('Macro',          {fg=p.base08,        })
  hi('Number',         {fg=p.base09,        })
  hi('Operator',       {fg=p.base05,        })
  hi('PreCondit',      {fg=p.base0A,        })
  hi('PreProc',        {fg=p.base0A,        })
  hi('Repeat',         {fg=p.base0A,        })
  hi('Special',        {fg=p.base0C,        })
  hi('SpecialChar',    {fg=p.base0F,        })
  hi('SpecialComment', {fg=p.base0C,        })
  hi('Statement',      {fg=p.base08,        })
  hi('StorageClass',   {fg=p.base0A,        })
  hi('String',         {fg=p.base0B,        })
  hi('Structure',      {fg=p.base0E,        })
  hi('Tag',            {fg=p.base0A,        })
  hi('Todo',           {fg=p.base0A, bg=p.base01,  })
  hi('Type',           {fg=p.base0A,        })
  hi('Typedef',        {fg=p.base0A,        })

  -- Other from 'base16-vim'
  hi('Bold',       {       bold=true,      })
  hi('Italic',     {       italic=true,    })
  hi('TooLong',    {fg=p.base08,           })
  hi('Underlined', {       underline=true, })

  -- Git diff
  hi('DiffAdded',   {fg=p.base0B, bg=p.base00,  })
  hi('DiffFile',    {fg=p.base08, bg=p.base00,  })
  hi('DiffLine',    {fg=p.base0D, bg=p.base00,  })
  hi('DiffNewFile', {link='DiffAdded'})
  hi('DiffRemoved', {link='DiffFile'})

  -- Git commit
  hi('gitcommitBranch',        {fg=p.base09,  bold=true, })
  hi('gitcommitComment',       {link='Comment'})
  hi('gitcommitDiscarded',     {link='Comment'})
  hi('gitcommitDiscardedFile', {fg=p.base08,  bold=true, })
  hi('gitcommitDiscardedType', {fg=p.base0D,      })
  hi('gitcommitHeader',        {fg=p.base0E,      })
  hi('gitcommitOverflow',      {fg=p.base08,      })
  hi('gitcommitSelected',      {link='Comment'})
  hi('gitcommitSelectedFile',  {fg=p.base0B,  bold=true, })
  hi('gitcommitSelectedType',  {link='gitcommitDiscardedType'})
  hi('gitcommitSummary',       {fg=p.base0B,      })
  hi('gitcommitUnmergedFile',  {link='gitcommitDiscardedFile'})
  hi('gitcommitUnmergedType',  {link='gitcommitDiscardedType'})
  hi('gitcommitUntracked',     {link='Comment'})
  hi('gitcommitUntrackedFile', {fg=p.base0A,      })

  -- Built-in diagnostic
  hi('DiagnosticError', {fg=p.base08,   })
  hi('DiagnosticHint',  {fg=p.base0D,   })
  hi('DiagnosticInfo',  {fg=p.base0C,   })
  hi('DiagnosticOk',    {fg=p.base0B,   })
  hi('DiagnosticWarn',  {fg=p.base0E,   })

  hi('DiagnosticFloatingError', {fg=p.base08, bg=p.base01,  })
  hi('DiagnosticFloatingHint',  {fg=p.base0D, bg=p.base01,  })
  hi('DiagnosticFloatingInfo',  {fg=p.base0C, bg=p.base01,  })
  hi('DiagnosticFloatingOk',    {fg=p.base0B, bg=p.base01,  })
  hi('DiagnosticFloatingWarn',  {fg=p.base0E, bg=p.base01,  })

  hi('DiagnosticSignError', {link='DiagnosticFloatingError'})
  hi('DiagnosticSignHint',  {link='DiagnosticFloatingHint'})
  hi('DiagnosticSignInfo',  {link='DiagnosticFloatingInfo'})
  hi('DiagnosticSignOk',    {link='DiagnosticFloatingOk'})
  hi('DiagnosticSignWarn',  {link='DiagnosticFloatingWarn'})

  hi('DiagnosticUnderlineError', {  underline=true, sp=p.base08})
  hi('DiagnosticUnderlineHint',  {  underline=true, sp=p.base0D})
  hi('DiagnosticUnderlineInfo',  {  underline=true, sp=p.base0C})
  hi('DiagnosticUnderlineOk',    {  underline=true, sp=p.base0B})
  hi('DiagnosticUnderlineWarn',  {  underline=true, sp=p.base0E})

  -- Built-in LSP
  hi('LspReferenceText',  { bg=p.base02,  })
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
	hi('@keyword.return', {fg=p.base08,   })
	hi('@symbol',         {fg=p.base0E,   })
	hi('@variable',       {fg=p.base05,   })

	hi('@text.strong',   {  bold=true,          })
	hi('@text.emphasis', {  italic=true,        })
	hi('@text.strike',   {  strikethrough=true, })

  -- Semantic tokens
    -- Source: `:h lsp-semantic-highlight`
    -- Included only those differing from default links
    hi('@lsp.type.variable',      {fg=p.base05,   })

    hi('@lsp.mod.defaultLibrary', {link='Special'})
    hi('@lsp.mod.deprecated',     {fg=p.base08,   })

 
  if H.has_integration('folke/lazy.nvim') then
    hi('LazyButton',       { bg=p.base01,     })
    hi('LazyButtonActive', { bg=p.base02,     })
    hi('LazyDimmed',       {link='Comment'})
    hi('LazyH1',           { bg=p.base02, bold=true, })
  end

  if H.has_integration('folke/noice.nvim') then
    hi('NoiceCmdlinePopupBorder', {fg=p.base0D,   })
    hi('NoiceConfirmBorder',      {fg=p.base0E,   })
  end

  -- folke/trouble.nvim
  if H.has_integration('folke/trouble.nvim') then
    hi('TroubleCount',           {fg=p.base0B,  bold=true, })
    hi('TroubleFoldIcon',        {fg=p.base05,      })
    hi('TroubleIndent',          {fg=p.base02,      })
    hi('TroubleLocation',        {fg=p.base04,      })
    hi('TroubleSignError',       {link='DiagnosticError'})
    hi('TroubleSignHint',        {link='DiagnosticHint'})
    hi('TroubleSignInformation', {link='DiagnosticInfo'})
    hi('TroubleSignOther',       {link='DiagnosticInfo'})
    hi('TroubleSignWarning',     {link='DiagnosticWarn'})
    hi('TroubleText',            {fg=p.base05,      })
    hi('TroubleTextError',       {link='TroubleText'})
    hi('TroubleTextHint',        {link='TroubleText'})
    hi('TroubleTextInformation', {link='TroubleText'})
    hi('TroubleTextWarning',     {link='TroubleText'})
  end

  -- folke/todo-comments.nvim
  -- Everything works correctly out of the box

  if H.has_integration('folke/which-key.nvim') then
    hi('WhichKey',          {fg=p.base0D,        })
    hi('WhichKeyDesc',      {fg=p.base05,        })
    hi('WhichKeyFloat',     {fg=p.base05, bg=p.base01,  })
    hi('WhichKeyGroup',     {fg=p.base0E,        })
    hi('WhichKeySeparator', {fg=p.base0B, bg=p.base01,  })
    hi('WhichKeyValue',     {fg=p.base03,        })
  end

  if H.has_integration('hrsh7th/nvim-cmp') then
    hi('CmpItemAbbr',           {fg=p.base05,           })
    hi('CmpItemAbbrDeprecated', {fg=p.base03,           })
    hi('CmpItemAbbrMatch',      {fg=p.base0A,       bold=true, })
    hi('CmpItemAbbrMatchFuzzy', {fg=p.base0A,       bold=true, })
    hi('CmpItemKind',           {fg=p.base0F, bg=p.base01,     })
    hi('CmpItemMenu',           {fg=p.base05, bg=p.base01,     })

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
    hi('GitSignsAdd',             {fg=p.base0B, bg=p.base01,  })
    hi('GitSignsAddLn',           {link='GitSignsAdd'})
    hi('GitSignsAddInline',       {link='GitSignsAdd'})

    hi('GitSignsChange',          {fg=p.base0E, bg=p.base01,  })
    hi('GitSignsChangeLn',        {link='GitSignsChange'})
    hi('GitSignsChangeInline',    {link='GitSignsChange'})

    hi('GitSignsDelete',          {fg=p.base08, bg=p.base01,  })
    hi('GitSignsDeleteLn',        {link='GitSignsDelete'})
    hi('GitSignsDeleteInline',    {link='GitSignsDelete'})

    hi('GitSignsUntracked',       {fg=p.base0D, bg=p.base01,  })
    hi('GitSignsUntrackedLn',     {link='GitSignsUntracked'})
    hi('GitSignsUntrackedInline', {link='GitSignsUntracked'})
  end

  if H.has_integration('nvim-neo-tree/neo-tree.nvim') then
    hi('NeoTreeDimText',              {fg=p.base03,           })
    hi('NeoTreeDotfile',              {fg=p.base04,           })
    hi('NeoTreeFadeText1',            {link='NeoTreeDimText'})
    hi('NeoTreeFadeText2',            {fg=p.base02,           })
    hi('NeoTreeGitAdded',             {fg=p.base0B,           })
    hi('NeoTreeGitConflict',          {fg=p.base08,       bold=true, })
    hi('NeoTreeGitDeleted',           {fg=p.base08,           })
    hi('NeoTreeGitModified',          {fg=p.base0E,           })
    hi('NeoTreeGitUnstaged',          {fg=p.base08,           })
    hi('NeoTreeGitUntracked',         {fg=p.base0A,           })
    hi('NeoTreeMessage',              {fg=p.base05, bg=p.base01,     })
    hi('NeoTreeModified',             {fg=p.base07,           })
    hi('NeoTreeRootName',             {fg=p.base0D,       bold=true, })
    hi('NeoTreeTabInactive',          {fg=p.base04,           })
    hi('NeoTreeTabSeparatorActive',   {fg=p.base03, bg=p.base02,     })
    hi('NeoTreeTabSeparatorInactive', {fg=p.base01, bg=p.base01,     })
  end

  if H.has_integration('nvim-telescope/telescope.nvim') then
    hi('TelescopeBorder',         {fg=p.base0F,           })
    hi('TelescopeMatching',       {fg=p.base0A,           })
    hi('TelescopeMultiSelection', {      bg=p.base01, bold=true, })
    hi('TelescopeSelection',      {      bg=p.base01, bold=true, })
  end

  -- Terminal colors
  vim.g.terminal_color_0 = p.base00
  vim.g.terminal_color_1 = p.base08
  vim.g.terminal_color_2 = p.base0B
  vim.g.terminal_color_3 = p.base0A
  vim.g.terminal_color_4 = p.base0D
  vim.g.terminal_color_5 = p.base0E
  vim.g.terminal_color_6 = p.base0C
  vim.g.terminal_color_7 = p.base05
  vim.g.terminal_color_8 = p.base03
  vim.g.terminal_color_9 = p.base08
  vim.g.terminal_color_10 = p.base0B
  vim.g.terminal_color_11 = p.base0A
  vim.g.terminal_color_12 = p.base0D
  vim.g.terminal_color_13 = p.base0E
  vim.g.terminal_color_14 = p.base0C
  vim.g.terminal_color_15 = p.base07
end

return M