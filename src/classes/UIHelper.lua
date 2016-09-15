local UIHelper = require('libs.middleclass.middleclass')('UIHelper')
local lume = require('libs.lume.lume')
local imgui = require('imgui')

function UIHelper:initialize(args)
	self.postRenderStack = {}
	
	-- go by keys, call final callback
	self.menu = {}
	
	self:Reset()
end

function UIHelper:RenderMenuLevel(name, value)
	if type(value) == "function" then
		if name == "" then
			imgui.MenuItem("(Empty)", nil, false, false)
		elseif imgui.MenuItem(name) then
			value(name)
		end
	elseif type(value) == "table" then
		if imgui.BeginMenu(name) then
			local i = 0
			for k, v in pairs(value) do
				self:RenderMenuLevel(k, v)
				i = i + 1
			end
			if i == 0 then
				imgui.MenuItem("(Empty)", nil, false, false)
			end
			imgui.EndMenu()
		end
	end
end

function UIHelper:RenderMenu()
	if imgui.BeginMainMenuBar() then
		if imgui.BeginMenuBar() then
			for k, v in pairs(self.menu) do
				if type(v) == 'table' then
					self:RenderMenuLevel(k, v)
				elseif type(v) == 'function' then
					if imgui.BeginMenu(k) then
						self:RenderMenuLevel(k, v)
						imgui.EndMenu()
					end
				end
			end
			imgui.EndMenuBar()
		end
		imgui.EndMainMenuBar()
	end
end

function UIHelper:AddMenu(path, callback, shortcut, selected, enabled)
	local parts = lume.split(path, "/")
	local ctable = self.menu
	local depth = #parts
	
	for k,v in pairs(parts) do
		if k == depth then
			ctable[v] = callback
		else
			if not ctable[v] then
				ctable[v] = {}
			end
			ctable = ctable[v]
		end
	end
end

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