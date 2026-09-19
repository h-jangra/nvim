local M = {}

local function open(cmd, list, msg)
  if #list() == 0 then
    return vim.notify(msg, vim.log.levels.INFO)
  end
  vim.cmd(cmd)
end

function M.workspace()
  vim.diagnostic.setqflist({ open = false })
  open("copen", vim.fn.getqflist, "No workspace diagnostics")
end
M.picker_workspace = M.workspace

function M.buffer()
  local items = vim.diagnostic.toqflist(vim.diagnostic.get(0))
  vim.fn.setqflist(items, "r")
  vim.fn.setqflist({}, "a", { title = "Diagnostics: " .. (vim.fs.basename(vim.api.nvim_buf_get_name(0)) or "Current Buffer") })
  open("copen", vim.fn.getqflist, "No buffer diagnostics")
end
M.picker_buffer = M.buffer

function M.open_float()
  vim.diagnostic.open_float({ border = "rounded" })
end
M.float = M.open_float

function M.jump(count, severity)
  vim.diagnostic.jump({ count = count, float = true, severity = severity })
  vim.cmd("normal! zz")
end

function M.next_error()
  M.jump(1, vim.diagnostic.severity.ERROR)
end

function M.prev_error()
  M.jump(-1, vim.diagnostic.severity.ERROR)
end

function M.next_warn()
  M.jump(1, vim.diagnostic.severity.WARN)
end

function M.prev_warn()
  M.jump(-1, vim.diagnostic.severity.WARN)
end

function M.toggle()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end

function M.toggle_qf()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.getwininfo(win)[1].quickfix == 1 and vim.fn.getwininfo(win)[1].loclist == 0 then
      vim.cmd("cclose")
      return
    end
  end
  -- Populate with current buffer diagnostics only so it does not dump other buffers
  local items = vim.diagnostic.toqflist(vim.diagnostic.get(0))
  vim.fn.setqflist(items, "r")
  vim.fn.setqflist({}, "a", { title = "Diagnostics: " .. (vim.fs.basename(vim.api.nvim_buf_get_name(0)) or "Current Buffer") })
  open("copen", vim.fn.getqflist, "No diagnostics")
end

function M.toggle_loc()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.fn.getwininfo(win)[1].loclist == 1 then
      vim.cmd("lclose")
      return
    end
  end
  vim.diagnostic.setloclist({ open = false })
  open("lopen", function()
    return vim.fn.getloclist(0)
  end, "No diagnostics")
end

function M.copy_line()
  local diags = vim.diagnostic.get(0, {
    lnum = vim.fn.line(".") - 1,
  })

  if #diags > 0 then
    vim.fn.setreg("+", table.concat(vim.tbl_map(function(d)
      return d.message
    end, diags), "\n"))
  end
end

function M.setup()
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded" },
  })

  local map = vim.keymap.set
  map("n", "]d", function() M.jump(1) end, { desc = "Next Diagnostic" })
  map("n", "[d", function() M.jump(-1) end, { desc = "Prev Diagnostic" })
  map("n", "]e", M.next_error, { desc = "Next Error" })
  map("n", "[e", M.prev_error, { desc = "Prev Error" })
  map("n", "]w", M.next_warn, { desc = "Next Warning" })
  map("n", "[w", M.prev_warn, { desc = "Prev Warning" })
end

return M
