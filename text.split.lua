_G.text = {}

text.split = function(s, sep)
	local sep, fields = sep or ":", {}
	local pattern = ("([^%s]+)"):format(sep)
	s:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end