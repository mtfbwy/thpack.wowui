-- 距离显示
T.ask("PLAYER_LOGIN", "resource", "env").answer("yard", function(_, res, env)

    local rawConfig = {
        item = {
            ["霜纹投网"] = 25,
        },
        skill = {
        },
        skills = {
            "射击",
            "致盲", "暗影步", "致命投掷",
            "火球术", "寒冰箭", "冰枪术", "奥术冲击", "变形术",
            "惩击", "暗言术：痛",
            "审判", "制裁之锤", "圣光术", "驱邪术",
            "闪电箭", "大地震击", "治疗波", "先祖之魂",
            "冲锋", "英勇投掷",
        }
    };

    local function recalc()
        for i, skillName in pairs(rawConfig.skills) do
            local r = select(6, GetSpellInfo(skillName))
            if r and r > 0 then
                rawConfig.skill[skillName] = r
            else
                rawConfig.skill[skillName] = nil
            end
        end
    end

    local function lookup()
        if (UnitIsUnit("target", "player")) then
            return "."
        end
        local r = 99
        for name, range in pairs(rawConfig.item) do
            if IsItemInRange(name, "target") == 1 and r > range then
                r = range;
            end
        end
        for name, range in pairs(rawConfig.skill) do
            if IsSpellInRange(name, "target") == 1 and r > range then
                r = range;
            end
        end
        if r == 99 then
            r = ".";
        end
        return r;
    end

    local totalElapsed = 0;
    function update(self, elapsed)
        totalElapsed = totalElapsed + elapsed;
        if totalElapsed >= 0.1 then
            self.fs:SetText(lookup());
            totalElapsed = 0;
        end
    end

    recalc();

    local pendingUpdate = nil;

    local f = CreateFrame("frame", nil, UIParent)
    f:SetSize(160 * env.dotsRelative, 32 * env.dotsRelative)
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -60 * env.dotsRelative)
    f.unit = "target"

    local fs = f:CreateFontString();
    fs:SetFont(res.font.COMBAT, 32 * env.dotsRelative, "OUTLINE");
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
            pendingUpdate = 1;
        elseif event == "PLAYER_TARGET_CHANGED" then
            if pendingUpdate then
                recalc();
                pendingUpdate = nil;
            end
            if UnitExists("target") then
                self:SetScript("OnUpdate", update);
            else
                self:SetScript("OnUpdate", nil);
                if InCombatLockdown() then
                    self.fs:SetText(".");
                else
                    self.fs:SetText("");
                end
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            self.fs:SetTextColor(0, 1, 0);
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.fs:SetTextColor(1, 0, 0);
        end
    end);
end);
