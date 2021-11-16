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

function M.handler(opts)
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
  vim.lsp.buf_request(0, 'workspace/executeCommand', {command = 'metavars'}, M.handler(opts))
end

return M
