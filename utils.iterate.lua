utils.iterate = function(l, t, c)
	local a = l[t]
	if type(a) == "table" then
		for i, o in ipairs(a) do
			local args = {i, o}
			if type(o.center) ~= "nil" then args = {i, o, o.center, o.middle} end
			c(unpack(args))
		end
	end
end

utils.syls = function(l, c)
	utils.iterate(l, "syls", c)
end

utils.words = function(l, c)
	utils.iterate(l, "words", c)
end

utils.chars = function(l, c)
	utils.iterate(l, "chars", c)
end

utils.lines = function(c)
	for li, line in ipairs(lines) do
		c(li, table.copy(line), line)
	end
end

utils.stylefunc = function(arr)
	utils.lines(function(li, l, line)
		if type(arr[line.style]) == "nil" then return end
		arr[line.style](l, line, li)
	end)
end