local Console = require('libs.middleclass.middleclass')('Console')

local imgui = require('imgui')

Console.static.default_color = { 1.0, 1.0, 1.0, 1.0 }
Console.static.status_colors = {
	nay = { 1.0, 0.4, 0.4, 1.0 },
	warn = { 1.0, 0.78, 0.58, 1.0 },
	yay = { 0.4, 1.0, 0.4, 1.0 }
}

--[[
	Console
]]
function Console:initialize(args)
	self.console_history = {}
	-- entries in the form of {status=status, text=text}
end

function Console:Log(status, text)
	table.insert(self.console_history, {
		status = status,
		text = text
	})
end

function Console:Render()
	imgui.PushStyleVar("ItemSpacing", 4, 1)
	for i,item in ipairs(self.console_history) do
		-- get the color
		local color = Console.status_colors[item.status] or Console.default_color 
		
		imgui.PushStyleColor("Text", unpack(color))
		
		imgui.TextUnformatted("[" .. item.status .. "] " .. item.text)
		
		imgui.PopStyleColor()
	end
	imgui.PopStyleVar()
end

return Console