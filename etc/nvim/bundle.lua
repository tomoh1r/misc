local vim = vim
local api = vim.api

local dein_repo_dir = vim.env.HOME .. '/.cache/dein/repos/github.com/Shougo/dein.vim'
vim.o.runtimepath = dein_repo_dir .. ',' .. vim.o.runtimepath

vim.fn['dein#begin'](vim.env.HOME .. '/.cache/dein')
vim.fn['dein#add'](dein_repo_dir)
vim.fn['dein#add']('Shougo/deoplete.nvim')

--if !has('nvim') then
--  vim.fn['dein#add']('roxma/nvim-yarp')
--  vim.fn['dein#add']('roxma/vim-hug-neovim-rpc')
--end

-- NERD tree
vim.fn['dein#add']('preservim/nerdtree')
vim.fn['dein#add']('preservim/nerdcommenter')

-- Python
vim.fn['dein#add']('nvie/vim-flake8', {on_ft = 'python'})
vim.fn['dein#add']('Glench/Vim-Jinja2-Syntax', {on_ft = 'python'})

-- JavaScript
vim.fn['dein#add']('jelera/vim-javascript-syntax', {on_ft = 'javascript'})
vim.fn['dein#add']('leafgarland/typescript-vim', {on_ft = 'typescript'})
vim.fn['dein#add']('jason0x43/vim-js-indent', {on_ft = {'javascript', 'typescript'}})

-- Elixir
vim.fn['dein#add']('elixir-lang/vim-elixir')
vim.fn['dein#add']('BjRo/vim-extest', {on_ft = 'elixir'})

-- PowerShell
vim.fn['dein#add']('PProvost/vim-ps1', {on_ft = 'ps1'})

-- Kotlin
vim.fn['dein#add']('udalov/kotlin-vim', {on_ft = 'kotlin'})

-- Terraform
vim.fn['dein#add']('hashivim/vim-terraform')

-- colo
vim.fn['dein#add']('tomasr/molokai')
vim.fn['dein#add']('altercation/vim-colors-solarized')

vim.fn['dein#end']()

-- plugin install check
if (vim.fn['dein#check_install']() ~= 0) then
  vim.fn['dein#install']()
end

-- plugin remove check
local removed_plugins = vim.fn['dein#check_clean']()
if vim.fn.len(removed_plugins) > 0 then
  vim.fn.map(removed_plugins, "delete(v:val, 'rf')")
  vim.fn['dein#recache_runtimepath']()
end
