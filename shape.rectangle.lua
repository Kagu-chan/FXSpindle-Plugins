function shape.rectangle(w, h)
	if type(w) ~= "number" or type(h) ~= "number" then
		error("number and number expected", 2)
	end
	return ("m 0 0 l %d 0 %d %d 0 %d"):format(w, w, h, h)
end