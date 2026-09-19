-- Highlight on yank and put (0.13: vim.hl.hl_op replaces deprecated on_yank)
vim.api.nvim_create_autocmd({ "TextYankPost", "TextPutPost" }, {
  callback = function()
    vim.hl.hl_op({ higroup = "Visual", timeout = 150 })
  end,
})

-- Floating quickfix & location list
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(ev)
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(win).relative ~= "" then return end

    local is_loc = vim.fn.getwininfo(win)[1].loclist == 1
    local qf_title = is_loc and vim.fn.getloclist(0, { title = 1 }).title or vim.fn.getqflist({ title = 1 }).title
    local title = (qf_title and qf_title ~= "") and (" " .. qf_title .. " ") or (is_loc and " Location List " or " Quickfix ")
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.min(math.max(#(is_loc and vim.fn.getloclist(0) or vim.fn.getqflist()), 3), math.floor(vim.o.lines * 0.5))

    vim.api.nvim_win_set_config(win, {
      relative = "editor",
      row = math.floor((vim.o.lines - height) / 3),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      style = "minimal",
      border = "rounded",
      title = title,
      title_pos = "center",
    })

    local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
    local prev_buf = prev_win > 0 and vim.api.nvim_win_get_buf(prev_win) or vim.fn.bufnr("#")
    local orig_list = is_loc and vim.fn.getloclist(0) or vim.fn.getqflist()
    local filtered = false

    local opts = { buffer = ev.buf, silent = true, nowait = true }
    vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
    vim.keymap.set("n", "<CR>", "<CR><cmd>pcall(vim.cmd, 'cclose')<cr><cmd>pcall(vim.cmd, 'lclose')<cr>", opts)

    -- Toggle filter between all entries and current buffer entries
    vim.keymap.set("n", "b", function()
      if not filtered then
        local cur_items = vim.tbl_filter(function(item)
          return item.bufnr == prev_buf
        end, orig_list)
        if #cur_items > 0 then
          if is_loc then
            vim.fn.setloclist(0, cur_items, "r")
          else
            vim.fn.setqflist(cur_items, "r")
          end
          filtered = true
          vim.notify("Showing current buffer (" .. #cur_items .. " items)", vim.log.levels.INFO)
        else
          vim.notify("No items for current buffer", vim.log.levels.WARN)
        end
      else
        if is_loc then
          vim.fn.setloclist(0, orig_list, "r")
        else
          vim.fn.setqflist(orig_list, "r")
        end
        filtered = false
        vim.notify("Showing all buffers (" .. #orig_list .. " items)", vim.log.levels.INFO)
      end
    end, opts)
  end,
})
