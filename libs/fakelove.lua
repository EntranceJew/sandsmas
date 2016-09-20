--[[
	Pretend to be LÖVE, what a great prank
	another great job, EntranceJew "gee thanks"
	MIT license probably.
]]
local lume = require("libs.lume.lume")

local fakelove = {}
fakelove.__index = fakelove

local function scale(valueIn, baseMin, baseMax, limitMin, limitMax)
	return ((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin
end

local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local function new(self, reallove)
	local zt = deepcopy(reallove)
	local t = setmetatable(zt, fakelove)
	t:initialize(reallove)
	return t
end

function fakelove:initialize(reallove)
	local x, y, display = reallove.window.getPosition()
	local width, height, flags = reallove.window.getMode()
	self.store = {
		audio = {},
		event = {},
		filesystem = {},
		font = {},
		graphics = {},
		image = {},
		joystick = {},
		keyboard = {},
		math = {},
		mouse = {
			x = 0,
			y = 0,
		},
		physics = {},
		sound = {},
		system = {},
		thread = {},
		timer = {},
		touch = {},
		video = {},
		window = {
			title = reallove.window.getTitle(),
			x = x,
			y = y,
			display = display,
			width = width,
			height = height,
			flags = flags,
			
			focus = reallove.window.hasFocus(),
			mouseFocus = reallove.window.hasMouseFocus(),
		},
	}
	self.reallove = reallove
	
	local mergelove = {
		mouse = {
			getPosition = function()
				local mx, my = reallove.mouse.getPosition()
				if self.window.hasMouseFocus() then
					self.store.mouse.x = mx - self.store.window.x
					self.store.mouse.y = my - self.store.window.y
				end
				return self.store.mouse.x, self.store.mouse.y
			end,
		},
		window = {
			--[[
			close = function() 
				
			end,
			fromPixels = function() 
				
			end,
			getDisplayCount = function() 
				
			end,
			getDesktopDimensions = function() 
				
			end,
			getDisplayName = function() 
				
			end,
			getFullscreen = function() 
				
			end,
			getFullscreenModes = function() 
				
			end,
			getIcon = function() 
				
			end,
			]]
			getMode = function() 
				return self.store.window.width, self.store.window.height, self.store.window.flags
			end,
			--[[
			getPixelScale = function() 
				
			end,
			]]
			getPosition = function() 
				return self.store.window.x, self.store.window.y, self.store.window.display
			end,
			getTitle = function()
				return self.store.window.title
			end,
			hasFocus = function() 
				return self.store.window.focus
			end,
			hasMouseFocus = function() 
				local mx, my = reallove.mouse.getPosition()
				return (mx >= self.store.window.x
					and my >= self.store.window.y
					and mx <= self.store.window.x + self.store.window.width
					and my <= self.store.window.y + self.store.window.height
				)
			end,
			--[[
			isDisplaySleepEnabled = function() 
				
			end,
			isOpen = function() -- @WARNING: UNDOCUMENTED
				
			end,
			isVisible = function() 
				
			end,
			maximize = function() 
				
			end,
			minimize = function() 
				
			end,
			requestAttention = function() 
				
			end,
			setDisplaySleepEnabled = function() 
				
			end,
			setFullscreen = function() 
				
			end,
			setIcon = function() 
				
			end,
			]]
			setMode = function(width, height, flags)
				self.store.window.width = width
				self.store.window.height = height
				self.store.window.flags = flags or self.store.window.flags
				return true
			end,
			setPosition = function(x, y, display) 
				self.store.window.x = x
				self.store.window.y = y
				self.store.window.display = display or self.store.window.display
			end,
			setTitle = function(title)
				self.store.window.title = title
			end
			--[[
			showMessageBox = function() 
				
			end,
			toPixels = function() 
				
			end,
			]]
		}
	}
	
	-- does this work? I don't know.
	for k, v in pairs(mergelove) do
		self[k] = lume.merge(self[k], v)
	end
end

return setmetatable({new=new}, {__call=function(_,...) return new(...) end})