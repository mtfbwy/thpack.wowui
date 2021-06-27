-- 自动选择最贵的任务奖励
(function()
    local f = CreateFrame("frame");
    f:RegisterEvent("QUEST_COMPLETE");
    f:SetScript("OnEvent", function()
        local maxPrice, indexOfMaxPrice = 0, 0;
        for i = 1, GetNumQuestChoices() do
            local item = GetQuestItemLink("choice", i);
            if item then
                local price = select(11, GetItemInfo(item))
                if price > maxPrice then
                    maxPrice, indexOfMaxPrice = price, i;
                end
            end
        end
        if indexOfMaxPrice > 0 then
            _G["QuestInfoRewardsFrameQuestInfoItem" .. indexOfMaxPrice]:Click();
        end
    end);
end)();
