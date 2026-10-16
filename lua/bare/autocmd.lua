vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.hl_op({ higroup = "Visual", timeout = 150 })
  end,
})
