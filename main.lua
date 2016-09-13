io.stdout:setvbuf("no")
local imgui = require("imgui")
local UIHelper = require("src.classes.UIHelper"):new()
local editor = require("src.classes.Editor"):new('yay')
local projector = require("libs.projector")
local nogame, pong

--
-- LOVE callbacks
--

-- this gets merged into the sandboxes
-- therefore, we are exposing the gift of sandsmas here
local sandsmas = {
	sandsmas = {
		editor = editor
	}
}

function love.load(arg)
	nogame = projector:new("project/nogame/main.lua", sandsmas)
	pong = projector:new("project/pong/main.lua", sandsmas)
	
	local testfunc = function() end
	UIHelper:AddMenu("File/New", testfunc)
	UIHelper:AddMenu("File/Open", testfunc)
	UIHelper:AddMenu("File/Save", testfunc)
	UIHelper:AddMenu("File/Save As...", testfunc)
	UIHelper:AddMenu("Edit/This", testfunc)
	UIHelper:AddMenu("Edit/Thing", testfunc)
	UIHelper:AddMenu("Help/About", testfunc)
end

function love.update(dt)
	imgui.NewFrame()
	nogame:update(dt)
	pong:update(dt)
	
	-- reverse the hierarchy stack so things are roughly in hierarchial view
	editor.inspector:ClearSelection()
	for _, uid in ipairs(editor.hierarchy.chrono_selection) do
		editor.inspector:AddSelection(editor.hierarchy.objects[uid])
	end
end

function love.draw()
	local wx, wy, x, y
	UIHelper:RenderMenu()
	
	imgui.SetNextWindowPos(0, 0)
	imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight())
	
	if UIHelper:Begin("DockArea", nil, { "NoResize", "NoMove", "NoBringToFrontOnFocus" }) then
		imgui.BeginDockspace()
			imgui.SetNextDock("Right")
			
			if imgui.BeginDock("Inspector") then
				editor.inspector:Render()
			end
			imgui.EndDock()
			
			imgui.SetNextDock("Left")
			
			if imgui.BeginDock("Project") then
				imgui.Text("Project")
			end
			imgui.EndDock()
			if imgui.BeginDock("Console") then
				editor.console:Render()
			end
			imgui.EndDock()
			
			imgui.SetNextDock("Top")
			
			if imgui.BeginDock("Hierarchy") then
				editor.hierarchy:Render()
			end
			imgui.EndDock()
			
			imgui.SetNextDock("Right")
			
			if imgui.BeginDock("Scene") then
				nogame.active = imgui.IsWindowFocused() 
				local x, y = imgui.GetWindowPos()
				local w, h = imgui.GetWindowSize()
				UIHelper:PushPostRender(function()
					nogame:setPos(x, y)
					nogame:resize(w, h)
					nogame:draw()
				end)
			end
			imgui.EndDock()
			
			if imgui.BeginDock("Game") then
				pong.active = imgui.IsWindowFocused() 
				local x, y = imgui.GetWindowPos()
				local w, h = imgui.GetWindowSize()
				UIHelper:PushPostRender(function()
					pong:setPos(x, y)
					pong:resize(w, h)
					pong:draw()
				end)
			end
			imgui.EndDock()
			
		imgui.EndDockspace()
	end
	UIHelper:End()

	love.graphics.clear(100, 100, 100, 255)
	imgui.Render()
	
	UIHelper:PostRender()
end

function love.quit()
	imgui.ShutDown()
end

--
-- User inputs
--
function love.textinput(t)
	imgui.TextInput(t)
end

function love.keypressed(key)
	imgui.KeyPressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == "y" then
		editor.console:Log('error', "too many dannies")
	end
end

function love.keyreleased(key)
	imgui.KeyReleased(key)
end

function love.mousemoved(x, y)
	imgui.MouseMoved(x, y)
end

function love.mousepressed(x, y, button)
	imgui.MousePressed(button)
end

function love.mousereleased(x, y, button)
	imgui.MouseReleased(button)
end

function love.wheelmoved(x, y)
	imgui.WheelMoved(y)
end