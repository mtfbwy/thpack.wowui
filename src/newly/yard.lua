-- 距离显示
P.ask("pp").answer("yard", function(pp)

    local dp = pp.dp;

    local fontCombat = Addon.Res.fontCombat;

    local rawConfig = {
        item = {
            ["霜纹投网"] = 25,
        },
        skill = {
            "射击", "投掷",
            "致盲", "暗影步", "致命投掷",
            "火球术", "寒冰箭", "冰枪术", "奥术冲击", "变形术",
            "惩击", "暗言术：痛",
            "审判", "制裁之锤", "圣光术", "驱邪术",
            "闪电箭", "大地震击", "治疗波", "治疗之涌", "先祖之魂", "风剪",
            "冲锋", "英勇投掷",
        }
    };

    local function reckon()
        rawConfig._skills = {};
        for i, skillName in pairs(rawConfig.skill) do
            local maxRange = select(6, GetSpellInfo(skillName));
            if maxRange and maxRange > 0 then
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
            if IsItemInRange(name, "target") and r > range then
                r = range;
            end
        end
        for name, range in pairs(rawConfig._skills) do
            if IsSpellInRange(name, "target") and r > range then
                r = range;
            end
        end
        if r == 99 then
            r = ".";
        end
        return r;
    end

    local f = CreateFrame("frame", nil, UIParent)
    f:SetSize(160 * dp, 32 * dp);
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -40)
    f.unit = "target"
    f.accumulatedElapsed = 0;
    f.pendingReckon = 1;

    local fs = f:CreateFontString();
    fs:SetFont(fontCombat, 32 * dp, "OUTLINE");
    fs:SetTextColor(0, 1, 0);
    fs:SetJustifyH("CENTER");
    fs:SetJustifyV("MIDDLE");
    fs:SetAllPoints();
    f.fs = fs;

    f:RegisterEvent("PLAYER_TALENT_UPDATE")
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
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
                self.accumulatedElapsed = self.accumulatedElapsed + elapsed;
                if self.accumulatedElapsed >= 0.1 then
                    self.fs:SetText(lookup());
                    self.accumulatedElapsed = 0;
                end
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
end);
