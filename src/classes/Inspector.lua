local Inspector = require('libs.middleclass.middleclass')('Inspector')

local imgui = require('imgui')

--[[
	Inspector
]]
function Inspector:initialize(args)
	self.selection = {}
	self.selection_names = {}
end

function Inspector:AddSelection(...)
	for k,v in pairs({...}) do
		-- self:Register(v)
		table.insert(self.selection, v)
	end
end

-- @WARNING: Doesn't register objects for performance reasons.
function Inspector:SetSelection(...)
	self.selection = {...}
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
		for k, v in pairs(var) do
			local typ = type(v)
			if typ == "number" then
				local num, dec = math.modf(v)
				-- this can be -0
				if math.abs(dec) == 0 then
					imgui.InputInt(k, v)
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

return Inspector