local optional = require("core.mod").optional

-- Flash enhances the built-in search functionality by showing labels
-- at the end of each match, letting you quickly jump to a Mific
-- location.
local Flash = require("core.mod").patch("flash")
local M = { "flash.nvim",
  event = "VeryLazy",
  reloadable = true,
  opts = {
    labels = "asdfghjklqwertyuiopzxcvbnm1234567890ASDFGHJKLQWERTYUIOPZXCVBNM",
    label = {
      uppercase = false,
      reuse = "all",
    },
    modes = {
      telescope = {
        pattern = "^.",
        prompt = { enabled = false },
        label = { after = {0, -1}, exclude = "jk" },
        highlight = { backdrop = false, matches = false },
        search = {
          mode = "search",
          exclude = {
            function(win)
              return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
            end,
          },
        },
        abort = function()
          vim.api.nvim_input("A")
        end,
        labeler = function(matches, state)
          local labels = state:labels()
          table.sort(matches, function(a, b)
            return a.pos[1] > b.pos[1]
          end)
          local len = math.min(#labels, #matches)
          for i = 1, len do
            matches[i].label = labels[i]
          end
        end,
      }
    },
    config = function(conf)
      if conf.mode == "search" then
        conf.action = Flash.process_search_jump
      end
    end
  },
}

function Flash.jump(opts)
  opts = opts or {}
  local state = require("flash.repeat").get_state("jump", opts)
  state:loop({abort = opts.abort})
  return state
end

local function start_search()
  vim.api.nvim_feedkeys("zt", "n", false)
  local search = function() vim.api.nvim_input("/") end
  optional("mini.animate", search).execute_after("scroll", search)
end

function Flash.process_search_jump(match, state)
  local Jump = require("flash.plugins.search")
  local tree = require("neo-tree.sources.manager").get_state_for_window(match.win)
  if not tree then
    Jump.jump(match, state)
    return
  end
  -- do not save jumps to neo-tree in history
  state.opts.jump.register = false
  state.opts.jump.history = false
  Jump.jump(match, state)
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    once = true,
    callback = vim.schedule_wrap(function()
      -- jumped on tree node, open it
      local node = tree.tree:get_node()
      local was_loaded = node.loaded
      if not node:is_expanded() then
        tree.commands.open(tree)
      end
      if node.type == "directory" then
        if was_loaded then
          vim.schedule(start_search)
        else
          require("neo-tree.events").subscribe({
            event = "after_render",
            once = true,
            handler = start_search,
            id = "trigger_search_continuous",
          })
        end
      end
    end),
  })
end

function Flash.telescope(prompt_bufnr)
  local opts = M.opts.modes.telescope
  opts.action = function(match)
    local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
    picker:set_selection(match.pos[1] - 1)
    require("telescope.actions").select_default(prompt_bufnr)
  end
  opts.actions = require("config.keymaps").flash_in_telescope(prompt_bufnr)
  Flash.jump(opts)
end

return M
