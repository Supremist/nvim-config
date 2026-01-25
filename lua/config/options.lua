local editor = require("config.editor")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.clipboard = ""
opt.guifont = "JetBrainsMono Nerd Font:h11"
opt.termguicolors = true
opt.shell = 'nu'

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
opt.cursorline = true

opt.list = true
opt.showbreak="↪"
opt.listchars="tab: ⎯→,nbsp:␣,lead:•,multispace:•,trail:•,extends:⟩,precedes:⟨"
opt.virtualedit="block,onemore"

opt.sessionoptions="buffers,curdir,folds,help,tabpages,winsize,terminal,skiprtp" -- winpos,resize

-- exclude -_ from default keyword chars
-- opt.iskeyword = "@,48-57,192-255,^-"

opt.fileformats="unix,dos"
-- Undo persistence
opt.undofile = true
opt.undolevels = 2000 -- Max number of saved undo changes
-- opt.undodir = vim.fn.stdpath("data").."/undo" -- the default

-- Debug options
-- opt.verbose = 5 -- [0, 16] level
-- opt.verbosefile = vim.fn.stdpath("data").."/verbose.log"
