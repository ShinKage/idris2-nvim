local M = {}

local Menu = require('nui.menu')
local event = require('nui.utils.autocmd').event

local popup_options = {
  relative = 'win',
  position = {
    row = '0%',
    col = '100%',
  },
  border = {
    style = 'rounded',
    highlight = 'FloatBorder',
    text = {
      top = 'Metavariables',
      top_align = 'center'
    }
  },
  highlight = 'Normal:Normal',
}

local function pos_lt(x, y)
  if x.line == y.line then
    return x.character < y.character
  end
  return x.line < y.line
end

local function pos_gt(x, y)
  if x.line == y.line then
    return x.character > y.character
  end
  return x.line > y.line
end

function M.jump_handler(backward)
  local sorting = pos_lt
  local compare = pos_gt
  if backward then
    sorting = pos_gt
    compare = pos_lt
  end

  return function(err, result, ctx, config)
    if vim.tbl_isempty(result) then
      print('No metavariables in context')
      return
    end

    -- Jump only within buffer
    local uri = vim.uri_from_bufnr(0)
    vim.tbl_filter(function(item)
      return item.uri == uri
    end, result)

    table.sort(result, function(x, y)
      return sorting(x.location.range.start, y.location.range.start)
    end)

    local curpos = vim.fn.getcurpos()
    local curloc = { line = curpos[2] - 1, character = curpos[3] - 1 }

    for _, v in ipairs(result) do
      if compare(v.location.range.start, curloc) then
        vim.lsp.util.jump_to_location(v.location)
        return
      end
    end
    vim.lsp.util.jump_to_location(result[1].location)
  end
end

function M.menu_handler(opts)
  local opts = opts or {}
  return function (err, result, ctx, config)
    if vim.tbl_isempty(result) then
      print('No metavariables in context')
      return
    end

    local items = vim.tbl_map(function(x)
      local text = x.name .. ' : ' .. x.type
      return Menu.item(text, { metavar = x })
    end, result)
    local menu = Menu(popup_options, {
      lines = items,
      max_width = 100,
      separator = {
        char = '-',
        text_align = 'right',
      },
      keymap = {
        focus_next = { 'j', '<Down>', '<Tab>' },
        focus_prev = { 'k', '<Up>', '<S-Tab>' },
        close = { '<Esc>', '<C-c>' },
        submit = { '<CR>', '<Space>' },
      },
      on_submit = function(item)
        if item.metavar.location ~= nil then
          vim.lsp.util.jump_to_location(item.metavar.location)
        else
          error('selected metavar is not in a physical location')
        end
      end,
    })

    menu:mount()
    if opts.popup then
      menu:on(event.BufLeave, menu.menu_props.on_close, { once = true })
    end
  end
end

function M.request_all(opts)
  vim.lsp.buf_request(0, 'workspace/executeCommand', {command = 'metavars'}, M.menu_handler(opts))
end

function M.goto_next()
  vim.lsp.buf_request(0, 'workspace/executeCommand', {command = 'metavars'}, M.jump_handler(false))
end

function M.goto_prev()
  vim.lsp.buf_request(0, 'workspace/executeCommand', {command = 'metavars'}, M.jump_handler(true))
end

return M
