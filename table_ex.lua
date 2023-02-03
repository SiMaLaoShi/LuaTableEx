local type = type
local tostring = tostring
local format = string.format
local getmetatable = getmetatable
local next = next
local setmetatable = setmetatable
local pairs = pairs

local __MAX_TABLE_DEPTH = 9

local function __dump_tab(depth)
    local buffer = ""
    for _ = 1, depth do
        buffer = buffer .. "\t"
    end
    return buffer
end

local tostring_key = function(v)
    if type(v) == "string" then
        return "'" .. tostring(v) .. "'"
    end
    return tostring(v)
end

local mt_new = function(tbl, key)
    local mt = getmetatable(tbl)
    local nk, nv
    if mt and type(mt.__index) == 'table' then
        nk, nv = next(mt.__index, key)
    else
        nk, nv = next(tbl, key)
    end
    if nk then
        nv = tbl[nk]
    end
    return nk, nv
end

local function mt_pairs(tbl, key)
    return mt_new, tbl, nil
end

local function dump_table(t, depth)
    local tp = type(t)
    local buffer = ""
    if tp == "table" then
        local dt = depth + 1
        if dt > __MAX_TABLE_DEPTH then
            buffer = buffer .. "..."
            return buffer
        end

        buffer = buffer .. "{\n"
        depth = depth + 1
        --这个mtPairs可以如果没有重写过pairs
        for k, v in mt_pairs(t) do
            if type(k) == "string" or type(k) == "function" or type(k) == "table" then
                buffer = buffer .. __dump_tab(depth) .. tostring(format("['%s']", tostring(k))) .. " = "
            else
                buffer = buffer .. __dump_tab(depth) .. tostring(format("[%s]", tostring(k))) .. " = "
            end
            if type(v) == "table" then
                if k == "__index" or k == "__newindex" then
                    buffer = buffer .. "{}"
                else
                    buffer = buffer .. dump_table(v, depth)
                end
            else
                buffer = buffer .. tostring_key(v)
            end

            if depth ~= 0 then
                buffer = buffer .. ","
            end
            buffer = buffer .. "\n"
        end

        depth = depth - 1
        buffer = buffer .. __dump_tab(depth) .. "}"
    else
        buffer = buffer .. tostring(t)
    end

    return buffer
end

function __tostring(val)
    if type(val) == 'table' then
        return __table_tostring(val)
    elseif type(val) == 'string' then
        return "\"" .. tostring(val) .. "\""
    else
        return tostring(val)
    end
end

function __table_tostring(t)
    local s = "{"
    local i = 1
    for k, v in mt_pairs(t) do
        local signal = ","
        if i == 1 then
            signal = ""
        end
        if type(k) == 'number' then
            s = format("%s%s[%s]=%s", s, signal, tostring(k), __tostring(v))
        elseif type(k) == 'function' or type(k) == 'table' then
            s = format("%s%s['%s']=%s", s, signal, tostring(k), __tostring(v))
        else
            s = format("%s%s%s=%s", s, signal, tostring(k), __tostring(v))
        end
        i = i + 1
    end
    s = s .. "}"
    return s
end

table.toJson = function(t)
    if type(t) ~= "table" then
        return ""
    end
    return dump_table(t, 0)
end

table.tostring = function(t)
    if t == nil or _G.next(t) == nil then
        return "{}"
    end
    return __table_tostring(t)
end

table.isEmpty = function(t)
    if t == nil or _G.next(t) == nil then
        return true
    end
    return false
end

table.copy = function(t, mt)
    local ret = {}
    if not mt then
        setmetatable(ret, getmetatable(mt))
    end
    for k, v in mt_pairs(t) do
        ret[k] = v
    end
    return ret
end

table.deepClone = function (t, mt)
    local ret = {}
    if not mt then
        setmetatable(ret, getmetatable(t))
    end

    for k, v in mt_pairs(t) do
        if type(v) == "table" then
            ret[k] = table.deep_clone(v)
        else
            ret[k] = v
        end
    end

    return ret
end

table.contains = function(t, val)
    if t then
        for _, v in pairs(t) do
            if v == val then
                return true
            end
        end
    end
    return false
end

table.append = function (t, o)
    if t then
        for k, v in pairs(o) do
            t[k] = v
        end
    end
    return t
end

table.appendArray = function(dest, src)
    for _, v in ipairs(src) do
        dest[#dest + 1] = v
    end
end

table.removeRepetition = function(src)
    local dest = {}
    for k, v in pairs(src) do
        dest[v] = k
    end
    local t = {}
    for k, _ in pairs(dest) do
        t[#t + 1] = k
    end
    return t
end

table.len = function(t)
    local n = 0
    for _, _ in pairs(t) do
        n = n + 1
    end
    return n
end