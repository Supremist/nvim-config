local M = {}

local color_params = {"fg", "bg", "sp"}

local function add_attrs(attrs, attr_str)
  for _, attr in ipairs(vim.split(attr_str, ",")) do
    attrs[attr] = true
  end
end

local skip_cterm = true

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
     elseif k == "cterm" and not skip_cterm then
       group_value["cterm"] = {}
       add_attrs(group_value["cterm"], v)
     elseif k:sub(1, 5) ~= "cterm" or not skip_cterm then
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

function invert_table(t)
  local res = {}
  for k, v in pairs(t) do
    res[v] = k
  end
  return res
end

function merge_table(to, from)
  return vim.tbl_deep_extend("force", to, from)
end

function M.parse_highlights(hl_groups)
  local hl = {}
  hl.groups = hl_groups
  hl.tree = {}
  hl.palette = {}
  
  function add_link(from, to)
    if not hl.tree[from] then hl.tree[from] = {} end
    table.insert(hl.tree[from], to)
  end
  
  local palette = {}
  for name, val in pairs(hl_groups) do
    if next(val) == nil then
      add_link("cleared", name)
    elseif val.link then
      add_link(val.link, name)
    else
      local has_color = false
      for _, color_param in ipairs(color_params) do
        local color_val = val[color_param]
        if color_val then
          palette[color_val] = true
          if not has_color then
            add_link(color_val, name)
            has_color = true
          end
        end
      end
      if not has_color then
        add_link("discolored", name)
      end
    end
  end
  hl.palette = invert_table(require("theme.colors").generate_names(palette))
  
  hl.tree.color_names = {}
  for name, color in pairs(hl.palette) do
    if name ~= color then
      hl.tree[name] = hl.tree[color]
      hl.tree[color] = nil
    end
    table.insert(hl.tree.color_names, name)
  end
  for name, children in pairs(hl.tree) do
    table.sort(children)
  end
  hl.tree.categories = {}
  for i, name in ipairs(hl.tree.color_names) do
    hl.tree.categories[i] = name
  end
  table.insert(hl.tree.categories, "discolored")
  table.insert(hl.tree.categories, "cleared")
  hl.tree.root = {}
  for _, category in ipairs(hl.tree.categories) do
    for _, name in ipairs(hl.tree[category] or {}) do
      table.insert(hl.tree.root, name)
    end
  end
  table.sort(hl.tree.root)
  return hl
end

function M.save_theme(hl_groups, name)
  local colors = require("theme.colors")
  colors.load()
  local file,err = io.open(name..".lua",'w')
  if not file then
    print("error:", err)
    return
  end
  local hl = M.parse_highlights(hl_groups)
  file:write("local p = { -- palette\n")
  for _, name in ipairs(hl.tree.color_names) do
    local color = hl.palette[name]
    if name ~= color then
      file:write(string.format('  %s = "%s",\n', name, color))
    end
  end
  file:write("} -- palette\n\nlocal highlights = {\n")
  
  local name_by_color = invert_table(hl.palette)
  function print_name(name)
    return name:sub(1,1) == "@" and string.format('["%s"]', name) or name
  end
  
  function print_group(val)
    local visited = {}
    local text = {}
    local keys = {}
    for _, name in ipairs(color_params) do
      if val[name] then
        local color_name = name_by_color[val[name]]
        if color_name == val[name] then
          table.insert(text, string.format('%s = "%s"', name, color_name))
        else
          table.insert(text, string.format("%s = p.%s", name, color_name))
        end
        visited[name] = true
      end
    end
    for key, val in pairs(val) do
      if not visited[key] then
        table.insert(keys, key)
      end
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
      table.insert(text, string.format("%s = %s", key, vim.inspect(val[key]):gsub("\n", "")))
    end
    return table.concat(text, ", ")
  end
  
  for _, category in ipairs(hl.tree.categories) do
    local groups = hl.tree[category] or {}
    if #groups > 0 then
      file:write(" -- ", category, "\n")
      for _, group in ipairs(groups) do
        local val = hl.groups[group]
        file:write(string.format('  %-30s = { %s },\n', print_name(group), print_group(val)))
      end
    end
  end
  file:write("} -- highlights\n")
  
  file:write("\nlocal links = {")
  local visited = {}
  
  function indent(level)
    file:write('\n')
    for i = 0, level, 1 do file:write("  ") end
  end
  
  function print_link(node, level)
    level = level or 0
    if visited[node] then return end
    visited[node] = true
    local children = hl.tree[node] or {}
    if #children == 0 then
      if level == 0 then 
        return
      end
      indent(level)
      file:write(string.format('%s = {},', print_name(node)))
    else
      indent(level)
      file:write(string.format('%s = {', print_name(node)))
      for _, child in ipairs(children) do
        print_link(child, level+1)
      end
      indent(level)
      file:write("},")
    end
  end
  
  for _, highlight in ipairs(hl.tree.root) do
    print_link(highlight)
  end
  
  file:write("\n} -- links\n")
  file:write("return {palette = p, highlights = highlights, links = links}\n")
  for name, _ in pairs(visited) do
    hl_groups[name] = nil
  end
  vim.print(hl_groups)
  file:close()
end

function from_links_tree(links)
  local hl = {}
  function visit(root, node)
    root = root[node] or {}
    for child, _ in pairs(root) do
      hl[child] = {link = node}
      visit(root, child)
    end
  end
  for node, _ in pairs(links) do
    visit(links, node)
  end
  return hl
end

function flatten_highlights(hl)
  return merge_table(from_links_tree(hl.links), hl.highlights)
end

function equals(o1, o2)
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= 'table' then return false end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then return false end
  end
  return true
end

function remove_table(from, table)
  for key, val in pairs(table) do
    if equals(from[key], val) then
      from[key] = nil
    end
  end
end

function M.test()
  local hl = M.extract_highlights()
  
  --vim.print(from_links_tree(dofile("default.lua").links))
  remove_table(hl, flatten_highlights(dofile("default.lua")))
  
  M.save_theme(hl, "theme")
end

function M.default()
  M.save_theme(M.extract_highlights(), "default")
end

function M.save_hl_xml()
 local file,err = io.open("highlights.xml",'w')
  if not file then
    print("error:", err)
    return
  end
  local groups = M.extract_highlights()
  local tree, palette = M.parse_hl_tree(groups)
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