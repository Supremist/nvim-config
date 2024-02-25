local Path = require("plenary.path")
local scandir = require("plenary.scandir")
local aucmd = require("core.aucmd")

local M = {
  dir = Path:new(vim.fn.stdpath("data"), "sessions"),
  name = nil, -- current session name, if any
  au = aucmd.add_group("Session"),
}

function M.get_name(session_filepath)
  return tostring(Path:new(session_filepath):make_relative(tostring(M.dir)))
end

function M.init()
  aucmd.on_vim_enter(function()
    local recent = M.list_all_recent()
    if #recent > 0 then
      M.load(recent[1])
    end
  end, "Autoload session")

  M.au:add_cmd("VimLeavePre", "*", function()
    if M.name then
      M.save()
    end
  end, "Autosave session")

  M.au:add_cmd("StdinReadPre", "*", function()
    vim.g.started_with_stdin = true
  end, "Check if started with stdin", {once = true})
end

function M.load(name, opts)
  local loader = function()
    local swapfile = vim.o.swapfile
    vim.o.swapfile = false
    vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPre' })
    vim.api.nvim_command('silent source ' .. tostring(M.dir:joinpath(name)))
    --vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPost' }) -- done by vimscript in session file
    M.name = M.get_name(vim.v.this_session)
    vim.o.swapfile = swapfile
  end
  if opts and opts.merge then
    loader()
  else
    M.clean(opts and opts.force or false, loader)
  end
end

function M.save(name)
  if not M.dir:is_dir() then
    M.dir:mkdir()
  end
  -- Remove all non-file and utility buffers because they cannot be saved.
  -- for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
  --   if vim.api.nvim_buf_is_valid(buffer) and not M.is_restorable(buffer) then
  --     vim.api.nvim_buf_delete(buffer, { force = true })
  --   end
  -- end

  -- Clear all passed arguments to avoid re-executing them.
  if vim.fn.argc() > 0 then
    vim.api.nvim_command('%argdel')
  end
  -- TODO backup the old session before rewrite
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })
  vim.api.nvim_command('mksession! ' .. tostring(M.dir:joinpath(name or M.name)))
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePost' })
end

function M.detach()
  M.name = nil
  vim.v.this_session = ""
end

function M.has_changes()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buffer, 'modified') then
      return true
    end
  end
  return false
end

-- TODO Maybe after clean or detach ask user for next session name. And decide to create new or load existing
function M.clean(force, callback)
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
    M.name = nil
    -- Delete all buffers first except the current one to avoid entering buffers scheduled for deletion.
    local current_buffer = vim.api.nvim_get_current_buf()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buffer) and buffer ~= current_buffer then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
    vim.api.nvim_buf_delete(current_buffer, { force = true })
    if callback then
      callback()
    end
  end)
end

function M.list_all_recent()
  local sessions = {}
  for _, filepath in ipairs(scandir.scan_dir(tostring(M.dir))) do
    table.insert(sessions, { timestamp = vim.fn.getftime(filepath), name = M.get_name(filepath)})
  end
  table.sort(sessions, function(a, b) return a.timestamp > b.timestamp end)
  for i=1,#sessions do
    sessions[i] = sessions[i].name
  end
  return sessions
end

-- function M.choose()
--   -- If we are in a session already, don't list the current session.
--   if utils.is_session then
--     local cwd = vim.loop.cwd()
--     local is_current_session = cwd and config.dir_to_session_filename(cwd).filename == sessions[1].filename
--     if is_current_session then
--       table.remove(sessions, 1)
--     end
--   end
--
--   -- If no sessions to list, send a notification.
--   if #sessions == 0 then
--     vim.notify('The only available session is your current session. Nothing to select from.', vim.log.levels.INFO)
--   end
--
--   return sessions
-- end

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

return M
