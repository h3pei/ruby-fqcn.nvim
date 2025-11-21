local M = {}

--- Set up a Ruby buffer with content and cursor position
---@param content string Ruby code content
---@param cursor_pos number[] Cursor position {row, col} (1-indexed row)
---@return number bufnr Buffer number
function M.setup_ruby_buffer(content, cursor_pos)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(bufnr)

  -- Set content
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Set filetype to Ruby
  vim.bo[bufnr].filetype = "ruby"

  -- Set cursor position
  if cursor_pos then
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end

  return bufnr
end

--- Get buffer content as string
---@param bufnr number Buffer number
---@return string content Buffer content
function M.get_buffer_content(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

--- Check if dependencies are available
---@return boolean ok True if all dependencies are available
function M.check_dependencies()
  local ok, _ = pcall(require, "nvim-treesitter")
  if not ok then
    return false
  end

  local parser_ok, _ = pcall(vim.treesitter.language.add, "ruby")
  return parser_ok
end

--- Clean up buffer after test
---@param bufnr number Buffer number
function M.cleanup_buffer(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

--- Get clipboard content (+ register)
---@return string content Clipboard content
function M.get_clipboard()
  return vim.fn.getreg("+")
end

return M
