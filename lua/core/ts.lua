local parsers = require "nvim-treesitter.parsers"
local tsrange = require "nvim-treesitter.tsrange"
local ts_utils = require "nvim-treesitter.ts_utils"
local TSRange = tsrange.TSRange

local M = {}

---@alias Position {row: integer, col: integer}
---@alias Direction "forward" | "backward"


local function pos_cmp(a, b)
  if a[1] < b[1] then return -1 end
  if a[1] > b[1] then return  1 end
  if a[2] < b[2] then return -1 end
end

local function range_intersection(range1, range2)
  assert(range1.buf == range2.buf, "Failed to compare ranges from different buffers")
  
end

local function get_leaf(node, direction)
  while node:child_count() > 0 do
    if direction == "forward" then
      node = node:child(0)
    else
      node = node:child(node:child_count()-1)
    end
  end
  return node
end

---@param from TSNode first node
local function iter_leaf(from, direction)
  local function next_sibling(node)
    if not direction or direction == "forward" then
      return node:next_sibling()
    end
    return node:prev_sibling()
  end

  local node = get_leaf(from, direction)
  return function()
    local next = next_sibling(node)
    while not next do
      node = node:parent()
      if not node then
        return
      end
      next = next_sibling(node)
    end
    node = get_leaf(next, direction)
    return node
  end
end

---@param range TSRange valid search range
---@return TSNode? smallest_node -- that fully contains the `range`
---similar to TSRange.parent()
function M.get_smallest_node(range)
  local lang_tree = parsers.get_parser(range.buf)
  if not lang_tree then
    return
  end

  local root = ts_utils.get_root_for_position(range[1], range[2], lang_tree)
  if not root then
    return
  end

  return root:descendant_for_range(range[1], range[2], range[3], range[4])
end


-- 1. Find smallest node, that fully contains selection range
-- 2. Walk into desired direction. Get next candidate node
-- 3. Check filter(candidate)
--

function M.highlight_range(range, buf, hl_namespace, hl_group)
  ---@type integer, integer, integer, integer
  local start_row, start_col, end_row, end_col = unpack(range)
  -- local opts = {timeout = 2000}
  vim.highlight.range(buf, hl_namespace, hl_group, { start_row, start_col }, { end_row, end_col }, {})
end

function M.highlight_glance(range, buf, timeout)
  timeout = timeout or 2000
  local hl_group = "DiagnosticVirtualTextWarn"
  local hl_ns = vim.api.nvim_create_namespace("core.ts_temp_highlght")
  M.highlight_range(range, buf, hl_ns, hl_group)
  vim.defer_fn(function ()
    vim.api.nvim_buf_clear_namespace(buf, hl_ns, range[1], range[3]+1)
  end, timeout)
end

function M.test()
  local buf = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)
  local range = TSRange.new(buf, pos[1]-1, pos[2], pos[1]-1, pos[2])
  local node = M.get_smallest_node(range)
  -- vim.print(node:range())
  local iter = iter_leaf(node, "forward")
  node = iter()
  -- vim.print(node:range())
  local parent_range = {node:range()}
  M.highlight_glance(parent_range, buf)
end

return M
