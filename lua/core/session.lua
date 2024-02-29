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
  if not vim.g.Reloading then
    M.au:add_cmd("StdinReadPre", "*", function()
      vim.g.started_with_stdin = true
    end, "Check if started with stdin", {once = true})

    aucmd.on_vim_enter(function()
      -- Do not autoload session if has any args
      if vim.fn.argc() > 0 or vim.g.started_with_stdin then
        return
      end
      -- TODO Do not autoload if vim crashed last time
      local recent = M.list_all_recent()
      if #recent > 0 then
        M.load(recent[1])
      end
    end, "Autoload session")
  end

  M.au:add_cmd("VimLeavePre", "*", M.autosave, "Autosave session")

  vim.api.nvim_create_user_command("Ses",
    function(opts)
      local args = opts.fargs
      local cmd_name = args[1] or "load"
      local cmd = M[cmd_name]
      table.remove(args, 1)
      table.insert(args, opts.bang)
      if cmd then
        local ret = cmd(unpack(args))
        if ret ~= nil then
          vim.print(cmd_name, ": ", ret)
        end
      else
        vim.notify("Session command "..cmd.." not found", vim.log.levels.ERROR)
      end
    end, {
      nargs = "*",
      complete = function(ArgLead, CmdLine, CursorPos)
        local cmds = {"new", "load", "save", "clear", "detach", "merge"}
        local args = vim.split(CmdLine, "%s+")
        local n = #args - 2
        if n == 0 then
          return vim.tbl_filter(function(val)
            return vim.startswith(val, args[2])
          end, cmds)
        end

        if args[2] == "clear" or args[2] == "detach" then
          return
        end

        if n == 1 then
          return vim.tbl_filter(function(val)
            return vim.startswith(val, args[3])
          end, M.list_all_recent())
        end

        return {}
      end}
  )
end

function M.choose(on_select, force)
  if not M.save_if_changed(force) then
    return
  end
  force = true

  local sessions = M.list_all_recent()
  if M.name then
    -- Do not list current session
    local index = require("core.tbl").findKey(sessions, M.name)
    if index then
      table.remove(sessions, index)
    end
  end
  if #sessions == 0 then
    vim.notify("No sessions to select from", vim.log.levels.INFO)
    return
  end
  vim.ui.select(sessions, {
    prompt = "Load Session",
    -- format_item = function(item) return utils.shorten_path(item.dir) end,
  }, function(item)
    if item then
      on_select(item, force)
    end
  end)
end

function M.source(name)
  local swapfile = vim.o.swapfile
  vim.o.swapfile = false
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPre' })
  vim.api.nvim_command('silent source ' .. tostring(M.dir:joinpath(name)))
  --vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPost' }) -- done by vimscript in session file
  M.name = M.get_name(vim.v.this_session)
  vim.o.swapfile = swapfile
end

function M.merge(name, force)
  if name then
    M.source(name)
  else
    M.choose(M.source, force)
  end
end

function M.load(name, force)
  if name then
    M.clear(force, function() M.source(name) end)
  else
    M.choose(M.load, force)
  end
end

function M.new(name, force)
  if name then
    M.save(name, force)
    return
  end

  name = ""
  vim.ui.input({prompt = "Enter session name: ", default = name}, function(input)
    if input then
      M.save(input, force)
    end
  end)
end

function M.save(name, force)
  name = name or M.name
  if not name then
    M.new()
    return
  end
  if M.name ~= name and not force and M.dir:joinpath(name):exists() then
    local choice = vim.fn.confirm("Session file \""..name.."\" already exists. Overwrite?", "&Yes\n&No\n&Cancel")
    if choice == 1 then
      -- fallthrough
    elseif choice == 2 then
      M.new(name)
      return
    else
      return
    end
  end

  M.name = name

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
  vim.api.nvim_command('mksession! ' .. tostring(M.dir:joinpath(M.name)))
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePost' })
end

function M.autosave()
  if M.name then
    M.save()
  end
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

function M.save_if_changed(skip_save)
  if not skip_save and M.has_changes() then
    -- Ask to save files in current session before closing them.
    local choice = vim.fn.confirm('The files in the current session have changed. Save changes?', '&Yes\n&No\n&Cancel')
    if choice == 3 or choice == 0 then
      return false -- Cancel.
    elseif choice == 1 then
      vim.api.nvim_command('silent wall')
    end
  end
  return true
end

-- TODO Maybe after clear or detach ask user for next session name. And decide to create new or load existing
function M.clear(force, callback)
  if not M.save_if_changed(force) then
    return
  end
  -- Save sesssion if there is one
  M.autosave()

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

M.init()

return M
