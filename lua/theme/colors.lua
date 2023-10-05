local M = {}

M.colors = {}

function M.rgb2hex(rgb)
    local value = (rgb.r * 0x10000) + (rgb.g * 0x100) + rgb.b
    return string.format("#%06x", value)
end

function M.hex2rgb(hex)
   hex = hex:gsub("#","")
   local f = hex:len() == 3 and 17 or 1
   return {
     r = f*tonumber("0x"..hex:sub(1,2)), 
     g = f*tonumber("0x"..hex:sub(3,4)),
	 b = f*tonumber("0x"..hex:sub(5,6)),
  }
end

function M.load(filter)
  -- Colors file from https://github.com/codebrainz/color-names
  -- contains color names with rgb values
  local file, err = io.open(debug.getinfo(1, "S").source:match("^@(.*/)").."colors.csv", "r")
  if not file then
    print("error:", err)
    return
  end
  
  filter = filter or function() return true end
  local colors = {}
  for line in file:lines() do
    local res = vim.split(line, ",")
	local name = res[1]
	-- local desc = res[2]
	-- local hex = res[3]
	local rgb = {r = res[4], g = res[5], b = res[6]}
	if filter(name, rgb) then
	  colors[name] = rgb
	end
  end
  file:close()
  if #M.colors == 0 then
    M.colors = colors
  end
  return colors
end

function M.find_color_name(rgb)
  local function dist_fn(other)
    local r, g, b = other.r-rgb.r, other.g-rgb.g, other.b-rgb.b
    return r*r + g*g + b*b
  end
  local min_dist = 3*256*256
  local min_name = nil
  for name, color in pairs(M.colors) do
    local dist = dist_fn(color)
    if dist < min_dist then
	  min_dist = dist
	  min_name = name
	end
  end
  return min_name
end

function M.generate_names(palette)
  local names = {}
  local conflicts = {}
  for color, _ in pairs(palette) do
    local name = color:sub(1,1) == '#' and M.find_color_name(M.hex2rgb(color)) or color
	names[color] = name
	if not conflicts[name] then conflicts[name] = {} end
	table.insert(conflicts[name], color)
  end
  -- resolve conflicting names
  for name, colors in pairs(conflicts) do
    if #colors > 1 then
	  for i, color in ipairs(colors) do
	    names[color] = name..tostring(i)
	  end
	end
  end
  return names
end

return M