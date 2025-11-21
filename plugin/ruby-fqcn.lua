-- Prevent loading twice
if vim.g.loaded_ruby_fqcn then
  return
end
vim.g.loaded_ruby_fqcn = true

-- Register command
vim.api.nvim_create_user_command("CopyRubyFQCN", function()
  require("ruby-fqcn").copy_fqcn()
end, { desc = "Copy Ruby FQCN (Fully Qualified Class Name) to clipboard" })
