require('config.lazy')
--vim.cmd("colorscheme habamax")
vim.cmd("colorscheme shine")

function theme_next()

end

function has_words_before()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        return false
    end
    local line = vim.api.nvim_get_current_line()
    return line:sub(col, col):match("%s") == nil
end



vim.opt.number = true
vim.opt.foldmethod = 'marker'
vim.opt.relativenumber = true
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.cinoptions = 'l1'
--vim.opt.winborder='single'
vim.opt.winborder='single'

vim.opt.completeopt = {'menu', 'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess:append('c')

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


local set_hl_for_floating_window = function()
  vim.api.nvim_set_hl(0, 'NormalFloat', {
    link = 'Normal',
  })
  vim.api.nvim_set_hl(0, 'FloatBorder', {
    bg = 'none',
  })

  --vim.api.nvim_set_hl(0, "CmpItemAbbr", { link = 'Normal', })
  --vim.api.nvim_set_hl(0, "CmpDoc", { link = 'Normal', })
  vim.api.nvim_set_hl(0, "Pmenu", { link = 'Normal', }) -- menu background
  --vim.api.nvim_set_hl(0, "CmpBorder", { link = 'PmenuSel', })
  --vim.api.nvim_set_hl(0, "PmenuSel", { }) -- selected item
  --vim.api.nvim_set_hl(0, "PmenuThumb", { link = 'Normal', })

  ----local bg = vim.api.nvim_get_hl_by_name("PmenuSel", true).background
  ----if bg then
  ----  -- set border fg to that same color (hex)
  ----  local hex = string.format("#%06x", bg)
  ----  vim.api.nvim_set_hl(0, "CmpBorder", { fg = hex })
  ----  -- if blink.cmp or another plugin uses its own border group, set it too:
  ----  vim.api.nvim_set_hl(0, "BlinkCmpBorder", { fg = hex })
  ----  vim.api.nvim_set_hl(0, "FloatBorder", { fg = hex })
  ----end

end

set_hl_for_floating_window()

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  desc = 'Avoid overwritten by loading color schemes later',
  callback = set_hl_for_floating_window,
})




-- debug
local mason_dap = require("mason-nvim-dap")
local dap = require("dap")
local ui = require("dapui")
local dap_virtual_text = require("nvim-dap-virtual-text")

-- Dap Virtual Text
dap_virtual_text.setup()

mason_dap.setup({
	ensure_installed = { "cppdbg", "codelldb" },
	automatic_installation = true,
	handlers = {
		function(config)
			require("mason-nvim-dap").default_setup(config)
		end,
	},
})

dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}

dap.adapters.codelldb = {
    type = "executable",
    command = "codelldb",
    name = "lldb"
}

-- Configurations
dap.configurations.c = {

  --{
  --	name = "Launch file",
  --	type = "cppdbg",
  --	request = "launch",
  --	program = function()
  --		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  --	end,
  --	cwd = "${workspaceFolder}",
  --	stopAtEntry = false,
  --	MIMode = "lldb",
  --	miDebuggerPath = "/usr/bin/lldb",
  --},
  --{
  --	name = "Attach to lldbserver :1234",
  --	type = "cppdbg",
  --	request = "launch",
  --	MIMode = "lldb",
  --	miDebuggerServerAddress = "localhost:1234",
  --	miDebuggerPath = "/usr/bin/lldb",
  --	cwd = "${workspaceFolder}",
  --	program = function()
  --		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  --	end,
  --},
  {
    name = "Launch exe",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
  --{
  --  name = "Launch",
  --  type = "gdb",
  --  request = "launch",
  --  program = function()
  --    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  --  end,
  --  args = {}, -- provide arguments if needed
  --  cwd = "${workspaceFolder}",
  --  stopAtBeginningOfMainSubprogram = false,
  --},
  --{
  --  name = "Select and attach to process",
  --  type = "gdb",
  --  request = "attach",
  --  program = function()
  --    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  --  end,
  --  pid = function()
  --    local name = vim.fn.input('Executable name (filter): ')
  --    return require("dap.utils").pick_process({ filter = name })
  --  end,
  --  cwd = '${workspaceFolder}'
  --},
  --{
  --  name = 'Attach to gdbserver :1234',
  --  type = 'gdb',
  --  request = 'attach',
  --  target = 'localhost:1234',
  --  program = function()
  --    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  --  end,
  --  cwd = '${workspaceFolder}'
  --}
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c

-- Dap UI

ui.setup()

vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

dap.listeners.before.attach.dapui_config = function()
	ui.open()
end
dap.listeners.before.launch.dapui_config = function()
	ui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	ui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	ui.close()
end
