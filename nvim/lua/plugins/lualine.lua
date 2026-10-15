-- Statusline copied from Aejkatappaja's setup (LazyVim's lualine layout):
-- mode | branch | root dir, file path, breadcrumb | ... | progress, location | clock
vim.o.showcmdloc = "statusline" -- pending keys (e.g. "gj") show in the statusline

local sora = {
  accent = "#80c8e0", dark = "#1e2430", bg = "#0e1018", fg = "#c8d0e0",
  muted = "#586478", steel = "#8898b8", green = "#90c8a0", purple = "#b0a0d8",
  red = "#c46c78", gold = "#d4b878",
}

local function sora_theme()
  local function mode(c)
    return {
      a = { fg = sora.dark, bg = c, gui = "bold" },
      b = { fg = sora.fg, bg = sora.dark },
      c = { fg = sora.steel, bg = "NONE" },
    }
  end
  return {
    normal = mode(sora.accent),
    insert = mode(sora.green),
    visual = mode(sora.purple),
    replace = mode(sora.red),
    command = mode(sora.gold),
    inactive = mode(sora.muted),
  }
end

local function theme()
  return vim.g.colors_name == "sora" and sora_theme() or "auto"
end

local function root_dir()
  local root = vim.fs.root(0, { ".git", "Cargo.toml", "package.json", "lua" }) or vim.uv.cwd()
  return "󰉋 " .. vim.fs.basename(root)
end

local function pretty_path()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return "[No Name]"
  end
  local root = vim.fs.root(0, { ".git", "Cargo.toml", "package.json", "lua" }) or vim.uv.cwd()
  local rel = vim.fs.relpath(vim.fs.dirname(root), file)
  return rel or vim.fn.fnamemodify(file, ":~")
end

return {
  { "SmiteshP/nvim-navic", lazy = true, opts = { lazy_update_context = true, highlight = true, separator = " > " } },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
    config = function()
      local navic = require("nvim-navic")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, ev.buf)
          end
        end,
      })

      local function setup()
        require("lualine").setup({
          options = {
            theme = theme(),
            globalstatus = true,
            disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch" },
            lualine_c = {
              { root_dir, color = { fg = sora.steel }, cond = function() return vim.o.columns > 110 end },
              {
                "diagnostics",
                symbols = { error = " ", warn = " ", info = " ", hint = " " },
              },
              { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
              { pretty_path },
              { function() return navic.get_location() end, cond = function() return navic.is_available() end },
            },
            lualine_x = {
              { function() return "%S" end, color = { fg = sora.purple } },
              {
                "diff",
                symbols = { added = " ", modified = " ", removed = " " },
                source = function()
                  local g = vim.b.gitsigns_status_dict
                  if g then
                    return { added = g.added, modified = g.changed, removed = g.removed }
                  end
                end,
              },
            },
            lualine_y = {
              { "progress", separator = " ", padding = { left = 1, right = 0 } },
              { "location", padding = { left = 0, right = 1 } },
            },
            lualine_z = {
              function() return "󰥔 " .. os.date("%R") end,
            },
          },
          extensions = { "lazy", "fzf" },
        })
      end

      setup()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = setup })
    end,
  },
}
