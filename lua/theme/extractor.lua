local M = {}

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
     group_value[k] = v
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

function M.save_hl_xml()
 local file,err = io.open("highlights.xml",'w')
  if not file then
    print("error:", err)
    return
  end
  local groups = M.extract_highlights()
  local tree = {}
  for name, val in pairs(groups) do
    if val.link then
	  local children = tree[val.link] or {}
	  table.insert(children, name)
	  tree[val.link] = children
	end
  end
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