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

local require = require("lazy.core.util").lazy_require
local Util = require("util")
-- Just more compact
local n = "n"
local i = "i"


local M = {}
M.plugins = {}

M.global = {
-- mode   lhs  rhs                          description
  {"n,x", "k", "v:count == 0 ? 'gk' : 'k'", "move up one *wrapped* line",   expr = true},
  {"n,x", "j", "v:count == 0 ? 'gj' : 'j'", "move down one *wrapped* line", expr = true},

  {"n,x", "↑", "v:count == 0 ? 'gk' : 'k'", "move up one *wrapped* line",   expr = true},
  {"n,x", "↓", "v:count == 0 ? 'gj' : 'j'", "move down one *wrapped* line", expr = true},

  {i, "↑", "<C-o>gk", "move up one *wrapped* line"},
  {i, "↓", "<C-o>gj", "move down one *wrapped* line"},

  {i, "<C-H>", "<C-w>", "delete previous word"}, -- <C-BS> is <C-H> because of terminal app
  {i, "<C-w>", "<ESC><C-w>", "window menu from insert mode"},
}

local cmd = require("neo-tree.command")
M.plugins["neo-tree.nvim"] = {
  {n, "<L>fe", function() cmd.execute({toggle = true, dir = Util.get_root()}) end, "Explorer NeoTree (root dir)"},
  {n, "<L>fE", function() cmd.execute({toggle = true, dir = vim.loop.cwd()}) end, "Explorer NeoTree (cwd)"},
  {n, "<L>e", "<L>fe", "Explorer NeoTree (root dir)", remap = true },
  {n, "<L>E", "<L>fE", "Explorer NeoTree (cwd)", remap = true },
}

return M
