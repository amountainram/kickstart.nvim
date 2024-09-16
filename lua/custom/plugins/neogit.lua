return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim', -- optional
    'ibhagwan/fzf-lua', -- optional
    'echasnovski/mini.pick', -- optional
  },
  config = true,
  keys = function(_, keys)
    return {
      { '<leader>ng', '<cmd>Neogit kind=tab<CR>', desc = 'Open Neogit' },
      unpack(keys),
    }
  end,
}
