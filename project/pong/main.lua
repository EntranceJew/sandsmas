local editor = sandsmas.editor
local imgui = sandsmas.imgui

local class = require('libs.middleclass.middleclass')
objects = { Pad = {}, Ball = {} }
local scale = function(valueIn, baseMin, baseMax, limitMin, limitMax)
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin
end

--[[
	Pad
]]

local Pad = class('Pad')
local Ball = class('Ball')
local Transform = class('Transform')

function Transform:initialize(x, y, sx, sy, rx, ry)
	self.x = x or 0
	self.y = y or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.rx = rx or 0
	self.ry = ry or 0
end

function Transform:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function Transform:getPosition()
	return self.x, self.y
end

function Transform:setScale(sx, sy)
	self.sx = sx or self.sx
	self.sy = sy or self.sy
end

function Transform:getScale()
	return self.sx, self.sy
end

function Transform:setRotation(rx, ry)
	self.rx = rx or self.rx
	self.ry = ry or self.ry
end

function Transform:getRotation()
	return self.rx, self.ry
end

Pad.static.score_to_win = 6
Pad.static.color = {1.0,1.0,1.0,1.0}

function Pad:initialize(upKey, downKey)
	self.upKey = upKey or "w"
	self.downKey = downKey or "s"
	
	self.honk = true
	
	self.playerNo = #objects['Pad'] + 1
	
	self.width = 60
	
	self.moveSpeed = 7
	
	self.extent = 250
	
	self.score = 0
	
	self.color = Pad.color
	
	self.sign = -1
	if self.playerNo > 1 then
		self.sign = self.sign * -1
	end
	
	self.transform = Transform:new(0, 0, 20, 100)
	
	table.insert(objects['Pad'], self)
end

function Pad:update(dt)
	local moveValue 
	if love.keyboard.isDown(self.upKey) and love.keyboard.isDown(self.downKey) then
		-- what do you expect?
	elseif love.keyboard.isDown(self.upKey) then
		self.transform:setPosition(nil, self.transform.y - self.moveSpeed)
	elseif love.keyboard.isDown(self.downKey) then
		self.transform:setPosition(nil, self.transform.y + self.moveSpeed)
	end
	
	if self.transform.y < -self.extent then
		self.transform:setPosition(nil, -self.extent)
	end
	if self.transform.y > self.extent then
		self.transform:setPosition(nil, self.extent)
	end
	
	if self.score > Pad.score_to_win and self.color == Pad.color then
		self.color = {1.0,0.0,0.0,1.0}
	end
end

function Pad:draw()
	if self.color ~= Pad.color then
		love.graphics.setColor(self.color[1]*255, self.color[2]*255, self.color[3]*255, self.color[4]*255)
	end
	love.graphics.rectangle("fill", (Ball.outer_limit_x*self.sign)-10, self.transform.y - 50, 20, 100)
end

--[[
	Ball
]]

Ball.static.inner_limit_x = 325
Ball.static.outer_limit_x = 350

function Ball:initialize()
	self.x = 0
	self.y = 0
	self.speed = 3
	self.vx = -self.speed
	self.vy = self.speed
	
	self.limit_y = 285
	self.inner_limit_x = 325
	self.outer_limit_x = 350
	self.goal_limit = 415
	
	table.insert(objects['Ball'], self)
end

function Ball:update(dt)
	self.x = self.x + self.vx
	self.y = self.y + self.vy
	
	if math.abs(self.y) >= self.limit_y then
		self.vy = -self.vy
	end
	
	self:check_goal(objects['Pad'][1])
	self:check_goal(objects['Pad'][2])
end

function Ball:check_goal(pad)
	local otherPlayerNo = (3-pad.playerNo)
	
	local boundaryCheck = false
	if pad.playerNo == 1 then
		boundaryCheck = self.x < self.inner_limit_x*pad.sign and self.x > self.outer_limit_x*pad.sign
	elseif pad.playerNo == 2 then
		boundaryCheck = self.x > self.inner_limit_x*pad.sign and self.x < self.outer_limit_x*pad.sign
	end
	
	if boundaryCheck and math.abs(pad.transform.y - self.y) < pad.width then
		self.speed = self.speed + scale(pad.playerNo, 1, 2, 0.2, 0.5)
		self.x = self.inner_limit_x*pad.sign
		self.vx = self.speed*pad.sign*-1
		self.vy = self.vy * scale(pad.playerNo, 1, 2, 0.5, 0.8) + math.random(-10, 10) / (otherPlayerNo*10) * self.speed
	end
	
	if self.x > self.goal_limit or self.x < -self.goal_limit then
		local scoringPlayer = 1
		local logStatus = 'yay'
		local logBanter = 'Good for you!'
		if self.x < -self.goal_limit then
			scoringPlayer = 2
			logStatus = 'nay'
			logBanter = 'Idiot.'
		end
		self.x = 0
		self.vx = -self.vx
		objects['Pad'][scoringPlayer].score = objects['Pad'][scoringPlayer].score + 1
		editor.console:Log(logStatus, "Player #" .. scoringPlayer .. " scored a goal! " .. logBanter)
	end
end

function Ball:draw()
	love.graphics.circle("fill", self.x, self.y, 15)
end

--[[
	love
]]

function love.load(args)
	local root = editor.hierarchy:NewObject("Root")
	local balls = editor.hierarchy:NewObject("Balls", root)
	local paddles = editor.hierarchy:NewObject("Pads", root)
	
	Ball:new()
	Pad:new("up", "down")
	Pad:new("left", "right")
	
	editor.inspector:SetTypeGUI(
		"instance of class Transform",
		function(name, value)
			imgui.Columns(2, "visualizer", false)
			imgui.Text(name)
			imgui.NextColumn()
			
			imgui.Columns(2, "labels_and_vis")
			imgui.Text("Position"); imgui.NextColumn()
			local changed_x, new_x = imgui.InputFloat("x", value.x); imgui.SameLine()
			if changed_x then value.x = new_x end
			local changed_y, new_y = imgui.InputFloat("y", value.y)
			if changed_y then value.y = new_y end
			imgui.NextColumn()
			
			imgui.Text("Scale"); imgui.NextColumn()
			local changed_sx, new_sx = imgui.InputFloat("sx", value.sx); imgui.SameLine()
			if changed_sx then value.sx = new_sx end
			local changed_sy, new_sy = imgui.InputFloat("sy", value.sy)
			if changed_sy then value.sy = new_sy end
			imgui.NextColumn()
			
			imgui.Text("Rotation"); imgui.NextColumn()
			local changed_rx, new_rx = imgui.InputFloat("rx", value.rx); imgui.SameLine()
			if changed_rx then value.rx = new_rx end
			local changed_ry, new_ry = imgui.InputFloat("ry", value.ry)
			if changed_ry then value.ry = new_ry end
			imgui.NextColumn()
			imgui.Columns(1)
			
			imgui.Columns(1)
			
			return (changed_x or changed_y or
					changed_sx or changed_sy or
					changed_rx or changed_ry),
					value
		end
	)
	
	editor.inspector:SetTypeIdentifier(
		"instance of class Transform",
		function(name, value)
			return type(value) == 'table' and value.class and value.class == Transform
		end
	)
	
	-- register all the objects we made
	-- collect them for a selection
	local selection = {}
	for k1,v1 in pairs(objects) do
		for k2,v2 in pairs(v1) do
			editor.hierarchy:Register( v2 )
			local parent
			if k1 == 'Ball' then
				parent = balls
			elseif k1 == 'Pad' then
				parent = paddles
			end
			
			editor.hierarchy:SetObjectParent( v2,  parent )
		end
	end
end

function love.update(dt)
	for k1,v1 in pairs(objects) do
		for k2,v2 in pairs(v1) do
			v2:update(dt)
		end
	end
end

function love.draw()
	love.graphics.translate(400, 300)
	love.graphics.print(objects['Pad'][1].score, -380, -280)
	love.graphics.print(objects['Pad'][2].score, 370, -280)
	
	for k1,v1 in pairs(objects) do
		for k2,v2 in pairs(v1) do
			love.graphics.setColor(255,255,255)
			v2:draw()
		end
	end
end

function love.keypressed(key, scan)
	if key == "i" then
		love.graphics.setColor(0,0,255)
	end
end