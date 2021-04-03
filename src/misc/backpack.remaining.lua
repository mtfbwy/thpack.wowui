(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("BAG_UPDATE");
    f:SetScript("OnEvent", function(self, event, ...)
        local bagId = (...);
        -- check FrameXML/Constants.lua
        -- BACKPACK_CONTAINER = 0
        -- NUM_BAG_SLOTS = 4
        if (bagId >= 0 and bagId <= 4) then
            -- check FrameXML/MainMenuBarBagButtons.lua
            -- check FrameXML/MainMenuBarBagButtons.xml
            -- check FrameXML/ItemButtonTemplate.xml
            if MainMenuBarBackpackButtonCount then
               local n = CalculateTotalNumberOfFreeBagSlots();
               MainMenuBarBackpackButtonCount:SetText(string.format("(%d)", n));
            end
        end
    end);
end)();
