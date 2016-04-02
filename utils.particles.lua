function utils.particles(count, line, obj, stretch_min, stretch_max, ass, shape, frame_duration, fade_in, fade_out, trace)
    
    local function get_point(a, b, c, x)
        -- f(x) = ax² + bx + c
        return {x, math.round(((a*x)*(a*x) + b*x + c) / 10, 3)}
    end
    
    for i = 1, count do
        local go_left = math.random(2) == 1 -- gehe ich nach links? andernfalls rechts
        local move_x_start = math.random(obj.width) -- Wo fängt die bewegung an (relativ zum mittelpunkt)
        local move_x = math.random(obj.width) -- Wie weit bewege ich mich zur seite? (relativ zum berechneten startpunkt)
        local start_x = obj.center + (go_left and (0 - move_x_start) or move_x_start) -- Finaler Startpunkt
        
        local move_y = math.random(obj.height) -- Wie weit verschiebt sich die startposition auf der y-achse?
        
        local stretch = stretch_min + (math.random((stretch_max - stretch_min) * 10) / 10) -- Zufällige Steigung im Rahmen der Parameter
        
        local duration = line.end_time - line.start_time
        for s, e, i, n in utils.frames(line.start_time, line.end_time, frame_duration) do
            local function get_alpha()
                local c = i * frame_duration
                local v = 255
                if c < fade_in then
                    v = utils.interpolate(math.trim(c / fade_in, 0, 1), 0, 255)
                elseif c > (duration - fade_out) then
                    v = utils.interpolate(math.trim((duration - c) / fade_out, 0, 1), 255, 0)
                end
                return convert.a_to_ass(v)
            end
            local pct = i / n
            local point = get_point(stretch, 1, 1, utils.interpolate(pct, 0, move_x))
            
            local l = table.copy(line)
            l.start_time = s
            l.end_time = e
            l.text = ("{\\an5\\pos(%.3f,%.3f)\\a%s%s\\p1}%s"):format(
                start_x + (go_left and (-1*point[1]) or point[1]),
                obj.top + move_y + (-1*point[2]),
                get_alpha(),
                ass,
                shape
            )
            
            io.write_line(l)
        end

        if trace then print(("Particles: %.3d from %.3d"):format(i, count)) end
    end
    
end