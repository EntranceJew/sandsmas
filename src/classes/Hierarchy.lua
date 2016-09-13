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
	
	-- keyed by UIDs, contains if a object is selected in the hierarchy
	self.selection = {}
	
	-- keyed by index id, contains ipairs of objects that were selected, in order
	self.chrono_selection = {}
	
	self.open_stack = {}
end

function Hierarchy:RenderObject(object)
	local name = Hierarchy.GetObjectName( object )
	local node_clicked, node_open
	local node_flags = {"OpenOnArrow", "OpenOnDoubleClick"}
	local leaf_flags = {"Leaf", "NoTreePushOnOpen"}
	local use_flags
	
	-- Increase spacing to differentiate leaves from expanded contents.
	imgui.PushStyleVar("IndentSpacing", imgui.GetFontSize()*0.5)
	
	local has_children = not self:GetObjectHasNoChildren(object)
	if has_children then
		use_flags = node_flags
	else
		use_flags = leaf_flags
	end
	
	if self.selection[object.id] then
		table.insert(use_flags, "Selected")
	end
	
	node_open = imgui.TreeNodeEx(name, use_flags)
	node_clicked = imgui.IsItemClicked()
	
	self.open_stack[object.id] = node_open
	if node_open and has_children then
		for _, child_object in pairs(self.objects) do
			if self.parents[child_object.id] == object.id then
				self:AltRenderObject(child_object)
			end
		end
		imgui.TreePop()
	end
	
	if node_clicked then
		-- Update selection state. Process outside of tree loop to avoid visual inconsistencies during the clicking-frame.
		if love.keyboard.isDown("lctrl", "rctrl") then
			-- CTRL+click to toggle
			
			if self.selection[object.id] then
				local found_id
				for i, v in ipairs(self.chrono_selection) do
					if v == object.id then
						found_id = i
						break
					end
				end
				if found_id then
					table.remove(self.chrono_selection, found_id)
				end
			else
				table.insert(self.chrono_selection, object.id)
			end
			
			self.selection[object.id] = not self.selection[object.id]
		else
			-- Click to single-select
			self.selection = { [object.id] = true }
			self.chrono_selection = { [1] = object.id }
		end
	end
	
	imgui.PopStyleVar()
end

function Hierarchy:Render()
	for _, object in pairs(self.objects) do
		if self.parents[object.id] == '' then
			self:AltRenderObject(object)
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

function Hierarchy:GetObjectHasNoChildren(object)
	for k, v in pairs(self.parents) do
		if object.id == v then
			return false
		end
	end
	return true
end

return Hierarchy