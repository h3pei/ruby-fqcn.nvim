-- Minimal init for testing
vim.cmd([[set runtimepath+=.]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/plenary.nvim]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/nvim-treesitter]])

-- Ensure Ruby parser is available
local ok, _ = pcall(vim.treesitter.language.add, "ruby")
if not ok then
  print("Warning: Ruby tree-sitter parser not found. Some tests may fail.")
end

-- Basic settings for testing
vim.o.swapfile = false
vim.o.hidden = true

-- Load the plugin
require("ruby-fqcn")
