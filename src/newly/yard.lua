-- 距离显示
P.ask("pp").answer("yard", function(pp)

    local dp = pp.dp;

    local fontCombat = A.Res.fontCombat;

    local rawConfig = {
        item = {
            ["霜纹投网"] = 25,
        },
        skill = {
            "射击", "投掷",
            "飞镖投掷", "暗影步", "致盲", "闷棍", "背刺",
            "火球术", "寒冰箭", "冰枪术", "奥术冲击", "变形术",
            "惩击", "暗言术：痛",
            "审判", "制裁之锤", "圣光术", "驱邪术",
            "闪电箭", "大地震击", "治疗波", "治疗之涌", "先祖之魂", "风剪",
            "冲锋", "撕裂", "英勇投掷",
            "碎玉闪电", "嚎镇八方", "分筋错骨", "怒雷破",
        }
    };

    local function reckon()
        rawConfig._skills = {};
        for i, skillName in pairs(rawConfig.skill) do
            local maxRange = select(6, GetSpellInfo(skillName));
            if maxRange then
                if (maxRange == 0) then
                    maxRange = 5; -- 近战范围
                end
                rawConfig._skills[skillName] = maxRange;
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

        local r = 99;
        for name, range in pairs(rawConfig.item) do
            if IsItemInRange(name, "target") == 1 and r > range then
                r = range;
            end
        end
        for name, range in pairs(rawConfig._skills) do
            if IsSpellInRange(name, "target") == 1 and r > range then
                r = range;
            end
        end
        if r == 99 then
            r = ".";
        end
        return r;
    end

    local f = CreateFrame("FRAME", nil, UIParent)
    f:SetSize(60 * dp, 32 * dp);
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -40 * dp)
    f.elapsed = 0;

    local fs = f:CreateFontString();
    fs:SetFont(fontCombat, 32 * dp, "OUTLINE");
    fs:SetTextColor(0, 1, 0);
    fs:SetJustifyH("CENTER");
    fs:SetJustifyV("MIDDLE");
    fs:SetAllPoints();
    f.fs = fs;

    local uiVersion = select(4, GetBuildInfo());
    if (uiVersion >= 20000) then
        f:RegisterEvent("PLAYER_TALENT_UPDATE")
        f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    end
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
            if (InCombatLockdown()) then
                self.pendingReckon = 1;
            else
                self.pendingReckon = nil;
                reckon();
            end
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed;
                if self.elapsed < 0.1 then
                    return;
                end
                self.elapsed = 0;
                self.fs:SetText(lookup());
            end);
        elseif event == "PLAYER_REGEN_ENABLED" then
            self.fs:SetTextColor(0, 1, 0);
            if self.pendingReckon then
                self.pendingReckon = nil;
                reckon();
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.fs:SetTextColor(1, 0, 0);
        end
    end);

    if (InCombatLockdown()) then
        f.pendingReckon = 1;
    else
        f.pendingReckon = nil;
        reckon();
    end
end);
