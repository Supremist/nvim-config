
local function enable_relativenumber()
  vim.o.relativenumber = vim.o.number
end

local function disable_relativenumber()
  vim.o.relativenumber = false
end

-- Show relative line number when in command mode and absolute line number in edit mode
local group = vim.api.nvim_create_augroup("LineNumber", { clear = true })
vim.api.nvim_create_autocmd({"WinEnter", "FocusGained", "InsertLeave"}, {
  pattern = "*",
  callback = enable_relativenumber,
  group = group,
})
vim.api.nvim_create_autocmd({"WinLeave", "FocusLost", "InsertEnter"}, {
  pattern = "*",
  callback = disable_relativenumber,
  group = group,
})

vim.api.nvim_create_autocmd({"CmdlineLeave"}, {
  pattern = "*",
  callback = function()
    enable_relativenumber()
    vim.cmd.redraw()
  end,
  group = group,
})
vim.api.nvim_create_autocmd({"CmdlineEnter"}, {
  pattern = "*",
  callback = function()
    disable_relativenumber()
    vim.cmd.redraw()
  end,
  group = group,
})

-- Use Ctrl-L to toggle the line number display.
--vim.api.nvim_set_keymap("", "<C-L>",
--  ':lua toggleln()<CR>:lua require"gitsigns".toggle_signs()<CR>',
--  { noremap = true, silent = true }
--)
