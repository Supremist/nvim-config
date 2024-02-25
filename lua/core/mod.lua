local M = {}
M.loader = {original = {}}
M.patches = {}
M._patcher_installed = false

function M.current_file_path(level)
  return debug.getinfo(level or 1, "S").source:sub(2, -1)
end

function M.split_path(file)
  local path, mod = file:match("^(.*)/lua/(.*)$")
  if not mod then
    return
  end
  mod = mod:gsub("/init%.lua$", ""):gsub("%.lua$", ""):gsub("/", ".")
  return path, mod
end

function M.unload(module)
  package.loaded[module] = nil
  package.preload[module] = nil
  local luacache = (_G.__luacache or {}).cache
  if luacache then
    luacache[module] = nil
  end
end

function M.find_preloader(module)
  if package.preload[module] then
    return package.preload[module]
  end
  for _, searcher in ipairs(package.searchers or package.loaders) do
    local loader = searcher(module)
    if type(loader) == "function" then
      package.preload[module] = loader
      return loader
    end
  end
end

function M.loader.get()
  return package.searchers or package.loaders
end

function M.loader.hook(priority, hook)
  local loaders = M.loader.get()
  local prev = loaders[priority]
  if not M.loader.original[priority] then
    M.loader.original[priority] = prev
  end
  loaders[priority] = function(modname)
    local ret = prev(modname)
    if type(ret) == "function" then
      return function(name)
        local mod = ret(name)
        local hook_ret = hook(name, mod)
        return hook_ret == nil and mod or hook_ret
      end
    end
    return ret
  end
end

function M.loader.unhook_all()
  local loaders = M.loader.get()
  for i, loader in ipairs(M.loader.original) do
    loaders[i] = loader
  end
  M.loader.original = {}
end

function M.patch(mod, patch)
  patch = patch or {}
  local res = M.patches[mod]
  if res then
    return require("core.tbl").deep_update(res, patch)
  end
  M.patches[mod] = patch
  return patch
end

function M.install_patcher()
  if M._patcher_installed then
    return
  end
  local tbl = require "core.tbl"
  local function patcher(modname, mod)
    local patch = M.patches[modname]
    if patch then
      return tbl.deep_update(mod, patch)
    end
    return mod
  end
  M.loader.hook(2, patcher)
  M.loader.hook(3, patcher)
  M._patcher_installed = true
end

function M.optional(module, on_err)
  local mod = package.loaded[module]
  if mod then
    return mod
  end
  if on_err then
    on_err()
  end
  return require("core.tbl").dummy
end

function M.reload(module)
  M.unload(module)
  return require(module)
end

function M.reload_file(file)
  local path, mod = M.split_path(file)
  if mod then
    return M.reload(mod)
  end
  return dofile(file)
end

return M
