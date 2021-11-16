local M = {}

M.filters = {
  CASE_SPLIT = 'refactor.rewrite.CaseSplit',
  MAKE_CASE = 'refactor.rewrite.MakeCase',
  MAKE_WITH = 'refactor.rewrite.MakeWith',
  MAKE_LEMMA = 'refactor.extract.MakeLemma',
  ADD_CLAUSE = 'refactor.rewrite.AddClause',
  EXPR_SEARCH = 'refactor.rewrite.ExprSearch',
  GEN_DEF = 'refactor.rewrite.GenerateDef',
  REF_HOLE = 'refactor.rewrite.RefineHol',
}

local function has_multiple_results(filter)
  return filter == M.filters.EXPR_SEARCH
           or filter == M.filters.GEN_DEF
           or filter == M.filters.REF_HOLE
end

local function single_action_handler(err, result, ctx, config)
  if #result > 1 then
    error('received code action with multiple results')
  end

  local action = result[1]

  if action.edit ~= nil then
    vim.lsp.util.apply_workspace_edit(action.edit)
  end
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
function M.refne_hole()   M.request_single(M.filters.REF_HOLE)    end

return M
