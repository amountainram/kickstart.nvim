return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = {
    { '<C-t>', desc = 'Toggle terminal' },
    { '<leader>tf', desc = '[T]erminal [F]loat' },
    { '<leader>tv', desc = '[T]erminal [V]ertical' },
  },
  opts = {
    open_mapping = '<C-t>',
    direction = 'tab',
    shade_terminals = false,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    vim.keymap.set('n', '<leader>tf', function()
      require('toggleterm').toggle(0, nil, nil, 'float')
    end, { desc = '[T]erminal [F]loat' })

    vim.keymap.set('n', '<leader>tv', function()
      require('toggleterm').toggle(0, nil, nil, 'vertical')
    end, { desc = '[T]erminal [V]ertical' })
  end,
}
