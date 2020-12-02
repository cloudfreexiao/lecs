local TinyECS = require("fecs.tiny_ecs")

---@class Filter
local Filter = {}

---@public
---@vararg Comp
---@return function
function Filter.RequireAll(...)
    local f = {...}
    for i = 1, #f do
        f[i] = f[i].__cname
    end

    return TinyECS.requireAll(table.unpack(f))
end

---@public
---@vararg Component
---@return function
function Filter.RequireAny(...)
    local f = {...}
    for i = 1, #f do
        f[i] = f[i].__cname
    end
    return TinyECS.requireAny(table.unpack(f))
end

---@public
---@vararg Component
---@return function
function Filter.RejectAll(...)
    local f = {...}
    for i = 1, #f do
        f[i] = f[i].__cname
    end
    return TinyECS.rejectAll(table.unpack(f))
end

---@public
---@vararg Component
---@return function
function Filter.RejectAny(...)
    local f = {...}
    for i = 1, #f do
        f[i] = f[i].__cname
    end
    return TinyECS.rejectAny(table.unpack(f))
end

---@public
---@vararg function
---@return function
function Filter.And(...)
    return TinyECS.requireAll(...)
end

---@public
---@vararg function
---@return function
function Filter.Or(...)
    return TinyECS.requireAny(...)
end

return Filter
