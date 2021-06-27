local SpellBook = {};

function SpellBook.getSpellName(spellIdOrName, notCheck)
    local localName = GetSpellInfo(spellIdOrName);
    if (notCheck) then
        return localName;
    end
    if (localName) then
        return GetSpellInfo(localName);
    end
    return nil;
end

function SpellBook.getSpellRange(spellIdOrName)
    local localName, _, _, _, minRange, maxRange = GetSpellInfo(spellIdOrName);
    if (not localName) then
        return nil;
    else
        return minRange, maxRange;
    end
end

--------

local RangeBook = {};

RangeBook.candidateSpells = {
    -- mutual
    "攻击", "射击",
    2764, -- throw [8,30]
    -- mage
    "火球术", "寒冰箭", "冰枪术", "奥术冲击", "变形术",
    -- monk
    "碎玉闪电", "嚎镇八方", "分筋错骨", "怒雷破",
    -- paladin
    "制裁之锤", -- [0,10]
    "驱邪术", -- [0,30]
    "审判", -- [0,10]
    "圣光术", -- [0,40]
    "保护祝福", -- [0,30]
    -- priest
    "惩击", "暗言术：痛",
    -- rogue
    "飞镖投掷", "暗影步", "致盲", "闷棍", "背刺",
    -- shaman
    "闪电箭", "大地震击", "治疗波", "治疗之涌", "先祖之魂", "风剪",
    -- warlock
    686, -- 暗影箭 [0-30]
    5782, -- 恐惧术 [0-20]
    5697, -- 魔息术 [0-30]
    -- warrior
    100, -- charge [8,25]
    772, -- rend [melee]
    5246, -- intimidating-shout [0,10]
    "英勇投掷",
};

RangeBook.spellRanges = {};

function RangeBook.init()
    local spells = RangeBook.candidateSpells;
    local spellRanges = RangeBook.spellRanges;

    table.clear(spellRanges);
    for _, v in pairs(spells) do
        local spellName = SpellBook.getSpellName(v);
        if (spellName) then
            local minRange, maxRange = SpellBook.getSpellRange(spellName);
            if (maxRange) then
                if (maxRange == 0) then
                    -- melee
                    maxRange = 5;
                end
                spellRanges[spellName] = { minRange, maxRange };
            end
        end
    end
end

function RangeBook.getUnitRange(unit)
    if (not UnitExists(unit)) then
        return;
    end

    local spellRanges = RangeBook.spellRanges;

    if (UnitIsUnit(unit, "player")) then
        return { 0, 0 };
    end

    local resultRanges = { 0, 99 };
    for spellName, range in pairs(spellRanges) do
        local inRange = IsSpellInRange(spellName, unit);
        if (inRange == 1) then
            resultRanges = Seg.op(resultRanges, range[1], range[2], Seg.getIntersection);
        elseif (inRange == 0) then
            resultRanges = Seg.op(resultRanges, range[1], range[2], Seg.getSubstraction);
        end
    end
    return resultRanges;
end

function RangeBook.getUnitRangeString(unit)
    local resultRanges = RangeBook.getUnitRange(unit);

    if (not resultRanges) then
        return;
    end

    if (resultRanges[2] == 0) then
        return "*";
    end
    if (resultRanges[2] == 99) then
        return "*";
    end

    if (array.size(resultRanges) == 2) then
        if (resultRanges[2] == 0) then
            return 0;
        elseif (resultRanges[2] == 99) then
            return "*"
        elseif (resultRanges[1] == 0 or resultRanges[1] >= 10) then
            return resultRanges[2];
        end
    end

    local s = "";
    for i = 1, array.size(resultRanges), 2 do
        s = s .. resultRanges[i] .. "-" .. resultRanges[i + 1];
        if (i + 1 < array.size(resultRanges)) then
            s = s .. ","
        end
    end
    return s;
end

--------

local f = CreateFrame("Frame", nil, UIParent, nil);
f:SetSize(1, 1);
f:SetPoint("TOPLEFT");

local rangeText = f:CreateFontString();
rangeText:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE");
rangeText:SetTextColor(0, 1, 0);
--rangeText:SetJustifyH("RIGHT");
--rangeText:SetPoint("TOP", TargetFrame, "TOPLEFT", 112, -6);
rangeText:SetJustifyH("LEFT");
rangeText:SetPoint("BOTTOMLEFT", TargetFrame, "BOTTOMRIGHT", -40, 33);
f.rangeText = rangeText;

local tocVersion = select(4, GetBuildInfo());
if (tocVersion >= 21000) then
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
        RangeBook.init();
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self.rangeText:SetTextColor(0, 1, 0);
    elseif (event == "PLAYER_REGEN_DISABLED") then
        self.rangeText:SetTextColor(1, 0, 0);
    elseif (event == "PLAYER_TARGET_CHANGED") then
        -- update immediately
        self:GetScript("OnUpdate")(self, 99);
    end
end);

f:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed;
    if (self.elapsed > 0.1) then
        self.elapsed = 0;
        local rangeString = RangeBook.getUnitRangeString("target");
        if (rangeString and rangeString ~= "*") then
            rangeString = rangeString .. "yd";
        end
        self.rangeText:SetText(rangeString);
    end
end);
