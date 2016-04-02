function shape.center(s)
	s = shape.nullify(s)
	local x, y, x2, y2 = shape.bounding(s)
	return shape.move(s, 0 - x2 / 2, 0 - y2 / 2)
end