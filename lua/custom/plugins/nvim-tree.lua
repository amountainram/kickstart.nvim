return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('nvim-tree').setup {
      filters = {
        git_ignored = false,
      },
      reload_on_bufenter = true,
      actions = {
        open_file = {
          resize_window = true,
        },
      },
    }
  end,
  keys = {
    {
      '<C-n>',
      function()
        vim.cmd [[NvimTreeToggle]]
      end,
      mode = { 'n', 't' },
      desc = 'Toggle nvim-tree',
    },
    {
      '<C-f>',
      function()
        vim.cmd [[NvimTreeFindFile]]
      end,
      desc = 'Show current file in nvim-tree',
    },
  },
}
