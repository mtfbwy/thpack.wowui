P.ask("pp").answer("energyTick", function(pp)

    local dp = pp.dp;

    local _, unitClass = UnitClass("player");
    if (unitClass ~= "ROGUE") then
        return;
    end

    local f = CreateFrame("FRAME");
    f:SetSize(60 * dp, 3 * dp);
    f:SetPoint("CENTER", 0, -60 * dp);

    f:SetBackdrop({
        bgFile = A.Res.texSquare,
    });
    f:SetBackdropColor(1, 1, 0, 0.3);

    f.spark = f:CreateTexture(nil, "OVERLAY");
    f.spark:SetTexture("Interface/CastingBar/UI-CastingBar-Spark");
    f.spark:SetSize(6 * dp, 12 * dp);
    f.spark:SetBlendMode("ADD");

    f.lastEnergyTick = 0;
    f.recentEnergy = 0;

    f:SetScript("OnUpdate", function(self, elapsed)
        local powerType = Enum.PowerType.Energy or 3;
        local energy = UnitPower("player", powerType);
        local d = energy - self.recentEnergy;
        -- exclude [Thistle Tea]
        -- TODO exclude [Adrenaline Rush]
        if (d > 19 and d < 21) then
            self.lastEnergyTick = GetTime();
        end
        self.recentEnergy = energy;

        local ratio = ((GetTime() - self.lastEnergyTick) / 2) % 1;
        self.spark:ClearAllPoints();
        self.spark:SetPoint("CENTER", f, "LEFT", f:GetWidth() * ratio, 0);
    end);
end);
