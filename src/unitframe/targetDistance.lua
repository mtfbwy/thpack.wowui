local Seg = {};

function Seg.getIntersection(start1, end1, start2, end2)
    local intersectionStart = start1 >= start2 and start1 or start2;
    local intersectionEnd = end1 <= end2 and end1 or end2;
    if (intersectionStart <= intersectionEnd) then
        return intersectionStart, intersectionEnd;
    else
        return nil;
    end
end

function Seg.getSubstraction(start1, end1, start2, end2)
    local intersectionStart, intersectionEnd = Seg.getIntersection(start1, end1, start2, end2);
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

function Seg.op(segs, start2, end2, op)
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
        local resultStart, resultEnd = op(segs[i], segs[i + 1], start2, end2);
        if (resultStart) then
            table.insert(resultSegs, resultStart);
            table.insert(resultSegs, resultEnd);
        end
    end
    return resultSegs;
end

--------

local data = {};

data.spells = {
    -- mutual
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
    -- warlock
    "暗影箭", "恐惧术", "魔息术",
    -- warrior
    "冲锋", "撕裂", "英勇投掷",
};

data.spellRanges = {};

local function filterCandidate(spells, spellRanges)
    table.clear(spellRanges);
    for _, v in pairs(spells) do
        local spellName, _, _, _, minRange, maxRange = GetSpellInfo(v);
        if (maxRange) then
            if (maxRange == 0) then
                -- melee
                maxRange = 5;
            end
            spellRanges[spellName] = { minRange, maxRange };
        end
    end
end

local function findDistance(spellRanges)
    local unit = "target";
    if (not UnitExists(unit)) then
        return "";
    end

    if (UnitIsUnit(unit, "player")) then
        return "."; -- in case of in combat
    end

    local MAX_RANGE = 99;
    local resultSegs = { 0, MAX_RANGE };
    for spellName, range in pairs(spellRanges) do
        local inRange = IsSpellInRange(spellName, unit);
        if (inRange == 1) then
            resultSegs = Seg.op(resultSegs, range[1], range[2], Seg.getIntersection);
        elseif (inRange == 0) then
            resultSegs = Seg.op(resultSegs, range[1], range[2], Seg.getSubstraction);
        end
    end

    if (resultSegs[2] == MAX_RANGE) then
        return ".";
    end

    if (#resultSegs == 2) then
        if (resultSegs[1] == 0 or resultSegs[1] > 10) then
            return resultSegs[2];
        end
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

--------

local f = CreateFrame("Frame", nil, TargetFrame, nil);
f:SetSize(1, 1);
f:SetPoint("BOTTOMRIGHT", TargetFrame, "TOPLEFT", 2, -39);

local textView = f:CreateFontString();
textView:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE");
textView:SetTextColor(0, 1, 0);
textView:SetJustifyH("RIGHT");
textView:SetPoint("BOTTOMRIGHT");
f.textView = textView;

if (select(4, GetBuildInfo()) >= 20000) then
    f:RegisterEvent("PLAYER_TALENT_UPDATE");
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
end
f:RegisterEvent("LEARNED_SPELL_IN_TAB");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("PLAYER_REGEN_ENABLED");
f:RegisterEvent("PLAYER_REGEN_DISABLED");
f:RegisterEvent("PLAYER_TARGET_CHANGED");

f:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD"
            or event == "PLAYER_TALENT_UPDATE"
            or event == "ACTIVE_TALENT_GROUP_CHANGED"
            or event == "LEARNED_SPELL_IN_TAB") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        filterCandidate(data.spells, data.spellRanges);
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self.textView:SetTextColor(0, 1, 0);
    elseif (event == "PLAYER_REGEN_DISABLED") then
        self.textView:SetTextColor(1, 0, 0);
    elseif (event == "PLAYER_TARGET_CHANGED") then
        -- update immediately
        self:GetScript("OnUpdate")(self, 99);
    end
end);

f:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed;
    if (self.elapsed > 0.1) then
        self.elapsed = 0;
        self.textView:SetText(findDistance(data.spellRanges));
    end
end);
