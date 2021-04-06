addonName, addon = ...;
if (addon.HealthFrame) then
    return;
end

addon.HealthFrame = {};
local HealthFrame = addon.HealthFrame;

function HealthFrame.malloc(uf)
    local healthFrame = CreateFrame("Frame", nil, uf, nil);
    uf.healthFrame = healthFrame;

    local healthBar = CreateFrame("StatusBar", nil, healthFrame, nil);
    healthBar:SetFrameStrata("BACKGROUND");
    healthBar:SetFrameLevel(1);
    healthBar:SetMinMaxValues(0, 1);
    healthBar:SetStatusBarTexture(A.Res.healthbar32);
    healthBar:SetBackdrop({
        bgFile = A.Res.tile32,
    });
    healthBar:SetBackdropColor(0, 0, 0, 0.85);
    healthBar:SetSize(60, 4);
    healthBar:SetPoint("BOTTOM", healthFrame, "BOTTOM", 0, 0);
    healthFrame.healthBar = healthBar;

    local healthGlowFrame = A.createBorderFrame(healthBar, {
        edgeFile = A.Res.path .. "/3p/glow.tga",
        edgeSize = 5,
    });
    healthGlowFrame:SetBackdropBorderColor(0, 0, 0, 0.7);
    healthFrame.glowFrame = healthGlowFrame;

    -- TODO health bar glow for threat level

    local healthText = healthFrame:CreateFontString(nil, "ARTWORK", nil);
    healthText:SetFont(A.Res.path .. "/3p/impact.ttf", 12, "OUTLINE");
    healthText:SetVertexColor(1, 1, 1);
    healthText:SetShadowOffset(0, 0);
    healthText:SetJustifyH("LEFT");
    healthText:SetPoint("LEFT", healthBar, "RIGHT", 2, 1);
    healthFrame.healthText = healthText;

    healthFrame.eventHandlers = {
        ["PLAYER_REGEN_ENABLED"] = HealthFrame.refreshIfUnitIsPlayer,
        ["PLAYER_REGEN_DISABLED"] = HealthFrame.refreshIfUnitIsPlayer,
        ["UNIT_HEALTH_FREQUENT"] = HealthFrame.refreshIfUnitMatches,
    };

    return healthFrame;
end

function HealthFrame.getUnit(self)
    return self:GetAttribute("unit");
end

function HealthFrame.setUnit(self, unit)
    unit = unit and string.lower(unit);
    self:SetAttribute("unit", unit);
end

function HealthFrame.refreshIfUnitMatches(self, unit)
    unit = unit and string.lower(unit);
    if (HealthFrame.getUnit(self) != unit) then
        return;
    end

    local currentHealth = UnitHealth(unit);
    local maxHealth = UnitHealthMax(unit);
    local healthRate = currentHealth / maxHealth;

    local healthBar = self.healthBar;
    if (healthBar) then
        healthBar:SetValue(healthRate);
        if (UnitIsPlayer(unit) and UnitIsEnemy("player", unit)) then
            healthBar:SetStatusBarColor(A.getUnitClassColorByUnit(unit):toVertex());
        else
            healthBar:SetStatusBarColor(A.getUnitNameColorByUnit(unit):toVertex());
        end
    end

    local healthText = self.healthText;
    if (healthText) then
        if (healthRate == 1 and not UnitAffectingCombat("player")) then
            healthText:SetText(nil);
        else
            local percentage;
            if (healthRate > 0.01) then
                percentage = math.floor(healthRate * 100);
            else
                percentage = math.floor(healthRate * 1000) / 10;
            end
            healthText:SetText(percentage);
            healthText:SetVertexColor(A.getUnitHealthColorByRate(healthRate):toVertex());
        end
    end
end

function HealthFrame.refreshIfUnitIsPlayer(self)
    HealthFrame.refreshIfUnitMatches(self, "player");
end
