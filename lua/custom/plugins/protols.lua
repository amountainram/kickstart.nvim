return {
  'coder3101/protols',
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  config = function()
    require('lspconfig').protols.setup {
      cmd = { 'env', 'RUST_BACKTRACE=full', 'protols' },
      filetypes = { 'proto' },
    }
  end,
}
