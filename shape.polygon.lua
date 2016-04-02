function shape.polygon(edges, size)
	local shape, shape_n = {string.format("m 0 %s l", -size)}, 1
	local outer_p
	for i = 1, edges do
		outer_p = math.rotate({0, -size, 0}, "z", (i / edges)*360)
		shape_n = shape_n + 1
		shape[shape_n] = string.format(" %.3f %.3f", outer_p[1], outer_p[2])
	end
	shape = table.concat(shape)
	-- Shift to positive numbers
	local min_x, min_y = 0, 0
	shape:gsub("(%-?[%d%.]+)%s+(%-?[%d%.]+)", function(x, y)
		min_x, min_y = math.min(min_x, x), math.min(min_y, y)
	end)
	shape = shape:gsub("(%-?[%d%.]+)%s+(%-?[%d%.]+)", function(x, y)
		return string.format("%s %s", x-min_x, y-min_y)
	end)
	-- Return result
	return shape
end