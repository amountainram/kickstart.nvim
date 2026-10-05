-- NvChad UI configuration, merged over the defaults in
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Saving this file reloads NvChad UI and recompiles the base46 highlights.
---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = 'tokyonight',
  theme_toggle = { 'tokyonight', 'one_light' },
  transparency = false,
  -- Compiled in addition to base46's defaults (blink, git, telescope, whichkey, treesitter, ...)
  integrations = { 'dap', 'gitsigns', 'neogit', 'todo', 'semantic_tokens' },
}

M.ui = {
  statusline = { theme = 'default', separator_style = 'default' },
  tabufline = {
    -- Leave room on the left of the tabline for the file explorer
    treeOffsetFt = 'neo-tree',
  },
}

-- Signature help popup while typing function arguments (blink.cmp's own one is
-- disabled in init.lua so the two don't stack)
M.lsp = { signature = true }

return M
