local Timer = newProto(nil, function(o)
    o._f = CreateFrame("Frame", nil, nil, nil);
end);

function Timer:_setInterval()
    self._count = 0;
    self:_setIntervalInternal(function()
        if (self._count < self._times) then
            self._callback();
        else
            self:stop();
        end
        self._count = self._count + 1;
    end, self._delay);
end

function Timer:_setIntervalInternal(callback, delay)
    delay = delay / 1000;
    local accumulated = 0;
    self._f:SetScript("OnUpdate", function(self, elapsed)
        accumulated = accumulated + elapsed;
        if (accumulated < delay) then
            return;
        end
        accumulated = 0; -- not to catch up
        callback();
    end);
end

function Timer:_clearInterval()
    self._f:SetScript("OnUpdate", nil);
end

function Timer:isRunning()
    return self._f:GetScript("OnUpdate") ~= nil;
end

function Timer:schedule(callback, delay, times)
    if (self:isRunning()) then
        error(string.format("E: timer is running"));
        return;
    end

    self._callback = callback;
    self._delay = delay;
    self._times = times;

    self:_setInterval();

    return self;
end

function Timer:stop()
    if (self:isRunning()) then
        self:_clearInterval();
    end
    return self;
end

function Timer:reschedule()
    if (self._callback == nil or self._delay == nil or self._times == nil) then
        error(string.format("E: timer is not configured"));
        return;
    end
    self:stop();
    self:_setInterval();
    return self;
end

_G.Timer = Timer;
