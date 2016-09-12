local Hierarchy = require('libs.middleclass.middleclass')('Hierarchy')
local lume = require('libs.lume.lume')

local imgui = require('imgui')

-- Hierarchy.static.property = 'great'

--[[
	Hierarchy
]]
function Hierarchy:initialize(args)
	self.objects = {}
end

function Hierarchy:Register(obj)
	if obj.id and self.objects[id] == obj then
		-- already registered, soft warning
		assert(false, "Object '" .. tostring(obj) .. "' [" .. obj.id .. "] already has a UUID.")
	elseif obj.id and self.objects[id] ~= obj then
		assert(false, "Object '" .. tostring(obj) .. "' [" .. obj.id .. "] had an ID but was not registered.\nCollision with entity properties.")
	end
	
	local id = lume.uuid()
	if self.objects[id] then
		assert(false, "Generated UUID collided with existing registered object '" .. tostring(self.objects[id]) .. "' [" .. id .. "].\nAttempted to register: Object '" .. tostring(obj) .. "'.")
	end
	
	obj.id = id
	self.objects[id] = obj
	return id
end

return Hierarchy