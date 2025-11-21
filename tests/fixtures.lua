local M = {}

M.simple_class = [[
class Foo
  def bar
  end
end
]]

M.simple_module = [[
module Foo
  def bar
  end
end
]]

M.nested_class = [[
module Foo
  class Bar
    def baz
    end
  end
end
]]

M.deeply_nested = [[
module Foo
  module Bar
    class Baz
      def qux
      end
    end
  end
end
]]

M.parent_scope = [[
module Foo
  module Bar
    class Baz
    end
  end
end
]]

M.scope_resolution = [[
class Foo::Bar
  def baz
  end
end
]]

M.struct_new = [[
module Foo
  Customer = Struct.new(:name, :address)
end
]]

M.struct_new_with_block = [[
module Foo
  Customer = Struct.new(:name) do
    def greeting
      "Hello"
    end
  end
end
]]

M.data_define = [[
class Foo
  Point = Data.define(:x, :y)
end
]]

M.indented_class = [[
module Foo
  class Bar
  end
end
]]

M.comment_before_class = [[
# comment
class Foo
end
]]

M.multiple_classes = [[
class Foo
end

class Bar
  def baz
  end
end
]]

M.variable_assignment = [[
class Foo
  bar = 123
end
]]

return M
