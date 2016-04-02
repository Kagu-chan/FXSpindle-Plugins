function shape.scale(s, px)
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
	
	local x, y, r, b = shape.bounding(s)
	local w, h = r - x, b - y
	
	local fx = getScaleFactor(w, 40)
	local fy = getScaleFactor(h, 40)
	local fac = fx > fy and fy or fx
	s = shape.split(s, 1)
	return shape.nullify(s:gsub("(%-?[%d%.]+)", function(w)
		return w * fac
	end))
end