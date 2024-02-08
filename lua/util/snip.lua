local keys = require "which-key.keys"

local file = {}
local M = {}

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

function M.trace_messages()
  local f,err = io.open("C:/Users/sergk/nvim_log.txt", "a")
  if not f then
    print("IO Error: ", err)
    return
  end
  file = f
  file:write("Tracing started\n")
  local ns = vim.api.nvim_create_namespace('message_listener')
  vim.ui_attach(ns, {ext_messages = true}, function(event, ...)
    file:write(event, "\n")
  end)
end

function M.stop_tracing()
  file:close()
end

-- vim.print(require("config.keymaps").plugins["flash.nvim"]:reshape({"id", "rhs", "mode"}, {1}))
return M
