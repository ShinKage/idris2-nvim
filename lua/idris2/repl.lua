local M = {}

local Input = require('nui.input')
local event = require('nui.utils.autocmd').event

local term_popup_options = {
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
      top = "Evaluate",
      top_align = "left",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal",
  },
}

-- err, result, ctx
function M.menu_handler(expression)
  return function (err, result, ctx, config)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
    else
      vim.notify(result, vim.log.levels.INFO)
    end
  end
end

function M.evaluate()
  local input = Input(term_popup_options, {
    prompt = '> ',
    default_value = '',
    on_submit = function(value)
      local params = {
        command = 'repl',
        arguments = { value },
      }
      vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.menu_handler(value))
    end,
  })
  input:mount()
end

return M
