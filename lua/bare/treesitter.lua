-- Minimal native Treesitter textobjects and motions for Neovim 0.13+
--
-- Textobjects (Visual 'v' & Operators 'd', 'c', 'y'):
-- if / af : Inner / Around Function or Method (vif, vaf, dif, daf, cif, caf, yif, yaf)
-- ic / ac : Inner / Around Class or Struct   (vic, vac, dic, dac, cic, cac, yic, yac)
-- ia / aa : Inner / Around Parameter/Argument(via, vaa, dia, daa, cia, caa, yia, yaa)
-- ii / ai : Inner / Around Conditional       (vii, vai, dii, dai, cii, cai, yii, yai)
-- il / al : Inner / Around Loop (for, while) (vil, val, dil, dal, cil, cal, yil, yal)
-- ib / ab : Inner / Around Block / Body      (vib, vab, dib, dab, cib, cab, yib, yab)
--
-- Motions:
-- ]f / [f : Next / Previous Function Start
-- ]F / [F : Next / Previous Function End
-- ]c / [c : Next / Previous Class Start
-- ]C / [C : Next / Previous Class End

local M = {}

local NODE_TYPES = {
  f = {
    "function_declaration", "function_definition", "local_function", "function_item",
    "method_declaration", "method_definition", "arrow_function", "closure_expression",
    "func_literal", "anonymous_function", "constructor_declaration", "method",
  },
  c = {
    "class_definition", "class_declaration", "class_specifier", "struct_specifier",
    "struct_item", "impl_item", "interface_declaration", "record_declaration", "trait_item",
  },
  a = { "parameter", "formal_parameter" },
  i = { "if_statement", "if_expression", "switch_statement", "match_expression", "case_statement" },
  l = { "for_statement", "for_in_statement", "while_statement", "repeat_statement", "loop_expression" },
  b = { "block", "compound_statement", "statement_list", "body" },
}

local function match_type(node, kind)
  if not node or not node:named() then return false end
  local t = node:type()
  if kind == "a" and (t:match("parameter") or t:match("param") or (node:parent() and node:parent():type():match("parameter"))) then
    return not t:match("parameters")
  end
  for _, target in ipairs(NODE_TYPES[kind] or {}) do
    if t == target then return true end
  end
  return false
end

local function find_node(kind)
  local cur = vim.api.nvim_win_get_cursor(0)
  local node = vim.treesitter.get_node({ pos = { cur[1] - 1, cur[2] } })
  while node do
    if match_type(node, kind) then return node end
    node = node:parent()
  end
end

local function get_range(node, inner)
  local sr, sc, er, ec = node:range()
  if not inner then
    return sr, sc, er, ec, er > sr
  end

  local body = node:field("body")[1] or node:field("consequence")[1]
  if not body then
    for child in node:iter_children() do
      if match_type(child, "b") then body = child; break end
    end
  end
  if not body then return sr, sc, er, ec, er > sr end

  local bsr, bsc, ber, bec = body:range()
  local lines = vim.api.nvim_buf_get_lines(0, bsr, ber + 1, false)
  local first, last = lines[1] or "", lines[#lines] or ""

  if first:sub(bsc + 1, bsc + 1) == "{" and last:sub(bec, bec) == "}" then
    if ber > bsr + 1 then
      return bsr + 1, 0, ber - 1, #(lines[#lines - 1] or ""), true
    elseif ber == bsr then
      local txt = first:sub(bsc + 2, bec - 1)
      local l = (txt:match("^%s*()") or 1) - 1
      local r = #txt - (txt:match(".*()%S") or #txt)
      return bsr, bsc + 1 + l, ber, bec - 1 - r, false
    end
  end
  return bsr, 0, ber, #(lines[#lines] or ""), ber > bsr
end

function M.select(kind, inner)
  local node = find_node(kind)
  if not node then return end
  local sr, sc, er, ec, linewise = get_range(node, inner)
  local mode = vim.api.nvim_get_mode().mode
  local in_v = mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V"

  if linewise then
    if not in_v or mode ~= "V" then vim.cmd("normal! V") end
    vim.api.nvim_win_set_cursor(0, { sr + 1, 0 })
    vim.cmd("normal! o")
    vim.api.nvim_win_set_cursor(0, { er + 1, 0 })
  else
    if in_v and mode == "V" then vim.cmd("normal! v") elseif not in_v then vim.cmd("normal! v") end
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd("normal! o")
    vim.api.nvim_win_set_cursor(0, { er + 1, math.max(0, ec - 1) })
  end
end

function M.jump(kind, forward, end_pos)
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if not ok or not parser then return end
  local tree = parser:parse()[1]
  if not tree then return end

  local cur = vim.api.nvim_win_get_cursor(0)
  local targets = {}
  local function walk(n)
    if match_type(n, kind) then
      local sr, sc, er, ec = n:range()
      table.insert(targets, { row = (end_pos and er or sr) + 1, col = end_pos and ec or sc })
    end
    for ch in n:iter_children() do walk(ch) end
  end
  walk(tree:root())

  table.sort(targets, function(a, b) return a.row < b.row or (a.row == b.row and a.col < b.col) end)
  if forward then
    for _, t in ipairs(targets) do
      if t.row > cur[1] or (t.row == cur[1] and t.col > cur[2]) then
        return vim.api.nvim_win_set_cursor(0, { t.row, t.col })
      end
    end
  else
    for i = #targets, 1, -1 do
      local t = targets[i]
      if t.row < cur[1] or (t.row == cur[1] and t.col < cur[2]) then
        return vim.api.nvim_win_set_cursor(0, { t.row, t.col })
      end
    end
  end
end

function M.setup()
  for _, obj in ipairs({
    { "f", "function" }, { "c", "class" }, { "a", "parameter" },
    { "i", "conditional" }, { "l", "loop" }, { "b", "block" },
  }) do
    local k, name = obj[1], obj[2]
    vim.keymap.set({ "x", "o" }, "i" .. k, function() M.select(k, true) end, { silent = true, desc = "Inner " .. name })
    vim.keymap.set({ "x", "o" }, "a" .. k, function() M.select(k, false) end, { silent = true, desc = "Around " .. name })
  end

  vim.keymap.set({ "n", "x", "o" }, "]f", function() M.jump("f", true, false) end, { silent = true, desc = "Next function start" })
  vim.keymap.set({ "n", "x", "o" }, "[f", function() M.jump("f", false, false) end, { silent = true, desc = "Prev function start" })
  vim.keymap.set({ "n", "x", "o" }, "]F", function() M.jump("f", true, true) end, { silent = true, desc = "Next function end" })
  vim.keymap.set({ "n", "x", "o" }, "[F", function() M.jump("f", false, true) end, { silent = true, desc = "Prev function end" })
  vim.keymap.set({ "n", "x", "o" }, "]c", function() M.jump("c", true, false) end, { silent = true, desc = "Next class start" })
  vim.keymap.set({ "n", "x", "o" }, "[c", function() M.jump("c", false, false) end, { silent = true, desc = "Prev class start" })
end

return M
