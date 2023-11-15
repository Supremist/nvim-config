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
-- Better up/down
-- mode   lhs  rhs                                description
  {"n,x", "k", expr("v:count == 0 ? 'gk' : 'k'"), "move up one *wrapped* line"},
  {"n,x", "j", expr("v:count == 0 ? 'gj' : 'j'"), "move down one *wrapped* line"},

  {"n,x", "↑", expr("v:count == 0 ? 'gk' : 'k'"), "move up one *wrapped* line"},
  {"n,x", "↓", expr("v:count == 0 ? 'gj' : 'j'"), "move down one *wrapped* line"},

  {"i", "↑", "<C-o>gk", "move up one *wrapped* line"},
  {"i", "↓", "<C-o>gj", "move down one *wrapped* line"},

--Move lines
  {"n", "<A-j>", "<CMD>m .+1<CR>==", "Move down"},
  {"n", "<A-k>", "<CMD>m .-2<CR>==", "Move up"},
  {"i", "<A-j>", "<ESC><CMD>m .+1<CR>==gi", "Move down"},
  {"i", "<A-k>", "<ESC><CMD>m .-2<CR>==gi", "Move up"},
  {"v", "<A-j>", ":m '>+1<CR>gv=gv", "Move down"},
  {"v", "<A-k>", ":m '<-2<CR>gv=gv", "Move up"},

-- Consistant mappings
  {"i", "<C-H>", "<C-w>", "delete previous word"}, -- <C-BS> is <C-H> because of terminal app
  {"i", "<C-w>", "<ESC><C-w>", "window menu from insert mode"},

  {"i", "<Esc>", {function()
    local cmp = package.loaded["cmp"]
    return cmp and cmp.visible() and cmp.abort()
  end}, "Close popup or enter Normal mode"}
}

local tree = require("neo-tree.command")
M.plugins["neo-tree.nvim"] = {
  {"n", "<L>fe", function() tree.execute({toggle = true, dir = Util.get_root()}) end, "Explorer NeoTree (root dir)"},
  {"n", "<L>fE", function() tree.execute({toggle = true, dir = vim.loop.cwd()}) end, "Explorer NeoTree (cwd)"},
  {"n", "<L>e", "<L>fe", "Explorer NeoTree (root dir)", remap = true },
  {"n", "<L>E", "<L>fE", "Explorer NeoTree (cwd)", remap = true },
}

M.plugins["LuaSnip"] = {
  {"i", "<C-e>", {W("luasnip").expand()} },
  {"i,s", "<C-j>", {W("luasnip").jump(1)} },
  {"i,s", "<C-k>", {W("luasnip").jump(-1)} },
  {"i,s", "<C-y>", {W("luasnip").change_choice(1)} },
}

function M.cmp_mappings(cmp)
  local function complete_or(method, opts)
    return function()
      if cmp.visible() then
        cmp[method](opts)
      else
        cmp.complete()
      end
    end
  end
  return Keymaps.table_by_lhs({
    {"i", "<C-n>", complete_or("select_next_item", { behavior = cmp.SelectBehavior.Select })},
    {"i", "<C-p>", complete_or("select_prev_item", { behavior = cmp.SelectBehavior.Select })},
    {"i", "<C-b>", cmp.mapping.scroll_docs(-4)},
    {"i", "<C-f>", cmp.mapping.scroll_docs(4)},
    {"i", "<Tab>", cmp.mapping.confirm({ select = true }), "Accept selected item | select first"},
    {"i", "<S-Tab>", cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, })},
  })
end

return M
