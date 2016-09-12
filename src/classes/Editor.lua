local Editor = require('libs.middleclass.middleclass')('Editor')

--[[
	Editor
]]
function Editor:initialize(args)
	-- components
	self.console = require('src.classes.Console')()
	self.hierarchy = require('src.classes.Hierarchy')()
	self.inspector = require('src.classes.Inspector')()
end

return Editor