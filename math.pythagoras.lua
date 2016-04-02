math.pythagoras = function(a, b, c)
	local avail, missing = nil, nil
	if a and b then
		c = math.pow((math.pow(a, 2) + math.pow(b, 2)), 0.5)
	else
		avail = a and a or b
		missing = math.pow((math.pow(c, 2) - math.pow(avail, 2)), 0.5)
		a = a and a or missing
		b = b and b or missing
	end
	return a, b, c
end