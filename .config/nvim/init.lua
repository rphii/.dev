require('config.lazy')
vim.cmd("colorscheme habamax")

function theme_next()

end


vim.opt.number = true
vim.opt.foldmethod = 'marker'
vim.opt.relativenumber = true
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.cinoptions = 'l1'

vim.opt.completeopt = {'menu', 'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess:append('c')

local function tab_complete()
  if vim.fn.pumvisible() == 1 then
    -- navigate to next item in completion menu
    return '<Down>'
  end

  local c = vim.fn.col('.') - 1
  local is_whitespace = c == 0 or vim.fn.getline('.'):sub(c, c):match('%s')

  if is_whitespace then
    -- insert tab
    return '<Tab>'
  end

  local lsp_completion = vim.bo.omnifunc == 'v:lua.vim.lsp.omnifunc'

  if lsp_completion then
    -- trigger lsp code completion
    --vim.fn.feedkeys("\\<CR>")
    --vim.fn.feedkeys("<C-x><C-o>")
    --vim.fn.feedkeys('<C-n>', 't')
    return '<C-x><C-o>'
  end

  -- suggest words in current buffer
  return '<C-x><C-n>'
end

local function tab_prev()
  if vim.fn.pumvisible() == 1 then
    -- navigate to previous item in completion menu
    return '<Up>'
  end

  -- insert tab
  return '<Tab>'
end

vim.keymap.set('i', '<Tab>', tab_complete, {expr = true})
vim.keymap.set('i', '<S-Tab>', tab_prev, {expr = true})

vim.lsp.enable('clangd')
vim.lsp.enable('csharp')
vim.lsp.enable('pyright')
vim.diagnostic.config({
	virtual_lines = { current_line = true }
})

vim.keymap.set('n', '<S-l>', ':tabnext<CR>');
vim.keymap.set('n', '<S-h>', ':tabprev<CR>');


-- time it takes to trigger the `CursorHold` event
vim.opt.updatetime = 400

local function highlight_symbol(event)
  local id = vim.tbl_get(event, 'data', 'client_id')
  local client = id and vim.lsp.get_client_by_id(id)
  if client == nil or not client.supports_method('textDocument/documentHighlight') then
    return
  end

  local group = vim.api.nvim_create_augroup('highlight_symbol', {clear = false})

  vim.api.nvim_clear_autocmds({buffer = event.buf, group = group})

  vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
    group = group,
    buffer = event.buf,
    callback = vim.lsp.buf.document_highlight,
  })

  vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    group = group,
    buffer = event.buf,
    callback = vim.lsp.buf.clear_references,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = {buffer = args.buf}

    --vim.keymap.set('n', '<C-Space>', '<C-x><C-o>', opts)
    --vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    --vim.keymap.set({'n', 'x'}, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)

    --vim.keymap.set('n', 'grt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    --vim.keymap.set('n', 'grd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)

    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gi", vim.lsp.buf.implementation, "Implementation")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")

    
    --local client_id = args.data.client_id
    --vim.lsp.completion.enable(true, client_id, 0, { autotrigger = true })

  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Setup highlight symbol',
  callback = highlight_symbol,
})


local builtin = require('telescope.builtin')
vim.g.mapleader = " "
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.g["markdown_folding"] = 1

vim.api.nvim_set_option("clipboard", "unnamed")
