local function get_options(keymap)
  local rhs = keymap.rhs
  local opts = {
    noremap = keymap.noremap or not keymap.remap, -- Defaults to true
    nowait = keymap.nowait or keymap.wait == false, -- Defaults to false
    silent = keymap.silent ~= nil and keymap.silent or true, -- Defaults to true
  }
  for _, opt_name in ipairs({"desc", "replace_keycodes", "silent", "script", "unique", "expr"}) do
    opts[opt_name] = keymap[opt_name]
  end
  if type(rhs) == "function" then
    opts.callback = rhs
    rhs = ""
  end
  return rhs, opts
end

local M = {}
local ft_augroup = vim.api.nvim_create_augroup("FileTypeKeymapsGlobal", {clear = true})

function M.expand(str)
  if type(str) ~= "string" then
    return str
  end
  local res = str:gsub("<[lL]>", "<Leader>")
  res = res:gsub("<[lL][lL]>", "<LocalLeader>")
  res = res:gsub("<[pP]>", "<Plug>")
  res = res:gsub("↑", "<Up>")
  res = res:gsub("↓", "<Down>")
  return res
end

function M.split(str, sep)
  if str == nil or type(str) == "table" then
    return str
  end
  if sep == nil then
    sep = ",%s"
  end
  local res = {}
  for substr in string.gmatch(str, "[^"..sep.."]+") do
    table.insert(res, substr)
  end
  return res
end

local function parse_complex_rhs(keymap)
  local rhs = keymap.rhs
  local lhs = keymap.lhs
  if type(rhs) == "table" and rhs.value then
    local opts = rhs
    rhs = rhs.value
    opts.value = nil
    for k,v in pairs(opts) do
      keymap[k] = v
    end
  end
  if type(rhs) == "table" then
    if #rhs == 1 and type(rhs[1]) == "string" then
      return M.expand(rhs[1])
    end
    return function()
      for _, fn in ipairs(rhs) do
        if fn() then
          return
        end
      end
      vim.api.nvim_feedkeys(M.termcodes(lhs), "n", false)
    end
  end
  return M.expand(rhs)
end

function M.parse(keymaps)
  local res = {}
  if #keymaps == 0 or keymaps[1][1] == nil then
    return keymaps -- Already parsed
  end
  for i,keymap in ipairs(keymaps) do
    local spec = vim.deepcopy(keymap)
    if spec[1] ~= nil then
      spec.lhs = M.expand(spec[2])
      spec.rhs = spec[3]
      spec.rhs = parse_complex_rhs(spec)
      spec.mode = M.split(spec[1])
      spec.ft = M.split(spec.ft)
      spec.desc = spec[4]
      spec.buffer = keymap.buffer == true and 0 or keymap.buffer
      spec[1] = nil
      spec[2] = nil
      spec[3] = nil
      spec[4] = nil
    end
    res[i] = spec
  end
  return res
end

function M.toLazyKeySpec(keymaps)
  local res = {}
  for i,keymap in ipairs(M.parse(keymaps)) do
    local spec = vim.deepcopy(keymap)
    spec[1] = spec.lhs
    spec[2] = spec.rhs
    spec.nowait = not spec.wait
    spec.lhs = nil
    spec.rhs = nil
    spec.wait = nil
    res[i] = spec
  end
  return res
end

function M.table_by_mode(keymaps)
  local res = {}
  for _, k in ipairs(M.parse(keymaps)) do
    for _, mode in ipairs(k.mode) do
      res[mode] = res[mode] or {}
      res[mode][k.lhs] = k.rhs
    end
  end
  return res
end

function M.table_by_lhs(keymaps)
  local res = {}
  for _, k in ipairs(M.parse(keymaps)) do
    res[k.lhs] = res[k.lhs] or {}
    for _, mode in ipairs(k.mode) do
      res[k.lhs][mode] = k.rhs
    end
  end
  return res
end

function M.cmd(command)
  return "<CMD>"..command.."<CR>"
end

function M.expr(value)
  return {expr = true, value = value}
end

function M.termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M._set_keymap(keymap, buffer)
  if buffer == nil then
    buffer = keymap.buffer
  end
  local lhs = keymap.lhs
  local rhs, opts = get_options(keymap)
  if buffer then
    for _, mode in ipairs(keymap.mode) do
      vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
    end
  else
    for _, mode in ipairs(keymap.mode) do
      vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
  end
end

function M.set(keymaps)
  for _, keymap in ipairs(M.parse(keymaps)) do
    if keymap.ft then
      -- This will create keymap only for new buffers
      -- Use layer if you want to create/remove keymaps dynamicaly for already existing buffers
      vim.api.nvim_create_autocmd("FileType", {
        group = ft_augroup,
        pattern = keymap.ft,
        desc = "Set keymap depending on buffer filetype",
        callback = function(ev)
          M._set_keymap(keymap, ev.buf)
        end,
      })
    else
      M._set_keymap(keymap)
    end
  end
end

function M.del(keymaps)
  for _, keymap in ipairs(M.parse(keymaps)) do
    local modes = keymap.mode
    local buffer = keymap.buffer == true and 0 or keymap.buffer
    if buffer then
      for _, mode in ipairs(modes) do
        pcall(vim.api.nvim_buf_del_keymap, buffer, mode, keymap.lhs)
      end
    else
      for _, mode in ipairs(modes) do
        pcall(vim.api.nvim_del_keymap, mode, keymap.lhs)
      end
    end
  end
end

function M.wrap(provider)
  return setmetatable({}, {__index = function(t, method_name) -- return fake object
    return function(...) -- which will have fake methods with arg forwarding
      local args = {...}
      return function(fallback) -- method returns a function which calls real object provider, and than method from real object
        local unpack = table.unpack or unpack
        local res = provider()[method_name](unpack(args))
        if res ~= nil and not res and fallback then
          fallback()
        end
        return res
      end
    end
  end})
end

-- Usage:
-- local fn = wrap_mod("module_name").method_name(arg1, arg2 ...)
-- where fn is a function which will call the method_name() with args
function M.wrap_mod(module)
  return M.wrap(function() return require(module) end)
end

return M
