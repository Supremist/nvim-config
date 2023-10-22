local map = function(mode, from, to)
  vim.api.nvim_set_keymap(mode, from, to, {noremap = true})
end

map("n", "j", "gj")
map("n", "k", "gk")
map("v", "j", "gj")
map("v", "k", "gk")

