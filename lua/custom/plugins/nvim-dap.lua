-- Debugging (DAP): nvim-dap + dap-ui + inline variable values.
--
-- Keymaps: VS Code-style F-keys for stepping, everything else under <leader>d.
--   <F5> start/continue  <F10> step over  <F11> step into  <S-F11> step out
--   <F9> toggle breakpoint  <F7> toggle UI (also q in any debug window)  <F12> Lua server (debug Neovim itself)
--
-- Adapters: Go via nvim-dap-go (delve), C/C++/Rust via nvim-dap-lldb (codelldb),
-- Lua via one-small-step-for-vimkind. A .vscode/launch.json in the project is picked
-- up automatically by `continue`.

-- Wrap calls so the plugins are only required when a key is pressed (keeps dap lazy)
local function dap(method, ...)
  local args = { ... }
  return function()
    require('dap')[method](unpack(args))
  end
end

local function toggle_lua_server()
  local osv = require 'osv'
  if osv.is_running() then
    osv.stop()
    vim.notify 'Debug: Lua server stopped'
  else
    osv.launch { port = 8086 }
  end
end

-- dap-ui open/close that also gets neo-tree out of the way: it is closed when the
-- debug UI opens and shown again when the debug UI closes (only if it was open before).
local neotree_was_open = false

local function find_win(predicate)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if predicate(vim.bo[vim.api.nvim_win_get_buf(win)].filetype) then
      return win
    end
  end
end

local function is_debug_ft(ft)
  return ft:match '^dapui_' ~= nil or ft == 'dap-repl'
end

local function ui_open()
  if find_win(function(ft)
    return ft == 'neo-tree'
  end) then
    neotree_was_open = true
    require('neo-tree.command').execute { action = 'close' }
  end
  require('dapui').open { reset = true } -- reset = restore the configured window sizes
end

local function ui_close()
  require('dapui').close()
  if neotree_was_open then
    neotree_was_open = false
    require('neo-tree.command').execute { action = 'show' }
  end
end

local function ui_toggle()
  if find_win(is_debug_ft) then
    ui_close()
  else
    ui_open()
  end
end

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio', -- required by nvim-dap-ui
    { 'theHamsta/nvim-dap-virtual-text', opts = {} }, -- variable values inline, next to the code

    -- Installs the debug adapters
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    'leoluz/nvim-dap-go', -- go
    'julianolf/nvim-dap-lldb', -- c, cpp, rust
    'jbyuki/one-small-step-for-vimkind', -- lua (Neovim plugins/config)
  },
  keys = {
    -- Stepping
    { '<F5>', dap 'continue', desc = 'Debug: Start/Continue' },
    { '<F10>', dap 'step_over', desc = 'Debug: Step Over' },
    { '<F11>', dap 'step_into', desc = 'Debug: Step Into' },
    { '<S-F11>', dap 'step_out', desc = 'Debug: Step Out' },
    { '<F23>', dap 'step_out', desc = 'Debug: Step Out' }, -- what <S-F11> arrives as under tmux/xterm terminfo
    { '<F9>', dap 'toggle_breakpoint', desc = 'Debug: Toggle Breakpoint' },
    {
      '<F7>',
      ui_toggle,
      desc = 'Debug: Toggle UI',
    },
    { '<F12>', toggle_lua_server, desc = 'Debug: Launch/Stop Lua server (port 8086)' },

    -- Breakpoints
    { '<leader>db', dap 'toggle_breakpoint', desc = 'Toggle [B]reakpoint' },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Conditional [B]reakpoint',
    },
    {
      '<leader>dl',
      function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log message ({expr} is interpolated): ')
      end,
      desc = '[L]og point',
    },
    { '<leader>dC', dap 'clear_breakpoints', desc = '[C]lear all breakpoints' },
    { '<leader>dL', dap 'list_breakpoints', desc = '[L]ist breakpoints (quickfix)' },

    -- Session
    { '<leader>dc', dap 'continue', desc = 'Start/[C]ontinue' },
    { '<leader>dg', dap 'run_to_cursor', desc = 'Run to cursor ([G]o here)' },
    { '<leader>dr', dap 'run_last', desc = '[R]erun last configuration' },
    { '<leader>dt', dap 'terminate', desc = '[T]erminate session' },
    { '<leader>dp', dap 'pause', desc = '[P]ause' },
    { '<leader>dk', dap 'up', desc = 'Stack frame up' },
    { '<leader>dj', dap 'down', desc = 'Stack frame down' },

    -- Inspect
    {
      '<leader>du',
      ui_toggle,
      desc = 'Toggle [U]I',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      mode = { 'n', 'v' },
      desc = '[E]valuate expression',
    },
    {
      '<leader>dR',
      function()
        require('dap').repl.toggle()
      end,
      desc = 'Toggle [R]EPL',
    },
    { '<leader>dn', toggle_lua_server, desc = 'Lua server for debugging [N]eovim' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'delve', 'codelldb' },
      handlers = {
        -- Default handler: registers adapter + basic configurations for installed adapters
        function(config)
          require('mason-nvim-dap').default_setup(config)
        end,
        -- nvim-dap-go / nvim-dap-lldb register richer configurations for these;
        -- letting mason-nvim-dap add its own as well duplicates every entry in the picker
        delve = function() end,
        codelldb = function() end,
      },
    }

    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- 4 windows instead of the default 6: breakpoints are in <leader>dL (quickfix)
      -- and watches are covered by <leader>de (evaluate)
      layouts = {
        {
          position = 'left',
          size = 45,
          elements = {
            { id = 'scopes', size = 0.7 }, -- variables
            { id = 'stacks', size = 0.3 }, -- call stack / threads
          },
        },
        {
          position = 'bottom',
          size = 12,
          elements = {
            { id = 'repl', size = 0.5 }, -- debugger REPL + adapter output, with the step controls
            { id = 'console', size = 0.5 }, -- program stdout/stdin (integrated terminal)
          },
        },
      },
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Open the UI when a session starts. It is intentionally *not* closed when the program
    -- exits, so its output and any unhandled exception stay visible; close it with q, <F7> or <leader>du.
    dap.listeners.after.event_initialized['dapui_config'] = ui_open

    -- `q` in any debug window closes the whole debug UI (not just that one split)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'dapui_scopes', 'dapui_stacks', 'dapui_console', 'dap-repl' },
      desc = 'Close the whole dap-ui with q',
      callback = function(args)
        vim.keymap.set('n', 'q', ui_close, { buffer = args.buf, desc = 'Debug: Close UI' })
      end,
    })

    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

    local function set_dap_marker_colors()
      -- Reuse current SignColumn background (except for DapStoppedLine)
      local sign_column_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
      -- if bg or ctermbg aren't found, use bg = 'bg' (which means current Normal) and ctermbg = 'Black'
      -- convert to 6 digit hex value starting with #
      local sign_column_bg = (sign_column_hl.bg ~= nil) and ('#%06x'):format(sign_column_hl.bg) or 'bg'
      local sign_column_ctermbg = (sign_column_hl.ctermbg ~= nil) and sign_column_hl.ctermbg or 'Black'

      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00ff00', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d', ctermbg = 'Green' })
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#c23127', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#e0af68', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#888ca6', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      desc = 'Prevent colorscheme clearing self-defined DAP marker colors',
      callback = set_dap_marker_colors,
    })
    -- base46 (NvChad UI) themes don't fire ColorScheme, they fire this instead
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NvThemeReload',
      desc = 'Prevent base46 theme switch clearing self-defined DAP marker colors',
      callback = set_dap_marker_colors,
    })
    set_dap_marker_colors()

    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
    require('dap-lldb').setup {}

    dap.configurations.lua = {
      {
        type = 'nlua',
        request = 'attach',
        name = 'Attach to running Neovim instance',
      },
    }

    dap.adapters.nlua = function(callback, config)
      callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
    end
  end,
}
