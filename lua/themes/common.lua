local M = {}

function M.create(name, colors)
  local theme = {
    name = name,
    colors = colors,
    config = { blur = true },
  }

  function theme.setup(opts)
    if opts then
      theme.config = vim.tbl_deep_extend("force", theme.config, opts)
    end

    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
      vim.cmd("syntax reset")
    end

    vim.g.colors_name = name

    local blur = theme.config.blur
    local bg_base = blur and colors.none or colors.base
    local bg_mantle = blur and colors.none or colors.mantle
    local bg_crust = blur and colors.none or colors.crust
    local bg_status = blur and colors.none or colors.surface0

    local highlights = {
      -- Basic UI
      Normal = { fg = colors.text, bg = bg_base },
      NormalNC = { link = "Normal" },
      Comment = { fg = colors.surface2, italic = true },

      -- Syntax
      Constant = { fg = colors.peach },
      String = { fg = colors.green },
      Character = { link = "String" },
      Identifier = { fg = colors.mauve },
      Function = { fg = colors.blue },
      Statement = { fg = colors.mauve },
      Operator = { fg = colors.sky },
      Keyword = { fg = colors.sapphire },
      Exception = { fg = colors.red },
      PreProc = { fg = colors.yellow },
      Include = { fg = colors.mauve },
      Define = { link = "Include" },
      Macro = { link = "Include" },
      Type = { fg = colors.sapphire },
      StorageClass = { fg = colors.mauve },
      Structure = { link = "StorageClass" },
      Typedef = { link = "StorageClass" },
      Special = { fg = colors.sapphire },
      SpecialChar = { fg = colors.red },
      Tag = { fg = colors.peach },
      Delimiter = { fg = colors.subtext0 },
      SpecialComment = { fg = colors.surface2 },
      Debug = { fg = colors.red },

      -- UI elements
      LineNr = { fg = colors.overlay0, bg = colors.none },
      CursorLineNr = { fg = colors.peach, bold = true, bg = colors.none },
      CursorLine = { bg = colors.surface0 },
      CursorColumn = { bg = colors.surface0 },
      ColorColumn = { bg = colors.crust },
      Conceal = { fg = colors.surface1 },
      Cursor = { fg = colors.base, bg = colors.text },
      Directory = { fg = colors.blue },
      EndOfBuffer = { fg = colors.base, bg = bg_base },
      ErrorMsg = { fg = colors.red },
      Folded = { fg = colors.blue, bg = colors.overlay0 },
      FoldColumn = { bg = bg_base, fg = colors.surface2 },
      SignColumn = { bg = bg_base, fg = colors.overlay0 },
      MatchParen = { fg = colors.peach, bold = true },
      NonText = { fg = colors.crust },
      NormalFloat = { fg = colors.text, bg = bg_base },
      FloatBorder = { fg = colors.blue, bg = bg_base },
      FloatTitle = { fg = colors.blue, bold = true },
      FloatFooter = { fg = colors.overlay1, italic = true },
      NotifyFloat = { fg = colors.text, bg = colors.mantle },
      NotifyFloatBorder = { fg = colors.blue, bg = colors.mantle },

      -- Dimmed & Multiple Cursors
      Dimmed = { fg = colors.surface2 },
      MultiCursor = { fg = colors.base, bg = colors.peach },
      MultiCursorMain = { fg = colors.base, bg = colors.teal, bold = true },

      -- Status line and tabs
      StatusLine = { fg = colors.text, bg = bg_mantle },
      StatusLineNC = { fg = colors.surface2, bg = bg_mantle },
      TabLine = { bg = bg_mantle, fg = colors.overlay0 },
      TabLineFill = { bg = bg_crust },
      TabLineSel = { fg = colors.crust, bg = colors.blue },

      -- Winbar / bufferline
      WinBar = {},
      WinBarNC = {},
      WinBarActive = { fg = colors.base, bg = colors.sky, bold = true },
      WinBarInactive = { fg = colors.blue, bg = colors.surface1 },

      -- Statusline segments
      StlBase = { fg = colors.subtext1, bg = bg_status },
      StlModified = { fg = colors.green, bg = bg_status },
      StlGitBranch = { fg = colors.sky, bg = bg_status },
      StlLsp = { fg = colors.teal, bg = bg_status },
      StlDiagErr = { fg = colors.red, bg = bg_status },
      StlDiagWarn = { fg = colors.yellow, bg = bg_status },
      StlDiagInfo = { fg = colors.sky, bg = bg_status },
      StlDiagHint = { fg = colors.teal, bg = bg_status },
      StlModeN = { fg = colors.base, bg = colors.sky, bold = true },
      StlModeI = { fg = colors.base, bg = colors.text, bold = true },
      StlModeV = { fg = colors.base, bg = colors.teal, bold = true },
      StlModeR = { fg = colors.base, bg = colors.green, bold = true },
      StlModeC = { fg = colors.base, bg = colors.mauve, bold = true },
      StlModeT = { fg = colors.base, bg = colors.teal, bold = true },

      -- Visual mode & Search
      Visual = { bg = colors.surface1 },
      Search = { bg = colors.surface2, fg = colors.text },
      IncSearch = { bg = colors.peach, fg = colors.crust },
      CurSearch = { link = "IncSearch" },

      -- Pmenu
      Pmenu = { bg = bg_base, fg = colors.text },
      PmenuSel = { bg = colors.surface0, fg = colors.blue, bold = true, sp = colors.blue },
      PmenuSbar = { bg = bg_base },
      PmenuThumb = { bg = colors.blue },
      PmenuMatch = { fg = colors.peach, bold = true, sp = colors.peach },
      PmenuMatchSel = { link = "PmenuMatch" },
      PmenuBorder = { fg = colors.teal, bg = bg_base },
      PmenuShadow = { fg = colors.teal, bg = bg_base },

      -- Diagnostics
      DiagnosticError = { fg = colors.red },
      DiagnosticWarn = { fg = colors.yellow },
      DiagnosticInfo = { fg = colors.sapphire },
      DiagnosticHint = { fg = colors.teal },
      DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
      DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow },
      DiagnosticUnderlineInfo = { undercurl = true, sp = colors.sapphire },
      DiagnosticUnderlineHint = { undercurl = true, sp = colors.teal },

      -- LSP
      LspReferenceText = { bg = colors.overlay0 },
      LspGhostText = { fg = colors.surface2, italic = true },

      -- Special
      Todo = { bg = colors.yellow, fg = colors.base },
      Underlined = { underline = true },
      Bold = { bold = true, fg = colors.text },
      Italic = { italic = true, fg = colors.text },

      -- Git
      diffAdded = { fg = colors.green },
      diffChanged = { fg = colors.yellow },
      diffRemoved = { fg = colors.red },
      BareGitAdd = { fg = colors.green, bold = true },
      BareGitChange = { fg = colors.sapphire, bold = true },
      BareGitDelete = { fg = colors.red, bold = true },
      BareGitUntracked = { fg = colors.teal, bold = true },
      BareGitRenamed = { fg = colors.mauve, bold = true },
      BareGitIgnored = { fg = colors.surface2, italic = true },

      -- File manager
      BareFilesDir = { link = "Directory" },
      BareFilesFile = { link = "Normal" },
      BareFilesHidden = { link = "Comment" },

      WinSeparator = { fg = colors.surface1 },
    }

    for group, hl_opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, hl_opts)
    end
  end

  function theme.toggle_blur()
    theme.config.blur = not theme.config.blur
    theme.setup()
  end

  return theme
end

return M
