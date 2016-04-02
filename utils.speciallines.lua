_G.special_lines = {}

utils.find_special = function(_type)
	local res = {}
	local n = 1
	local arr = {}
	arr[_type] = function(l, line)
		res[n] = l
		n = n + 1
	end
	utils.stylefunc(arr)
	n = 1
	arr = {}
	for li, line in ipairs(res) do
		if (line.text:find("type:", 1, true)) then
			local t = text.split(line.text)[2]
			if type(arr[t]) == "nil" then arr[t] = {} end

			arr[t][#arr[t]+1] = line
		end
	end
	_G.special_lines[_type] = arr
end

utils.select_specials = function(vendor, _type, start_time, end_time)
	local objects = _G.special_lines[vendor][_type]
	if not type(objects) == "table" then return {} end

	local result = {}
	for i, e in ipairs(objects) do
		if e.start_time >= start_time and e.end_time <= end_time then
			result[#result + 1] = e
		end
	end
	return result
end