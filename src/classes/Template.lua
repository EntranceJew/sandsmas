local Template = require('libs.middleclass.middleclass')('Template')

local imgui = require('imgui')

-- Template.static.property = 'great'

--[[
	@class	Template	Example class.
]]
function Template:initialize(args)
	-- self.instance_value = {}
end

--[[
	@method	Template:ExampleMethod	A method that exemplifies an instance method.
	@param	table	a_table	A table that stuff happens to.
	@param	string	a_string	A string that things happen to.
	@param	number	a_number	A number that things happen to.
	@return	bool	The status of the operation.
]]
function Template:ExampleMethod(a_table, a_string, a_number)
	return true
end

return Template