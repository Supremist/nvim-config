local Tbl = require "core.tbl"
local M = {}

local Keymaps = {}
local KeymapsMT = {__index = Keymaps}

function Keymaps:reshape(key_scheme, value_scheme)
  return Tbl.reshape(self.list, key_scheme, value_scheme)
end

function Keymaps:set(buf)
  M.set(self.list, buf)
end

function Keymaps:del()
  M.del(self.list)
end

function Keymaps:copy()
  local res = setmetatable(Tbl.shallowcopy(self), KeymapsMT)
  res.list = Tbl.shallowcopy(self.list)
  return res
end

-- remove mappings with the same id & mode
function Keymaps:resolve()
  self.list = Tbl.flatten(self:reshape({"mode", "id"}, {1}), 2)
  return self
end

function Keymaps:extend(other)
  vim.list_extend(self.list, other.list)
  return self
end

function Keymaps:filter(filter_fn)
  Tbl.filter(self.list, filter_fn, self.list)
  return self
end

function Keymaps:merged_modes()
  local res = {}
  for _, by_rhs in pairs(self:reshape({"id", "rhs", "mode"}, {1})) do
    for _, by_mode in pairs(by_rhs) do
      local modes = {}
      for mode, _ in pairs(by_mode) do
        table.insert(modes, mode)
      end
      local spec = vim.deepcopy(by_mode[modes[1]])
      spec.mode = modes
      table.insert(res, spec)
    end
  end
  return res
end

function Keymaps:to_lazy()
  local res = {}
  for i, spec in pairs(self:merged_modes()) do
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

function Keymaps:to_whichkey()
  local res = {}
  local modes = {}
  for _, keymap in ipairs(self.list) do
    modes[keymap.mode] = true
    local spec = {}
    if keymap.rhs == "..." then
      spec.name = keymap.desc
      -- workaround for https://github.com/folke/which-key.nvim/issues/482
      spec["<F20>"] = "which_key_ignore"
    else
      spec[1] = keymap.rhs
      spec[2] = keymap.desc
    end
    res[keymap.lhs] = spec
  end
  res.mode = {}
  for mode, _ in pairs(modes) do
    table.insert(res.mode, mode)
  end
  return res
end

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
  if type(rhs) ~= "table" then
    return M.expand(rhs)
  end
  local tp = rhs.type
  rhs.type = nil
  if rhs.value and tp == "options" then
    local opts = rhs
    rhs = rhs.value
    opts.value = nil
    Tbl.deep_update(keymap, opts)
    return M.expand(rhs)
  end
  if tp == "layered" then
    return function()
      for _, fn in ipairs(rhs) do
        if fn() then
          return
        end
      end
      vim.api.nvim_feedkeys(M.termcodes(keymap.lhs), "n", false)
    end
  end
  return rhs
end

function M.parse(keymaps, opts)
  if getmetatable(keymaps) == KeymapsMT then
    return keymaps
  end
  local res = {}
  opts = opts or {}
  local name = opts.name
  opts.name = nil
  if not keymaps then
    return {}
  end
  if #keymaps == 0 or keymaps[1][1] == nil then
    assert(false)
    return keymaps -- Already parsed?
  end
  for _,keymap in ipairs(keymaps) do
    local spec = Tbl.shallowcopy(keymap)
    if spec[1] == nil then
      table.insert(res, spec)
    else
      local mode_list = parse_modes(spec[1])
      local lhs_list = spec[2]
      lhs_list = type(lhs_list) == "table" and lhs_list or {lhs_list}
      spec.rhs = spec[3]
      spec.rhs = parse_complex_rhs(spec)
      spec.ft = split(spec.ft)
      spec.desc = spec[4]
      if name then
        spec.desc = name..": "..spec.desc
      end
      spec.buffer = keymap.buffer == true and 0 or keymap.buffer
      spec[1] = nil
      spec[2] = nil
      spec[3] = nil
      spec[4] = nil

      for _, mode in ipairs(mode_list) do
        spec.mode = mode
        for _, lhs in ipairs(lhs_list) do
          spec.lhs = M.expand(lhs)
          spec.id = M.termcodes(spec.lhs)
          table.insert(res, vim.tbl_deep_extend("force", opts, spec))
        end
      end
    end
  end
  return setmetatable({name = name, list = res}, KeymapsMT)
end

function M.cmd(command)
  return "<CMD>"..command.."<CR>"
end

function M.add_options(keymaps, opts)
  for _, keymap in pairs(keymaps) do
    Tbl.deep_update(keymap, opts)
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

function M._set_keymap(keymap, buffer)
  if buffer == nil then
    buffer = keymap.buffer
  end
  local lhs = keymap.lhs
  local rhs, opts = get_options(keymap)
  if buffer then
    vim.api.nvim_buf_set_keymap(buffer, keymap.mode, lhs, rhs, opts)
  else
    vim.api.nvim_set_keymap(keymap.mode, lhs, rhs, opts)
  end
end

function M.set(keymaps, buffer)
  for _, keymap in ipairs(keymaps) do
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
  for _, keymap in ipairs(keymaps) do
    local buffer = keymap.buffer == true and 0 or keymap.buffer
    if buffer then
      pcall(vim.api.nvim_buf_del_keymap, buffer, keymap.mode, keymap.lhs)
    else
      pcall(vim.api.nvim_del_keymap, keymap.mode, keymap.lhs)
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

function M.save_view()
  -- credits to https://github.com/gbprod/stay-in-place.nvim
  local unpack = table.unpack or unpack
  local res = {}
  res.line, res.col = unpack(vim.api.nvim_win_get_cursor(0))
  res.len_before = vim.api.nvim_get_current_line():len()
  res.winview = vim.fn.winsaveview()
  return res
end

function M.restore_view(view)
  vim.fn.winrestview(view.winview)
  local len_after = vim.api.nvim_get_current_line():len()
  local new_col = math.max(0, view.col - view.len_before + len_after)
  vim.api.nvim_win_set_cursor(0, { view.line, new_col })
end

M._context = {}

function M.opfunc_dispatch(motion_type)
  M._context.motion_type = motion_type
  local args = M._context.args
  local unpack = table.unpack or unpack
  M._context.opfunc(M._context, unpack(args))
  M._context.is_repeat = true
end

function M.set_opfunc(func, ...)
  M._context.args = {...}
  M._context.view = M.save_view()
  M._context.register = vim.v.register
  M._context.count = vim.v.count
  M._context.is_repeat = false
  M._context.restore_view = function() M.restore_view(M._context.view) end
  if type(func) == "function" then
    M._context.opfunc = func
    func = {"core.keymaps", "opfunc_dispatch"}
  end
  vim.go.opfunc = "v:lua.require'"..func[1].."'."..func[2]
end

function M.operator(func, ...)
  local args = {...}
  return function()
    local unpack = table.unpack or unpack
    M.set_opfunc(func, unpack(args))
    return "g@"
  end
end

return M
