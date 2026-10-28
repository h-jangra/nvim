vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.hl_op({ higroup = "Visual", timeout = 150 })
  end,
})

local lsp_format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_format_group,
  callback = function(args)
    local buf = args.buf
    local clients = vim.lsp.get_clients({ bufnr = buf })

    -- Organize imports
    for _, client in ipairs(clients) do
      if client:supports_method("textDocument/codeAction") then
        local results = vim.lsp.buf_request_sync(buf, "textDocument/codeAction", {
          textDocument = vim.lsp.util.make_text_document_params(buf),
          context = { only = { "source.organizeImports" } },
        }, 1000)

        for client_id, res in pairs(results or {}) do
          local cl = vim.lsp.get_client_by_id(client_id)
          for _, action in ipairs(res.result or {}) do
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, cl and cl.offset_encoding or "utf-8")
            elseif action.command and cl then
              cl:exec_cmd(action.command, { bufnr = buf })
            end
          end
        end
        break
      end
    end

    -- Format buffer
    for _, client in ipairs(clients) do
      if client:supports_method("textDocument/formatting") then
        vim.lsp.buf.format({ bufnr = buf, timeout_ms = 1000 })
        break
      end
    end
  end,
})
