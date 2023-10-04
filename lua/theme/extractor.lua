local M = {}

local color_params = {"fg", "bg", "sp", "ctermfg", "ctermbg"}

local function add_attrs(attrs, attr_str)
  for _, attr in ipairs(vim.split(attr_str, ",")) do
    attrs[attr] = true
  end
end

function M.parse_hl_line(hl_line)
  local group_name, spec = string.match(hl_line, "([^ ]+)%s+xxx (.*)")
  local cleared_prefix = "cleared"
  if spec:sub(1, #cleared_prefix) == cleared_prefix then 
    return group_name, {} 
  end
  local linked = string.match(spec, "links to ([^ ]+)")
  if linked then return group_name, {link=linked} end
  local group_value = {}
   for k, v in string.gmatch(spec, "(%w+)=([^ ]+)") do
     if k:sub(1, 3) == "gui" then
	   k = k:sub(4, -1)
	 end
	 if k == "" then
	   add_attrs(group_value, v)
	 elseif k == "cterm" then
	   group_value["cterm"] = {}
	   add_attrs(group_value["cterm"], v)
	 else
	   group_value[k] = v
	 end
   end
   return group_name, group_value
end


function M.extract_highlights()
  local output = vim.split(vim.fn.execute "highlight", "\n")
  local hl_lines = {}
  for _, v in ipairs(output) do
    if v ~= "" then
  	  if v:sub(1, 1) == " " then
  	    local part_of_old = v:match "%s+(.*)"
  	    hl_lines[#hl_lines] = hl_lines[#hl_lines] .. part_of_old
  	  else
  	    table.insert(hl_lines, v)
  	  end
	end
  end

  local hl_groups = {}
  for _, v in ipairs(hl_lines) do
    local k, val = M.parse_hl_line(v)
    hl_groups[k] = val
  end
  return hl_groups
end

function M.parse_hl_tree(hl_groups, palette)
  palette = palette or {}
  local tree = {}
  local function add_link(from, to)
    if not tree[from] then tree[from] = {} end
	table.insert(tree[from], to)
  end
  for name, val in pairs(hl_groups) do
    local has_link = false
    if val.link then
	  add_link(val.link, name)
	  has_link = true
	else
      for _, color_param in ipairs(color_params) do
	    if val[color_param] then
		  local color_val = val[color_param]
		  local color_name = ""
		  if palette[color_val] then
		    color_name = palette[color_val]
		  else
		    color_name = color_val:sub(1,1) == "#" and "cl_" .. color_val:sub(2,-1) or color_val
			palette[color_val] = color_name
		  end
		  if not has_link then
	        add_link(color_name, name)
		    has_link = true
		  end
	    end
	  end
	end
  end
  return tree
end

function M.save_theme(hl_groups, palette)
  palette = palette or {}
  local file,err = io.open("theme.lua",'w')
  if not file then
    print("error:", err)
    return
  end
  local tree = M.parse_hl_tree(hl_groups, palette)
  local stack = {}
  local visited = {}
  file:write("local p = { -- palette\n")
  for color, name in pairs(palette) do
    if name ~= color then
      file:write(string.format('  %s = "%s",\n', name, color))
      table.insert(stack, name)
	end
  end
  file:write("} -- palette\nlocal g = { -- highlight groups\n")
  local level_count = #stack
  local level = 0
  file:write(" -- Level", level, " contains ", level_count, " groups\n")
  while(#stack > 0) do
    local top = stack[1]
	table.remove(stack, 1)
	level_count = level_count-1
	if not visited[top] then
	  visited[top] = true
	  local hl = hl_groups[top]
	  if hl then
	    file:write(string.format('["%s"] = %s,\n', top, vim.inspect(hl):gsub("\n", "")))
	  end
	  for _, child in ipairs(tree[top] or {}) do
	    table.insert(stack, child)
	  end
	end
	if level_count == 0 then
	  file:write("\n")
	  level = level+1
	  level_count = #stack
	  file:write(" -- Level", level, " contains ", level_count, " groups\n")
	end
  end
  file:write("}")
  file:close()
end

function M.test()
  M.save_theme(M.extract_highlights())
end

function M.save_hl_xml()
 local file,err = io.open("highlights.xml",'w')
  if not file then
    print("error:", err)
    return
  end
  local groups = M.extract_highlights()
  local palette = {}
  local tree = M.parse_hl_tree(groups, palette)
  vim.print(palette)
  local visited = {}
  local order = {}
  
  local function visit_node(node)
    if visited[node] then return end
	visited[node] = true
	for _, v in ipairs(tree[node] or {}) do visit_node(v) end
	table.insert(order, 1, node)
  end
  
  local function print_node(node, level)
    if visited[node] then return end
	visited[node] = true
	
	local name = string.gsub(node, "@", "AT_")
	for i = 0, level, 1 do file:write("  ") end
	if tree[node] then
      file:write(string.format("<%s>\n", name))
	  for _, v in ipairs(tree[node]) do print_node(v, level+1) end
	  for i = 0, level, 1 do file:write("  ") end
	  file:write(string.format("</%s>\n", name))
	else
	  file:write(string.format("<%s/>\n", name))
	end
  end
  
  for name, children in pairs(tree) do
    visit_node(name)
  end
  
  visited = {}
  file:write("<highlights>\n")
  for _, node in ipairs(order) do
	print_node(node, 0)
  end
  file:write("\n")
  for name, val in pairs(groups) do
    if not val.link and not visited[name] then
	  print_node(name, 0)
	end
  end

  file:write("</highlights>")
  file:close()
end

return M