function shape.rotate(shape, achsis, angle)
    shape = shape:gsub("(%-?[%d%.]+)%s+(%-?[%d%.]+)", 
		function(l, r)
            return string.format("%s %s", unpack(math.rotate({tonumber(l), tonumber(r), 0}, achsis, angle)))
		end
	)
	return shape
end