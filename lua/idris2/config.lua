local M = {}

local defaults = {
  -- opts for the handlers
  client = {
    hover = {
      use_split = false,
      split_size = '30%',
      auto_resize_split = false,
      split_position = 'bottom',
      with_history = false,
      use_as_popup = false,
    },
  },
  -- opts for nvim-lspconfig
  server = {},
  autostart_semantic = true,
  use_default_semantic_hl_groups = true,
  default_regexp_syntax = true,
}

M.options = {}
M.semantic_refresh = false
M.split_open = false
M.split_history = false

function M.setup(options)
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})
  if M.options.autostart_semantic then
    M.semantic_refresh = true
  end
  if M.options.client.hover.use_split and not M.options.client.hover.use_as_popup then
    M.split_open = true
  end
  vim.g.idris2_regexp_syntax_enabled = options.default_regexp_syntax
end

return M
