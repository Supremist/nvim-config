-- This file is loaded by lazy.nvim. 
-- It extracts keymaps for plugins from "config.keymaps" and converts it to LazyKeySpec format
local spec = {}

for name, val in pairs(require("config.keymaps").plugins) do
  table.insert(spec, {name, keys = val:to_lazy()})
end
return spec

