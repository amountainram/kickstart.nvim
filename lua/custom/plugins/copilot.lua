return {
  -- Inline completions (Claude Code has no inline-completion equivalent, so we
  -- keep Copilot for this). Chat/agent workflows are handled by claudecode.nvim.
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
    end,
  },
}
