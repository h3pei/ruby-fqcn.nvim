# ruby-fqcn.nvim

Neovim plugin to extract fully qualified class names (FQCN) from Ruby classes and modules.

Provides the `:CopyRubyFQCN` command to copy to clipboard, as well as the `get_fqcn()` API for use by other plugins.

![ruby-fqcn.nvim demo](https://github.com/user-attachments/assets/781cd86b-7883-442d-b47b-82ab79c910fc)

## Requirements

- Neovim 0.10+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with Ruby parser (Run `:TSInstall ruby`)

## Installation

```lua
-- lazy.nvim
{
  "h3pei/ruby-fqcn.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = "ruby",
}
```

## Usage

With a Ruby file open, run the `:CopyRubyFQCN` command. that's it!

Based on the cursor position, the FQCN of the current class/module will be copied to the clipboard.

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
-- example:
vim.keymap.set("n", "<leader>cf", "<cmd>CopyRubyFQCN<cr>", { desc = "Copy Ruby FQCN" })
```
