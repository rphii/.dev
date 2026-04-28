return {
    'Saghen/blink.cmp',

    --dependencies = { 'rafamadriz/friendly-snippets' },

    version = '1.*',

    --@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        
        -- disable cmdline
        --cmdline = { enabled = false },
        
        -- :h blink-cmp-config-keymap
        keymap = {
            preset = 'none',

            -- If completion hasn't been triggered yet, insert the first suggestion; if it has, cycle to the next suggestion.
            ['<Tab>'] = {
                function(cmp)
                    if has_words_before() then
                        return cmp.show_and_insert()
                    end
                end,
                --'show_and_insert',
                function(cmp)
                    --if not cmp.visible() then
                        --cmp.complete()
                    --end
                    if has_words_before() then
                        --return cmp.show_and_insert()
                        return cmp.insert_next()
                    end
                end,
                'fallback',
            },
            -- Navigate to the previous suggestion or cancel completion if currently on the first one.
            ['<S-Tab>'] = {
                function(cmp)
                    if has_words_before() then
                        return cmp.insert_prev()
                    end
                end,
                'fallback' },
            ['<C-e>'] = { 'hide', 'fallback' },
            ['<C-space>'] = { 'cancel', 'show', 'fallback' },
        },

        completion = {
            documentation = { auto_show = true, window = { border = 'single' } },
            menu = {
                enabled = true, auto_show = false,
                draw = {
                    columns = {
                        { "label", "label_description", gap = 1 },
                        { "kind_icon", "kind" },
                    },
                },
                border = 'single',
                max_height = 200,
            },
            list = {
                selection = { preselect = false },
                cycle = { from_top = true },
            },
            trigger = { show_on_trigger_character = true, show_on_blocked_trigger_characters = { ' ', '\n', '\t' } },
            --ghost_text = { enabled = true, show_with_menu = false },
        },

        signature = { enabled = true, window = { border = 'single' } },

        appearance = {
            nerd_font_variant = 'mono',
        },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" },

        -- you may want to set the following options
        --completion.menu.auto_show = false, -- only show menu on manual <C-space>
        --completion.ghost_text.show_with_menu = false, -- only show when menu is closed

    },
    opts_extend = { "sources.default" }

}

