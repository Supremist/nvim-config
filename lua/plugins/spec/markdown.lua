return require("core.plugin_spec").spec({
  { "markdown-preview.nvim",
    optional = true,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_browser = "C:/Program Files/Mozilla Firefox/firefox.exe"
      vim.g.mkdp_echo_preview_url = 1
    end,
    ft = { "markdown" },
  },
})
