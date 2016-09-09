--[[
	Projector For Picture-in-Picture
	very good thanks EntranceJew
	MIT license probably.
]]
--[[
	things to think about:
	* l.graphics does not thread nicely so we can't utilize this for sandboxing a render
	* stuff like l.k.isDown bounce reads right off SDL and don't matter to us
]]
--[[
	@TODO:
	* because we pass through a clone of love, things like love.keyboard.isDown
		read from the editor's LOVE despite sandboxed love.keypressed.* events 
		not being run.
	* makes u think
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

local function honk_load_core(entry)
	-- create new environment
	local env = { 
		love = clone(love)
	}
	local metaenv = {
		-- pass-through
		__index = function(t, i)
			--if i ~= 'love' then
				return rawget(_G, i)
			--else
			--	assert(false, 'We wanted love but I do not know if that is our love or their love.')
			--end
		end,
	}
	setmetatable(env, metaenv)
	
	-- load the chunk
	local ok, chunk = pcall( love.filesystem.load, entry )
	assert(ok, "The entry point '" .. entry .. "' appears invalid.")
	
	-- apply the environment to the chunk
	setfenv(chunk, env)
	
	-- invoke the chunk
	local result
	ok, result = pcall( chunk )
	assert(ok, "Chunk execution failed for entry point '" .. entry .. "', error: " .. tostring(result) )
	
	-- we have now captured 'entry' inside 'env'
	-- we have not entered the loaded environment
	return env, metaenv
end

function projector:getBaseFromEntryPoint(entry)
	local ret = {string.match(entry, "(.-)([^\\/]-%.?([^%.\\/]*))$")}
	return ret[1]
end

function projector:initialize(entry, x, y, w, h)
	-- set the entry point for our emulation
	self.entry  = entry or 'main.lua'
	
	-- emulate path level imports and hope to god we don't get a collision
	self.base_path = self:getBaseFromEntryPoint(self.entry)
	
	if self.base_path ~= '' then
		print('declared base path', self.base_path)
		self.added_path = ';' .. self.base_path .. '?.lua;' .. self.base_path .. '?/init.lua'
		love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. self.added_path)
	else
		print('fug')
	end
	
	-- set where the emulation should draw
	self.x      = x or 0
	self.y      = y or 0
	-- set how large the emulation should be
	self.w = w or love.graphics.getWidth()
	self.h = h or love.graphics.getHeight()
	
	-- timers for play / focus emulation
	self.dt = 0
	self.gt = 0
	self.tt = 0
	self.active = true
	
	-- preserve reality as it was before we messed with things
	-- the "absolutely safe capsule" for package, etc.
	self.asc = getfenv()
	
	-- load our core
	self.env = honk_load_core(self.entry)
	self.env.love.load()
end

function projector:enterEnvironment()
	
end

function projector:renderAbsolutelySafeCapsule()
	self.asc = {
		package = {
			cpath = package.cpath,
			loaded = package.loaded,
			loadlib = package.loadlib,
			path = package.path,
			preload = package.preload,
			searchers = package.searchers,
			searchpath = package.searchpath
		},
	}
end

--[[
	cpath = package.cpath,
	loaded = {}, -- blanking
	loadlib = package.loadlib,
	path = package.path,
	preload = {},
	searchers = {},
	searchpath = package.searchpath
]]

function projector:setPos(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

function projector:resize(w, h)
	if self.w ~= w or self.h ~= h then
		self.w = w or self.w
		self.h = h or self.h
		
		if self.env.love.resize then
			self:doInEnv(self.env.love.resize, self.w, self.h)
		end
	end
end

function projector:doInEnv(func, ...)
	-- have some variables set in our scope before entering env
	local ok, result
	local pcall = pcall
	
	-- enter the env, execute, immediately leave
	setfenv(1, self.env)
	ok, result = pcall( func, ... )
	setfenv(1, self.asc)
	
	-- we're done here
	return ok, result
end

function projector:draw()
	love.graphics.push("all")
	love.graphics.translate(self.x, self.y)
	love.graphics.scale(self.w/love.graphics.getWidth(), self.h/love.graphics.getHeight())
	love.graphics.setScissor(self.x, self.y, self.w, self.h)
	self:doInEnv(self.env.love.draw)
	--love.graphics.setScissor()
	love.graphics.pop()
end

function projector:update(dt)
	if self.active then
		self.gt = self.gt + dt
		self.dt = dt
		self:doInEnv(self.env.love.update, dt)
	end
	self.tt = self.tt + dt
end

function projector:keypressed(key, scan)
	if self.env.love.keypressed then
		self:doInEnv(self.env.love.keypressed)
	end
end

return setmetatable({new=new}, {__call=function(_,...) return new(...) end})