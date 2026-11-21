vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

vim.keymap.set("n", "gf", function()
  local line = vim.api.nvim_get_current_line()
  local candidates = {}
  for m in line:gmatch("require[%s%(]+['\"]([%w%.%_%-]+)['\"]") do
    local p = m:gsub("%.", "/")
    candidates[#candidates + 1] = vim.api.nvim_get_runtime_file("lua/" .. p .. ".lua", false)[1]
    candidates[#candidates + 1] = vim.api.nvim_get_runtime_file("lua/" .. p .. "/init.lua", false)[1]
  end
  for m in line:gmatch("[~%w_./%-%+]+") do
    candidates[#candidates + 1] = m
  end
  for _, p in ipairs(candidates) do
    if p and p ~= "" then
      p = vim.fn.expand((p:gsub("^['\"]", ""):gsub("['\"),;:]+$", "")))
      local f = vim.fn.filereadable(p) == 1 and p or vim.fn.findfile(p)
      if f ~= "" then return vim.cmd.edit(vim.fn.fnameescape(f)) end
    end
  end
end, { desc = "Go to file" })

-- Copy relative path
vim.keymap.set('n', '<leader>cf', function()
  vim.fn.setreg('+', vim.fn.expand('%:p'))
end, { desc = "Copy absolute file path" })

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
