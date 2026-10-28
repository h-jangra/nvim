local M = {}
local a, f = vim.api, vim.fn

local modes = {
  n = "N",
  i = "I",
  v = "V",
  V = "V-L",
  ["\22"] = "V-B",
  R = "R",
  s = "S",
  c = "C",
  r = "R",
  t = "T"
}

local mode_hl = { N = true, I = true, V = true, R = true, C = true, T = true }

local function git()
  local file = f.expand("%:p")
  local dir = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
  local root = vim.fs.root(dir, ".git")
  if not root then return "" end

  local gitdir = root .. "/.git"
  local x = io.open(gitdir)
  if x then
    local line = x:read("*l")
    x:close()
    local path = line and line:match("^gitdir:%s*(.+)")
    if path then
      gitdir = vim.fs.isabs(path) and path or vim.fs.normalize(vim.fs.joinpath(root, path))
    end
  end

  x = io.open(gitdir .. "/HEAD")
  if not x then return "" end
  local line = x:read("*l")
  x:close()

  local branch = line and (line:match("ref: refs/heads/(.+)") or line:sub(1, 7))
  return branch and " " .. branch or ""
end

local function lsp()
  local c = vim.lsp.get_clients({ bufnr = 0 })
  local n = {}
  for _, x in ipairs(c) do n[#n + 1] = x.name end
  return table.concat(n, ", ")
end

local function diagnostics()
  local d = vim.diagnostic.count(0)
  local out = {}
  local icons = {
    [1] = "%#StlDiagErr#󰅚 ",
    [2] = "%#StlDiagWarn#󰀦 ",
    [3] = "%#StlDiagInfo#󰋼 ",
    [4] = "%#StlDiagHint#󰌵 "
  }

  for i = 1, 4 do
    if (d[i] or 0) > 0 then
      out[#out + 1] = icons[i] .. d[i]
    end
  end

  return table.concat(out, " ")
end

function M.statusline()
  local raw = a.nvim_get_mode().mode
  local mode = modes[raw] or "N"
  local mh = "%#StlMode" .. (mode_hl[mode] and mode or "N") .. "#"

  local file = f.expand("%:~:.")
  file = file == "" and "Untitled" or vim.bo.buftype == "terminal" and "Terminal" or file

  local left = {
    mh .. " " .. mode .. " %#StlBase#", (vim.bo.modified and "%#StlModified#" or "%#StlBase#") .. file
  }

  local g = git()
  if g ~= "" then left[#left + 1] = "%#StlGitBranch#" .. g end

  local d = diagnostics()
  if d ~= "" then left[#left + 1] = d end

  local right = {}
  local l = lsp()
  if l ~= "" then right[#right + 1] = "%#StlLsp# " .. l end

  local r = table.concat(right, " ")
  return table.concat(left, " ") .. " %#StatusLine# %= " .. (r ~= "" and r .. " %#StlBase#" or "") .. mh .. " %L "
end

local g = a.nvim_create_augroup("StlEvents", { clear = true })

a.nvim_create_autocmd(
  { "DiagnosticChanged", "LspAttach", "LspDetach", "RecordingEnter", "RecordingLeave", "ColorScheme" },
  { group = g, callback = function() vim.cmd.redrawstatus() end }
)

vim.o.statusline = "%!v:lua.require('bare.status').statusline()"

return M
