shape.sizes = function(s)
	local x, y, x2, y2 = shape.bounding(s)
	return x2 - x, y2 - y, (x2 - x) / 2, (y2 - y) / 2
end