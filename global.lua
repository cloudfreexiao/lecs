local Pool = require("lecs.pool")
local Entity = require("lecs.entity")

---@class Global
---@field private _entityPool Pool
local Global = {}

function Global:init()
    self._entityPool = Pool({
        ctor = {
            [Pool.DEFAULT_TAG] = Entity.new -- obj create function
        }
    })
end

---@param world World
---@return Entity
function Global:GetEntity(world, eid, singletonName)
    return self._entityPool:get(world, eid, singletonName)
end

---@param entity Entity
function Global:RecycleEntity(entity)
    self._entityPool:recycle(entity)
end

Global:init()

return Global