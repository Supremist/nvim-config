local M = {}

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

return M
