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
    },
  },
  -- opts for nvim-lspconfig
  server = {},
  autostart_semantic = true,
  use_default_semantic_hl_groups = true,
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
  if M.options.client.hover.use_split then
    M.split_open = true
  end
end

return M
