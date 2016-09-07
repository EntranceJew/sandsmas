require "imgui"
local projector = require("projector")
local nogame

--
-- LOVE callbacks
--

function love.load(arg)
    nogame = projector:new("nogame.lua")
end

function love.update(dt)
    print('bonus')
    imgui.NewFrame()
    nogame:update(dt)
end

local capture = {}
local function CaptureWindowDims()
    local x, y = imgui.GetWindowPos()
    local w, h = imgui.GetWindowSize()
    capture = {
        x = x,
        y = y,
        w = w,
        h = h
    }
    if x or y or w or h then
        return capture
    else
        capture = nil
        return
    end
end
local function CaptureWidgetDims()
    local x, y = imgui.GetItemRectMin()
    local w, h = imgui.GetItemRectMax()
    w = w - x
    h = h - y
    capture = {
        x = x,
        y = y,
        w = w,
        h = h
    }
    if x or y or w or h then
        return capture
    else
        capture = nil
        return
    end
end
local sceneCap
local gameCap

local maxdocks
local docks = 1
function daink(bug, name)
    local lies = "dock_" .. docks
    if bug ~= nil then
        lies = lies .. "_" .. bug
        imgui.SetNextDock(bug);
    end
    
    if name ~= nil then
        lies = name
    end
    
    if imgui.BeginDock(lies) then
        imgui.Text(lies);
    end
    imgui.EndDock();
    
    docks = docks + 1
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
    
    if imgui.Begin("DockArea", nil, { "NoResize", "NoMove", "NoBringToFrontOnFocus" }) then
        imgui.BeginDockspace()
            imgui.SetNextDock("Right");
            
            if imgui.BeginDock("Inspector") then
                imgui.Text("Inspector");
            end
            imgui.EndDock();
            
            imgui.SetNextDock("Left");
            
            if imgui.BeginDock("Project") then
                imgui.Text("Project");
            end
            imgui.EndDock();
            if imgui.BeginDock("Console") then
                imgui.Text("Console");
            end
            imgui.EndDock();
            
            imgui.SetNextDock("Top");
            
            if imgui.BeginDock("Hierarchy") then
                imgui.Text("Hierarchy");
            end
            imgui.EndDock();
            
            imgui.SetNextDock("Right");
            
            if imgui.BeginDock("Scene") then
                imgui.Text("Scene");
            end
            imgui.EndDock();
            if imgui.BeginDock("Game") then
                CaptureWindowDims()
                --print(capture.x, capture.y, capture.w, capture.h)
                imgui.Text("Game");
            end
            imgui.EndDock();
        imgui.EndDockspace()
    end
    imgui.End()

    love.graphics.clear(100, 100, 100, 255)
    imgui.Render();
    
    if capture then
        print(capture.x, capture.y, capture.w, capture.h)
        nogame:setPos(capture.x, capture.y)
        nogame:resize(capture.w/love.graphics.getWidth(), capture.h/love.graphics.getHeight())
        nogame:draw()
        
        capture = nil
    end
end

function love.quit()
    imgui.ShutDown();
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