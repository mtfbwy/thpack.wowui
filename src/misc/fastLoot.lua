(function()
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
