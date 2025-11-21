---@meta

---@diagnostic disable: lowercase-global

-- Plenary test functions
---@param name string
---@param fn function
function describe(name, fn) end

---@param name string
---@param fn function
function it(name, fn) end

---@param fn function
function before_each(fn) end

---@param fn function
function after_each(fn) end

-- Assert functions
---@class Assert
---@field are AssertAre
---@field is_nil fun(value: any)
---@field is_true fun(value: any)
---@field is_false fun(value: any)
assert = {}

---@class AssertAre
---@field equal fun(expected: any, actual: any)
---@field same fun(expected: any, actual: any)
