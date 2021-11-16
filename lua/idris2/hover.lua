local config = require('idris2.config')
local Split = require('nui.split')
local event = require('nui.utils.autocmd').event

local M = {}

M.res_split = nil

function M.handler(err, result, ctx, cfg)
  if config.split_open then
    vim.api.nvim_buf_set_option(M.res_split.bufnr, 'modifiable', true)
    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    lines = vim.lsp.util.trim_empty_lines(lines)
    lines = vim.lsp.util.stylize_markdown(M.res_split.bufnr, lines)
    vim.api.nvim_buf_set_lines(M.res_split.bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(M.res_split.bufnr, 'modifiable', false)
  else
    return vim.lsp.handlers.hover(err, result, ctx, cfg)
  end
end

function M.setup()
  M.res_split = Split({
    relative = 'editor',
    position = config.options.hover_split_position,
    size = '20%',
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
  vim.api.nvim_buf_set_name(M.res_split.bufnr, 'Idris2ResponseBuffer')
  M.res_split:on({event.BufWinEnter, event.BufEnter}, function()
    if vim.fn.winnr('$') == 1 and vim.api.nvim_get_current_win() == M.res_split.winid then
      vim.cmd([[q]])
    end
  end)
  if not config.split_open then
    M.res_split:hide()
  end
end

function M.open_split()
  if config.split_open then
    return
  end
  config.split_open = true
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
