local type = type
local pairs = pairs
local tostring = tostring
local format = string.format
local getmetatable = getmetatable
local next = next

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
            if type(k) == "string" or type(k) == "function" then
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

table.toJson = function(t)
    if type(t) ~= "table" then
        return ""
    end
    return dump_table(t, 0)
end

local function __table_tostring (t)
    local function __tostring(val)
        if type(val)=='table' then
            return __table_tostring(val)
        elseif type(val)=='string' then
            return "\"" .. tostring(val) .. "\""
        else
            return tostring(val)
        end
    end

    if t == nil or _G.next(t) == nil then
        return "{}"
    end
    local s = "{"
    local i = 1
    for k, v in pairs(t) do
        local signal = ","
        if i == 1 then
            signal = ""
        end
        if type(k) == 'number' then
            s = s .. signal .. '[' .. k .. "]=" .. __tostring(v)
        elseif type(k) == 'function' then
            s = s .. signal .. '[' .. tostring_key(k) .. "]=" .. __tostring(v)
        else
            s = s .. signal .. (tostring(k)) .. "=" .. __tostring(v)
        end
            i = i + 1
        end
    s = s .. "}"
    return s
end

table.tostring = function(val)
    if type(val)=='table' then
        return __table_tostring(val)
    elseif type(val)=='string' then
        return "\"" .. tostring(val) .. "\""
    else
        return tostring(val)
    end
end