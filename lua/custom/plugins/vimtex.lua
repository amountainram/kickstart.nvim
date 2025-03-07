return {
  'lervag/vimtex',
  lazy = false,
  init = function()
    vim.cmd 'syntax enable'

    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_syntax_enabled = 0
  end,
}
