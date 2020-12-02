local TinyECS = require("fecs.tiny_ecs")
local Filter = require("fecs.filter")

---@class System
---@field protected filter Filter
---@field private _system table
---@field private _world World
local System = class("System")

function System:ctor()
    self.filter = Filter

    local system = TinyECS.system()
    system.filter = self:CreateFilter()
    system.update = function(t, dt)
        self:Update(t.entities, dt)
    end

    self._system = system
    self._world = nil
end

function System:CreateFilter()
end

---@param entities Entity[]
function System:Update(entities, dt)
end

---@protected
---@return World
function System:GetWorld()
    return self._world
end

return System
