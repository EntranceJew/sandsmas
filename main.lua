local imgui = require("imgui")
local UIHelper = require("src.classes.UIHelper")()
local projector = require("libs.projector")
local nogame

--
-- LOVE callbacks
--

function love.load(arg)
    nogame = projector:new("project/main.lua")
end

function love.update(dt)
    imgui.NewFrame()
    nogame:update(dt)
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
                imgui.Text("Inspector")
            end
            imgui.EndDock()
            
            imgui.SetNextDock("Left")
            
            if imgui.BeginDock("Project") then
                imgui.Text("Project")
            end
            imgui.EndDock()
            if imgui.BeginDock("Console") then
                imgui.Text("Console")
            end
            imgui.EndDock()
            
            imgui.SetNextDock("Top")
            
            if imgui.BeginDock("Hierarchy") then
                imgui.Text("Hierarchy")
            end
            imgui.EndDock()
            
            imgui.SetNextDock("Right")
            
            if imgui.BeginDock("Scene") then
                imgui.Text("Scene")
            end
            imgui.EndDock()
            
            if imgui.BeginDock("Game") then
                local x, y = imgui.GetWindowPos()
                local w, h = imgui.GetWindowSize()
                UIHelper:PushPostRender(function()
                    nogame:setPos(x, y)
                    nogame:resize(w/love.graphics.getWidth(), h/love.graphics.getHeight())
                    nogame:draw()
                end)
                imgui.Text("Game")
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