return {
  {
    'Olical/conjure',
    ft = { 'clojure', 'fennel', 'racket', 'scheme', 'lisp' },
    init = function()
      vim.g['conjure#mapping#prefix'] = ','
      vim.g['conjure#log#hud#enabled'] = false
    end,
  },
  -- Structural editing, optional
  { 'guns/vim-sexp', ft = { 'clojure', 'fennel', 'scheme', 'lisp' } },
  'tpope/vim-sexp-mappings-for-regular-people',
  'tpope/vim-repeat',
  'tpope/vim-surround',
}
