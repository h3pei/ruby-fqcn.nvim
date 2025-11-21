# ruby-fqcn.nvim

Neovim plugin to extract fully qualified class names (FQCN) from Ruby classes and modules.

Provides the `:CopyRubyFQCN` command to copy to clipboard, as well as the `get_fqcn()` API for use by other plugins.

*TODO: demo gif*

## Requirements

- Neovim 0.10+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with Ruby parser

## Installation

### lazy.nvim

```lua
{
  "your-username/ruby-fqcn.nvim",
  ft = "ruby",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
```

## Usage

### Command

With a Ruby file open, run the `:CopyRubyFQCN` command.

Based on the cursor position, the FQCN of the current class/module will be copied to the clipboard.

## Example

```ruby
module Foo
  module Bar
    class Baz
      # If cursor is here => "Foo::Bar::Baz" is copied
    end
    # If cursor is here => "Foo::Bar" is copied
  end

  # If cursor is here => "Foo" is copied

  Qux = Struct.new(:x, :y) do
    # If cursor is here
    # => "Foo::Customer" is copied
  end

  Quux = Data.define(:x, :y) # If cursor is here => "Foo::Quux" is copied
end
```

## Keymapping

You can set up a keymapping as you like:

```lua
vim.keymap.set("n", "<leader>rc", "<cmd>CopyRubyFQCN<cr>", { desc = "Copy Ruby FQCN" })
```
