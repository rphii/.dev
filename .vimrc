colorscheme evening             " colors
let &t_SI = "\e[6 q"            " line cursor insert
let &t_EI = "\e[2 q"            " block cursor else
set foldmethod=marker           " fold @ {{{}}}
set number                      " enable line numbers
set relativenumber              " set relative numbers
syntax on                       " enable syntax highlighs
function s:SetCursorLine()      " set cursorline+change color
    set cursorline
    hi CursorLine cterm=none ctermbg=238
endfunction
autocmd BufEnter * call s:SetCursorLine()
autocmd WinEnter * call s:SetCursorLine()
autocmd VimEnter * call s:SetCursorLine()
set showmatch                   " shows matching brackets
set ruler                       " always shows location in file (line#)
set smarttab                    " autotabs for certain code
set shiftwidth=4                " shift to 4 spaces
" shift + h/l change tabs
nnoremap <S-h> :tabprevious<CR>
nnoremap <S-l> :tabnext<CR>
nnoremap <C-l> :nohlsearch<CR>

