local M = {}

function M.current_file_path(level)
  return debug.getinfo(level or 1, "S").source:sub(2, -1)
end

M.config_dir = M.current_file_path():match("^(.*)/lua/")

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

function M.require(opts)
  local module = opts[1]
  if opts.reload then
    M.unload(module)
  end
  if opts.optional then
    local mod = package.loaded[module]
    if mod then
      return mod
    end
    if M.find_preloader(module) == nil then
      return
    end
  end
  if opts.lazy then
    return require("lazy.core.util").lazy_require(module)
  end
  return require(module)
end

function M.reload_config(dir)
  dir = dir or M.config_dir.."/lua/"
  require("lazy.core.util").walkmods(dir, M.unload)
  require("lazy.core.plugin").load()
  local plugins = {}
  for _, plugin in pairs(require("lazy.core.config").plugins) do
    if plugin.deactivate then
      table.insert(plugins, plugin)
    end
  end
  require("lazy").reload({plugins = plugins})
end

function M.reload_plugin(name)
  local plugin = require("lazy.core.config").plugins[name]
  require("lazy.core.loader").reload(plugin)
end

return M
