
local M = {}

function M.set_relativenumber(is_enabled)
  is_enabled = is_enabled and vim.o.number
  if vim.o.relativenumber == is_enabled then
    return
  end
  vim.o.relativenumber = is_enabled
  vim.cmd.redraw()
end

function M.set_hybridnumber(is_enabled)
  M.hybridnumber = is_enabled
  -- Show relative line number when in command mode and absolute line number in edit mode
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

return M
