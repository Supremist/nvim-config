local M = {}

function M.deep_update(dst, src)
  for k,v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" then
      M.deep_update(dst[k], v)
    else
      dst[k] = v
    end
  end
  return dst
end

function M.shallowcopy(tbl)
  local res = {}
  for key, val in pairs(tbl) do
    res[key] = val
  end
  return res
end

function M.filter(list, fn, dest)
  dest = dest or {}
  local sz = #list
  local src = 1
  local dst = 1
  while src <= sz do
    if fn(list[src]) then
      dest[dst] = list[src]
      dst = dst + 1
    end
    src = src + 1
  end
  if list == dest then
    for i = dst, sz do
      dest[i] = nil
    end
  end
  return dest
end

function M.reshape(value, key_scheme, value_scheme)
  if #key_scheme == 0 then
    if not value_scheme or #value_scheme == 0 then
      return value
    end
    for _, value_name in pairs(value_scheme) do
      value = value[value_name]
    end
    return value
  end
  local key_name = key_scheme[1]
  key_scheme = M.shallowcopy(key_scheme)
  table.remove(key_scheme, 1)
  local stage1 = {}
  for _, item in ipairs(value) do
    local key = item[key_name]
    stage1[key] = stage1[key] or {}
    table.insert(stage1[key], item)
  end
  local stage2 = {}
  for key, val in pairs(stage1) do
    stage2[key] = M.reshape(val, key_scheme, value_scheme)
  end
  return stage2
end

M.dummy = setmetatable({}, {
  __index = function (t, k)
    return t
  end,
  __call = function (t, ...) end}
)

return M
