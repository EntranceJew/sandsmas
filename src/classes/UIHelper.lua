local UIHelper = require('libs.middleclass.middleclass')('UIHelper')

local imgui = require('imgui')

function UIHelper:Dock(name, layout)
	local fullname = "dock_" + self.numDocks
	if layout ~= nil then
		fullname = fullname .. "_" .. layout
		imgui.SetNextDock(layout)
	end

	if name ~= nil then
		fullname = name
	end

	if imgui.BeginDock(fullname) then
		imgui.Text(fullname)
	end
	imgui.EndDock()
	
	self.numDocks = self.numDocks + 1
end

function UIHelper:initialize(args)
	self.postRenderStack = {}
	
	self:Reset()
end

function UIHelper:Reset()
	self.numDocks = 0
end

function UIHelper:PostRender()
	for k,v in pairs(self.postRenderStack) do
		v()
	end
	self.postRenderStack = {}
end

function UIHelper:PushPostRender(func)
	table.insert(self.postRenderStack, func)
end

function UIHelper:Begin(...)
	return imgui.Begin(...)
end

function UIHelper:End()
	imgui.End()
	self:Reset()
end

return UIHelper