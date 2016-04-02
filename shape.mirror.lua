function shape.mirror(shape, achsis)
	local min_x, min_y, max_x, max_y = Yutils.shape.bounding(shape)
	shape = shape:gsub("(%-?[%d%.]+)%s+(%-?[%d%.]+)", 
		function(l, r)
			if achsis == "x" then
				l = max_x - l
			elseif achsis == "y" then
				r = max_y - r
			else
				error("`x' or `y' expected for achsis")
			end
			return string.format("%s %s", l, r)
		end
	)
	return shape
end