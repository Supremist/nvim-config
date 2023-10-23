local map = function(mode, from, to)
  vim.api.nvim_set_keymap(mode, from, to, {noremap = true})
end

--move up/down one *wrapped* line
map("n", "j", "gj")
map("n", "k", "gk")
map("v", "j", "gj")
map("v", "k", "gk")

--<C-BS> is <C-H> because of terminal app
--make <C-BS> delete previous word, and <C-W> can be consistent with normal mode
map("i", "<C-H>", "<C-w>")
map("i", "<C-w>", "<ESC><C-w>")

