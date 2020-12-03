local Component = require("fecs.component")

---@class Entity
---@field public id number
---@field private _world World
---@field private _singletonName boolean
---@field private _comps table<string, number>
local Entity = class("Entity")

function Entity:ctor()
    self.id = 0
    self._world = nil
    self._singletonName = nil
    self._comps = {}
end

---@public
---@param comp Component
function Entity:AddComponent(comp)
    assert(comp:isInstComponent(), comp)

    self[comp.__cname] = comp
    self._comps[comp.__cname] = 1

    self._world:AddEntity(self)
end

---@public
---@param name component name
function Entity:GetComponent(name)
    return self[name]
end

---@public
---@param comp Component
function Entity:RemoveComponent(comp)
    self[comp.__cname] = nil
    self._comps[comp.__cname] = nil

    self._world:AddEntity(self)
end

---@public
---@return boolean
function Entity:IsSingleton()
    return self._singletonName ~= nil
end

---@public
---@return World
function Entity:GetWorld()
    return self._world
end

--region Private

---@private
---@param world World
---@param id number
---@param singletonName string
function Entity:awakeFromPool(world, id, singletonName)
    self.id = id
    self._world = world
    self._singletonName = singletonName

    if self._singletonName then
        self._world:AddSingletonEntity(self)
    end
end

---@private
function Entity:recycleToPool()
    ---clear all components
    for k, _ in pairs(self._comps) do
        self[k] = nil
    end

    self._world = nil
    self._comps = {}
    self._singletonName = nil

    self.id = 0
end

--endregion

return Entity
