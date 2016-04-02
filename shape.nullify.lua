function shape.nullify(s)
	local x, y = shape.bounding(s)
	return shape.move(s, 0 - x, 0 - y)
end