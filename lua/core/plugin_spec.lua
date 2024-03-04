local M = {
  _spec_loaded = {},
}


-- Fill second apperance of plugin spec.
-- First apperance is in the "installed.lua" file
-- Second apperance may be in separate file dedicated for each plugin.
-- It is filled with keys from "config.keymaps", changed default for "optional"
function M.spec(plugins)
  local plugin_keymaps = require("config.keymaps").plugins
  if type(plugins[1]) == "string" then
    plugins = { plugins }
  end
  for _, plugin in pairs(plugins) do
    local full_name = plugin[1]
    local name_parts = vim.split(full_name, "/")
    local name = name_parts[#name_parts]
    local keys = plugin_keymaps[full_name] or plugin_keymaps[name]
    if keys then
      plugin.keys = require("core.tbl").array_append(plugin.keys or {}, keys:to_lazy())
    end
    if plugin.optional == nil then
      plugin.optional = true
    end
    M._spec_loaded[name] = true
  end
  return plugins
end

-- If plugin spec has no second apperance, we need to load it's keymaps as new spec
function M.load_missing_keymaps()
  local spec = {}
  for name, val in pairs(require("config.keymaps").plugins) do
    if not M._spec_loaded[name] then
      table.insert(spec, {name, optional = true, keys = val:to_lazy()})
    end
  end
  return spec
end

return M

