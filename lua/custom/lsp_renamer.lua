-- Floating LSP rename prompt, styled like NvChad UI's renamer.
-- NvChad's own `nvchad.lsp.renamer` relies on `vim.lsp.util._get_line_byte_from_position`,
-- a private API removed in nvim 0.13, so this only draws the prompt and delegates the
-- actual rename (prepareRename, position encoding, multiple clients) to vim.lsp.buf.rename().
return function()
  local api = vim.api
  local orig_win = api.nvim_get_current_win()
  local cword = vim.fn.expand '<cword>'

  local buf = api.nvim_create_buf(false, true)
  local win = api.nvim_open_win(buf, true, {
    height = 1,
    style = 'minimal',
    border = 'single',
    row = 1,
    col = 1,
    relative = 'cursor',
    width = math.max(#cword + 15, 25),
    title = { { ' Renamer ', '@comment.danger' } },
    title_pos = 'center',
  })
  vim.wo[win].winhl = 'Normal:Normal,FloatBorder:Removed'

  vim.bo[buf].buftype = 'prompt'
  vim.fn.prompt_setprompt(buf, '')
  api.nvim_buf_set_lines(buf, 0, -1, true, { cword })
  vim.cmd 'startinsert!'

  local function close()
    if api.nvim_buf_is_valid(buf) then
      api.nvim_buf_delete(buf, { force = true })
    end
    if api.nvim_win_is_valid(orig_win) then
      api.nvim_set_current_win(orig_win)
    end
  end

  vim.keymap.set({ 'i', 'n' }, '<Esc>', function()
    vim.cmd 'stopinsert'
    close()
  end, { buffer = buf })

  vim.fn.prompt_setcallback(buf, function(text)
    local new_name = vim.trim(text)
    close()
    if new_name ~= '' and new_name ~= cword then
      vim.lsp.buf.rename(new_name)
    end
  end)
end
