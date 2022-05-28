local vim = vim
local api = vim.api

-- Note: Skip initialization for vim-tiny or vim-small.
--if !1 | finish | endif

-- basically, I code bash scripts
vim.g.is_bash = 1

api.nvim_command [[luafile ~\Program\misc\etc\nvim\bundle.lua]]
api.nvim_command [[source ~\Program\misc\etc\vim\encodings]]
api.nvim_command [[source ~\Program\misc\etc\vim\filetypes]]
api.nvim_command [[source ~\Program\misc\etc\vim\basis]]

vim.bo.syntax = 'on'
vim.o.background = 'dark'
vim.g.solarized_termcolors = 256
api.nvim_command [[colorscheme darkblue]]
