(function()
    local _, unitClass = UnitClass("player");
    if (unitClass ~= "ROGUE") then
        return;
    end

    local function createTempEnchantChargesText(buff)
        local textView = buff:CreateFontString(nil, "ARTWORK", "NumberFontNormal");
        textView:SetPoint("BOTTOMRIGHT", 3, 2);
        textView:SetText(nil);
        return textView;
    end

    local text1 = createTempEnchantChargesText(TempEnchant1);
    local text2 = createTempEnchantChargesText(TempEnchant2);

    local f = CreateFrame("Frame", nil, nil, nil);

    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("UNIT_AURA");
    f:SetScript("OnEvent", function(self, event, ...)
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantId,
                hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo();
        if (hasMainHandEnchant) then
            local textView = not hasOffHandEnchant and text1 or text2;
            textView:SetText(mainHandEnchantId > 0 and mainHandCharges or nil);
        end
        if (hasOffHandEnchant) then
            local textView = text1;
            textView:SetText(offHandCharges > 0 and offHandCharges or nil);
        end
    end);
end)();
