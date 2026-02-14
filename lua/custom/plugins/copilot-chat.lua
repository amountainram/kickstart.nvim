-- return {
--   {
--     'CopilotC-Nvim/CopilotChat.nvim',
--     dependencies = {
--       { 'nvim-lua/plenary.nvim', branch = 'master' },
--     },
--     build = 'make tiktoken',
--     opts = {
--       -- See Configuration section for options
--     },
--   },
-- }

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    --Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
    interactions = {
      --NOTE: Change the adapter as required
      chat = { adapter = 'copilot' },
      inline = { adapter = 'copilot' },
    },
    opts = {
      log_level = 'DEBUG',
    },
  },
}
