
-- move PlayerFrame into hud

-- move pet

-- move buffs under PlayerFrame

-- bigger my buff

-- health show both value and percent

-- show race / creature type

-- mana/energy/rage/... show value

-- add CastBar

local function movePlayerFrame()
    PlayerFrame:SetUserPlaced(true);
    PlayerFrame:ClearAllPoints();
    PlayerFrame:SetPoint("TOPLEFT", UIParent, "CENTER", -310, -140);

    TargetFrame.levelText:ClearAllPoints();
    TargetFrame.levelText:SetPoint("CENTER", 64, -15);
end

local f = CreateFrame("Frame", nil, UIParent, nil);
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", function(self, event, ...)
    movePlayerFrame();
end);

