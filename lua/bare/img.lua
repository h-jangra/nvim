local M = {}
local api, fs, fn = vim.api, vim.fs, vim.fn

function M.paste()
  local name = fn.input("Image filename: ")
  if name == "" then return end

  local dir = fs.dirname(api.nvim_buf_get_name(0))
  local assets = fs.joinpath(dir, "assets")
  if not vim.uv.fs_stat(assets) then vim.uv.fs_mkdir(assets, 493) end

  local path = fs.joinpath(assets, name .. ".png")
  local escaped = fn.shellescape(path)
  local cmd = os.getenv("WAYLAND_DISPLAY") and fn.executable("wl-paste") == 1
      and "wl-paste -t image/png > " .. escaped
      or fn.executable("xclip") == 1
      and "xclip -selection clipboard -t image/png -o > " .. escaped

  if not cmd then return vim.notify("No clipboard image utility found.", vim.log.levels.ERROR) end

  local res = vim.system({ "sh", "-c", cmd }):wait()
  local stat = vim.uv.fs_stat(path)

  if res.code ~= 0 or not stat or stat.size == 0 then
    if stat then vim.uv.fs_unlink(path) end
    return vim.notify("Failed to save clipboard image.", vim.log.levels.ERROR)
  end

  local rel = "./assets/" .. name .. ".png"
  local line = vim.bo.filetype == "typst"
      and string.format('#image("%s", width: 100%%)', rel)
      or string.format("![%s](%s)", name, rel)

  api.nvim_put({ line }, "c", true, true)
end

function M.delete()
  local line = api.nvim_get_current_line()
  local path = line:match("!%[.-%]%((.-)%)") or line:match('#image%("([^"]+)"')

  if not path then return vim.notify("No image found on the current line.") end

  local dir = fs.dirname(api.nvim_buf_get_name(0))
  local target = fs.normalize(fs.joinpath(dir, path))

  if not vim.startswith(target, dir .. "/") then
    return vim.notify("Image path outside document directory.", vim.log.levels.ERROR)
  end

  if vim.uv.fs_stat(target) then
    vim.uv.fs_unlink(target)
  end
end

function M.setup()
  vim.keymap.set("n", "<leader>p", M.paste, { desc = "Paste clipboard image" })
  vim.keymap.set("n", "<leader>d", M.delete, { desc = "Delete image under cursor" })
end

return M
