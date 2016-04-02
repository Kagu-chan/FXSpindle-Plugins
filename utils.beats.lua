utils.beats = function(_start, _end, _offset, _bpm)
    local _beat = 60000 / _bpm
    while _offset > _start do
        _offset = _offset - _beat
    end
    local _i, _n, _first = 0, math.ceil((_end - _start) / _beat), _offset
    while not math.between(_first, _start - _beat, _start + _beat) do
        _first = _first + _beat
    end
    return function()
        _i = _i + 1
        if _i <= _n then
            local _percent = ((_first + _i * _beat) - math.trim(_first + (_i-1) * _beat, _start, _end)) / _beat
            
            return math.trim(_first + (_i-1) * _beat, _start, _end), math.trim(_first + _i * _beat, _start, _end), _i, _n, _beat, math.round(_percent, 3), math.floor((_first + (_i) * _beat) / _beat)
        end
    end
end