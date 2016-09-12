io.stdout:setvbuf("no")
local imgui = require("imgui")
local UIHelper = require("src.classes.UIHelper"):new()
local editor = require("src.classes.Editor"):new('yay')
local projector = require("libs.projector")
local nogame, pong

--[[ vec2
float dim[2] = { entitySelected->sprite->dimension.x, entitySelected->sprite->dimension.y }
imgui.InputFloat2("Dimension", dim)
]]

--[[ vec2
float pos[2] = { entitySelected->position.x, entitySelected->position.y };
imgui.InputFloat2("Position", pos);
entitySelected->position.x = pos[0];
entitySelected->position.y = pos[1];
]]

--[[ color4
float color[4] = { entitySelected->sprite->color.r, entitySelected->sprite->color.g, entitySelected->sprite->color.b, entitySelected->sprite->color.a };
imgui.ColorEdit4("Color", color);
entitySelected->sprite->color.r = color[0];
entitySelected->sprite->color.g = color[1];
entitySelected->sprite->color.b = color[2];
entitySelected->sprite->color.a = color[3];
]]

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
	nogame = projector:new("project/nogame.lua", sandsmas)
	pong = projector:new("project/main.lua", sandsmas)
end

function love.update(dt)
	imgui.NewFrame()
	nogame:update(dt)
	pong:update(dt)
end

function love.draw()
	local wx, wy, x, y
	if imgui.BeginMainMenuBar() then
		if imgui.BeginMenu("File") then
			imgui.MenuItem("New")
			imgui.MenuItem("Open")
			imgui.MenuItem("Save")
			imgui.MenuItem("Save As...")
			imgui.EndMenu()
		end
		if imgui.BeginMenu("Edit") then
			imgui.MenuItem("Test")
			imgui.EndMenu()
		end
		if imgui.BeginMenu("Call") then
			imgui.MenuItem("Test")
			imgui.EndMenu()
		end
		if imgui.BeginMenu("The") then
			imgui.MenuItem("Test")
			imgui.EndMenu()
		end
		if imgui.BeginMenu("Cops") then
			imgui.MenuItem("Test")
			imgui.EndMenu()
		end
		if imgui.BeginMenu("Window") then
			imgui.MenuItem("Test")
			imgui.EndMenu()
		end
		if imgui.BeginMenu("Help") then
			imgui.MenuItem("Test")
			imgui.EndMenu()
		end
		imgui.EndMainMenuBar()
	end
	
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
				imgui.Text("Hierarchy")
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