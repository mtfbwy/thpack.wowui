if (Seg) then
    return;
end

Seg = {};

function Seg.getIntersection(seg1Start, seg1End, seg2Start, seg2End)
    local intersectionStart = seg1Start >= seg2Start and seg1Start or seg2Start;
    local intersectionEnd = seg1End <= seg2End and seg1End or seg2End;
    if (intersectionStart <= intersectionEnd) then
        return intersectionStart, intersectionEnd;
    else
        return nil;
    end
end

function Seg.getSubstraction(seg1Start, seg1End, seg2Start, seg2End)
    local intersectionStart, intersectionEnd = Seg.getIntersection(seg1Start, seg1End, seg2Start, seg2End);
    if (not intersectionStart) then
        return seg1Start, seg1End;
    elseif (seg1Start == intersectionStart) then
        if (seg1End == intersectionEnd) then
            return nil;
        else
            return intersectionEnd, seg1End;
        end
    elseif (seg1End == intersectionEnd) then
        return seg1Start, intersectionStart;
    else
        return seg1Start, intersectionStart, intersectionEnd, seg1End;
    end
end

function Seg.op(segs, seg2Start, seg2End, op)
    if (op == "intersection") then
        op = Seg.getIntersection;
    elseif (op == "substraction") then
        op = Seg.getSubstraction;
    end
    if (type(op) ~= "function") then
        return nil;
    end

    local resultSegs = {};
    for i = 1, #segs, 2 do
        local r1Start, r1End, r2Start, r2End = op(segs[i], segs[i + 1], seg2Start, seg2End);
        if (r1Start) then
            table.insert(resultSegs, r1Start);
            table.insert(resultSegs, r1End);
        end
        if (r2Start) then
            table.insert(resultSegs, r2Start);
            table.insert(resultSegs, r2End);
        end
    end
    return resultSegs;
end
