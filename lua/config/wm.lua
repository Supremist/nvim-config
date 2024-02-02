-- vim.cmd.cnoreabbrev("help", "vert help")

local wm_group = require("core.aucmd").add_group("WindowManagementGroup")

wm_group:add_cmd("BufWinEnter", "*.txt", function(ev)
  if vim.bo[ev.buf].filetype ~= "help" then
    return
  end
  vim.cmd.wincmd("L")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(win, 80)
end, "Update help window geometry")
