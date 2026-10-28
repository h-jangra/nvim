local servers = {
  luals = {
    cmd = { "lua-language-server" },
    ft = { "lua" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" }, disable = { "undefined-global" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    ft = { "python" },
    settings = { python = { analysis = { autoImportCompletions = true } } },
  },
  tsls = {
    cmd = { "typescript-language-server", "--stdio" },
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    settings = {
      typescript = { suggest = { autoImports = true } },
      javascript = { suggest = { autoImports = true } },
    },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    ft = { "rust" },
    settings = {
      ["rust-analyzer"] = { cargo = { allFeatures = true }, checkOnSave = true, procMacro = { enable = true } },
    },
  },
  gopls = {
    cmd = { "gopls" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    settings = {
      gopls = {
        completeUnimported = true,
        gofumpt = true,
        staticcheck = true,
        analyses = { unusedparams = true },
      },
    },
  },
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
    },
    ft = { "c", "cpp", "objc", "objcpp" },
  },
  html = { cmd = { "vscode-html-language-server", "--stdio" }, ft = { "html" } },
  cssls = { cmd = { "vscode-css-language-server", "--stdio" }, ft = { "css", "scss", "less" } },
  jsonls = { cmd = { "vscode-json-language-server", "--stdio" }, ft = { "json" } },
  taplo = { cmd = { "taplo", "lsp", "stdio" }, ft = { "toml" } },
  bash_ls = { cmd = { "bash-language-server", "start" }, ft = { "bash", "sh" } },
  ansiblels = { cmd = { "ansible-language-server", "--stdio" }, ft = { "yaml", "yml" } },
  tinymist = { cmd = { "tinymist", "lsp" }, ft = { "typst" } },
  jdtls = {
    cmd = { "jdtls" },
    ft = { "java" },
    settings = {
      java = {
        saveActions = { organizeImports = true },
        completion = { enabled = true, guessMethodArguments = true, lazyResolveTextEdit = true },
        signatureHelp = { enabled = false },
        configuration = { updateBuildConfiguration = "interactive" },
      },
    },
  },
  tailwindcss = {
    cmd = { "tailwindcss-language-server", "--stdio" },
    ft = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
  },
  qmlls = { cmd = { "qml-language-server" }, ft = { "qml" } },
  nimls = { cmd = { "nimlangserver" }, ft = { "nim", "nimble" } },
  yml = { cmd = { "yaml-language-server", "--stdio" }, ft = { "yaml", "yml" } },
  kotlin = { cmd = { "kotlin-lsp" }, ft = { "kotlin" } },
  zls = { cmd = { "zls" }, ft = { "zig" } },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

local root_markers = {
  ".git", "pom.xml", "build.gradle", "mvnw", "gradlew", "package.json", "Cargo.toml",
  "go.mod", "pyproject.toml", "setup.py", "requirements.txt", ".venv", ".luarc.json", "stylua.toml",
}

vim.lsp.inlay_hint.enable(true)

for name, cfg in pairs(servers) do
  if vim.fn.executable(cfg.cmd[1]) == 1 then
    vim.lsp.config[name] = {
      cmd = cfg.cmd,
      filetypes = cfg.ft,
      root_markers = root_markers,
      settings = cfg.settings,
      capabilities = capabilities,
      on_attach = on_attach,
    }
    vim.lsp.enable(name)
  end
end
