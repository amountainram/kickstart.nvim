-- Java: jdtls (Eclipse JDT Language Server) via nvim-jdtls.
--
-- jdtls is started here instead of going through `servers.mason` in init.lua: nvim-jdtls
-- adds what plain lspconfig can't (one workspace per project, debug/test bundles,
-- organize imports/extract refactors). Do not also list it there, or two clients attach.
--
-- jdtls, java-debug-adapter and java-test are installed by mason-tool-installer (init.lua).
--
-- Keymaps (Java buffers only):
--   <leader>jo organize imports   <leader>jv extract variable   <leader>jc extract constant
--   <leader>jm extract method     <leader>jt test nearest method <leader>jT test class
--   <F5> / <leader>dc on a Java buffer offers the main classes of the project.

-- One jdtls workspace (index/cache) per project, outside the project tree
local function workspace_dir(root)
  return vim.fn.stdpath 'cache' .. '/jdtls/workspace/' .. vim.fn.fnamemodify(root, ':p:h'):gsub('/', '%%')
end

-- Jars from java-debug-adapter and java-test that jdtls loads as plugins (enables DAP + tests)
local function bundles()
  local mason = vim.fn.stdpath 'data' .. '/mason/packages'
  local jars = vim.fn.glob(mason .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
  for _, jar in ipairs(vim.fn.glob(mason .. '/java-test/extension/server/*.jar', true, true)) do
    -- These two are not OSGi bundles: jdtls refuses to load them and reports an error
    local name = vim.fn.fnamemodify(jar, ':t')
    if name ~= 'com.microsoft.java.test.runner-jar-with-dependencies.jar' and name ~= 'jacocoagent.jar' then
      table.insert(jars, jar)
    end
  end
  return jars
end

local function start_jdtls()
  local jdtls = require 'jdtls'
  local root = vim.fs.root(0, { 'mvnw', 'gradlew', 'settings.gradle', 'settings.gradle.kts', 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' })
    or vim.fn.getcwd()

  local cmd = { vim.fn.stdpath 'data' .. '/mason/bin/jdtls', '-data', workspace_dir(root) }
  -- Mason's jdtls ships lombok; without the agent every Lombok-generated member is an error
  local lombok = vim.fn.stdpath 'data' .. '/mason/packages/jdtls/lombok.jar'
  if vim.uv.fs_stat(lombok) then
    table.insert(cmd, '--jvm-arg=-javaagent:' .. lombok)
  end

  -- Project formatter profile (same file VS Code points `java.format.settings.url` at)
  local formatter = root .. '/eclipse-formatter.xml'

  jdtls.start_or_attach {
    cmd = cmd,
    root_dir = root,
    capabilities = require('blink.cmp').get_lsp_capabilities(),
    init_options = { bundles = bundles() },
    settings = {
      java = {
        format = vim.uv.fs_stat(formatter) and { settings = { url = formatter } } or nil,
        signatureHelp = { enabled = true },
        inlayHints = { parameterNames = { enabled = 'literals' } },
        sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
        completion = {
          favoriteStaticMembers = {
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.Assert.*',
            'org.mockito.Mockito.*',
            'org.mockito.ArgumentMatchers.*',
          },
        },
      },
    },
    on_attach = function(_, bufnr)
      -- Registers the java DAP adapter; main classes are discovered when starting a session
      jdtls.setup_dap { hotcodereplace = 'auto' }

      local function map(keys, func, desc, mode)
        vim.keymap.set(mode or 'n', keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
      end
      map('<leader>jo', jdtls.organize_imports, '[O]rganize imports')
      map('<leader>jv', jdtls.extract_variable, 'Extract [V]ariable', { 'n', 'v' })
      map('<leader>jc', jdtls.extract_constant, 'Extract [C]onstant', { 'n', 'v' })
      map('<leader>jm', function()
        jdtls.extract_method(true)
      end, 'Extract [M]ethod', 'v')
      map('<leader>jt', jdtls.test_nearest_method, '[T]est nearest method')
      map('<leader>jT', jdtls.test_class, '[T]est class')
    end,
  }
end

return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = { 'mfussenegger/nvim-dap', 'saghen/blink.cmp' },
  config = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      group = vim.api.nvim_create_augroup('custom-jdtls', { clear = true }),
      desc = 'Start or attach jdtls',
      callback = start_jdtls,
    })
    -- The plugin is loaded by the FileType event of the first Java buffer, which has already fired
    if vim.bo.filetype == 'java' then
      start_jdtls()
    end
  end,
}
