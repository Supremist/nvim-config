# Introduction

This repo contains my evergrowing Neovim configuration. It is still a little messy, but I am working on it ;)
While you are welcome to clone and use the whole repo as your config, I wouldn't recommend this though.
I believe that your config should be personal and grow together with your knowledge of the editor. I encourage you to create your config from scratch ([or almost from scratch](https://github.com/nvim-lua/kickstart.nvim)), then look at other configs and take whatever snippets you like from them. I, myself, was inspired by [LazyVim](https://github.com/LazyVim/LazyVim) and [LunarVim](https://github.com/LunarVim/LunarVim), so check them out as well!

# What’s unique about this config?
 - Designed with reloadability in mind. A lot of scripts can be reloaded without restarting Neovim, but I generally cannot make all the plugins reloadable, so it never will be complete.
 - Prefer `lua` over `vimscript`. I believe that a new user should never learn `vimscript`, and I only know `lua` myself.
 - All key mappings in a single file. Even the plugin key mappings settings are converted to the single compact format and stored in `config/keymaps.lua` file. That is easier for me to manage, than storing keymaps in separate files for each plugin.
 - All plugin installations in a single file. It is for clear separation of plugin management (`installed_plugins.lua`) and plugin configuration (`plugins` dir).
# Features
 - [x] Plugin management ([lazy](https://github.com/folke/lazy.nvim))
 - [x] Autocompletion ([nvim-cmp](https://github.com/hrsh7th/nvim-cmp), [LuaSnip](https://github.com/L3MON4D3/LuaSnip))
 - [x] Language server protocol ([nvim-lspconfig](https://github.com/neovim/nvim-lspconfig))
 - [x] Tree explorer (files, classes and more: [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim))
 - [x] Fuzzy finder ([Telescope](https://github.com/nvim-telescope/telescope.nvim))
 - [x] Fast navigation ([Flash](https://github.com/folke/flash.nvim))
 - [x] Git integration ([GitSigns](https://github.com/lewis6991/gitsigns.nvim))
 - [x] Smart undo ([UndoTree](https://github.com/jiaoshijie/undotree))
 - [x] Session management (`core/session.lua`)
 - [ ] Project specific settings
 - [ ] Debugger integration
