local lsp = { "nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
      },
      severity_sort = true,
    },
    -- TODO Add support for Inlay hints
    -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
    -- Be aware that you also will need to properly configure your LSP server to
    -- provide the inlay hints.
    inlay_hints = {
      enabled = false,
    },
    -- add any global capabilities here
    capabilities = {},
    -- TODO Setup and configure formatters and autoformat
    -- Automatically format on save
    autoformat = false,
    -- Enable this to show formatters used in a notification
    -- Useful for debugging formatter issues
    format_notify = false,
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    setup = {},
  }
}

local clangd = { "clangd_extensions.nvim",
  opts = {
    inlay_hints = {
      inline = false,
    },
    ast = {
      --These require codicons (https://github.com/microsoft/vscode-codicons)
      role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
      },
      kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
      },
    },
  },
}

lsp.opts.servers = {
  jsonls = {},
  lua_ls = {
    -- keys = {},
    settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
        },
        completion = {
          callSnippet = "Replace",
        },
        diagnostics = {
          globals = {"vim"}
        },
      },
    },
  },

  -- Python
  pyright = {},
  ruff_lsp = {},

  clangd = {
    keys = {
      { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
    },
    root_dir = function(fname)
      return require("lspconfig.util").root_pattern(
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja"
      )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
          fname
        ) or require("lspconfig.util").find_git_ancestor(fname)
    end,
    capabilities = {
      offsetEncoding = { "utf-16" },
    },
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
}

-- you can do any additional lsp server setup here
-- return true if you don't want this server to be setup with lspconfig
-- example to setup with typescript.nvim
-- tsserver = function(_, opts)
--   require("typescript").setup({ server = opts })
--   return true
-- end,
-- Specify * to use this function as a fallback for any server
-- lsp.opts.setup["*"] = function(server, opts) end,

function lsp.opts.setup.clangd(_, opts)
  require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd.opts, { server = opts }))
  return false
end

function lsp.opts.setup.ruff_lsp()
  -- require("lazyvim.util").on_attach(function(client, _)
  -- if client.name == "ruff_lsp" then
  -- -- Disable hover in favor of Pyright
  -- client.server_capabilities.hoverProvider = false
  -- end
  -- end)
end

function lsp.on_attach(client, buffer)
  local conf = require("config.keymaps").lsp
  local maps = conf.any:copy()
  if conf[client.name] then
    maps:extend(conf[client.name]):resolve()
  end
  maps:filter(function(map)
    local method = map.has
    if not method then
      return true
    end
    method = method:find("/") and method or "textDocument/" .. method
    return client.supports_method(method, {bufnr = buffer})
  end)
  maps:set(buffer)
end

function lsp.config(_, opts)
  -- setup autoformat
  -- require("lazyvim.plugins.lsp.format").setup(opts)
  -- setup formatting and keymaps
  -- Util.on_attach(function(client, buffer)
  --  require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
  -- end)

  local servers = opts.servers
  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities(),
    opts.capabilities
  )

  local function setup(server)
    local server_opts = servers[server]
    if not server_opts then
      return
    end
    server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(capabilities),
    }, server_opts or {})

    if opts.setup[server] then
      if opts.setup[server](server, server_opts) then
        return
      end
    elseif opts.setup["*"] then
      if opts.setup["*"](server, server_opts) then
        return
      end
    end
    require("lspconfig")[server].setup(server_opts)
  end

  for server, _ in pairs(servers) do
    setup(server)
  end
  require("util.lsp").on_attach(lsp.on_attach)
end


return require("core.plugin_spec").spec({
  clangd,
  lsp,
})
