
local M = {}
M.hybridnumber = false
M.scrolloff_factor = 0.09
M.scroll_factor = 0.25

function M.set_relativenumber(is_enabled)
  is_enabled = is_enabled and vim.o.number
  if vim.o.relativenumber == is_enabled then
    return
  end
  vim.o.relativenumber = is_enabled
  vim.cmd.redraw()
end

-- Show relative line number when in command mode and absolute line number in edit mode
function M.set_hybridnumber(is_enabled)
  M.hybridnumber = is_enabled
  local group = require("core.aucmd").add_group("HybridLineNumber")
  M.set_relativenumber(is_enabled)

  if not is_enabled then
    return
  end

  local buf_enter_events = {"WinEnter", "FocusGained", "InsertLeave", "CmdlineLeave"}
  local buf_leave_events = {"WinLeave", "FocusLost",   "InsertEnter", "CmdlineEnter"}
  group:add_cmd(buf_enter_events, "*", function() M.set_relativenumber(true) end)
  group:add_cmd(buf_leave_events, "*", function() M.set_relativenumber(false) end)
end

function M.update_scroll(winid)
  winid = winid or vim.api.nvim_get_current_win()
  local height = vim.fn.winheight(winid)
  vim.wo.scrolloff = math.floor(M.scrolloff_factor * height + 0.5)
  vim.wo.scroll = math.floor(M.scroll_factor * height + 0.5)
end

require("core.aucmd").add_cmd({"WinEnter", "WinNew", "WinResized"}, "*",
  function() M.update_scroll() end, "Update scrolloff according to scrolloff_factor")

return M
