utils.get_beats = function (_start, _end, _offset, _bpm)
    local beats = {}
    for s, e, i, n, b, pct in utils.beats(_start, _end, _offset, _bpm) do
        beats[i] = {
            s = s,
            e = e,
            i = i,
            n = n,
            p = p,
            b = b,
            pct = pct,
        }
    end
    return beats
end