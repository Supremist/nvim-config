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

function M.set_shorthands(shorts)
  M.shorthands = shorts
end

local function has_brackets(str)
  return str:sub(1,1) == "<" and str:sub(-1,-1) == ">"
end

function M.expand(str)
  if type(str) ~= "string" then
    return str
  end
  for key, shorts in pairs(M.shorthands) do
    local stripped = has_brackets(key) and key:sub(2, #key-1) or key
    for _, short in ipairs(shorts) do
      if not has_brackets(short) then
        str = str:gsub("([<%-])"..short..">", "%1"..stripped..">")
      end
      str = str:gsub(short, key)
    end
  end
  return str
end

function M.key_labels()
  local labels = {}
  for key, shorts in pairs(M.shorthands) do
    labels[key] = shorts[1]
    labels[key:lower()] = shorts[1]
  end
  return labels
end

local function parse_modes(str)
  if str == nil or type(str) == "table" then
    return str
  end
  if #str == 0 then -- "" = "nvo"
    str = "nvo"
  end
  local res = {}
  for i=1,#str do
    local c = str:sub(i,i)
    if c == "!" then
      c = "ic"
    elseif c == "v" then
      c = "xs"
    end
    for j=1,#c do
      table.insert(res, c:sub(j,j))
    end
  end
  return res
end

local function split(str, sep)
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
  if type(rhs) ~= "table" then
    return M.expand(rhs)
  end
  local tp = rhs.type
  rhs.type = nil
  if rhs.value and tp == "options" then
    local opts = rhs
    rhs = rhs.value
    opts.value = nil
    opts.type = nil
    require("core.tbl").deep_update(keymap, opts)
    return M.expand(rhs)
  end
  if tp == "layered" then
    return function()
      for _, fn in ipairs(rhs) do
        if fn() then
          return
        end
      end
      vim.api.nvim_feedkeys(M.termcodes(lhs), "n", false)
    end
  end
  return rhs
end

function M.parse(keymaps)
  local res = {}
  if not keymaps then
    return {}
  end
  if #keymaps == 0 or keymaps[1][1] == nil then
    return keymaps -- Already parsed
  end
  for i,keymap in ipairs(keymaps) do
    local spec = vim.deepcopy(keymap)
    if spec[1] ~= nil then
      spec.lhs = M.expand(spec[2])
      spec.rhs = spec[3]
      spec.rhs = parse_complex_rhs(spec)
      spec.mode = parse_modes(spec[1])
      spec.ft = split(spec.ft)
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

function M.to_lazy_keyspec(keymaps)
  local res = {}
  for i,keymap in ipairs(M.parse(keymaps)) do
    local spec = vim.deepcopy(keymap)
    spec[1] = spec.lhs
    if not spec.manual then
      spec[2] = spec.rhs
    end
    spec.nowait = spec.nowait or spec.wait == false -- Defaults to false
    if not spec.nowait then spec.nowait = nil end -- Shorter spec, omit defaults
    spec.lhs = nil
    spec.rhs = nil
    spec.wait = nil
    res[i] = spec
  end
  return res
end

function M.to_which_key_spec(keymaps)
  local res = {}
  local modes = {}
  for _, keymap in ipairs(M.parse(keymaps)) do
    for _, mode in ipairs(keymap.mode) do
      modes[mode] = true
    end
    local spec = vim.deepcopy(keymap)
    spec.mode = nil
    spec.lhs = nil
    if spec.rhs == "..." then
      spec.name = spec.desc
    else
      spec[1] = spec.rhs
      spec[2] = spec.desc
    end
    spec.rhs = nil
    spec.desc = nil
    -- workaround for https://github.com/folke/which-key.nvim/issues/482
    spec["<F20>"] = "which_key_ignore"
    res[keymap.lhs] = spec
  end
  res.mode = {}
  for mode, _ in pairs(modes) do
    table.insert(res.mode, mode)
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

function M.table_by_lhs(keymaps, opts)
  local res = {}
  opts = opts or {}
  for _, k in ipairs(M.parse(keymaps)) do
    local lhs = opts.termcodes and M.termcodes(k.lhs) or k.lhs
    if opts.nomode then
      res[lhs] = k.rhs
    else
      res[lhs] = res[lhs] or {}
      for _, mode in ipairs(k.mode) do
        res[lhs][mode] = k.rhs
      end
    end
  end
  return res
end

function M.cmd(command)
  return "<CMD>"..command.."<CR>"
end

function M.add_options(keymaps, opts)
  for _, keymap in pairs(keymaps) do
    require("core.tbl").deep_update(keymap, opts)
  end
  return keymaps
end

function M.options_builder(opts)
  return function(value)
    return vim.tbl_deep_extend("force", {type="options", value = value}, opts)
  end
end

function M.layered(...)
  return {type="layered", ...}
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

function M.set(keymaps, buffer)
  for _, keymap in ipairs(M.parse(keymaps)) do
    if keymap.ft then
      -- This will create keymap only for new buffers
      -- Use layer if you want to create/remove keymaps dynamicaly for already existing buffers
      require("core.aucmd").filetype(keymap.ft, function(ev)
        M._set_keymap(keymap, ev.buf)
      end, "Set keymap depending on buffer filetype")
    else
      M._set_keymap(keymap, buffer)
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

function M.wrap(provider, policy)
  if not policy then
    policy = "bind"
  end
  local get_real = function(t)
    local obj = provider()
    for _, key in ipairs(t.__path) do
      obj = obj[key]
    end
    return obj
  end
  local policies = {
    forward = function(t)
      return function(...)
        return get_real(t)(...)
      end
    end,
    bind = function(t, ...)
      local args = {...}
      local unpack = table.unpack or unpack
      return function(fallback)
        local res = get_real(t)(unpack(args))
        if res ~= nil and not res and fallback then
          fallback()
        end
        return res
      end
    end
  }
  local mt = {
    __index = function(tbl, key) -- return fake object
      local val = setmetatable({__path = vim.deepcopy(tbl.__path)}, getmetatable(tbl))
      table.insert(val.__path, key)
      tbl[key] = val
      return val
    end,
    __call = policies[policy]
  }

  return setmetatable({__path = {}}, mt)
end

-- Usage:
-- local fn = wrap_mod("module_name").method_name(arg1, arg2 ...)
-- where fn is a function which will call the method_name() with args
function M.wrap_mod(module)
  return M.wrap(function() return require(module) end)
end

function M.forward_mod(module)
  return M.wrap(function() return require(module) end, "forward")
end

return M
