local editor = require("config.editor")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.clipboard = ""
opt.guifont = "JetBrainsMono Nerd Font:h11"
opt.termguicolors = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

opt.incsearch = true
opt.hlsearch = false

opt.ignorecase = true
opt.smartcase = true

opt.updatetime = 2000

opt.number = true
editor.set_hybridnumber(true)
editor.watch_win_size()

opt.list = true
opt.showbreak="↪"
opt.listchars="tab: ⎯→,nbsp:␣,lead:•,multispace:•,trail:•,extends:⟩,precedes:⟨"

