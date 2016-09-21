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
local lume = require("libs.lume.lume")
local fakelove = require("libs.fakelove")

local projector = {}
projector.__index = projector

local function nop() end

-- this comes from lume don't beat me up
local function clone(t)
	local rtn = {}
	for k, v in pairs(t) do rtn[k] = v end
	return rtn
end

local function new(self, entry, exposed, x, y, sx, sy)
	local t = setmetatable({}, projector)
	t:initialize(entry, exposed, x, y, sx, sy)
	return t
end

function projector:load_core(entry, exposed)
	-- create new environment
	local env = { 
		love = fakelove:new(love)
	}
	
	-- merge an external environment
	if exposed and type(exposed) == "table" then
		env = lume.merge(env, exposed)
	end
	
	local metaenv = { __index = _G }
	setmetatable(env, metaenv)
	
	-- put it on us
	self.env = env
	
	-- wipe all callbacks
	self:loveEncapsulate()
	
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

function projector:loadstringInEnv(str)
	local ok, chunk = pcall( loadstring, str )
	assert(ok, "The chunk was messed up: " .. tostring(chunk) )
	
	setfenv( chunk, self.env )
	
	local result
	ok, result = pcall( chunk )
	assert(ok, "Chunk execution failed: " .. tostring(result) )
	
	return result
end

-- search and destroy: https://love2d.org/wiki/Category:Callbacks
function projector:loveEncapsulate()
	-- maybe_scopes: nogame, conf
	
	local bomb = [[
	-- keep error handlers because they prevent silent crashes
	local scopes = {
		--'errhand',
		--'threaderror',
		'draw',
		'load',
		'run',
		'update',
	}
	for k,v in pairs(love.handlers) do
		love[k] = nil
	end
	for k,v in ipairs(scopes) do
		love[v] = nil
	end
	]]
	return self:loadstringInEnv(bomb)
end

function projector:getBaseFromEntryPoint(entry)
	local ret = {string.match(entry, "(.-)([^\\/]-%.?([^%.\\/]*))$")}
	return ret[1]
end

function projector:initialize(entry, exposed, x, y, w, h)
	-- set the entry point for our emulation
	self.entry  = entry or 'main.lua'
	
	-- emulate path level imports and hope to god we don't get a collision
	self.base_path = self:getBaseFromEntryPoint(self.entry)
	
	if self.base_path ~= '' then
		self.added_path = ';' .. self.base_path .. '?.lua;' .. self.base_path .. '?/init.lua'
		love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. self.added_path)
	else
		assert(false, "Base path was wrong or broken.")
	end
	
	-- timers for play
	self.dt = 0
	self.gt = 0
	self.tt = 0
	
	-- preserve reality as it was before we messed with things
	-- the "absolutely safe capsule" for package, etc.
	self.asc = getfenv()
	
	-- load our core
	self.env = self:load_core(self.entry, exposed)
	
	if self.env.love.load then
		self:doInEnv( self.env.love.load )
	end
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

--[[
	LÖVE Callback Emulation Goes Here
]]
function projector:draw()
	love.graphics.push("all")
	
	local x, y = self.env.love.window.getPosition()
	local w, h = self.env.love.window.getMode()
	love.graphics.translate(x, y)
	love.graphics.scale(w/love.graphics.getWidth(), h/love.graphics.getHeight())
	love.graphics.setScissor(x, y, w, h)
	-- @TODO: right here, we should reload the graphics state
	self:doInEnv(self.env.love.draw)
	
	love.graphics.pop()
end

function projector:update(dt)
	if self.env.love.window.hasFocus() then
		self.gt = self.gt + dt
		self.dt = dt
		self:doInEnv(self.env.love.update, dt)
	end
	self.tt = self.tt + dt
end

-- do not use this from inside whatever is wrapping the projection's mousefocus
-- unless the projection is fullscreened
function projector:mousefocus(focus)
	--[[
		@TODO: special checks for when the mouse is given focus
		before we know where it is
	]]
	
	self:doInEnv(self.env.love.mousefocus, focus)
end

-- x, y is from global mouse position
function projector:_is_mousepos_in_bounds(x, y)
	return (x >= self.env.love.store.window.x
		and y >= self.env.love.store.window.y
		and x <= self.env.love.store.window.x + self.env.love.store.window.width
		and y <= self.env.love.store.window.y + self.env.love.store.window.height
	)
end

function projector:mousemoved(x, y, dx, dy, istouch)
	if self:_is_mousepos_in_bounds(x, y) then
		if not self.env.love.window.hasMouseFocus() then
			self.env.love.store.window.mouseFocus = true
			self:mousefocus(true)
		end
		
		self.env.love.store.mouse.x = x - self.env.love.store.window.x
		self.env.love.store.mouse.y = y - self.env.love.store.window.y
		
		-- pass to the *emulated game*
		self:doInEnv(self.env.love.mousemoved, 
			self.env.love.store.mouse.x, 
			self.env.love.store.mouse.y, 
			dx, dy, istouch
		)
	else
		-- the mouse moved away frome our fake window,
		-- therefore we only care about the last reported position
		if self.env.love.window.hasMouseFocus() then
			self.env.love.store.window.mouseFocus = false
			self:mousefocus(false)
		end
	end
end

function projector:mousepressed(x, y, button, istouch)
	if self:_is_mousepos_in_bounds(x, y) then
		-- @TODO: flash focus? issue a mousemoved?
		self.env.love.store.mouse.buttons[button] = true
		
		x = x - self.env.love.store.window.x
		y = y - self.env.love.store.window.y
		
		self:doInEnv(self.env.love.mousepressed, x, y, button, istouch)
	end
end

function projector:mousepressed(x, y, button, istouch)
	if self:_is_mousepos_in_bounds(x, y) then
		-- @TODO: flash focus? issue a mousemoved?
		self.env.love.store.mouse.buttons[button] = nil
		
		x = x - self.env.love.store.window.x
		y = y - self.env.love.store.window.y
		
		self:doInEnv(self.env.love.mousepressed, x, y, button, istouch)
	end
end

return setmetatable({new=new}, {__call=function(_,...) return new(...) end})