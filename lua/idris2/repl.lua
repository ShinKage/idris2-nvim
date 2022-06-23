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

function M.menu_handler(expression, opts)
  local opts = opts or {}
  return function (err, result, ctx, config)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    if opts.virtual then
      print(vim.inspect(opts))
      local ns = vim.api.nvim_create_namespace('nvim-lsp-virtual-hl')
      vim.api.nvim_buf_set_extmark(opts.s_start[1], ns, opts.s_start[2] - 1, opts.s_start[3] - 1, {
        id = 1,
        virt_text = {{ '> ' .. expression .. ' => ' .. result, 'Comment'}},
        virt_text_pos = 'eol',
      })
    else
      vim.notify(result, vim.log.levels.INFO)
    end
  end
end

function M.evaluate(opts)
  local opts = opts or {}
  if opts.expr ~= nil then
    local params = {
      command = 'repl',
      arguments = { opts.expr },
    }
    vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.menu_handler(opts.expr, opts))
  else
    local input = Input(term_popup_options, {
      prompt = '> ',
      default_value = '',
      on_submit = function(value)
        local params = {
          command = 'repl',
          arguments = { value },
        }
        vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.menu_handler(value, opts))
      end,
    })
    input:mount()
  end
end

local function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  if vim.tbl_isempty(lines) then
    return nil, nil, nil
  end
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return s_start, s_end, table.concat(lines, '\n')
end

function M.visual_evaluate(opts)
  local s_start, s_end, sel = get_visual_selection()
  local opts = vim.tbl_deep_extend('force', { s_start = s_start, s_end = s_end }, opts or {})
  if sel ~= nil and sel ~= '' then
    local params = {
      command = 'repl',
      arguments = { sel }
    }
    vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.menu_handler(sel, opts))
  else
    vim.notify('Nothing selected to evaluate', vim.log.levels.ERROR)
  end
end

return M
