---@class Component
local Component = class("Component")

function Component:ctor()
    self.__isinst = true
end

function Component:isInstComponent()
    return self.__isinst
end

return Component
