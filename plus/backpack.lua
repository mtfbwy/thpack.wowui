-- single click on backpack to toggle all bags
(function()
    -- mask button
    local f = CreateFrame("Button", nil, MainMenuBarBackpackButton, SecureButtonTemplate);
    f:SetAllPoints();
    f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD");
    f:SetScript("OnEnter", function(self)
        MainMenuBarBackpackButton:GetScript("OnEnter")(MainMenuBarBackpackButton);
    end);
    f:SetScript("OnLeave", function(self)
        MainMenuBarBackpackButton:GetScript("OnLeave")(MainMenuBarBackpackButton);
    end);
    f:SetScript("OnClick", function(self)
        ToggleAllBags();
    end);
end)();

-- at bank, open all bags including bank bags
(function()
    local f = CreateFrame("Frame");
    f:RegisterEvent("BANKFRAME_OPENED");
    f:SetScript("OnEvent", function(self, event, ...)
        ToggleAllBags();
    end);
end)();

-- 交易/商人/邮箱/银行关闭时不关包
(function()
    -- hook and kill args
    local BlizOpenAllBags = OpenAllBags;
    OpenAllBags = function()
        BlizOpenAllBags();
    end;
end)();

-- show number of free item slots
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
