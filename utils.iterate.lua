utils.iterate = function(l, t, c, skip_empty_lines)
	local a = l[t]
	skip_empty_lines = skip_empty_lines == "nil" and false or skip_empty_lines
	if type(a) == "table" then
		for i, o in ipairs(a) do
			if skip_empty_lines == false or (o.text ~= " " and o.text ~= "") then
				local args = {i, o}
				if type(o.center) ~= "nil" then args = {i, o, o.center, o.middle} end
				c(unpack(args))
			end
		end
	end
end

utils.syls = function(l, c, skip_empty_lines)
	utils.iterate(l, "syls", c, skip_empty_lines)
end

utils.words = function(l, c, skip_empty_lines)
	utils.iterate(l, "words", c, skip_empty_lines)
end

utils.chars = function(l, c, skip_empty_lines)
	utils.iterate(l, "chars", c, skip_empty_lines)
end

utils.lines = function(c)
	for li, line in ipairs(lines) do
		c(li, table.copy(line), line, line.center, line.middle)
	end
end

utils.stylefunc = function(arr)
	utils.lines(function(li, l, line, x, y)
		if type(arr.pre_style) ~= "nil" then arr.pre_style(l, line, li, x, y) end
		if type(arr[line.style]) ~= "nil" then arr[line.style](l, line, li, x, y) end
		if type(arr.post_style) ~= "nil" then arr.post_style(l, line, li, x, y) end
	end)
end