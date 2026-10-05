-- Startup layout: when nvim is opened with no file (`nvim` or `nvim <dir>`), show neo-tree
-- on the left and pick something useful for the main window:
--   1. the file you last edited inside this directory (from v:oldfiles / shada)
--   2. the README
--   3. the NvChad dashboard (nvdash)

local function is_under(path, dirs)
  for _, dir in ipairs(dirs) do
    if vim.startswith(path, dir .. '/') then
      return true
    end
  end
  return false
end

local function last_edited_file(cwd)
  -- cwd may be reached through a symlink (e.g. ~/.config/nvim), so accept both spellings
  local dirs = { cwd }
  local real = vim.uv.fs_realpath(cwd)
  if real and real ~= cwd then
    table.insert(dirs, real)
  end

  for _, file in ipairs(vim.v.oldfiles) do
    file = vim.fs.normalize(file)
    if is_under(file, dirs) and not file:find '/%.git/' and vim.fn.filereadable(file) == 1 then
      return file
    end
  end
end

local function readme(cwd)
  for name, type in vim.fs.dir(cwd) do
    if type == 'file' and name:lower():match '^readme' then
      return vim.fs.joinpath(cwd, name)
    end
  end
end

local read_stdin = false
vim.api.nvim_create_autocmd('StdinReadPre', {
  once = true,
  callback = function()
    read_stdin = true
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Open neo-tree and the last edited file / README on startup',
  once = true,
  nested = true, -- let BufRead/FileType autocmds fire for the file we open
  callback = function()
    local argc = vim.fn.argc()
    local arg_dir = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 and vim.fn.argv(0) or nil
    if read_stdin or (argc > 0 and not arg_dir) then
      return
    end

    local start_buf = vim.api.nvim_get_current_buf()
    if arg_dir then
      vim.cmd.cd(vim.fn.fnameescape(arg_dir))
    elseif vim.bo[start_buf].modified or vim.api.nvim_buf_line_count(start_buf) > 1 then
      return
    end

    local cwd = vim.fs.normalize(vim.fn.getcwd())
    local file = last_edited_file(cwd) or readme(cwd)
    if file then
      vim.cmd.edit(vim.fn.fnameescape(file))
      if arg_dir and vim.api.nvim_buf_is_valid(start_buf) and start_buf ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_buf_delete(start_buf, { force = true })
      end
    else
      require('nvchad.nvdash').open()
    end

    -- `show` opens the tree without moving the cursor out of the main window
    require('neo-tree.command').execute { action = 'show', reveal = file ~= nil }
  end,
})
