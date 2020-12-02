local Global = require("fecs.global")
local TinyECS = require("fecs.tiny_ecs")

---@class World
---@field private _world table
---@field private _eid number
---@field private _singletonEntity table<string, Entity>
---@field private _changedEntityCache Entity
local World = class("World")

function World:ctor()
    self._world = TinyECS.world()
    self._eid = 0
    self._singletonEntity = {}

    self._changedEntityCache = nil
end

--region Public

---@public
---@param dt number
function World:Update(dt)
    if self._changedEntityCache then
        self._changedEntityCache = nil
    end

    self._world:update(dt)
end

---@public
---@param system System
function World:AddSystem(system)
    self._world:addSystem(system._system)
    system._world = self
end

---@public
---@param system System
function World:RemoveSystem(system)
    self._world:removeSystem(system._system)
    system._world = nil
end

---@public
---@return Entity
function World:CreateEntity()
    local e = Global:GetEntity(self, self:GetEid())
    self:AddEntity(e)
    return e
end

---@public
---@param name string SingletonEntity Identifier
---@return Entity
function World:CreateSingletonEntity(name)
    if self._singletonEntity[name] then
        return self._singletonEntity[name]
    end

    local e = Global:GetEntity(self, self:GetEid(), name)
    self:AddEntity(e)
    return e
end

---@public
---@param entity Entity
function World:RemoveEntity(entity)
    if entity._singletonName then
        self:removeSingletonEntity(entity)
    end

    self._world:removeEntity(entity)

    if self._changedEntityCache == entity then
        self._changedEntityCache = nil
    end

    Global:RecycleEntity(entity)
end

---@public
---@param singletonName string
---@return Entity
function World:GetSingletonEntity(singletonName)
    return self._singletonEntity[singletonName]
end

--endregion

--region Private

---@private
function World:GetEid()
    self._eid = self._eid + 1
    return self._eid
end

---@private
---@param entity Entity
function World:AddEntity(entity)
    if entity ~= self._changedEntityCache then
        self._changedEntityCache = entity
        self._world:addEntity(entity)
    end
end

---@private
---@param entity Entity
function World:AddSingletonEntity(entity)
    if self._singletonEntity[entity._singletonName] then
        Log.e(string.format("Singleton entity %s already in this world"), entity._singletonName)
        return
    end

    self._singletonEntity[entity._singletonName] = entity
end

---@private
---@param entity Entity | string
function World:RemoveSingletonEntity(entity)
    local singletonName = entity
    if not type(entity) == "string" then
        singletonName = entity._singletonName
    end

    if not self._singletonEntity[singletonName] then
        Log.e(string.format("Entity %s isn't a singleton"), singletonName)
        return
    end

    self._singletonEntity[singletonName] = nil
end

--endregion

return World
