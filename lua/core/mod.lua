local M = {}

function M.current_file_path(level)
  return debug.getinfo(level or 1, "S").source:sub(2, -1)
end

function M.split_path(file)
  local path, mod = file:match("^(.*)/lua/(.*)$")
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
  return M.reload(mod)
end

return M
