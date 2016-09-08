local Editor = require('libs.middleclass.middleclass')('Editor')

Editor.static.is_great = 'heck yeah'

function Editor:initialize(args)
	
end

function Editor:isSweet()
	return self.sweetness > Editor.sweetness_threshold
end

return Editor