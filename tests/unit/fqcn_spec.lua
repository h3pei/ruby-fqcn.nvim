local helpers = require("tests.helpers")
local fixtures = require("tests.fixtures")
local ruby_fqcn = require("ruby-fqcn")

describe("ruby-fqcn", function()
  local bufnr

  before_each(function()
    -- Clear clipboard
    vim.fn.setreg("+", "")
    vim.fn.setreg('"', "")
  end)

  after_each(function()
    helpers.cleanup_buffer(bufnr)
  end)

  describe("get_fqcn", function()
    it("should return simple class name", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.simple_class, { 2, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo", result)
    end)

    it("should return simple module name", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.simple_module, { 2, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo", result)
    end)

    it("should return nested class name", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.nested_class, { 3, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Bar", result)
    end)

    it("should return deeply nested name", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.deeply_nested, { 4, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Bar::Baz", result)
    end)

    it("should return parent module when cursor is in parent scope", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.parent_scope, { 6, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo", result)
    end)

    it("should handle class with scope resolution", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.scope_resolution, { 2, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Bar", result)
    end)

    it("should handle Struct.new constant assignment", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.struct_new, { 2, 2 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Customer", result)
    end)

    it("should handle Struct.new with block", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.struct_new_with_block, { 3, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Customer", result)
    end)

    it("should handle Data.define constant assignment", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.data_define, { 2, 2 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Point", result)
    end)

    it("should handle cursor at line beginning with indentation", function()
      -- Cursor at column 0 (before indentation) on class Bar line
      bufnr = helpers.setup_ruby_buffer(fixtures.indented_class, { 2, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo::Bar", result)
    end)

    it("should return nil for non-Ruby files", function()
      bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(bufnr)
      vim.bo[bufnr].filetype = "lua"

      local result = ruby_fqcn.get_fqcn()
      assert.is_nil(result)
    end)

    it("should return nil when cursor is outside class/module", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.comment_before_class, { 1, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.is_nil(result)
    end)

    it("should handle multiple classes and return correct one", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.multiple_classes, { 5, 0 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Bar", result)
    end)

    it("should not include regular variable assignments", function()
      -- Cursor on the assignment line
      bufnr = helpers.setup_ruby_buffer(fixtures.variable_assignment, { 2, 2 })

      local result = ruby_fqcn.get_fqcn()
      assert.are.equal("Foo", result)
    end)
  end)

  describe("copy_fqcn", function()
    it("should copy FQCN to clipboard", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.nested_class, { 3, 0 })

      ruby_fqcn.copy_fqcn()

      local clipboard = helpers.get_clipboard()
      assert.are.equal("Foo::Bar", clipboard)
    end)

    it('should copy to both + and " registers', function()
      bufnr = helpers.setup_ruby_buffer(fixtures.simple_class, { 2, 0 })

      ruby_fqcn.copy_fqcn()

      assert.are.equal("Foo", vim.fn.getreg("+"))
      assert.are.equal("Foo", vim.fn.getreg('"'))
    end)

    it("should not copy when outside class/module", function()
      bufnr = helpers.setup_ruby_buffer(fixtures.comment_before_class, { 1, 0 })
      vim.fn.setreg("+", "original")

      ruby_fqcn.copy_fqcn()

      -- Clipboard should remain unchanged
      assert.are.equal("original", helpers.get_clipboard())
    end)

    it("should not copy for non-Ruby files", function()
      bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(bufnr)
      vim.bo[bufnr].filetype = "lua"
      vim.fn.setreg("+", "original")

      ruby_fqcn.copy_fqcn()

      assert.are.equal("original", helpers.get_clipboard())
    end)
  end)
end)
