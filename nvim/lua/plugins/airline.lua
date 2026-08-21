return {
    {
        "vim-airline/vim-airline",
        lazy = false,
        dependencies = {
            { "vim-airline/vim-airline-themes", lazy = false },
        },
        init = function()
            -- Let airline auto-detect theme from colorscheme
            -- Falls back to 'dark' which uses muted colors from the colorscheme
            vim.g.airline_theme = "base16_default_dark"

            -- Powerline separators (require a Nerd Font / powerline-patched font)
            vim.g.airline_powerline_fonts = 1

            -- Symbols
            vim.g["airline_symbols"] = vim.g["airline_symbols"] or {}
            local s = vim.g["airline_symbols"]
            s.branch = ""
            s.colnr = ":"
            s.readonly = ""
            s.linenr = ""
            s.maxlinenr = ""
            s.dirty = ""
            vim.g["airline_symbols"] = s

            -- Custom section_z format: percentage, line/total, column (no trailing symbols)
            vim.g["airline_section_z"] = "%p%% %l/%L :%c"

            -- Tabline (buffer list across the top)
            vim.g["airline#extensions#tabline#enabled"] = 1
            vim.g["airline#extensions#tabline#show_buffers"] = 1
            vim.g["airline#extensions#tabline#show_tabs"] = 0
            vim.g["airline#extensions#tabline#buffer_nr_show"] = 0
            vim.g["airline#extensions#tabline#show_close_button"] = 0
            vim.g["airline#extensions#tabline#left_sep"] = ""
            vim.g["airline#extensions#tabline#left_alt_sep"] = ""
            vim.g["airline#extensions#tabline#right_sep"] = ""
            vim.g["airline#extensions#tabline#right_alt_sep"] = ""

            -- Extensions
            vim.g["airline#extensions#branch#enabled"] = 1
            vim.g["airline#extensions#hunks#enabled"] = 1
            vim.g["airline#extensions#hunks#non_zero_only"] = 0

            -- Disable extensions that add extra info after position
            vim.g["airline#extensions#whitespace#enabled"] = 0
            vim.g["airline#extensions#searchcount#enabled"] = 0
            vim.g["airline#extensions#keymap#enabled"] = 0
            vim.g["airline#extensions#wordcount#enabled"] = 0
            vim.g["airline#extensions#nvimlsp#enabled"] = 0
            vim.g["airline#extensions#lsp#enabled"] = 0
        end,
        config = function()
            -- Use base16 which picks up colors from colorscheme in a muted way
            vim.cmd("AirlineTheme base16_default_dark")
        end,
    },
}
