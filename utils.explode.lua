shape.to_table = function(shap)
	local result, n = {}, 0
	shape.filter(shap, function(x, y)
		n = n + 1
		result[n] = {x, y}
	end)
	return result
end

shape.pixel = function(scale)
	return ("m 0 0 l %d 0 %d %d 0 %d"):format(scale, scale, scale, scale)
end

utils.explode = function(t, styleref, step, scale)
	step = step or 10
	scale = scale or 1
	
	local text = t.text
	local splitted = shape.split(convert.text_to_shape(text, styleref), 1)
	if splitted:find("m") then 
		local shap = shape.center(splitted)
		local text_table = shape.to_table(shap)
		local filtered_table = table.reset_indexes(table.select(text_table, function(e, i)
			return i % step == 0
		end))
		
		local _i = 0
		return function()
			_i = _i + 1
			if _i <= #filtered_table then
				return _i, #filtered_table, filtered_table[_i][1], filtered_table[_i][2], t.center, t.middle, shape.pixel(scale)
			end
		end
	else
		return function() end
	end
end