
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
  local group = vim.api.nvim_create_augroup("HybridLineNumber", { clear = true })
  M.set_relativenumber(is_enabled)

  if not is_enabled then
    return
  end

  local autocmd = function(events, callback)
    vim.api.nvim_create_autocmd(events, {pattern = "*", group = group, callback = callback})
  end

  autocmd({"WinEnter", "FocusGained", "InsertLeave"}, function() M.set_relativenumber(true) end)
  autocmd({"CmdlineLeave"}, function() M.set_relativenumber(true) end)

  autocmd({"WinLeave", "FocusLost", "InsertEnter"}, function() M.set_relativenumber(false) end)
  autocmd({"CmdlineEnter"}, function() M.set_relativenumber(false) end)
end

function M.update_scroll(winid)
  winid = winid or vim.api.nvim_get_current_win()
  local height = vim.fn.winheight(winid)
  vim.wo.scrolloff = math.floor(M.scrolloff_factor * height + 0.5)
  vim.wo.scroll = math.floor(M.scroll_factor * height + 0.5)
end

function M.watch_win_size()
  local group = vim.api.nvim_create_augroup("WinScrollWatcher", { clear = true })
  vim.api.nvim_create_autocmd({"WinEnter", "WinNew", "WinResized"}, {pattern = "*", group = group, callback = function()
    M.update_scroll()
  end})
end

return M
