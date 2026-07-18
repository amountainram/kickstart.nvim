-- Claude Code integration for Neovim.
-- https://github.com/coder/claudecode.nvim
--
-- Pure-Lua implementation of the same WebSocket/MCP protocol used by the
-- official VSCode/JetBrains extensions. Requires the `claude` CLI on PATH.
return {
  'coder/claudecode.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    terminal = {
      -- Dependency-free built-in terminal split. Set to 'snacks' if you ever
      -- add folke/snacks.nvim for a nicer floating terminal.
      provider = 'native',
      split_side = 'right',
      split_width_percentage = 0.35,
    },
  },
  keys = {
    -- Carried over from the old CopilotChat bindings:
    { '<leader>cc', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>cs', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send selection to Claude' },
    -- Add a file straight from the neo-tree explorer (reuses <leader>cs there).
    {
      '<leader>cs',
      '<cmd>ClaudeCodeTreeAdd<cr>',
      desc = 'Add file to Claude',
      ft = { 'neo-tree', 'NvimTree', 'oil', 'minifiles', 'netrw' },
    },
    -- Session management.
    { '<leader>cf', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>cr', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude session' },
    { '<leader>cC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude session' },
    { '<leader>cm', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
    { '<leader>cb', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer to Claude' },
    -- Diff review of Claude's proposed edits.
    { '<leader>ca', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept Claude diff' },
    { '<leader>cd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny Claude diff' },
  },
}
