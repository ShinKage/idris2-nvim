local config = require('idris2.config')
local Split = require('nui.split')
local event = require('nui.utils.autocmd').event

local M = {}

M.res_split = nil

function M.handler(err, result, ctx, cfg)
  if err ~= nil then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  if not result then
    return
  end

  if config.split_open then
    vim.api.nvim_buf_set_option(M.res_split.bufnr, 'modifiable', true)
    local prefixlines = {
      '------------------------------',
      '-- ' .. vim.fn.strftime('%c') .. ' --',
      '------------------------------'
    }
    local lines = vim.split(result.contents.value, '\n')
    lines = vim.lsp.util.trim_empty_lines(lines)
    table.insert(lines, '')

    if config.split_history then
      vim.api.nvim_buf_set_lines(M.res_split.bufnr, -1, -1, false, prefixlines)
      vim.api.nvim_buf_set_lines(M.res_split.bufnr, -1, -1, false, lines)
      local count = vim.api.nvim_buf_line_count(M.res_split.bufnr)
      vim.api.nvim_win_set_cursor(M.res_split.winid, {count, 0})
    else
      vim.api.nvim_buf_set_lines(M.res_split.bufnr, 0, -1, false, lines)
    end

    vim.api.nvim_buf_set_option(M.res_split.bufnr, 'modifiable', false)
  else
    return vim.lsp.handlers.hover(err, result, ctx, cfg)
  end
end

function M.setup()
  M.res_split = Split({
    relative = 'editor',
    position = config.options.hover_split_position,
    size = '30%',
    focusable = false,
    win_options = {
      foldenable = false,
      spell = false,
      signcolumn = 'no',
      wrap = false,
      number = false,
      relativenumber = false,
      foldenable = false,
    },
    buf_options = {
      modifiable = false,
      buftype = 'nofile',
      filetype = 'idris2',
      swapfile = false,
      buflisted = false,
    },
  })
  M.res_split:mount()
  vim.api.nvim_buf_set_name(M.res_split.bufnr, 'Idris2 LSP Response Buffer')
  M.res_split:on({event.BufWinEnter, event.BufEnter}, function()
    if vim.fn.winnr('$') == 1 and vim.api.nvim_get_current_win() == M.res_split.winid then
      vim.cmd [[q]]
    end
  end)
  M.res_split:on({event.BufHidden, event.WinClosed}, function()
    config.split_open = false
    M.res_split:hide()
  end)
  if not config.split_open then
    M.res_split:hide()
  end
end

function M.open_split(history)
  if config.split_open then
    return
  end
  config.split_open = true
  config.split_history = history or config.options.client.hover.with_history
  local winnr = vim.api.nvim_get_current_win()
  M.res_split:show()
  vim.api.nvim_set_current_win(winnr)
end

function M.close_split()
  if not config.split_open then
    return
  end
  config.split_open = false
  M.res_split:hide()
end

return M
