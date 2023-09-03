return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  -- https://github.com/nvim-treesitter/nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    -- dependencies = {
      -- {
        -- "nvim-treesitter/nvim-treesitter-textobjects",
        -- init = function()
          -- -- disable rtp plugin, as we only need its queries for mini.ai
          -- -- In case other textobject modules are enabled, we will load them
          -- -- once nvim-treesitter is loaded
          -- require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        -- end,
      -- },
    -- },
    cmd = { "TSUpdateSync" },
	-- TODO Incremental selection keybinds
    -- keys = {
      -- { "<c-space>", desc = "Increment selection" },
      -- { "<bs>", desc = "Decrement selection", mode = "x" },
    -- },
    ---@type TSConfig
    opts = {
      highlight = { 
	    enable = true,
		 -- Use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
		disable = function(lang, buf)
			local max_filesize = 500 * 1024 -- 500 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	  },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "cmake",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "vim",
        "vimdoc",
        "yaml",
      },
      -- incremental_selection = {
        -- enable = true,
        -- keymaps = {
          -- init_selection = "<C-space>",
          -- node_incremental = "<C-space>",
          -- scope_incremental = false,
          -- node_decremental = "<bs>",
        -- },
      -- },
    },
    ---@param opts TSConfig
    config = function(_, opts)
	-- Maybe filter duplicate opts here?
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}