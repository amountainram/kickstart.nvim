-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',

    -- lldb support
    'julianolf/nvim-dap-lldb',

    -- lua
    'jbyuki/one-small-step-for-vimkind',
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    local osv = require 'osv'
    return {
      -- Basic debugging keymaps, feel free to change to your liking!
      { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F10>', dap.step_over, desc = 'Debug: Step Over' },
      { '<F11>', dap.step_into, desc = 'Debug: Step Into' },
      { '<S-F11>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle [B]reakpoint' },
      { '<leader>db', dap.toggle_breakpoint, desc = 'Debug: [D]elete all [B]reakpoints' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set [B]reakpoint',
      },
      {
        '<leader>k',
        function()
          local widgets = require 'dap.ui.widgets'
          widgets.hover()
        end,
        desc = 'Inspect variable value or alternate action',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
      {
        '<F12>',
        function()
          if osv.is_running() then
            osv.stop()
            print 'Debug: Lua Server Stopped'
          else
            osv.launch { port = 8086 }
          end
        end,
        desc = 'Debug: Launch/Stop Lua Server on port 8086',
      },

      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'lldb',
        'codelldb',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
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

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      desc = 'Prevent colorscheme clearing self-defined DAP marker colors',
      callback = function()
        -- Reuse current SignColumn background (except for DapStoppedLine)
        local sign_column_hl = vim.api.nvim_get_hl(0, { name = 'SignColumn' })
        -- if bg or ctermbg aren't found, use bg = 'bg' (which means current Normal) and ctermbg = 'Black'
        -- convert to 6 digit hex value starting with #
        local sign_column_bg = (sign_column_hl.bg ~= nil) and ('#%06x'):format(sign_column_hl.bg) or 'bg'
        local sign_column_ctermbg = (sign_column_hl.ctermbg ~= nil) and sign_column_hl.ctermbg or 'Black'

        vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00ff00', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
        vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d3d', ctermbg = 'Green' })
        vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#c23127', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
        vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#888ca6', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
        vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef', bg = sign_column_bg, ctermbg = sign_column_ctermbg })
      end,
    })

    -- reload current color scheme to pick up colors override if it was set up in a lazy plugin definition fashion
    vim.cmd.colorscheme(vim.g.colors_name)

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
    -- Install rust specific config
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
