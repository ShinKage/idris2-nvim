local M = {}

local Input = require('nui.input')
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
      top = 'Browse Namespace',
      top_align = 'center'
    }
  },
  highlight = 'Normal:Normal',
}

local name_popup_options = {
  relative = "cursor",
  position = {
    row = 1,
    col = 0,
  },
  size = 30,
  border = {
    style = "rounded",
    highlight = "FloatBorder",
    text = {
      top = "Namespace",
      top_align = "left",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal",
  },
}

-- err, result, ctx
function M.menu_handler(ns, opts)
  local opts = opts or { popup = true }
  return function (err, result, ctx, config)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    if vim.tbl_isempty(result) then
      vim.notify('No definitions in ' .. ns, vim.log.levels.INFO)
      return
    end

    local items = vim.tbl_map(function(x)
      local text = x.name
      return Menu.item(text, { entry = x })
    end, result)
    local menu = Menu(popup_options, {
      lines = items,
      max_width = 100,
      max_height = 20,
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
        if item.entry.location ~= nil then
          vim.lsp.util.jump_to_location(item.entry.location, 'utf-32')
        else
          vim.notify('Selected name is not in a physical location', vim.log.levels.ERROR)
        end
      end,
    })

    menu:mount()
    if opts.popup then
      menu:on(event.BufLeave, menu.menu_props.on_close, { once = true })
    end
  end
end

function M.browse(opts)
  local input = Input(name_popup_options, {
    prompt = '> ',
    default_value = '',
    on_submit = function(value)
      local params = {
        command = 'browseNamespace',
        arguments = { value },
      }
      vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.menu_handler(value, opts))
    end,
  })
  input:mount()
end

return M
