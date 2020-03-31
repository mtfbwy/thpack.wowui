local function segIntersection(start1, end1, start2, end2)
    local intersectionStart = start1 >= start2 and start1 or start2;
    local intersectionEnd = end1 <= end2 and end1 or end2;
    if (intersectionStart <= intersectionEnd) then
        return intersectionStart, intersectionEnd;
    else
        return nil;
    end
end

local function segSubstraction(start1, end1, start2, end2)
    local intersectionStart, intersectionEnd = segIntersection(start1, end1, start2, end2);
    if (not intersectionStart) then
        return start1, end1;
    elseif (start1 == intersectionStart) then
        return intersectionEnd, end1;
    elseif (end1 == intersectionEnd) then
        return start1, intersectionStart;
    else
        return nil;
    end
end

local function segsOp(segs, start2, end2, op)
    if (op == "intersection") then
        op = segIntersection;
    elseif (op == "substraction") then
        op = segSubstraction;
    end
    if (type(op) ~= "function") then
        return nil;
    end

    local resultSegs = {};
    for i = 1, #segs, 2 do
        local resultStart, resultEnd = op(segs[i], segs[i + 1], start2, end2);
        if (resultStart) then
            table.insert(resultSegs, resultStart);
            table.insert(resultSegs, resultEnd);
        end
    end
    return resultSegs;
end

(function()

    local SELECTED_SPELLS = {
        -- common
        "攻击", "射击", "投掷",
        -- mage
        "火球术", "寒冰箭", "冰枪术", "奥术冲击", "变形术",
        -- monk
        "碎玉闪电", "嚎镇八方", "分筋错骨", "怒雷破",
        -- paladin
        "审判", "制裁之锤", "圣光术", "纯净术", "驱邪术",
        -- priest
        "惩击", "暗言术：痛",
        -- rogue
        "飞镖投掷", "暗影步", "致盲", "闷棍", "背刺",
        -- shaman
        "闪电箭", "大地震击", "治疗波", "治疗之涌", "先祖之魂", "风剪",
        -- warrior
        "冲锋", "撕裂", "英勇投掷",
    };

    local spellRanges = {};

    local function rebuild()
        table.clear(spellRanges);
        for _, spellName in pairs(SELECTED_SPELLS) do
            local minRange, maxRange = select(5, GetSpellInfo(spellName));
            if (maxRange) then
                if (maxRange == 0) then
                    -- melee
                    maxRange = 5;
                end
                spellRanges[spellName] = { minRange, maxRange };
            end
        end
    end

    local function lookup()
        if (not UnitExists("target")) then
            return "";
        end

        if (UnitIsUnit("target", "player")) then
            return ".";
        end

        local MAX_RANGE = 99;
        local resultSegs = { 0, MAX_RANGE };
        for spellName, range in pairs(spellRanges) do
            local inRange = IsSpellInRange(spellName, "target");
            if (inRange == 1) then
                resultSegs = segsOp(resultSegs, range[1], range[2], segIntersection);
            elseif (inRange == 0) then
                resultSegs = segsOp(resultSegs, range[1], range[2], segSubstraction);
            end
        end

        if (resultSegs[2] == MAX_RANGE) then
            return ".";
        end

        if (#resultSegs == 2 and resultSegs[1] == 0) then
            return resultSegs[2];
        end

        local s = "";
        for i = 1, #resultSegs, 2 do
            s = s .. resultSegs[i] .. "-" .. resultSegs[i + 1];
            if (i + 1 < #resultSegs) then
                s = s .. ","
            end
        end
        return s;
    end

    local f = CreateFrame("Frame", nil, nil, nil);

    if (select(4, GetBuildInfo()) >= 20000) then
        f:RegisterEvent("PLAYER_TALENT_UPDATE");
        f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    end
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("PLAYER_TARGET_CHANGED");
    f:RegisterEvent("PLAYER_REGEN_ENABLED");
    f:RegisterEvent("PLAYER_REGEN_DISABLED");

    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "PLAYER_ENTERING_WORLD") then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            if (InCombatLockdown()) then
                f.pendingRebuild = 1;
            else
                f.pendingRebuild = nil;
                rebuild();
            end
        elseif (event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED") then
            if (InCombatLockdown()) then
                self.pendingRebuild = 1;
            else
                self.pendingRebuild = nil;
                rebuild();
            end
        elseif (event == "PLAYER_REGEN_ENABLED") then
            if (self.rangeTextView) then
                self.rangeTextView:SetTextColor(0, 1, 0);
            end
            if (self.pendingRebuild) then
                self.pendingRebuild = nil;
                rebuild();
            end
        elseif (event == "PLAYER_REGEN_DISABLED") then
            if (self.rangeTextView) then
                self.rangeTextView:SetTextColor(1, 0, 0);
            end
        elseif (event == "PLAYER_TARGET_CHANGED") then
            -- update immediately
            self:GetScript("OnUpdate")(self, 99);
        end
    end);

    f:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed;
        if (self.elapsed > 0.1) then
            self.elapsed = 0;
            if (self.rangeTextView) then
                self.rangeTextView:SetText(lookup());
            end
        end
    end);

    function setViewPort(rangeTextView)
        f.rangeTextView = rangeTextView;
    end

    local dp = A and A.dp or 0.75;

    local textView = UIParent:CreateFontString();
    textView:SetFont("fonts/arkai_c.ttf", 32 * dp, "OUTLINE");
    textView:SetTextColor(0, 1, 0);
    textView:SetJustifyH("CENTER");
    textView:SetJustifyV("MIDDLE");
    textView:SetSize(100 * dp, 32 * dp);
    textView:SetPoint("CENTER", UIParent, "CENTER", 0, -40 * dp)

    setViewPort(textView);
end)();
