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

local function expand_keys(str)
  if type(str) ~= "string" then
    return str
  end
  local res = str:gsub("<[lL]>", "<Leader>")
  res = res:gsub("<[lL][lL]>", "<LocalLeader>")
  return res
end

local function copy(t)
  local res = {}
  for k,v in pairs(t) do
    res[k] = v
  end
  return res
end

local M = {}

function M.toLazyKeySpec(keymaps)
  local res = {}
  for i,keymap in ipairs(keymaps) do
    local spec = copy(keymap)
    spec.mode = split(spec[1])
    spec.ft = split(spec.ft)
    spec[1] = expand_keys(spec[2])
    spec[2] = expand_keys(spec[3])
    spec.desc = spec[4]
    spec[4] = nil
    spec[3] = nil
    res[i] = spec
  end
  return res
end

function M.set(keymaps)
  for _,keymap in ipairs(keymaps) do
    local opts = copy(keymap)
    opts[1] = nil
    opts[2] = nil
    opts[3] = nil
    local ft = split(keymaps.ft) -- TODO bind only for filetype buffer
    opts.desc = opts[4]
    opts[4] = nil
    vim.keymap.set(split(keymap[1]), expand_keys(keymap[2]), expand_keys(keymap[3]), opts)
  end
end

return M
