require("table_ex")
require("helpfunc")
local fKey = function()
end
local boolKey = true
local tKey = {}
local t = {
    [1] = "hello",
    ['2'] = "hello",
    ["desc"] = 'hello',
    [fKey] = 'hello',
    [boolKey] = "hello",
    [2] = {
        [1] = "hello",
        ['2'] = "hello",
        ["desc"] = 'hello',
        ["fKey"] = 'hello',
        ['boolKey'] = "hello",
    },
    [tKey] = 100
}

------------------------------------------
print("纯表格 ==》Json")
print(table.toJson(t))
print("=============================================")
-------------------------------------------)
print("纯表格 ==》String")
print(table.tostring(t))
print("=============================================")
local class = require 'middleclass'
local Fruit = class('Fruit') -- 'Fruit' is the class' name

function Fruit:initialize(sweetness)
    self.sweetness = sweetness
end

Fruit.static.sweetness_threshold = 5 -- class variable (also admits methods)

function Fruit:isSweet()
    return self.sweetness > Fruit.sweetness_threshold
end

local Lemon = class('Lemon', Fruit) -- subclassing

function Lemon:initialize()
    Fruit.initialize(self, 1) -- invoking the superclass' initializer
end

local lemon = Lemon:new()

print("class ==》Json")
print(table.toJson(lemon))
print("=============================================")
print("class ==》string")
print(table.tostring(lemon))
print("=============================================")