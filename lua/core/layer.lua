local Keymaps = require("keymaps")

local Layer = {}
Layer.__index = Layer

function Layer.new(name, opts, keymaps)
  local l = opts
  l.name = name
  l.buffer = l.buffer == true and 0 or l.buffer
  setmetatable(l, Layer)
  for _, map in ipairs(Keymaps.parse(keymaps)) do
    if map.desc and map.desc ~= "" then
      map.desc = name..": "..map.desc
    end
    for _, mode in ipairs(map.mode) do
      local copy = vim.deepcopy(map)
      copy.mode = {mode}
      l.keymaps[mode][Keymaps.termcodes(map.lhs)] = copy
    end
  end
  l.saved_keymaps = {}
  l.active = false
  return l
end

function Layer:_save_keymaps(bufnr)
  self.saved_keymaps[bufnr] = {}

  for mode, keymaps in pairs(self.keymaps) do
    self.saved_keymaps[bufnr][mode] = {}
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
      local map_id = Keymaps.termcodes(map.lhs)
      local layer_map = keymaps[map_id]
      if layer_map then
        self.saved_keymaps[bufnr][mode][map_id] = {
          lhs = map.lhs,
          buffer = bufnr,
          mode = {mode},
          rhs = map.rhs or map.callback,
          expr = map.expr == 1,
          remap = map.noremap ~= 1,
          script = map.script == 1,
          silent = map.silent == 1,
          wait = map.nowait ~= 1,
          unique = map.unique == 1,
          desc = map.desc
        }
      end
    end
  end
end

function Layer:_restore_keymaps()
  for mode, keymaps in pairs(self.keymaps) do
    for map_id, layer_map in pairs(keymaps) do
      for bufnr, _ in pairs(self.saved_keymaps) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          local map = self.saved_keymaps[bufnr][mode][map_id]
          if map then
            Keymaps._set_keymap(map, bufnr)
          else
            vim.api.nvim_buf_del_keymap(bufnr, mode, layer_map.lhs)
          end
        end
      end
    end
  end

  self.saved_keymaps = {}
end

function Layer:_setup_keymaps(bufnr)
  if self.saved_keymaps[bufnr] then return end

  self:_save_keymaps(bufnr)
  for _, keymaps in pairs(self.keymaps) do
    for _, map in pairs(keymaps) do
      Keymaps._set_keymap(map, bufnr)
    end
  end
end

function Layer:_should_activate(bufnr)
  if not self.ft and not self.buffer or self.buffer == bufnr then
    return true
  end
  local buf_ft = vim.bo[bufnr].filetype
  for _, ft in ipairs(self.ft) do
    if buf_ft == ft then -- Maybe use matching?
      return true
    end
  end
  return false
end

function Layer:set_active(is_active)
  is_active = is_active or is_active == nil
  if self.active == is_active then return end
  self.active = is_active
  if is_active then
    if self.buffer then
      self:_setup_keymaps(self.buffer)
    else
      self.augroup = vim.api.nvim_create_augroup(self.name.."LayerUpdate", {clear = true})
      vim.api.nvim_create_autocmd("BufEnter", {
        group = self.augroup,
        desc = "Update layer keymaps",
        callback = function(ev)
          if self:_should_activate(ev.buf) then
            self:_setup_keymaps(ev.buf)
          end
        end,
      })
    end
  else
    self:_restore_keymaps()
    vim.api.nvim_del_augroup_by_id(self.augroup)
  end
end

return Layer
