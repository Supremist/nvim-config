local Path = require("plenary.path")

local M = {
  dir = Path:new(vim.fn.stdpath("data"), "sessions")
}

function M.load(name)
  local swapfile = vim.o.swapfile
  vim.o.swapfile = false
  -- utils.is_session = true
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPre' })
  vim.api.nvim_command('silent source ' .. tostring(M.dir:joinpath(name)))
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPost' })
  vim.o.swapfile = swapfile
end

function M.save(name)
  if not M.dir:is_dir() then
    M.dir:mkdir()
  end
  -- Remove all non-file and utility buffers because they cannot be saved.
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) and not M.is_restorable(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end

  -- Clear all passed arguments to avoid re-executing them.
  if vim.fn.argc() > 0 then
    vim.api.nvim_command('%argdel')
  end

  -- utils.is_session = true
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })
  vim.api.nvim_command('mksession! ' .. tostring(M.dir:joinpath(name)))
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePost' })
end

function M.has_changes()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buffer, 'modified') then
      return true
    end
  end
  return false
end

function M.clean(force)
  if not force then
    -- Ask to save files in current session before closing them.
    if M.has_changes() then
      local choice = vim.fn.confirm('The files in the current session have changed. Save changes?', '&Yes\n&No\n&Cancel')
      if choice == 3 or choice == 0 then
        return -- Cancel.
      elseif choice == 1 then
        vim.api.nvim_command('silent wall')
      end
    end
  end
  
  -- Schedule buffers cleanup to avoid callback issues
  vim.schedule(function()
    -- Delete all buffers first except the current one to avoid entering buffers scheduled for deletion.
    local current_buffer = vim.api.nvim_get_current_buf()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buffer) and buffer ~= current_buffer then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
    vim.api.nvim_buf_delete(current_buffer, { force = true })
  end)
end

---@param buffer number: buffer ID.
---@return boolean: `true` if this buffer could be restored later on loading.
function M.is_restorable(buffer)
  if #vim.api.nvim_buf_get_option(buffer, 'bufhidden') ~= 0 then
    return false
  end

  local buftype = vim.api.nvim_buf_get_option(buffer, 'buftype')
  if #buftype == 0 then
    -- Normal buffer, check if it listed.
    if not vim.api.nvim_buf_get_option(buffer, 'buflisted') then
      return false
    end
    -- Check if it has a filename.
    if #vim.api.nvim_buf_get_name(buffer) == 0 then
      return false
    end
  elseif buftype ~= 'terminal' and buftype ~= 'help' then
    -- Buffers other then normal, terminal and help are impossible to restore.
    return false
  end

  return true
end

-- vim.print(M.dir)

return M
