local M = {group = {}}

-- static groups crated on config load
M._static_groups = {
  Default = true, -- same as vim.api.nvim_create_autocmd("Default", {clear = true})
  -- This group is static, but not cleared. It is created when config loads but NOT cleared on reload.
  Permanent = false,
  FileTypeGroup = true,
  PluginLoad = true,
}

local Group = {}

function Group:add_cmd(events, pattern_or_buf, callback, desc, opts)
  opts = opts or {}
  if type(pattern_or_buf) == "number" then
    opts.buffer = pattern_or_buf
  else
    opts.pattern = pattern_or_buf
  end
  if type(callback) == "string" and callback:sub(1, 1) == ":" then
    opts.command = callback:sub(2, -1)
  else
    opts.callback = callback
  end
  opts.desc = desc
  opts.group = self.id
  return vim.api.nvim_create_autocmd(events, opts)
end

function M.add_group(name, opts)
  local group = setmetatable({}, {__index = Group})
  group.id = vim.api.nvim_create_augroup(name, opts or {})
  M.group[name] = group
  return group
end

function M.get_group(name, opts)
  opts = opts or {}
  opts.clear = false
  return M.add_group(name, opts)
end

function M.add_cmd(events, pattern_or_buf, callback, desc, opts)
  return M.group.Default:add_cmd(events, pattern_or_buf, callback, desc, opts)
end

function M.once(events, pattern_or_buf, callback, desc, opts)
  opts = opts or {}
  opts.once = true
  return M.add_cmd(events, pattern_or_buf, callback, desc, opts)
end

function M.filetype(pattern, callback, desc, opts)
  return M.gruop.FileTypeGroup.add_cmd("FileType", pattern, callback, desc, opts)
end

function M.on_plugin_load(name, callback, desc, opts)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    callback(name)
  else
    return M.group.PluginLoad:add_cmd("User", "LazyLoad", callback, desc, opts)
  end
end

for name, clear in pairs(M._static_groups) do
  M.add_group(name, {clear = clear})
end

return M
