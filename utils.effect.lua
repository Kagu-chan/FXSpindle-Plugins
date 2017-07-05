utils.effect = function(l, effects, ...)
    local values = {...}
    if (type(effects) ~= "table") then
        local effect, layers = effects, values[1]
        effects = {}
        values[1] = nil
        values = table.reset_indexes(values)
        for i, c in ipairs(layers) do
            effects[i] = effect:gsub("&LAYER&", layers[i])
        end
    end
    for i, e in ipairs(effects) do
        l.layer = l.layer + i
        l.text = e:format(unpack(values))
        io.write_line(l)
    end
end