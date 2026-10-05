-- NvChad UI: statusline, tabufline, theme picker, cheatsheet, nvdash, colorify.
-- Options live in lua/chadrc.lua (defaults: https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua).
-- Compiled highlights are loaded at the end of init.lua from `vim.g.base46_cache`.
return {
  'nvim-lua/plenary.nvim',
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  {
    'nvchad/ui',
    branch = 'v3.0',
    lazy = false,
    config = function()
      require 'nvchad'

      local map = vim.keymap.set
      -- Buffer navigation follows the tabufline order instead of the buffer list order
      map('n', ']b', function()
        require('nvchad.tabufline').next()
      end, { desc = 'Next buffer' })
      map('n', '[b', function()
        require('nvchad.tabufline').prev()
      end, { desc = 'Previous buffer' })
      map('n', '<leader>x', function()
        require('nvchad.tabufline').close_buffer()
      end, { desc = 'Close buffer' })

      map('n', '<leader>tc', function()
        require('nvchad.themes').open()
      end, { desc = '[T]oggle [C]olorscheme picker' })
      map('n', '<leader>?', '<cmd>NvCheatsheet<CR>', { desc = 'Keymaps cheatsheet' })
    end,
  },

  {
    'nvchad/base46',
    branch = 'v3.0',
    lazy = true,
    build = function()
      require('base46').load_all_highlights()
    end,
  },

  { 'nvchad/volt', lazy = true }, -- required by the theme picker
}
