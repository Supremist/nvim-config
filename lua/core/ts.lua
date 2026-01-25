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

function M.get_subword_range(range, offset)
  -- Delimiters - a set of characters, that can't be a part of subword
  -- Determine searching range:
  --   Search backward two times for delimiter groups before cursor pos: 
  --     vim.fn.searchpos([delimiters]+, 'bnW')
  --   From that point lazy iterate over matches of word patterns
end

----- TEST
----- positions vim's `w` will move to
-- local myVariableName = FOO_BAR_BAZ
-- ^     ^              ^ ^

-- positions spider's `w` will move to
-- local myVariableName = FOO_BAR_BAZ
-- ^     ^ ^       ^    ^ ^   ^   ^

-- -- positions vim's `w` will move to
-- if foo:find("%d") and foo == bar then print("[foo] has" .. bar) end
-- ^  ^  ^^   ^  ^^  ^   ^   ^  ^   ^    ^    ^  ^  ^ ^  ^ ^  ^  ^ ^  -> 21

-- positions spider's `w` will move to
-- if foo:find("%d") and foo == bar then print("[foo] has" .. bar) end
-- ^  ^   ^      ^   ^   ^   ^  ^   ^    ^       ^    ^    ^  ^    ^  -> 14
-- WTFuck, UPPERlower, TrIckYCaSe, УкрОборонПром, 1234, #f383ab, 3.23, 0b00, Test, 0B11, 0xf1b2, 0X1Fa0


function M.search()
  local word_patterns = {
    {'CamelCase', '\\u\\l+'}, -- 1 uppercase, >1 lowercase
    {'UPPERCASE', '\\u+\\l@!'}, -- >1 uppercase, no lowercase
    {'lowercase', '\\l+'},
    {'hex_digit', '%(\\#|<0[xXbB])\\x+'},
    {'digit', '\\d+'},
  }
  return M.get_match(word_patterns, {direction = "forward"})
end

---@alias NamePatternPair { [1]: string, [2]: string }
---@param named_patterns NamePatternPair[]
---@param opts { direction: Direction, wrap: boolean, current: boolean}
function M.get_match(named_patterns, opts)
  opts = vim.tbl_deep_extend("force", {direction = "forward", wrap = false, current = false}, opts or {})
  local pattern = M.vm_pattern_to_utf8(M.or_pattern(named_patterns))
  local flags = "w" and opts.wrap or "W"
  local bg_pos, end_pos
  if opts.current then
    if opts.direction == "forward" then
      end_pos = vim.fn.searchpos(pattern, "ce" ..flags)
      bg_pos  = vim.fn.searchpos(pattern, "cbp"..flags)
    else
      bg_pos  = vim.fn.searchpos(pattern, "cbp"..flags)
      end_pos = vim.fn.searchpos(pattern, "cen"..flags)
    end
  else
    if opts.direction == "forward" then
      bg_pos  = vim.fn.searchpos(pattern, "p"..flags)
      end_pos = vim.fn.searchpos(pattern, "cen"..flags)
    else
      end_pos = vim.fn.searchpos(pattern, "be"..flags)
      bg_pos  = vim.fn.searchpos(pattern, "cbp"..flags)
    end
  end
  if not bg_pos or bg_pos[1] == 0 then
    return
  end
  local name = named_patterns[bg_pos[3]-1][1]
  return {bg_pos[1], bg_pos[2], end_pos[1], end_pos[2]+1, name}
end

function M.get_matching_range()
  -- local delimiters   =   [[\v\C[[:space:]\n\r]+]]
  local delimiters = [[\v\C(%$)|(%^)|([[:space:]\n\r]+)]]
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local pos = vim.fn.searchpos(delimiters, 'bcW', cursor_pos[1]-1)
  pos = vim.fn.searchpos(delimiters, 'bW', cursor_pos[1]-1)
  -- vim.api.nvim_win_set_cursor(0, cursor_pos)
  -- pos = vim.fn.searchpos(delimiters, 'W', cursor_pos[1]+1)
  -- pos = vim.fn.searchpos(delimiters, 'bW', cursor_pos[1])
  return pos
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
  vim.print(node:type())
  -- vim.print(node:range())
  local iter = iter_leaf(node, "forward")
  node = iter()
  -- vim.print(node:range())
  local parent_range = {node:range()}
  M.highlight_glance(parent_range, buf)
end

---comment Convert Very magic pattern from asci to utf8 format
---@param pattern string vim very magic pattern string
---@return string result vim very magic pattern with utf8 support
function M.vm_pattern_to_utf8(pattern)
  local char_classes = {
    ['\\a'] = '[[:lower:][:upper:]]',
    ['\\l'] = '[[:lower:]]',
    ['\\u'] = '[[:upper:]]',
    ['\\p'] = '[[:print:]]',
    ['\\s'] = '[[:space:]]',
    ['\\S'] = '[^[:space:]]',
    ['\\d'] = '[[:digit:]]',
    ['\\x'] = '[[:xdigit:]]',
    -- {'alnum', '[[:lower:][:upper:][:digit:]]'},
  }

  for ascii_class, utf8_class in pairs(char_classes) do
    pattern = pattern:gsub(ascii_class, utf8_class)
  end
  return pattern
end

---@alias NamePatternPair { [1]: string, [2]: string }
---@param named_patterns NamePatternPair[]
---@return string composed_pattern
function M.or_pattern(named_patterns)
  assert(#named_patterns > 0 and #named_patterns <= 9)
  local patterns = {}
  for i, pair in ipairs(named_patterns) do
    patterns[i] = '('..pair[2]..')'
  end
  return [[\v\C]]..table.concat(patterns, '|')
end


local Search = {}
--- SearchLayer - bind keys to:
--- next
--- previous
--- toggle_direction
--- highlight_all
--- jump
---

function Search.next()
end

function Search.previous()
end

return M
