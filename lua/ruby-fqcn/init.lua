local fqcn = require("ruby-fqcn.fqcn")

local M = {}

--- Get FQCN (Fully Qualified Class Name) at cursor position
---@return string? fqcn FQCN string or nil on error
M.get_fqcn = fqcn.get_fqcn

--- Copy FQCN to clipboard
M.copy_fqcn = fqcn.copy_fqcn

return M
