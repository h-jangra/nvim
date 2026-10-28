local map = vim.keymap.set
local opts = { silent = true }

map("n", "<Esc>", "<cmd>nohlsearch<cr>", opts)
map("n", "<C-s>", "<cmd>silent write<cr>", opts)
map("n", "<leader>o", "<cmd>silent update<cr>:source %<cr>", { desc = "Save & Reload" })
map("n", "<A-q>", "<cmd>qall!<cr>", opts)
map("n", "<leader>a", "ggVG", { desc = "Select All" })
map("v", "<leader>s", ":'<,'>sort<CR>")

map("x", "<leader>=", function()
  local a, b = vim.fn.getpos("v")[2], vim.fn.line(".")
  local first, last = math.min(a, b), math.max(a, b)
  local sep = vim.fn.input("Delimiter: ")
  if sep == "" then return end

  local rows, widths = {}, {}
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, first - 1, last, false)) do
    rows[i] = vim.split(line, sep, { plain = true })
    for j, cell in ipairs(rows[i]) do
      rows[i][j] = vim.trim(cell)
      widths[j] = math.max(widths[j] or 0, #rows[i][j])
    end
  end

  for i, row in ipairs(rows) do
    for j, cell in ipairs(row) do
      row[j] = cell .. string.rep(" ", widths[j] - #cell)
    end
    rows[i] = table.concat(row, " " .. sep .. " "):gsub("%s+$", "")
  end

  vim.api.nvim_buf_set_lines(0, first - 1, last, false, rows)
end, { desc = "Align Columns" })

-- Explorer
map("n", "<leader>e", function() require("bare.filetree").toggle() end, { desc = "Toggle File Explorer" })

-- Clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to Clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank Line to Clipboard" })
map("n", "<C-c>", "<cmd>%y+<cr>", { desc = "Copy File to Clipboard" })

-- Buffers
map("n", "<Tab>", "<cmd>bnext<cr>", opts)
map("n", "<S-Tab>", "<cmd>bprevious<cr>", opts)
map("n", "<leader>b", "<cmd>bdelete!<cr>", { desc = "Close Buffer" })
map("n", "<leader>z", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, { desc = "Close all but current" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- Move lines
map("n", "<A-j>", ":m .+1<cr>==", opts)
map("n", "<A-k>", ":m .-2<cr>==", opts)
map("i", "<A-j>", "<Esc>:m .+1<cr>==gi", opts)
map("i", "<A-k>", "<Esc>:m .-2<cr>==gi", opts)
map("v", "<A-j>", ":m '>+1<cr>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<cr>gv=gv", opts)

-- Delete/change (don't yank)
map("v", "x", '"_x', opts)
map("v", "c", '"_c', opts)

-- Find and replace
map("n", "<leader>fr", function()
  local find = vim.fn.input("Find: ")
  if find == "" then return end
  local replace = vim.fn.input("Replace: ")
  vim.cmd("%s/" .. find .. "/" .. replace .. "/gc")
end, { desc = "Find & Replace" })

-- Copy diagnostics to clipboard
map("n", "<leader>cd", function()
  local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #diags > 0 then
    vim.fn.setreg("+", table.concat(vim.tbl_map(function(d) return d.message end, diags), "\n"))
  end
end, { desc = "Copy Line Diagnostics" })

-- LSP
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })
map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true, timeout_ms = 2000 }) end, { desc = "LSP Format" })
map("n", "<leader>li", "gg=G``", { desc = "Indent Entire File" })
map("n", "<leader>ds", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
map("n", "<leader>ws", function()
  vim.ui.input({ prompt = "Workspace Symbol: " }, function(query)
    if query and query ~= "" then
      vim.lsp.buf.workspace_symbol(query)
    end
  end)
end, { desc = "Workspace Symbols" })

-- Diagnostics & Quickfix Panel
map("n", "gl", function() vim.diagnostic.open_float({ border = "rounded" }) end, { desc = "Line Diagnostics" })
map("n", "<leader>xx", vim.diagnostic.setqflist, { desc = "Workspace Diagnostics" })
map("n", "<leader>xX", function()
  vim.fn.setqflist(vim.diagnostic.toqflist(vim.diagnostic.get(0)), "r")
  vim.cmd("copen")
end, { desc = "Buffer Diagnostics" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev Diagnostic" })
map("n", "]e", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,
  { desc = "Next Error" })
map("n", "[e", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end,
  { desc = "Prev Error" })
map("n", "]w", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN }) end,
  { desc = "Next Warning" })
map("n", "[w", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN }) end,
  { desc = "Prev Warning" })

-- Git (navigation, preview, revert)
map("n", "]h", function() require("bare.git").next_hunk() end, { desc = "Next Git Hunk" })
map("n", "[h", function() require("bare.git").prev_hunk() end, { desc = "Prev Git Hunk" })
map("n", "<leader>gp", function() require("bare.git").preview_hunk() end, { desc = "Git Preview Hunk" })
map("n", "<leader>gr", function() require("bare.git").revert_hunk() end, { desc = "Git Revert Hunk" })
map("n", "<leader>gR", function() require("bare.git").revert_file() end, { desc = "Git Revert File" })

map("n", "<leader>n", function() require("bare.notify").show_history() end, { desc = "Show Notification History" })

map("n", "<leader>fc", "<cmd>edit " .. vim.fn.stdpath("config") .. "/init.lua<cr>", { desc = "Edit Config" })

map("i", { "jk", "kj" }, "<Esc>", opts)
map("i", "<C-s>", "<Esc><cmd>silent write<cr>", opts)
