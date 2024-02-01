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
local cmd = Keymaps.cmd
local layered = Keymaps.layered
local W = Keymaps.wrap_mod
local F = Keymaps.forward_mod

local M = {}
M.plugins = {}
M.mappings = {}
M.lsp = {}

Keymaps.set_shorthands({
  ["<Leader>"] = {"<L>", "<l>"},
  ["<LocalLeader>"] = {"<LL>", "<ll>"},
  ["<Plug>"] = {"<P>", "<p>"},
  ["<Up>"] = {"↑"},
  ["<Down>"] = {"↓"},
  ["<Right>"] = {"→"},
  ["<Left>"] = {"←"},
  ["<Cr>"] = {"↲"},
  ["<Space>"] = {"␣"},
  ["<Tab>"] = {"⭾"},
})

M.which_key_groups = Keymaps.parse {
  {"n", "g",    "...", "+goto" },
  {"n", "r",    "...", "+reload" },
  {"n", "gz",   "...", "+surround" },
  {"n", "]",    "...", "+next" },
  {"n", "[",    "...", "+prev" },
  {"n", "<L>⭾", "...", "+tabs" },
  {"n", "<L>b", "...", "+buffer" },
  {"n", "<L>c", "...", "+code" },
  {"n", "<L>f", "...", "+file/find" },
  {"nv","<L>g", "...", "+git" },
  {"n", "<L>gh","...", "+hunks" },
  {"n", "<L>q", "...", "+quit/session" },
  {"n", "<L>s", "...", "+search" },
  {"n", "<L>u", "...", "+ui" },
  {"n", "<L>w", "...", "+windows" },
  {"n", "<L>x", "...", "+diagnostics/quickfix" },
}

M.global = Keymaps.parse {
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

--Leader
  {"n", "<L>ra", W("core.main").reload(), "Reload all config"},
  {"n", "<L>rf", function() require("core.mod").reload_file(vim.api.nvim_buf_get_name(0)) end, "Reload file"},
}

local tree = require("neo-tree.command")
M.plugins["neo-tree.nvim"] = Keymaps.parse {
  {"n", "<L>fe", function() tree.execute({toggle = true, dir = Util.get_root()}) end, "Explorer NeoTree (root dir)"},
  {"n", "<L>fE", function() tree.execute({toggle = true, dir = vim.loop.cwd()}) end, "Explorer NeoTree (cwd)"},
  {"n", "<L>e", "<L>fe", "Explorer NeoTree (root dir)", remap = true },
  {"n", "<L>E", "<L>fE", "Explorer NeoTree (cwd)", remap = true },
}
M.neo_tree = {
  global = {},
  filesystem = {
    ["<Space>"] = "none",
    ["/"] = "none",
    ["F"] = "fuzzy_finder",
  },
}

M.plugins["flash.nvim"] = Keymaps.parse {
  {"nx",  "#", W("flash").jump({search = { mode = "fuzzy", incremental = true}}), "Fuzzy Flash" },
  {"nxo", "s", W("flash").jump(), "Flash" },
  {"nxo", "S", W("flash").treesitter(), "Flash Treesitter" },
  {"o",   "r", W("flash").remote(), "Remote Flash" },
  {"ox",  "R", W("flash").treesitter_search(), "Treesitter Search" },
  {"c","<C-s>", W("flash").toggle(), "Toggle Flash Search" },
}

M.plugins["telescope.nvim"] = Keymaps.parse {
  { "n", "<L>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", "Switch Buffer" },
  { "n", "<L>/", Util.telescope("live_grep"), "Grep (root dir)" },
  { "n", "<L>:", "<cmd>Telescope command_history<cr>", "Command History" },
  { "n", "<L><Space>", Util.telescope("files"), "Find Files (root dir)" },
  -- find
  { "n", "<L>fb", "<cmd>Telescope buffers<cr>", "Buffers" },
  { "n", "<L>ff", Util.telescope("files"), "Find Files (root dir)" },
  { "n", "<L>fF", Util.telescope("files", { cwd = false }), "Find Files (cwd)" },
  { "n", "<L>fr", "<cmd>Telescope oldfiles<cr>", "Recent" },
  { "n", "<L>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), "Recent (cwd)" },
  -- git
  { "n", "<L>gc", "<cmd>Telescope git_commits<CR>", "commits" },
  { "n", "<L>gs", "<cmd>Telescope git_status<CR>", "status" },
  -- search
  { "n", '<L>s"', "<cmd>Telescope registers<cr>", "Registers" },
  { "n", "<L>sa", "<cmd>Telescope autocommands<cr>", "Auto Commands" },
  { "n", "<L>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer" },
  { "n", "<L>sc", "<cmd>Telescope command_history<cr>", "Command History" },
  { "n", "<L>sC", "<cmd>Telescope commands<cr>", "Commands" },
  { "n", "<L>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", "Document diagnostics" },
  { "n", "<L>sD", "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics" },
  { "n", "<L>sg", Util.telescope("live_grep"), "Grep (root dir)" },
  { "n", "<L>sG", Util.telescope("live_grep", { cwd = false }), "Grep (cwd)" },
  { "n", "<L>sh", "<cmd>Telescope help_tags<cr>", "Help Pages" },
  { "n", "<L>sH", "<cmd>Telescope highlights<cr>", "Search Highlight Groups" },
  { "n", "<L>sk", "<cmd>Telescope keymaps<cr>", "Key Maps" },
  { "n", "<L>sM", "<cmd>Telescope man_pages<cr>", "Man Pages" },
  { "n", "<L>sm", "<cmd>Telescope marks<cr>", "Jump to Mark" },
  { "n", "<L>so", "<cmd>Telescope vim_options<cr>", "Options" },
  { "n", "<L>sR", "<cmd>Telescope resume<cr>", "Resume" },
  { "n", "<L>sw", Util.telescope("grep_string", { word_match = "-w" }), "Word (root dir)" },
  { "n", "<L>sW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), "Word (cwd)" },
  { "v", "<L>sw", Util.telescope("grep_string"), "Selection (root dir)" },
  { "v", "<L>sW", Util.telescope("grep_string", { cwd = false }), "Selection (cwd)" },
  { "n", "<L>uC", Util.telescope("colorscheme", { enable_preview = true }), "Colorscheme with preview" },
  { "n", "<L>ss",
    Util.telescope("lsp_document_symbols", {
      symbols = {
        "Class",
        "Function",
        "Method",
        "Constructor",
        "Interface",
        "Module",
        "Struct",
        "Trait",
        "Field",
        "Property",
      },
    }),
    "Goto Symbol",
  },
  { "n", "<L>sS",
    Util.telescope("lsp_dynamic_workspace_symbols", {
      symbols = {
        "Class",
        "Function",
        "Method",
        "Constructor",
        "Interface",
        "Module",
        "Struct",
        "Trait",
        "Field",
        "Property",
      },
    }),
    "Goto Symbol (Workspace)",
  },
}

M.telescope_mappings = Keymaps.parse {
  {"i", "<C-t>", F("trouble.providers.telescope").open_with_trouble()},
  {"i", "<A-t>", F("trouble.providers.telescope").open_selected_with_trouble()},
  {"i", "<A-i>", function()
    local action_state = require("telescope.actions.state")
    local line = action_state.get_current_line()
    Util.telescope("find_files", { no_ignore = true, default_text = line })()
  end },
  {"i", "<A-h>", function()
    local action_state = require("telescope.actions.state")
    local line = action_state.get_current_line()
    Util.telescope("find_files", { hidden = true, default_text = line })()
  end },
  {"i", "<C-↓>", F("telescope.actions").cycle_history_next()},
  {"i", "<C-↑>", F("telescope.actions").cycle_history_prev()},
  {"i", "<C-f>", F("telescope.actions").preview_scrolling_down()},
  {"i", "<C-b>", F("telescope.actions").preview_scrolling_up()},
  {"i", "<C-s>", F("flash").telescope()},
  {"n", "s", F("flash").telescope()},
  {"n", "q", F("telescope.actions").close()},
}

function M.flash_in_telescope(buf)
  local act = W("telescope.actions")
  return Keymaps.parse({
    {"n", "j", act.move_selection_next(buf)},
    {"n", "k", act.move_selection_previous(buf)},
    {"n", "↓", act.move_selection_next(buf)},
    {"n", "↑", act.move_selection_previous(buf)},
    {"n", "↲", act.select_default(buf)},
  }):reshape({"id"}, {1, "rhs"})
end

M.plugins["LuaSnip"] = Keymaps.parse {
  {"i",  "<C-e>", layered(W("luasnip").expand()) },
  {"is", "<C-k>", layered(W("luasnip").jump(1)) },
  {"is", "<C-j>", layered(W("luasnip").jump(-1)) },
  {"is", "<C-y>", layered(W("luasnip").change_choice(1)) },
}

M.plugins["neoscroll.nvim"] = Keymaps.parse ({
  {"nv", "<C-u>", {'scroll', {'-vim.wo.scroll', 'true', '30'}}, "Smooth up"},
  {"nv", "<C-d>", {'scroll', {' vim.wo.scroll', 'true', '30'}}, "Smooth down"}
}, {name = "Scroll", manual = true})

M.plugins["vim-illuminate"] = Keymaps.parse {
  {"n", "[[", W("illuminate").goto_next_reference(true), "Next Reference"},
  {"n", "]]", W("illuminate").goto_prev_reference(true), "Prev Reference"},
}

M.plugins["mini.bufremove"] = Keymaps.parse {
  {"n", "<L>bd", W("mini.bufremove").delete(0, false), "Delete Buffer" },
  {"n", "<L>bD", W("mini.bufremove").delete(0, true), "Delete Buffer (Force)" },
}

M.plugins["Comment.nvim"] = Keymaps.parse ({
  {"n", "gcc", "toggler.line",   "Toggle current Line" },
  {"n", "gbc", "toggler.block",  "Toggle current Block" },
  {"nv","gc",  "opleader.line",  "Toggle Linewise Operator" },
  {"nv","gb",  "opleader.block", "Toggle Blockwise Operator" },
  {"n", "gcO", "extra.above",    "Add on the line above" },
  {"n", "gco", "extra.below",    "Add on the line below" },
  {"n", "gcA", "extra.eol",      "Add at the end of line" },
}, {name = "Comment", manual = true})

M.plugins["mini.ai"] = Keymaps.parse({
  {"xo", "a",  {"mappings", "around"},      "Around textobject"},
  {"xo", "i",  {"mappings", "inside"},      "Inside textobject"},
  {"xo", "an", {"mappings", "around_next"}, "Around next textobject"},
  {"xo", "in", {"mappings", "inside_next"}, "Inside next textobject"},
  {"xo", "al", {"mappings", "around_last"}, "Around last textobject"},
  {"xo", "il", {"mappings", "inside_last"}, "Inside last textobject"},
  {"nxo","g[", {"mappings", "goto_left"},   "Move to left \"around\""},
  {"nxo","g]", {"mappings", "goto_right"},  "Move to right \"around\""},
  -- default opts: use_nvim_treesitter = true; change to false for "nvim-treesitter-textobjects"
  {"xo", "ao", {"treesitter", {"@block.outer", "@conditional.outer", "@loop.outer"}}, "Block, conditional, loop"},
  {"xo", "io", {"treesitter", {"@block.inner", "@conditional.inner", "@loop.inner"}}, "Block, conditional, loop"},
  {"xo", "af", {"treesitter", "@function.outer"}, "Function"},
  {"xo", "if", {"treesitter", "@function.inner"}, "Function"},
  {"xo", "ac", {"treesitter", "@class.outer"}, "Class"},
  {"xo", "ic", {"treesitter", "@class.inner"}, "Class"},
  --{"xo", {"at", "it"}, {"table", "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$"}, "Tag"},
}, {manual = true})

function M.get_builtin_textobjects(dir)
  local balanced = {"\"", "'", "`", "(", "<", "[", "{"}
  local balanced_with_spaces = {")", ">", "]", "}"}
  local res = {
    [" "] = "Whitespace",
    ["?"] = "User Prompt",
    ["_"] = "Underscore",
    ["a"] = "Argument",
    ["t"] = "Tag",
    ["b"] = "Balanced ), ], }",
    ["q"] = "Quote `, \", '",
  }
  for _, obj in ipairs(balanced) do
    res[obj] = "Balanced "..obj
  end
  for _, obj in ipairs(balanced_with_spaces) do
    res[obj] = "Balanced "..obj..(dir == "inside" and " including white-space" or "")
  end
  return res
end

function M.cmp_mappings(cmp)
  return Keymaps.parse({
    {"i", "<C-n>", cmp.mapping.complete_or_select("next", { behavior = cmp.SelectBehavior.Select })},
    {"i", "<C-p>", cmp.mapping.complete_or_select("prev", { behavior = cmp.SelectBehavior.Select })},
    {"i", "<C-b>", cmp.mapping.scroll_docs(-4)},
    {"i", "<C-f>", cmp.mapping.scroll_docs(4)},
    {"i", "<Tab>", cmp.mapping.confirm({ select = true }), "Accept selected item | select first"},
    {"i", "<S-Tab>", cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, })},
  }):reshape({"lhs", "mode"}, {1, "rhs"})
end

function M.attach_gitsigns(buf)
  local gs = W("gitsigns")
  Keymaps.parse({
    {"n", "]h", gs.next_hunk(), "Next Hunk"},
    {"n", "[h", gs.prev_hunk(), "Prev Hunk"},
    {"nv", "<L>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk"},
    {"nv", "<L>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk"},
    {"n", "<L>ghS", gs.stage_buffer(), "Stage Buffer"},
    {"n", "<L>ghu", gs.undo_stage_hunk(), "Undo Stage Hunk"},
    {"n", "<L>ghR", gs.reset_buffer(), "Reset Buffer"},
    {"n", "<L>ghp", gs.preview_hunk(), "Preview Hunk"},
    {"n", "<L>ghb", gs.blame_line({ full = true }), "Blame Line"},
    {"n", "<L>ghd", gs.diffthis(), "Diff This"},
    {"n", "<L>ghD", gs.diffthis("~"), "Diff This ~"},
    {"ox", "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk"},
  }):set(buf)
end

-- lsp mappings for any server
M.lsp.any = Keymaps.parse ({
  {"n", "K",  vim.lsp.buf.hover, "Hover"},
  {"n", "gK", vim.lsp.buf.signature_help, "Signature Help", has = "signatureHelp"},
  {"n", "gD", vim.lsp.buf.declaration, "Goto Declaration", has = "declaration"},
  {"n", "gd", W("telescope.builtin").lsp_definitions({reuse_win = true}), "Goto Definition", has = "definition"},
  {"n", "gr", W("telescope.builtin").lsp_references(), "References"},
  {"n", "gI", W("telescope.builtin").lsp_implementations({reuse_win = true}), "Goto Implementation"},
  {"n", "gy", W("telescope.builtin").lsp_type_definitions({reuse_win = true}), "Goto T[y]pe Definition"},
  {"nv", "<L>ca", vim.lsp.buf.code_action, "Code Action", has = "codeAction"},
  {"n",  "<L>cr", vim.lsp.buf.rename, "Rename"},
}, {name = "LSP"})

M.lsp.clangd = Keymaps.parse {
  {"n", "<L>cR", cmd("ClangdSwitchSourceHeader"), "Switch Source/Header (C/C++)"},
}

return M
