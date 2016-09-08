--[[
	Projector For Picture-in-Picture
	very good thanks EntranceJew
	MIT license probably.
]]

local projector = {}
projector.__index = projector

local function nop() end

-- this comes from lume don't beat me up
local function clone(t)
	local rtn = {}
	for k, v in pairs(t) do rtn[k] = v end
	return rtn
end

local function new(self, entry, x, y, sx, sy)
	local t = setmetatable({}, projector)
	t:initialize(entry, x, y, sx, sy)
	return t
end

local function soft_load_core(entry)
	local env = setmetatable(
		{
			pairs = pairs,
			table = table,
			ipairs = ipairs,
			print = print,
			love = clone(love),
			require = require,
			setmetatable = setmetatable,
			tostring = tostring,
			assert = assert,
			type = type,
			math = math
		},
		{
		}
	)
	assert(pcall(setfenv(assert(love.filesystem.load(entry)), env)))
	setmetatable(env, nil)
	return env
end

local ScriptEnvironment = {
	pairs = pairs,
	table = table,
	ipairs = ipairs,
	print = print,
	love = clone(love),
	require = require,
	setmetatable = setmetatable,
	tostring = tostring,
	assert = assert,
	type = type,
	math = math
}
local function LoadScript(filename)
	local chunk = loadfile(filename)
	setfenv(chunk, ScriptEnvironment)
	chunk()
end

local function load_core(emu)
	-- prepare our environment
	--local env = {exlove = love, pcall = pcall, print = print, tostring = tostring, require = require}
	--setmetatable(env, {__index = _G})
	--setfenv(1, env)
	
	local env = {
		love = clone(love)
	}
	
	-- TODO: pcall this, make safe
	if love.filesystem.isFile(emu) then
		local result
		local ok, chunk = pcall( love.filesystem.load, emu )
		if not ok then
			print('The following error happend: ' .. tostring(chunk))
		else
			setfenv(chunk, env)
			ok, result = pcall(chunk) -- execute the chunk safely
			
			if not ok then -- will be false if there is an error
				print('The following error happened: ' .. tostring(result))
			else
				return result
			end
		end
	end
	return env
end

function projector:initialize(entry, x, y, sx, sy)
	-- set the entry point for our emulation
	self.entry  = entry or 'main.lua'
	-- set where the emulation should draw
	self.x      = x or 0
	self.y      = y or 0
	-- set how large the emulation should be
	self.sx  = sx or 1
	self.sy = sy or 1
	
	-- timers for play / focus emulation
	self.dt = 0
	self.gt = 0
	self.tt = 0
	self.active = true
	
	-- load our core
	self.env = soft_load_core(self.entry)
	self.env.love.load()
end

function projector:setPos(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function projector:resize(sx, sy)
	if self.sx ~= sx or self.sy ~= sy then
		self.sx = sx or self.sx
		self.sy = sy or self.sy
		
		self.env.love.resize(sx, sy)
	end
end

function projector:draw()
	love.graphics.push("all")
	love.graphics.translate(self.x, self.y)
	love.graphics.scale(self.sx, self.sy)
	self.env.love.draw()
	
	love.graphics.pop()
end

function projector:update(dt)
	if self.active then
		self.gt = self.gt + dt
		self.dt = dt
		self.env.love.update(dt)
	end
	self.tt = self.tt + dt
end

return setmetatable({new=new}, {__call=function(_,...) return new(...) end})