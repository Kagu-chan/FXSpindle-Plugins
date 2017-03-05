local utils_frames = utils._frames or utils.frames

function utils.particles(line, obj, count, stretch_min, stretch_max, callback)
    frame_duration = 24000 / 1001

    for ei, en, mx, my, ox, oy, shap in utils.explode(
        obj, 
        line.styleref, 
        count, 
        math.random(stretch_min * 10, stretch_max * 10) / 10)
    do
        utils.frames(line, function(fs, fe, fi, fn)
            callback(ei, en, mx, my, ox, oy, shap, fs, fe, fi, fn)
        end)
    end
end