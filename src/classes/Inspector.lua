local Inspector = require('libs.middleclass.middleclass')('Inspector')

local imgui = require('imgui')

Inspector.static.type_lookups = {
	default = function(name, value)
		return imgui.InputText(name, tostring(value), 40, {"ReadOnly"})
	end,
	string = function(name, value)
		return imgui.InputText(name, tostring(value), 40)
	end,
	int = imgui.InputInt,
	float = imgui.InputFloat,
	color4 = function(name, value)
		return imgui.ColorEdit4(name, unpack(value))
	end,
}
Inspector.static.type_guessers = {
	float = function(name, value)
		local num, dec
		if type(value) == "number" then
			num, dec = math.modf(value)
			return (
				math.abs(dec) ~= 0
			)
		end
		return false
	end,
	int = function(name, value)
		local num, dec
		if type(value) == "number" then
			num, dec = math.modf(value)
			return (
				math.abs(dec) == 0
			)
		end
		return false
	end,
	color4 = function(name, value)
		return (
			type(value) == "table" and
			#value == 4 and
			type(value[1]) == "number" and
			type(value[2]) == "number" and 
			type(value[3]) == "number" and 
			type(value[4]) == "number" and 
			value[1] >= 0 and value[1] <= 1 and
			value[2] >= 0 and value[2] <= 1 and
			value[3] >= 0 and value[3] <= 1 and
			value[4] >= 0 and value[4] <= 1 
		)
	end,
	color3 = function(name, value)
		return (
			type(value) == "table" and
			#value == 3 and
			type(value[1]) == "number" and
			type(value[2]) == "number" and 
			type(value[3]) == "number" and 
			value[1] >= 0 and value[1] <= 1 and
			value[2] >= 0 and value[2] <= 1 and
			value[3] >= 0 and value[3] <= 1
		)
	end,
}

--[[
	Inspector
]]
function Inspector:initialize(args)
	self.selection = {}
end

function Inspector:AddSelection(...)
	for k,v in pairs({...}) do
		table.insert(self.selection, v)
	end
end

function Inspector:SetSelection(...)
	self.selection = {...}
end

function Inspector:ClearSelection()
	self.selection = {}
end

function Inspector:Render()
	for k,v in ipairs(self.selection) do
		self:RenderInspect(v)
	end
end

function Inspector:RenderInspect(var)
	local itsname = tostring(var)
	if var.id then
		itsname = itsname .. "\t[" .. var.id .. "]"
	end
	
	if imgui.CollapsingHeader(tostring(itsname)) then
		local value_changed, out
		for k, v in pairs(var) do
			local typ = type(v)
			local atype = typ
			
			-- attempt to obtain the type from a sequence of functions
			-- if any function returns true, it is that type
			for k0, v0 in pairs(Inspector.type_guessers) do
				if v0(k, v) then
					atype = k0
				end
			end
			
			if not Inspector.type_lookups[atype] then
				atype = 'default'
			end
			
			if Inspector.type_lookups[atype] then
				out = {Inspector.type_lookups[atype](k, v)}
				
				-- get the status alone
				value_changed = out[1]
				table.remove(out, 1)
			end
			
			-- value changed
			if value_changed then
				if #out > 1 then
					var[k] = out
				else
					var[k] = out[1]
				end
			end
		end
	end
end

return Inspector