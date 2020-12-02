local fecs = require("fecs.init")
local Component = fecs.Component
local System = fecs.System
local World = fecs.World

local PlayerComponent = class("PlayerComponent", Component)
function PlayerComponent:ctor(...)
    PlayerComponent.super.ctor(self, ...)

    self.name = "Joe"
    self.phrase = "I'm a plumber."
    self.mass = 150
    self.hairColor = "brown"
end

local TalkingSystem = class("TalkingSystem", System)
function TalkingSystem:CreateFilter()
    return self.filter.RequireAll(PlayerComponent)
end

function TalkingSystem:Update(entities, dt)
    for _, e in ipairs(entities) do
        local PlayerComp = e:GetComponent("PlayerComponent")
        PlayerComp.mass = PlayerComp.mass + dt * 3
        Log.i(("%s who weighs %d pounds, says %q."):format(PlayerComp.name, PlayerComp.mass, PlayerComp.phrase))
    end
end

local world = World.new()
local talk_system = TalkingSystem.new()
world:AddSystem(talk_system)

local playerEntity = world:CreateEntity()
playerEntity:AddComponent(PlayerComponent.new())

return function()
    for _ = 1, 20 do
        world:Update(1)
    end
end

-- skynet.timeout(20 * 100, function ()
--     require("fecs.test")()
-- end)
