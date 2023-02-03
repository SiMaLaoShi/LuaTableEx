# LuaTableEx
扩展Lua中的table，使其能够展开table的内容，方便开发着能个查询到说需要的数据，类似网上工具的的Json格式化。

## 使用

```lua
require("table_ex")
local t = {}
print(table.toJson(t))
print(table.toJson(t))
```

## 演示

### table纯表格的演示结果

#### 测试代码

```lua
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
```

#### table.toJson

```json
{
	[true] = 'hello',
	['table: 00AA8C58'] = 100,
	['2'] = 'hello',
	[1] = 'hello',
	[2] = {
		['2'] = 'hello',
		[1] = 'hello',
		['boolKey'] = 'hello',
		['fKey'] = 'hello',
		['desc'] = 'hello',
	},
	['function: 00C78800'] = 'hello',
	['desc'] = 'hello',
}
```

#### table.tostring

```lua
{true="hello",['table: 00AA8C58']=100,2="hello",[1]="hello",[2]={2="hello",[1]="hello",boolKey="hello",fKey="hello",desc="hello"},['function: 00C78800']="hello",desc="hello"}
```

### table中带mt的演示效果，这里使用的是 [middleclass](https://github.com/kikito/middleclass)

#### 测试代码

```lua
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
```

#### table.toJson

```lua
{
	['sweetness'] = 1,
	['class'] = {
	},
}
```

#### table.tostring

```lua
{sweetness=1,class={}}
```

## 引用

[middleclass](https://github.com/kikito/middleclass)
