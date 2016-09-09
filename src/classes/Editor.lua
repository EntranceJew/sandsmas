local Editor = require('libs.middleclass.middleclass')('Editor')
local lume = require('libs.lume.lume')

Editor.static.is_great = 'heck yeah'

function Editor:initialize(args)
	self.selection = nil
	self.objects = {}
end

function Editor:Register(obj)
	local id = lume.uuid()
	if self.objects[id] then
		error('the universe has conspired against you')
	end
	obj.id = id
	self.objects[id] = obj
	return id
end

function Editor:isSweet()
	return self.sweetness > Editor.sweetness_threshold
end

return Editor