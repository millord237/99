set noswapfile
set rtp+=.

let s:paths = [
    \ "../plenary.nvim",
    \ expand("~/.local/share/nvim/lazy/plenary.nvim"),
    \ expand("~/.local/share/nvim/site/pack/*/start/plenary.nvim"),
    \ expand("~/.config/nvim/pack/*/start/plenary.nvim"),
    \ expand("~/.config/nvim/plugged/plenary.nvim"),
    \ "../nvim-treesitter/nvim-treesitter",
    \ expand("~/.local/share/nvim/lazy/nvim-treesitter/nvim-treesitter"),
    \ expand("~/.local/share/nvim/site/pack/*/start/nvim-treesitter/nvim-treesitter"),
    \ expand("~/.config/nvim/pack/*/start/nvim-treesitter/nvim-treesitter"),
    \ expand("~/.config/nvim/plugged/nvim-treesitter/nvim-treesitter"),
    \ ]

for s:path in s:paths
    if isdirectory(s:path)
        execute "set rtp+=" . s:path
        break
    endif
endfor

runtime! plugin/plenary.vim
runtime! plugin/nvim-treesitter/nvim-treesitter

