return {
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
    end,
  },
  {
    {
      'CopilotC-Nvim/CopilotChat.nvim',
      dependencies = {
        { 'nvim-lua/plenary.nvim', branch = 'master' },
      },
      build = 'make tiktoken',
      opts = {
        model = 'claude-opus-4.6', -- or the exact model name CopilotChat expects
      },
      keys = {
        { '<leader>cc', '<cmd>CopilotChatOpen<CR>', mode = 'n', desc = 'Open CopilotChat' },
        { '<leader>cs', '<cmd>CopilotChatSend<CR>', mode = 'v', desc = 'Send selection to CopilotChat' },
      },
    },
  },
}
