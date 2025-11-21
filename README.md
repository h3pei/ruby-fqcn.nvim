# ruby-fqcn.nvim

Neovim plugin to extract fully qualified class names (FQCN) from Ruby classes and modules.

Provides the `:CopyRubyFQCN` command to copy to clipboard, as well as the `get_fqcn()` API for use by other plugins.

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

### API

An API is available for use from other plugins or configurations:

```lua
local ruby_fqcn = require("ruby-fqcn")

-- Get FQCN (without copying to clipboard)
local fqcn = ruby_fqcn.get_fqcn()

-- Get FQCN and copy to clipboard
ruby_fqcn.copy_fqcn()
```

## Example

```ruby
module Foo
  module Bar
    class Baz
      # If cursor is here
      # => "Foo::Bar::Baz" is copied
    end
    # If cursor is here
    # => "Foo::Bar" is copied
  end

  # If cursor is here
  # => "Foo" is copied

  class Hoge
    # If cursor is here
    # => "Foo::Hoge" is copied
  end
end
```

## Keymapping

You can set up a keymapping as you like:

```lua
vim.keymap.set("n", "<leader>rc", "<cmd>CopyRubyFQCN<cr>", { desc = "Copy Ruby FQCN" })
```

## License

MIT
