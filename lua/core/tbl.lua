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

M.dummy = setmetatable({}, {
  __index = function (t, k)
    return t
  end,
  __call = function (t, ...) end}
)

return M
