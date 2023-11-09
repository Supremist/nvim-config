local map = function(mode, from, to)
  vim.keymap.set(mode, from, to, {noremap = true})
end

--move up/down one *wrapped* line
map({"n", "v"}, "j", "gj")
map({"n", "v"}, "k", "gk")

--<C-BS> is <C-H> because of terminal app
--make <C-BS> delete previous word, and <C-W> can be consistent with normal mode
map("i", "<C-H>", "<C-w>")
map("i", "<C-w>", "<ESC><C-w>")


-- New keymap structure
-- [1]: (StringArray) mode (see :h mode())
-- [2]: (string) lhs (see :h key-notation; also <L> is eqivalent to <Leader>, <LL> is eqivalent to <LocalLeader>)
-- [3]: (string|fun()) rhs
-- [4]: (string) descriptions (optional)
-- ft: (StringArray) filetype for buffer-local keymaps
-- and all other arguments options for vim.keymap.set (see :map-arguments)
-- where StringArray is (string|string[]) but if string contains "," then it will be splitted
