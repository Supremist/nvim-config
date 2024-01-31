local keys = require "which-key.keys"

local function get_upvalue(fn, name)
  local i = 1
  while true do
    local n, v = debug.getupvalue(fn, i)
   if not n then
      break
    end
    if n == name then
      return v
    end
    i = i + 1
  end
end

vim.print(require("config.keymaps").plugins["flash.nvim"]:reshape({"id", "rhs", "mode"}, {1}))
