local editor = sandsmas.editor

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

Pad.static.score_to_win = 6
Pad.static.color = {1.0,1.0,1.0,1.0}

function Pad:initialize(upKey, downKey)
	self.upKey = upKey or "w"
	self.downKey = downKey or "s"
	
	self.playerNo = #objects['Pad'] + 1
	
	self.y = 0
	
	self.width = 60
	
	self.moveSpeed = 7
	
	self.extent = 250
	
	self.score = 0
	
	self.color = Pad.color
	
	self.sign = -1
	if self.playerNo > 1 then
		self.sign = self.sign * -1
	end
	
	table.insert(objects['Pad'], self)
end

function Pad:update(dt)
	local moveValue 
	if love.keyboard.isDown(self.upKey) and love.keyboard.isDown(self.downKey) then
		-- what do you expect?
	elseif love.keyboard.isDown(self.upKey) then
		self.y = self.y - self.moveSpeed
	elseif love.keyboard.isDown(self.downKey) then
		self.y = self.y + self.moveSpeed
	end
	
	if self.y < -self.extent then
		self.y = -self.extent
	end
	if self.y > self.extent then
		self.y = self.extent
	end
	
	if self.score > Pad.score_to_win and self.color == Pad.color then
		self.color = {1.0,0.0,0.0,1.0}
	end
end

function Pad:draw()
	if self.color ~= Pad.color then
		love.graphics.setColor(self.color[1]*255, self.color[2]*255, self.color[3]*255, self.color[4]*255)
	end
	love.graphics.rectangle("fill", (Ball.outer_limit_x*self.sign)-10, self.y - 50, 20, 100)
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
	
	if boundaryCheck and math.abs(pad.y - self.y) < pad.width then
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
	Ball:new()
	Pad:new("up", "down")
	Pad:new("left", "right")
	
	-- register all the objects we made
	-- collect them for a selection
	local selection = {}
	for k1,v1 in pairs(objects) do
		for k2,v2 in pairs(v1) do
			editor.hierarchy:Register( v2 )
			table.insert( selection, v2 )
		end
	end
	
	-- set the selection
	editor.inspector:SetSelection( unpack(selection) )
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