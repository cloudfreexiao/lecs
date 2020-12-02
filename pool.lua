---
---Table pool for lua
---
---@class Pool
---@field public DEFAULT_TAG string @default object tag for pool
---@field private _ctorHandle table<string, function>
---@field private _pools table<string, table[]>
local Pool = {}

local DEFAULT_TAG = "__"

Pool.DEFAULT_TAG = DEFAULT_TAG
Pool.__index = Pool

setmetatable(
    Pool,
    {
        __call = function(class, opt)
            local instance = {}
            setmetatable(instance, Pool)
            instance:new(opt)
            return instance
        end
    }
)

---@param pool Pool
---@param tag string
---@param create boolean
local function getPoolArr(pool, tag, create)
    local poolArr = pool._pools[tag]
    if not poolArr and create then
        poolArr = {}
        pool._pools[tag] = poolArr
    end
    return poolArr
end

---@param pool Pool
---@param tag string
local function createInstance(pool, tag)
    tag = tag or DEFAULT_TAG
    local ctorHandle = pool._ctorHandle[tag]
    if ctorHandle then
        return ctorHandle()
    else
        return {}
    end
end

---@param pool Pool
---@param tag string
---@vararg any
local function getFromPool(pool, tag, ...)
    local ins = nil
    if pool._pools[tag] then
        local poolArr = pool._pools[tag]
        if #poolArr > 0 then
            ins = poolArr[#poolArr]
            poolArr[#poolArr] = nil
        end
    end

    if not ins then
        ins = createInstance(pool, tag)
    end

    if ins.awakeFromPool then
        ins:awakeFromPool(...)
    end

    return ins
end

---@param pool Pool
---@param tag string
---@param t string
---@vararg any
local function recycleToPool(pool, tag, t, ...)
    local poolArr = getPoolArr(pool, tag, true)

    poolArr[#poolArr + 1] = t
    if t.recycleToPool then
        t:recycleToPool(...)
    end
end

---@param pool Pool
---@param tag string
---@param clearCtorHandle boolean
local function clearPool(pool, tag, clearCtorHandle)
    pool._pools[tag] = nil
    if clearCtorHandle then
        pool._ctorHandle[tag] = nil
    end
end

---@private
function Pool:new(opt)
    self._ctorHandle = {}
    self._pools = {}

    if opt then
        if opt.ctor then
            for k, v in pairs(opt.ctor) do
                self._ctorHandle[k] = v
            end
        end

        if opt.presize then
            for k, v in pairs(opt.presize) do
                self:presize(v, k)
            end
        end
    end
end

---
---Set table constructor handle for object
---when get a table from pool, if there isn't a table in pool,
---will use this constructor handle to create new one and return it.
---@public
---@param handle function @create object handle
---@param tag string @[option] object tag
function Pool:setCtorHandle(handle, tag)
    tag = tag or DEFAULT_TAG
    self._ctorHandle[tag] = handle
end

---
---Get table from pool
---if table has a awakeFromPool function,
---will call this function with parameters by pass.
---@public
---@vararg any
---@return table
function Pool:get(...)
    return getFromPool(self, DEFAULT_TAG, ...)
end

---
---Get table from pool with object tag
---if table has a awakeFromPool function,
---will call taht function with parameters by pass.
---@public
---@param tag string
---@vararg any
---@return table
function Pool:getWithTag(tag, ...)
    return getFromPool(self, tag, ...)
end

---
---Recycle table to pool
---if table has a recycleToPool function,
---will call that function with parameters by pass.
---@public
---@param t table
---@vararg any
function Pool:recycle(t, ...)
    recycleToPool(self, DEFAULT_TAG, t, ...)
end

---
---Recycle table to pool with object tag
---if table has a recycleToPool function,
---will call that function with parameters by pass.
---@public
---@param t table
---@param tag string
---@vararg any
function Pool:recycleWithTag(t, tag, ...)
    recycleToPool(self, tag, t, ...)
end

---
---Pre create some table with an option object tag.
---@public
---@param count number
---@param tag string @[option] object tag
---@return boolean
function Pool:presize(count, tag)
    local poolArr = getPoolArr(self, tag or DEFAULT_TAG, true)
    if #poolArr >= count then
        return false
    end

    local needCreateSize = count - #poolArr
    local ctorHandle = self._ctorHandle[tag]
    local createFunction = ctorHandle and function()
            return ctorHandle()
        end or function()
            return {}
        end

    for i = 1, needCreateSize do
        poolArr[#poolArr + 1] = createFunction()
    end

    return true
end

---
---Clear objects in pool
---@public
---@param clearCtorHandle boolean @default false
function Pool:clear(clearCtorHandle)
    clearCtorHandle = clearCtorHandle or false
    clearPool(self, DEFAULT_TAG, clearCtorHandle)
end

---
---Clear all objects in pool
---@public
---@param clearCtorHandle boolean @default false
function Pool:clearAll(clearCtorHandle)
    self._pools = {}
    self._ctorHandle = {}
end

---
---Clear all objects with an object tag in pool
---@public
---@param tag string
---@param clearCtorHandle boolean @default false
function Pool:clearTag(tag, clearCtorHandle)
    clearCtorHandle = clearCtorHandle or false
    clearPool(self, tag, clearCtorHandle)
end

return Pool
