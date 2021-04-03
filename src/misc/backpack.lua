-- single click on backpack to toggle all bags
local maskButton = CreateFrame("Button", nil, MainMenuBarBackpackButton, SecureButtonTemplate);
maskButton:SetAllPoints();
maskButton:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD");
maskButton:SetScript("OnEnter", function(self)
    MainMenuBarBackpackButton:GetScript("OnEnter")(MainMenuBarBackpackButton);
end);
maskButton:SetScript("OnLeave", function(self)
    MainMenuBarBackpackButton:GetScript("OnLeave")(MainMenuBarBackpackButton);
end);
maskButton:SetScript("OnClick", function(self)
    ToggleAllBags(self);
end);

-- 交易/商人/邮箱/银行关闭时不关包
-- hook and kill args
local BlizOpenAllBags = OpenAllBags;
OpenAllBags = function()
    BlizOpenAllBags();
end;
