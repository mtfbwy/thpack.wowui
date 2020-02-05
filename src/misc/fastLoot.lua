(function()

    SetCVar("lootUnderMouse", 0);
    SetCVar("autoLootDefault", 1);
    SetCVar("autoLootRate", 0);
    SetCVar("autoOpenLootHistory", 0);

    local f = CreateFrame("Frame");
    f:RegisterEvent("LOOT_READY");
    f:SetScript("OnEvent", function ()
        if (GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")) then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i);
            end
        end
    end);
end)();
