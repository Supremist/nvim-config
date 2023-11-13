-- This file should contain all keymap declarations. It should not contain any functions.
-- It should not require any modules (Use lazy require for function key bindings).
-- Keymap structure
-- [1]: (StringArray) mode (see :h mode())
-- [2]: (string) lhs (see :h key-notation; also <L> is eqivalent to <Leader>, <LL> is eqivalent to <LocalLeader>)
-- [3]: (string|fun()) rhs
-- [4]: (string) description (optional)
-- ft: (StringArray) filetype for buffer-local keymaps
-- buffer: (integer|boolean) Creates buffer-local mapping, 0 or true for current buffer
-- remap: (boolean) Make the mapping recursive. Inverse of noremap. Defaults to false
-- wait: (boolean) Wait for input in case of mapping conflict. Inverse of nowait. Defaults to true
-- expr: (boolean) Evaluate rhs. Same as :h expr. Dafaults to false
-- replace_keycodes: (boolean) When "expr" is true, replace keycodes in the resulting string (see nvim_replace_termcodes()). Returning nil from the Lua "callback" is equivalent to returning an empty string.
-- silent: (boolean) - Do not echo mapping. Defaults to true
-- script, unique - same as original :map-arguments
-- where StringArray is (string|string[]) but if string contains "," then it will be splitted

local Keymaps = require("core.keymaps")
local require = require("lazy.core.util").lazy_require
local Util = require("util")

local expr = Keymaps.expr
local cmd = Keymaps.cmd
local W = Keymaps.wrap_mod

local M = {}
M.plugins = {}
M.mappings = {}

M.global = {
-- mode   lhs  rhs                                description
  {"n,x", "k", expr("v:count == 0 ? 'gk' : 'k'"), "move up one *wrapped* line"},
  {"n,x", "j", expr("v:count == 0 ? 'gj' : 'j'"), "move down one *wrapped* line"},

  {"n,x", "↑", expr("v:count == 0 ? 'gk' : 'k'"), "move up one *wrapped* line"},
  {"n,x", "↓", expr("v:count == 0 ? 'gj' : 'j'"), "move down one *wrapped* line"},

  {"i", "↑", "<C-o>gk", "move up one *wrapped* line"},
  {"i", "↓", "<C-o>gj", "move down one *wrapped* line"},

  {"i", "<C-H>", "<C-w>", "delete previous word"}, -- <C-BS> is <C-H> because of terminal app
  {"i", "<C-w>", "<ESC><C-w>", "window menu from insert mode"},
}

local tree = require("neo-tree.command")
M.plugins["neo-tree.nvim"] = {
  {"n", "<L>fe", function() tree.execute({toggle = true, dir = Util.get_root()}) end, "Explorer NeoTree (root dir)"},
  {"n", "<L>fE", function() tree.execute({toggle = true, dir = vim.loop.cwd()}) end, "Explorer NeoTree (cwd)"},
  {"n", "<L>e", "<L>fe", "Explorer NeoTree (root dir)", remap = true },
  {"n", "<L>E", "<L>fE", "Explorer NeoTree (cwd)", remap = true },
}

-- TODO Review LuaSnip and auto completion keybindings
M.plugins["LuaSnip"] = {
  {"i", "<tab>", expr(function() return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>" end)},
  {"s", "<tab>", W("luasnip").jump(1)},
  {"i,s", "<s-tab>", W("luasnip").jump(-1)},
}

function M.cmp_mappings(cmp)
  return Keymaps.table_by_lhs({
    {"i", "<C-n>", cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })},
    {"i", "<C-p>", cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })},
    {"i", "<C-b>", cmp.mapping.scroll_docs(-4)},
    {"i", "<C-f>", cmp.mapping.scroll_docs(4)},
    {"i", "<C-Space>", cmp.mapping.complete()},
    {"i", "<C-e>", cmp.mapping.abort()},
    {"i", "<CR>", cmp.mapping.confirm({ select = true })}, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    {"i", "<S-CR>", cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, })}, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  })
end

return M
