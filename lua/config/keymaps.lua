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
-- manual: (boolean) - do not create mapping by lazy
-- where StringArray is (string|string[]) but if string contains "," then it will be splitted

-- Mapping modes:
-- n: Normal mode
-- x: Visual mode - When typing commands while the Visual area is highlighted.
-- s: Select mode - like Visual mode but typing text replaces the selection.
-- o: Operator-pending mode - When an operator is pending. See :h omap-info
-- i: Insert mode - These are also used in Replace mode.
-- c: Command-line mode - When entering a ":" or "/" command.
-- t: Terminal mode - When typing in a :terminal buffer.
-- Combinations:
-- l: ic and unique Lang-Arg - For language mapping
-- v: xs - Visual and Select
-- !: ic - Insert and Command
-- "": nvo or nxso - default :map behavior

local Keymaps = require("core.keymaps")
local require = require("lazy.core.util").lazy_require
local Util = require("util")

local expr = Keymaps.options_builder({expr=true})
local manual = Keymaps.options_builder({manual=true})
local cmd = Keymaps.cmd
local layered = Keymaps.layered
local W = Keymaps.wrap_mod

local M = {}
M.plugins = {}
M.mappings = {}

M.global = {
-- Better up/down
-- mode   lhs  rhs                                description
  {"nx", "k", expr("v:count == 0 ? 'gk' : 'k'"), "move up one *wrapped* line"},
  {"nx", "j", expr("v:count == 0 ? 'gj' : 'j'"), "move down one *wrapped* line"},

  {"nx", "↑", expr("v:count == 0 ? 'gk' : 'k'"), "move up one *wrapped* line"},
  {"nx", "↓", expr("v:count == 0 ? 'gj' : 'j'"), "move down one *wrapped* line"},

  {"i", "↑", "<C-o>gk", "move up one *wrapped* line"},
  {"i", "↓", "<C-o>gj", "move down one *wrapped* line"},

--Move lines
  {"n", "<A-j>", "<CMD>m .+1<CR>==", "Move lines down"},
  {"i", "<A-j>", "<ESC><CMD>m .+1<CR>==gi", "Move lines down"},
  {"v", "<A-j>", ":m '>+1<CR>gv=gv", "Move lines down"},
  {"n", "<A-k>", "<CMD>m .-2<CR>==", "Move lines up"},
  {"i", "<A-k>", "<ESC><CMD>m .-2<CR>==gi", "Move lines up"},
  {"v", "<A-k>", ":m '<-2<CR>gv=gv", "Move lines up"},

-- Consistant mappings
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
M.neo_tree = {
  global = {},
  filesystem = {
    ["<space>"] = "none",
    ["/"] = "none",
    ["F"] = "fuzzy_finder",
  },
}

M.plugins["flash.nvim"] = {
  {"nx",  "#", W("flash").jump({search = { mode = "fuzzy", incremental = true}}), "Fuzzy Flash" },
  {"nxo", "s", W("flash").jump(), "Flash" },
  {"nxo", "S", W("flash").treesitter(), "Flash Treesitter" },
  {"o",   "r", W("flash").remote(), "Remote Flash" },
  {"ox",  "R", W("flash").treesitter_search(), "Treesitter Search" },
  {"c","<c-s>", W("flash").toggle(), "Toggle Flash Search" },
}

M.plugins["LuaSnip"] = {
  {"i",  "<C-e>", layered(W("luasnip").expand()) },
  {"is", "<C-k>", layered(W("luasnip").jump(1)) },
  {"is", "<C-j>", layered(W("luasnip").jump(-1)) },
  {"is", "<C-y>", layered(W("luasnip").change_choice(1)) },
}

M.plugins["neoscroll.nvim"] = {
  {"nv", "<C-u>", manual({'scroll', {'-vim.wo.scroll', 'true', '30'}}), "Smooth scrolling up"},
  {"nv", "<C-d>", manual({'scroll', {' vim.wo.scroll', 'true', '30'}}), "Smooth scrolling down"}
}

function M.cmp_mappings(cmp)
  return Keymaps.table_by_lhs({
    {"i", "<C-n>", cmp.mapping.complete_or_select("next", { behavior = cmp.SelectBehavior.Select })},
    {"i", "<C-p>", cmp.mapping.complete_or_select("prev", { behavior = cmp.SelectBehavior.Select })},
    {"i", "<C-b>", cmp.mapping.scroll_docs(-4)},
    {"i", "<C-f>", cmp.mapping.scroll_docs(4)},
    {"i", "<Tab>", cmp.mapping.confirm({ select = true }), "Accept selected item | select first"},
    {"i", "<S-Tab>", cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, })},
  })
end

return M
