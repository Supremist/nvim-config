local Mod = require "core.mod"
local KeymapsConf = require "config.keymaps"
local M = {}

M.config_dir = Mod.split_path(Mod.current_file_path())

local function is_reloadable(plugin)
  return plugin.deactivate or plugin.reloadable
end

function M.load_plugins()
  local lazy = package.loaded["lazy"]
  if not lazy then
    require("config.lazy")
    return
  end

  -- Only reloading from this point
  require("lazy.core.plugin").load()
  local Config = require "lazy.core.config"
  local Handler = require "lazy.core.handler"
  local reloadable = {}
  for _, plugin in pairs(Config.plugins) do
    if is_reloadable(plugin) then
      table.insert(reloadable, plugin)
    elseif plugin._.loaded then
      local mapping = KeymapsConf.plugins[plugin.name]
      if mapping then mapping:set() end
    else
      Handler.enable(plugin)
    end
  end
  lazy.reload({plugins = reloadable})
end

function M.load()
  require("config.options")
  require("config.wm")
  KeymapsConf.global:set()
  M.load_plugins()
  require("core.session").init()
end

function M.unload()
  local Config = require "lazy.core.config"
  local Handler = require "lazy.core.handler"
  Mod.loader.unhook_all()
  require("config.keymaps").global:del()

  for _, plugin in pairs(Config.plugins) do
    Handler.disable(plugin)
    plugin._.cache = nil
    local mapping = KeymapsConf.plugins[plugin.name]
    if mapping then mapping:del() end
  end
  require("lazy.core.util").walkmods(M.config_dir.."/lua/", Mod.unload)
end

function M.reload()
  M.unload()
  require("core.main").load()
end

function M.on_lazy_spec_load()
  Mod.install_patcher()
end

return M
