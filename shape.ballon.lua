shape.ballon = function(s, percent)
	s = shape.center(s)
	local function getScaleFactor(source, target)
		if source == target then return 1 end
		if source < target then
			local diff = target - source
			return 1 + diff / source
		else
			local to_big = source - target
			local sub_factor = to_big / source
			return 1 - sub_factor
		end
	end
	local sWidth, sHeight = shape.sizes(s)
	local mx, my = sWidth / 2, sHeight / 2
	local radiant = mx > my and mx or my
	s = shape.split(s, .1)
	sh = shape.filter(s, function(x, y)
		local _1, _2, h = math.pythagoras(x, y)
		if radiant == h then return x, y end
		
		targetradiant = utils.interpolate(percent, h, radiant)
		scale = getScaleFactor(h, targetradiant)
		
		return x * scale, y * scale
	end)
	
	return shape.center(sh)
end