local utils = require("ruby-fqcn.utils")

local M = {}

--- Extract name from node (constant or scope_resolution)
---@param node TSNode? Tree-sitter node
---@param bufnr number Buffer number
---@return string? name Extracted name or nil
local function get_node_name(node, bufnr)
  if not node then
    return nil
  end

  local node_type = node:type()

  if node_type == "constant" or node_type == "scope_resolution" then
    return vim.treesitter.get_node_text(node, bufnr)
  end

  return nil
end

--- Get name from class/module node
---@param node TSNode Tree-sitter node (class or module)
---@param bufnr number Buffer number
---@return string? name Class or module name, or nil
local function get_class_or_module_name(node, bufnr)
  local name_node = node:field("name")[1]
  if not name_node then
    return nil
  end

  return get_node_name(name_node, bufnr)
end

--- Get constant name from assignment node (e.g., Foo = Struct.new)
---@param node TSNode Tree-sitter node (assignment)
---@param bufnr number Buffer number
---@return string? name Constant name, or nil if not a constant assignment
local function get_constant_assignment_name(node, bufnr)
  local left_node = node:field("left")[1]
  if not left_node then
    return nil
  end

  -- Only handle constant assignments (left side is a constant)
  if left_node:type() == "constant" then
    return vim.treesitter.get_node_text(left_node, bufnr)
  end

  return nil
end

--- Get all class/module names containing cursor position
---@param bufnr number Buffer number
---@return string[]? namespaces Array of namespace names, or nil on error
local function get_namespace_chain(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1 -- 0-indexed
  local col = cursor[2]

  -- Get tree-sitter parser
  local parser = vim.treesitter.get_parser(bufnr, "ruby")
  if not parser then
    utils.notify_warn("Tree-sitter parser for Ruby not found")
    return nil
  end

  local tree = parser:parse()[1]
  if not tree then
    utils.notify_warn("Failed to parse buffer")
    return nil
  end

  local root = tree:root()

  -- Get the effective column position
  -- If cursor is before the first non-whitespace character, use that position instead
  -- This ensures we get the correct node when cursor is at line beginning
  local effective_col = col
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  if line then
    local first_non_ws = line:find("%S")
    if first_non_ws and col < first_non_ws - 1 then
      effective_col = first_non_ws - 1
    end
  end

  -- Get node at effective position
  local node = root:named_descendant_for_range(row, effective_col, row, effective_col)
  if not node then
    utils.notify_warn("No node found at cursor position")
    return nil
  end

  -- Traverse parents to collect class/module/constant assignment
  local namespaces = {}
  local current = node

  while current do
    local node_type = current:type()

    if node_type == "class" or node_type == "module" then
      local name = get_class_or_module_name(current, bufnr)
      if name then
        -- Insert at beginning (to maintain parent-to-child order)
        table.insert(namespaces, 1, name)
      end
    elseif node_type == "assignment" then
      local name = get_constant_assignment_name(current, bufnr)
      if name then
        -- Insert at beginning (to maintain parent-to-child order)
        table.insert(namespaces, 1, name)
      end
    end

    current = current:parent()
  end

  if #namespaces == 0 then
    utils.notify_warn("No class or module found at cursor position")
    return nil
  end

  return namespaces
end

--- Get FQCN (Fully Qualified Class Name) at cursor position
---@return string? fqcn FQCN string or nil on error
function M.get_fqcn()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Check filetype
  local filetype = vim.bo[bufnr].filetype
  if filetype ~= "ruby" then
    utils.notify_warn("This command only works with Ruby files")
    return nil
  end

  local namespaces = get_namespace_chain(bufnr)
  if not namespaces then
    return nil
  end

  -- Join with ::
  local fqcn = table.concat(namespaces, "::")
  return fqcn
end

--- Copy FQCN to clipboard
function M.copy_fqcn()
  local fqcn = M.get_fqcn()
  if not fqcn then
    return
  end

  -- Copy to clipboard
  vim.fn.setreg("+", fqcn)
  vim.fn.setreg('"', fqcn)

  utils.notify_info("Copied: " .. fqcn)
end

return M
