local opt = vim.opt

opt.laststatus = 3
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloffpad = 8
opt.scrolloff = 8
opt.showtabline = 0
opt.signcolumn = "yes:1"
opt.termguicolors = true

-- opt.shortmess:append("IcFsWu")
opt.autocomplete = true
opt.complete = { ".", "w" }
opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }
opt.winborder = "rounded"

vim.o.foldenable = false
vim.o.foldlevel = 99

opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.softtabstop = 2
opt.tabstop = 2

opt.swapfile = false
opt.backupcopy = "yes"
opt.undofile = true

opt.mousescroll = "ver:5,hor:0"
opt.synmaxcol = 240
opt.timeoutlen = 300
opt.ttimeoutlen = 10
opt.updatetime = 200
