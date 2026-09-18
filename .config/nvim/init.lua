local mapn = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end

function has_words_before()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
        return false
    end
    local line = vim.api.nvim_get_current_line()
    return line:sub(col, col):match("%s") == nil
end

--- General vim Option ------------------------------------------------------{{{
--vim.cmd("colorscheme koehler")
--vim.cmd("colorscheme slate")
--vim.cmd("colorscheme lunaperche")
--vim.cmd("colorscheme sorbet")
--vim.cmd("colorscheme elflord")
--vim.cmd("colorscheme torte")
--vim.cmd("colorscheme unokai")
vim.cmd("colorscheme catppuccin")
vim.opt.background = 'dark'
vim.opt.number = true
vim.opt.foldmethod = 'marker'
vim.opt.relativenumber = true
vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.opt.cinoptions = 'l1'
vim.opt.winborder = 'single'
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 6
vim.opt.cursorline = true
--vim.opt.winborder = 'rounded'

--vim.opt.completeopt = {'menu', 'menuone', 'noselect', 'noinsert'}
vim.opt.completeopt = {
  'menu',
  'menuone',
  --'noselect',
  'noinsert',
  'popup',
}

vim.opt.shortmess:append('c')

vim.g.mapleader = " "
vim.g["markdown_folding"] = 1

vim.keymap.set('n', '<S-l>', ':tabnext<CR>');
vim.keymap.set('n', '<S-h>', ':tabprev<CR>');

---- time it takes to trigger the `CursorHold` event
vim.opt.updatetime = 400
-----------------------------------------------------------------------------}}}

--- Plugins Gathering -------------------------------------------------------{{{
vim.pack.add({

    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/sindrets/diffview.nvim",

    -- ------ Treesitter -------------------------------------------------------
    -- Requires the `tree-sitter` CLI on PATH (macOS: `brew install tree-sitter`).
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },

    -- ------ Telescope (fuzzy finder) -----------------------------------------
    { src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.x" },
    -- fzf-native needs `make` on install; vim.pack auto-runs a Makefile if
    -- it exists, so no explicit build step is required here.
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",

    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
    "https://github.com/folke/which-key.nvim",

    "https://github.com/lewis6991/gitsigns.nvim",

})
-----------------------------------------------------------------------------}}}

--- Plugins Configuration ---------------------------------------------------{{{

local gitsigns = require("gitsigns")

gitsigns.setup({
  current_line_blame = false,
  auto_attach = true,

  on_attach = function(bufnr)

    local function map(mode, l, r, desc, opts)
      opts = opts or {}
      opts.desc = desc
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end, "Gitsign hunk next")

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end, "Gitsign hunk previous")

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk, "Gitsign hunk stage")
    map('n', '<leader>hr', gitsigns.reset_hunk, "Gitsign hunk reset")

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, "Gitsign hunk stage")

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, "Gitsign hunk reset")

    map('n', '<leader>hS', gitsigns.stage_buffer, "Gitsign buffer stage")
    map('n', '<leader>hR', gitsigns.reset_buffer, "Gitsign buffer reset")
    map('n', '<leader>hp', gitsigns.preview_hunk, "Gitsign preview hunk")
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, "Gitsign hunk preview inline")

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end, "Gitsign blame")

    map('n', '<leader>hd', gitsigns.diffthis, "Gitsigh diff")

    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end, "Gitsign diff ~")

    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, "Gitsign set qf list all")
    map('n', '<leader>hq', gitsigns.setqflist, "Gitsign set qf list")

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, "Gitsign toggle current line blame")
    map('n', '<leader>tw', gitsigns.toggle_word_diff, "Gitsign toggle word diff")

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk, "Gitsign select hunk")
  end
})

require("blink.cmp").setup({
  -- Enables keymaps, completions and signature help when true (doesn't apply to cmdline or term)
  --
  -- If the function returns 'force', the default conditions for disabling the plugin will be ignored
  -- Default conditions: (vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false)
  -- Note that the default conditions are ignored when `vim.b.completion` is explicitly set to `true`
  --
  -- Exceptions: vim.bo.filetype == 'dap-repl'
  enabled = function() return not vim.tbl_contains({ "lua", "markdown" }, vim.bo.filetype) end,

  -- Disable cmdline
  cmdline = { enabled = false },

  completion = {
    -- 'prefix' will fuzzy match on the text before the cursor
    -- 'full' will fuzzy match on the text before _and_ after the cursor
    -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
    keyword = { range = 'full' },

    -- Disable auto brackets
    -- NOTE: some LSPs may add auto brackets themselves anyway
    accept = { auto_brackets = { enabled = false }, },

    -- Don't select by default, auto insert on selection
    list = { selection = { preselect = false, auto_insert = false } },
    -- or set via a function
    --list = { selection = { preselect = function(ctx) return vim.bo.filetype ~= 'markdown' end } },
    trigger = { show_on_trigger_character = true, show_on_blocked_trigger_characters = { ' ', '\n', '\t' } },

    menu = {
      -- Don't automatically show the completion menu
      auto_show = false,
      border = 'single',
      max_height = 200,
      -- nvim-cmp style menu
      draw = {
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind_icon", "kind" }
        },
      },

    },

    -- Show documentation when selecting a completion item
    documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = 'single' } },

    -- Display a preview of the selected item on the current line
    ghost_text = { enabled = true },
  },

  sources = {
    -- Remove 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
    --default = { 'lsp', 'path', 'snippets' },
    default = { 'lsp', 'path' },
    providers = {
        lsp = {
            transform_items = function(_, items)
                for _, item in ipairs(items) do
                    local text = item.label:match("^[^(]+") or item.label
                    --text = text:gsub(";%s*$", "")
                    text = vim.trim(text)

                    if item.textEdit then
                        -- Preserve the LSP-provided replacement range.
                        item.textEdit.newText = text
                    else
                        item.insertText = text
                    end

                    item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText
                end

                return items
            end,
        },
    },
},

  -- Use a preset for snippets, check the snippets documentation for more information
  --snippets = { preset = 'default' | 'luasnip' | 'mini_snippets' | 'vsnip' },

  -- Experimental signature help support
  --- signature = { enabled = true, window = { border = 'single' }, }
  signature = {
      enabled = true,
      trigger = {
        -- Show after entering `(`, `,`, etc.
        show_on_trigger_character = true,

        -- Keep/update it while typing arguments
        show_on_insert = true,

        -- Optional: also show when the cursor is after a function name
        show_on_keyword = true,
    },

    window = {
        show_documentation = true,
    },
  },

  keymap = {
      preset = 'none',
      --['<enter>'] = { 'accept', 'fallback' },

      -- [==[
      ['<Tab>'] = {
          function(cmp)
              if has_words_before() then
                  return cmp.show_and_insert_or_accept_single()
              end
          end,
          function(cmp)
              if has_words_before() then
                  return cmp.select_next()
              end
          end,
          'fallback',
      },
      -- Navigate to the previous suggestion or cancel completion if currently on the first one.
      ['<S-Tab>'] = {
          function(cmp)
              if has_words_before() then
                  return cmp.select_prev()
              end
          end,
          'fallback'
      },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<C-space>'] = { 'hide_signature', 'cancel', 'show', 'fallback' },
      ['<enter>'] = {
          'accept',
          function(cmp)
              if cmp.snippet_active() then
                  return cmp.snippet_forward()
              end
          end,
          'fallback',
      },
      ['<C-a>'] = {
          function(cmp)
              if cmp.snippet_active() then
                  return cmp.snippet_backward()
              end
          end,
          'fallback',
      },
      --]==]
  },
})

--- add underline to the treesitter context
vim.cmd('hi TreesitterContextBottom gui=underline guisp=Grey')
vim.cmd('hi TreesitterContextLineNumberBottom gui=underline guisp=Grey')
vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

--- telescoping
local actions   = require("telescope.actions")
local telescope = require("telescope")

telescope.setup({
  defaults = {
    --prompt_prefix        = " ",
    --selection_caret      = "● ",
    -- filename_first puts the basename up front, then the full directory path —
    -- crucial for SvelteKit-style routes where every file is `+page.svelte`.
    path_display         = { filename_first = { reverse_directories = false } },
    sorting_strategy     = "ascending",
    layout_strategy      = "horizontal",
    layout_config        = {
      prompt_position = "top",
      horizontal      = { width = 0.9, preview_width = 0.55 },
    },
    file_ignore_patterns = { "node_modules", "%.git/" },
    -- Disable telescope's treesitter preview path. It assumes the master-branch
    -- nvim-treesitter API (`nvim-treesitter.parsers.ft_to_lang`,
    -- `nvim-treesitter.configs.is_enabled`) which doesn't exist on the `main`
    -- branch we pin in config/pack.lua. Previews fall back to regex syntax
    -- highlighting, which is fine for a scratch buffer.
    preview = { treesitter = { enable = false } },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      },
    },
    borderchars = { 
        "─", -- top
        "│", -- right
        "─", -- bottom
        "│", -- left
        "┌", -- top-left
        "┐", -- top-right
        "┘", -- bottom-right
        "└", -- bottom-left
    },
  },
  pickers = {
    find_files = { previewer = false, layout_config = { width = 0.7 } },
    buffers    = { previewer = false, layout_config = { width = 0.7 } },
    oldfiles   = { previewer = false, layout_config = { width = 0.7 } },
  },
  extensions = {
    fzf = {
      fuzzy                   = true,
      override_generic_sorter = true,
      override_file_sorter    = true,
      case_mode               = "smart_case",
    },
  },
})

-- Load the native fzf sorter; compiles on first install via vim.pack.
pcall(telescope.load_extension, "fzf")

local builtin = require("telescope.builtin")

mapn("<leader>ff", builtin.find_files,  "[F]ind [F]iles")
mapn("<leader>fg", builtin.live_grep,   "[F]ind by [G]rep")
-- Omarchy/LazyVim muscle memory: Space-Space fuzzy-finds files, <leader>sg greps.
mapn("<leader><leader>", builtin.find_files, "Find files")
mapn("<leader>sg", builtin.live_grep, "[S]earch by [g]rep (live)")
mapn("<leader>fb", builtin.buffers,     "[F]ind [B]uffers")
mapn("<leader>fh", builtin.help_tags,   "[F]ind [H]elp")
mapn("<leader>fk", builtin.keymaps,     "[F]ind [K]eymaps")
mapn("<leader>fr", builtin.oldfiles,    "[F]ind [R]ecent files")
mapn("<leader>fd", builtin.diagnostics, "[F]ind [D]iagnostics")
mapn("<leader>fs", builtin.lsp_document_symbols, "[F]ind [S]ymbols")
mapn("<leader>fc", builtin.colorscheme, "[F]ind [C]olorscheme")
mapn("<leader>fm", builtin.marks,       "[F]ind [M]arks")
mapn("<leader>fw", builtin.grep_string, "[F]ind [W]ord under cursor")
mapn("<leader>f.", builtin.resume,      "[F]ind: resume last picker")
mapn("<leader>fF", function()
  -- Find files in the directory of the current buffer (instead of cwd) — handy
  -- for poking around a sibling component without having to type the path.
  builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
end, "[F]ind [F]iles in current buffer's dir")
mapn("<leader>/",  builtin.current_buffer_fuzzy_find, "Search current buffer")

-- LunarVim search-group muscle memory: <leader>s* mirrors LunarVim's
-- telescope taxonomy. <leader>sr / <leader>sw / <leader>ss stay with
-- grug-far (plugins/grug_far.lua) — recent files remains at <leader>fr.
mapn("<leader>st", builtin.live_grep,   "[S]earch [t]ext (live grep)")
mapn("<leader>sf", builtin.find_files,  "[S]earch [f]iles")
mapn("<leader>sh", builtin.help_tags,   "[S]earch [h]elp")
mapn("<leader>sk", builtin.keymaps,     "[S]earch [k]eymaps")
mapn("<leader>sc", builtin.colorscheme, "[S]earch [c]olorscheme")
mapn("<leader>sl", builtin.resume,      "[S]earch: resume [l]ast")
-----------------------------------------------------------------------------}}}

--- LSP loading -------------------------------------------------------------{{{

---local wanted = {
---  lua_ls         = "lua-language-server",
---  pyright        = "pyright-langserver",
---  bashls         = "bash-language-server",
---  rust_analyzer  = "rust-analyzer",
---  clangd         = "clangd",
---  csharp         = "csharp",
---}
---
---local to_enable = {}
---for server, bin in pairs(wanted) do
---  if vim.fn.executable(bin) == 1 then
---    table.insert(to_enable, server)
---  end
---end
---if #to_enable > 0 then
---  vim.lsp.enable(to_enable)
---end

vim.lsp.config('lua-language-server', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
})
vim.lsp.enable('lua-language-server')

vim.lsp.config('bash-language-server', {
  filetypes = { 'bash', 'sh' },
})
vim.lsp.enable('bash-language-server')

vim.lsp.config('clangd', {
  cmd = { 'clangd', '--compile-commands-dir=build',
      '--background-index',
      -- '--clang-tidy',
      -- '--header-insertion=iwyu',
      '--completion-style=detailed',
      '--function-arg-placeholders',
      '--fallback-style=llvm',
      '--header-insertion=never',
  },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
})
vim.lsp.enable('clangd')

vim.lsp.config('rust_analyzer', {
  -- Server-specific settings. See `:help lsp-quickstart`
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { "Cargo.toml", "rust-project.json" },
  settings = {
    ['rust-analyzer'] = {},
  },
})
vim.lsp.enable('rust_analyzer')

-----------------------------------------------------------------------------}}}

--- LSP shortcuts -----------------------------------------------------------{{{

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', 'K', vim.lsp.buf.hover, 'LSP Hover')
    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('n', 'gr', vim.lsp.buf.references, 'References')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")

    map("n", "<leader>i", function() -- 'ih'
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
    end, "Toggle LSP inlay hints" )

    if client and client:supports_method("textDocument/documentHighlight") then
      local hl_group = vim.api.nvim_create_augroup("do_lsp_highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group    = hl_group,
        buffer   = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group    = hl_group,
        buffer   = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group    = vim.api.nvim_create_augroup("do_lsp_highlight_detach", { clear = true }),
        callback = function(ev)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "do_lsp_highlight", buffer = ev.buf })
        end,
      })
    end
  end,
})
---
-----------------------------------------------------------------------------}}}

--- LSP diagnostics ---------------------------------------------------------{{{
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false, -- play with that ...
  float = {
    border = 'single',
    --source = 'if_many',
  },
  underlined = false,
  --underdotted = true,
  --virtual_text = {
  --  spacing = 2,
  --  source = 'if_many',
  --  prefix = '●',
  --},
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN] = 'W',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.HINT] = 'H',
    },
  },
})
-----------------------------------------------------------------------------}}}

--- Custom lua functions ----------------------------------------------------{{{
local colorschemes = vim.fn.getcompletion("", "color")
table.sort(colorschemes)
local current_index = 0
local function next_colorscheme()
  if #colorschemes == 0 then
    vim.notify("No colorschemes found", vim.log.levels.WARN)
    return
  end
  current_index = current_index % #colorschemes + 1
  local name = colorschemes[current_index]
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify("Could not load colorscheme: " .. name .. "\n" .. err, vim.log.levels.ERROR)
  end
end
mapn("<leader>0", next_colorscheme, "Next colorscheme");
-----------------------------------------------------------------------------}}}

local function set_catppuccin_diff_colors()
  vim.api.nvim_set_hl(0, "FloatBorder", { link = "Comment", })
  vim.api.nvim_set_hl(0, "PmenuBorder", { link = "FloatBorder", })
  vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#243b2a", bg = "#a6e3a1", })
  vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#3b2428", bg = "#f38ba8", })
  vim.api.nvim_set_hl(0, "DiffChange", { fg = "#3a3424", bg = "#f9e2af", })
  vim.api.nvim_set_hl(0, "DiffText", { fg = "#594b24", bg = "#f9e2af", })
  --vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "DiffAdd", })
  --vim.api.nvim_set_hl(0, "GitSignsChange", { link = "DiffChange", })
  --vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "DiffDelete", })
  vim.api.nvim_set_hl(0, "GitSignsAddInline", { link = "DiffAdd", })
  vim.api.nvim_set_hl(0, "GitSignsChangeInline", { link = "DiffText", })
  vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { link = "DiffDelete", })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "catppuccin*",
  callback = set_catppuccin_diff_colors,
})

local function set_custom_highlights()
    -- style things:
    -- bold italic
    -- underline undercurl underdouble underdotted underdashed 
    -- strikethrough reverse standout nocombine

    -- Highlight the LSP reference match (hold hover)
    vim.api.nvim_set_hl(0, "LspReferenceText",  { bold = true, underline = true, })
    vim.api.nvim_set_hl(0, "LspReferenceRead",  { bold = true, underline = true, })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bold = true, underline = true, })

    -- Fix highlighting for floating window..
    vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal', })
    vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none', })
    vim.api.nvim_set_hl(0, "Pmenu", { link = 'Normal', }) -- menu background
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_custom_highlights,
})

vim.keymap.set("v", "<leader>fg", function()
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")
  text = text:gsub("\n", " ")
  require("telescope.builtin").live_grep({ default_text = text })
end, { desc = "Grep visual selection" })

-- apply highlights immediately
set_custom_highlights()
if vim.g.colors_name and vim.g.colors_name:match("^catppuccin") then
  set_catppuccin_diff_colors()
end

