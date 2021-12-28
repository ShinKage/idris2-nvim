local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local plugin_config = require('idris2.config')

local M = {}

M.filters = {
  CASE_SPLIT = 'refactor.rewrite.CaseSplit',
  MAKE_CASE = 'refactor.rewrite.MakeCase',
  MAKE_WITH = 'refactor.rewrite.MakeWith',
  MAKE_LEMMA = 'refactor.extract.MakeLemma',
  ADD_CLAUSE = 'refactor.rewrite.AddClause',
  EXPR_SEARCH = 'refactor.rewrite.ExprSearch',
  GEN_DEF = 'refactor.rewrite.GenerateDef',
  REF_HOLE = 'refactor.rewrite.RefineHole',
}

function M.introspect_filter(action)
  if string.match(action.title, "Case split") then
    return M.filters.CASE_SPLIT
  elseif string.match(action.title, "Make case") then
    return M.filters.MAKE_CASE
  elseif string.match(action.title, "Make with") then
    return M.filters.MAKE_WITH
  elseif string.match(action.title, "Add clause") then
    return M.filters.ADD_CLAUSE
  elseif string.match(action.title, "Make lemma") then
    return M.filters.MAKE_LEMMA
  elseif string.match(action.title, "Add clause") then
    return M.filters.ADD_CLAUSE
  elseif string.match(action.title, "Expression search") then
    return M.filters.EXPR_SEARCH
  elseif string.match(action.title, "Generate definition") then
    return M.filters.GEN_DEF
  elseif string.match(action.title, "Refine hole") then
    return M.filters.REF_HOLE
  end
end

local function has_multiple_results(filter)
  return filter == M.filters.EXPR_SEARCH
           or filter == M.filters.GEN_DEF
           or filter == M.filters.REF_HOLE
end

local function handle_code_action_post_hook(action)
  local optional_post_hook = plugin_config.options.code_action_post_hook
  if optional_post_hook ~= nil then
    optional_post_hook(action)
  end
end

local function single_action_handler(err, result, ctx, config)
  if not result or #result == 0 then
    vim.notify('No code actions available', vim.log.levels.INFO)
    return
  end

  if #result > 1 then
    error('Received code action with multiple results')
    return
  end

  local action = result[1]

  if action.edit ~= nil then
    vim.lsp.util.apply_workspace_edit(action.edit)
  end

  handle_code_action_post_hook(action)
end

function M.request_single(filter)
  local params = vim.lsp.util.make_range_params()
  params['context'] = { diagnostics = {}, only = { filter } }

  if has_multiple_results(filter) then
    vim.lsp.buf.code_action(params.context)
  else
    vim.lsp.buf_request(0, 'textDocument/codeAction', params, single_action_handler)
  end
end

function M.case_split()   M.request_single(M.filters.CASE_SPLIT)  end
function M.make_case()    M.request_single(M.filters.MAKE_CASE)   end
function M.make_with()    M.request_single(M.filters.MAKE_WITH)   end
function M.make_lemma()   M.request_single(M.filters.MAKE_LEMMA)  end
function M.add_clause()   M.request_single(M.filters.ADD_CLAUSE)  end
function M.expr_search()  M.request_single(M.filters.EXPR_SEARCH) end
function M.generate_def() M.request_single(M.filters.GEN_DEF)     end
function M.refine_hole()  M.request_single(M.filters.REF_HOLE)    end

local function on_with_hints_results(err, results, ctx, config)
  if not results or #results == 0 then
    vim.notify('No code actions available', vim.log.levels.INFO)
    return
  end

  local function apply_action(action)
    if not action then
      return
    end
    vim.lsp.util.apply_workspace_edit(action.edit)

    handle_code_action_post_hook(action)
  end

  vim.ui.select(results, {
    prompt = 'Code actions:',
    kind = 'codeaction',
    format_item = function(result)
      local title = result.title:gsub('\r\n', '\\r\\n')
      return title:gsub('\n', '\\n')
    end,
  }, apply_action)
end

local hints_popup_options = {
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
      top = "Hints",
      top_align = "left",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal",
  },
}

function M.refine_hole_hints()
  local range = vim.lsp.util.make_range_params()
  local input = Input(hints_popup_options, {
    prompt = '> ',
    default_value = '',
    on_submit = function(value)
      hints = vim.split(value, ',')
      range.context = { diagnostics = {} }
      local params = {
        command = 'refineHoleWithHints',
        arguments = {{
          codeAction = range,
          hints = hints,
        }},
      }
      vim.lsp.buf_request(0, 'workspace/executeCommand', params, on_with_hints_results)
    end,
  })
  input:mount()
end

function M.expr_search_hints()
  local range = vim.lsp.util.make_range_params()
  local input = Input(hints_popup_options, {
    prompt = '> ',
    default_value = '',
    on_submit = function(value)
      hints = vim.split(value, ',')
      range.context = { diagnostics = {} }
      local params = {
        command = 'exprSearchWithHints',
        arguments = {{
          codeAction = range,
          hints = hints,
        }},
      }
      vim.lsp.buf_request(0, 'workspace/executeCommand', params, on_with_hints_results)
    end,
  })
  input:mount()
end

function M.setup()
  local custom_handler = plugin_config.options.code_action_post_hook
  if custom_handler == nil then
    return
  end
  local ui_select = vim.ui.select
  vim.ui.select = function(action_tuples, opts, on_user_choice)
    local function on_choice(action_tuple)
      on_user_choice(action_tuple)
      if opts.kind == 'codeaction'
	and action_tuple ~= nil then
	  custom_handler(action_tuple[2])
      end
    end
    ui_select(action_tuples, opts, on_choice)
  end
end

return M
