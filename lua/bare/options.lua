local opt = vim.opt

opt.cmdheight = 1
opt.laststatus = 3
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.scrolloffpad = 8 -- 0.13: Keep cursor centered at end of buffer
opt.showtabline = 0
opt.signcolumn = "yes:1"
opt.termguicolors = true
opt.wrap = true

opt.shortmess:append("IcFsWu")                                   -- 0.13: 'u' silences undo/redo messages
opt.autocomplete = true
opt.complete = { ".", "w" }
opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
opt.previewpopup = "height:12,width:60,border:rounded"           -- 0.13: Floating preview window options
opt.winborder = "rounded"

-- Treesitter & LSP native folding (0.13)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = "v:lua.vim.lsp.foldtext()" -- 0.13: LSP highlighted fold text
vim.o.foldenable = false
vim.o.foldlevel = 99

opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.softtabstop = 2
opt.tabstop = 2

opt.incsearch = true

opt.autoread = true -- 0.13: Real-time file change detection via libuv filesystem watchers
opt.backup = false
opt.swapfile = false
opt.backupcopy = "yes"
opt.undodir = vim.fs.joinpath(vim.fn.stdpath("data"), "undodir")
opt.undofile = true

opt.mousescroll = "ver:5,hor:0"
opt.synmaxcol = 240
opt.timeoutlen = 300
opt.ttimeoutlen = 10
opt.updatetime = 200
opt.winheight = 1

vim.opt.shadafile = ""
