local Hierarchy = require('libs.middleclass.middleclass')('Hierarchy')
local lume = require('libs.lume.lume')

local imgui = require('imgui')

-- Hierarchy.static.property = 'great'
Hierarchy.static.GetObjectName = function(obj)
	return tostring(obj) .. " [" .. obj.id .. "]"
end

--[[
	Hierarchy
]]
function Hierarchy:initialize(args)
	-- keyed by UIDs, contains object table references
	self.objects = {}
	
	-- keyed by UIDs, contains UIDs for an object's parent
	self.parents = {}
	
	self.open_stack = {}
end

function Hierarchy:RenderObject(object)
	-- Use object uid as identifier.
	imgui.PushID(object.id)
	
	local name = Hierarchy.GetObjectName( object )
	local is_open = imgui.TreeNode( name )
	if is_open then
		
		for _, child_object in pairs(self.objects) do
			if self.parents[child_object.id] == object.id and self:RenderObject(child_object) then
				table.insert(self.open_stack, child_object.id)
			end
		end
		
		--[[
		-- show elements
		for k,v in pairs(object) do
			imgui.Bullet()
			imgui.Selectable(k)
		end
		]]
		
		
		imgui.TreePop()
	end
	
	imgui.PopID()
	return is_open
end

function Hierarchy:Render()
	-- ShowHelpMarker("This example shows how you may implement a property editor using two columns.\nAll objects/fields data are dummies here.\nRemember that in many simple cases, you can use imgui.SameLine(xxx) to position\nyour cursor horizontally instead of using the Columns() API.")

	self.open_stack = {}

	-- Iterate dummy objects with dummy members (all the same data)
	for _, object in pairs(self.objects) do
		if self.parents[object.id] == '' and self:RenderObject(object) then
			table.insert(self.open_stack, object.id)
		end
	end
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
	
	self.parents[id] = ''
	return id
end

function Hierarchy:NewObject(name, parent)
	local obj = {
		name = name
	}
	local omet = {
		__tostring = function(oself)
			return oself.name
		end,
	}
	setmetatable(obj, omet)
	
	self:Register(obj)
	self:SetObjectParent(obj, parent)
	
	return obj
end

-- Set an object's parent with a reference to both.
function Hierarchy:SetObjectParent(object, parent)
	local toset
	--local oldparent = self.parents[object.id]
	if parent then
		toset = parent.id
	else
		toset = ''
	end
	self.parents[object.id] = toset
end

return Hierarchy