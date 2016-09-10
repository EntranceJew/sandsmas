local Editor = require('libs.middleclass.middleclass')('Editor')
local lume = require('libs.lume.lume')

local imgui = require('imgui')

function Editor:initialize(args)
	-- hierarchy
	self.objects = {}
	
	-- inspector
	self.selection = {}
	self.selection_names = {}
	
	-- console
	self.console_history = {}
	-- entries in the form of {status=status, text=text}
end

--[[
	Hierarchy
]]

function Editor:Register(obj)
	if obj.id and self.objects[id] == obj then
		-- already registered, soft warning
		self:ConsoleLog('warn', "Object '" .. tostring(obj) .. "' [" .. obj.id .. "] already has a UUID.")
	elseif obj.id and self.objects[id] ~= obj then
		self:ConsoleLog('error', "Object '" .. tostring(obj) .. "' [" .. obj.id .. "] had an ID but was not registered.\nCollision with entity properties.")
	end
	
	local id = lume.uuid()
	if self.objects[id] then
		self:ConsoleLog('error', "Generated UUID collided with existing registered object '" .. tostring(self.objects[id]) .. "' [" .. id .. "].\nAttempted to register: Object '" .. tostring(obj) .. "'.")
	end
	
	obj.id = id
	self.objects[id] = obj
	return id
end

--[[
	Inspector
]]

function Editor:AddSelection(...)
	for k,v in pairs({...}) do
		self:Register(v)
		table.insert(self.selection, v)
	end
end

-- @WARNING: Doesn't register objects for performance reasons.
function Editor:SetSelection(...)
	self.selection = {...}
end

function Editor:RenderInspector()
	for k,v in ipairs(self.selection) do
		self:RenderInspect(v)
	end
end

function Editor:RenderInspect(var)
	local itsname = tostring(var)
	if var.id then
		itsname = itsname .. "\t[" .. var.id .. "]"
	end
	if imgui.CollapsingHeader(tostring(itsname)) then
		for k, v in pairs(var) do
			local typ = type(v)
			if typ == "number" then
				local num, dec = math.modf(v)
				if dec then
					imgui.InputFloat(k, v)
				else
					imgui.InputFloat(k, v)
				end
			elseif typ == "string" then
				imgui.InputText(k, v, 40)
			else
				imgui.InputText(k, tostring(v), 40)
			end
		end
	end
end

--[[
	Console
]]

function Editor:ConsoleLog(status, text)
	table.insert(self.console_history, {status=status, text=text})
end

function Editor:RenderConsole()
	imgui.PushStyleVar("ItemSpacing", 4, 1)
	for i,item in ipairs(self.console_history) do
		
		local color = { 1.0, 1.0, 1.0, 1.0 }
		if item.status == 'nay' then
			color = { 1.0, 0.4, 0.4, 1.0 }
		elseif item.status == 'warn' then
			color = { 1.0, 0.78, 0.58, 1.0 }
		elseif item.status == 'yay' then
			color = { 0.4, 1.0, 0.4, 1.0 }
		end
		
		imgui.PushStyleColor("Text", unpack(color))
		
		imgui.TextUnformatted("[" .. item.status .. "] " .. item.text)
		imgui.PopStyleColor()
	end
	imgui.PopStyleVar()
end

return Editor