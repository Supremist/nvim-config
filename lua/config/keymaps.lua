-- This file should contain all keymap declarations. It should not contain any functions.
-- It should not require any modules (Use lazy require for function key bindings).
-- Keymap structure
-- [1]: (StringArray) mode (see :h mode())
-- [2]: (string) lhs (see :h key-notation; also <L> is eqivalent to <Leader>, <LL> is eqivalent to <LocalLeader>)
-- [3]: (string|fun()) rhs
-- [4]: (string) description (optional)
-- ft: (StringArray) filetype for buffer-local keymaps
-- ... and all other arguments options for vim.keymap.set (see :map-arguments)
-- where StringArray is (string|string[]) but if string contains "," then it will be splitted

local require = require("lazy.core.util").lazy_require
local Util = require("util")

local M = {}
M.plugins = {}

M.global = {
  {"n,v", "j", "gj", "move down one *wrapped* line"},
  {"n,v", "k", "gk", "move up one *wrapped* line"},

  {"i", "<C-H>", "<C-w>", "delete previous word"}, -- <C-BS> is <C-H> because of terminal app
  {"i", "<C-w>", "<ESC><C-w>", "window menu from insert mode"},
}

local cmd = require("neo-tree.command")
M.plugins["neo-tree.nvim"] = {
  {"n", "<L>fe", function() cmd.execute({toggle = true, dir = Util.get_root()}) end, "Explorer NeoTree (root dir)"},
  {"n", "<L>fE", function() cmd.execute({toggle = true, dir = vim.loop.cwd()}) end, "Explorer NeoTree (cwd)"},
  {"n", "<L>e", "<L>fe", "Explorer NeoTree (root dir)", remap = true },
  {"n", "<L>E", "<L>fE", "Explorer NeoTree (cwd)", remap = true },
}

return M
