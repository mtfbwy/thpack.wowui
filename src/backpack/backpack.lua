-- 使打开/关闭背包的行为映射成打开/关闭所有包
-- 交易/银行打开时打开所有包
-- 商人/邮箱/银行关闭时不关包
(function()

    local function getContainerFrame(id)
        if (id < 0) then
            id = -id - 1 + NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
        else
            id = id + 1;
        end
        return _G["ContainerFrame" .. id];
    end

    local function toggleOne(id, cmd)
        id = id or 0;
        cmd = cmd or "TOGGLE";
        local size = GetContainerNumSlots(id);
        if size > 0 or id == KEYRING_CONTAINER then
            local container = getContainerFrame(id);
            local isOpen = container:IsShown();
            if not isOpen and (cmd == "TOGGLE" or cmd == "SHOW") then
                if not CanOpenPanels() or IsOptionFrameOpen() then
                    if UnitIsDead("PLAYER") then
                        NotWithDeadError();
                    end
                    return 0;
                end
                ContainerFrame_GenerateFrame(container, size, id)
                if id == KEYRING_CONTAINER then
                    SetButtonPulse(KeyRingButton, 0, 1);
                end
                return 1;
            elseif isOpen and (cmd == "TOGGLE" or cmd == "HIDE") then
                container:Hide();
                return 1
            end
        end
        return 0;
    end

    local function toggleAll(cmd)
        cmd = cmd or "TOGGLE";
        local m = 0;
        local n = 0;
        -- resequence the containers
        for i = 0, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, 1 do
            if GetContainerNumSlots(i) > 0 then
                m = m + 1;
            end
            n = n + toggleOne(i, "HIDE");
        end
        if cmd == "SHOW" or (cmd == "TOGGLE" and n ~= m) then
            if not CanOpenPanels() or IsOptionFrameOpen() then
                if UnitIsDead("PLAYER") then
                    NotWithDeadError();
                end
                return
            end
            for i = 0, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS, 1 do
                toggleOne(i, "SHOW");
            end
        end
    end

    local function openAll()
        toggleAll("SHOW");
    end

    local function closeAll(frame)
        if (frame ~= nil) then
            return;
        end
        toggleAll("HIDE");
    end

    -- hook
    (function()
        OpenBag     = function(id) toggleOne(id, "SHOW"); end;
        CloseBag    = function(id) toggleOne(id, "HIDE"); end;
        ToggleBag   = toggleOne;
        ToggleKeyRing   = function() toggleOne(KEYRING_CONTAINER); end;
        OpenBackpack    = openAll;
        CloseBackpack   = closeAll;
        ToggleBackpack  = toggleAll;
        OpenAllBags     = openAll;
        CloseAllBags    = closeAll;
        ToggleAllBags   = toggleAll;
    end)();

    local tocVersion = select(4, GetBuildInfo());
    local f = CreateFrame("Frame")
    f:RegisterEvent("BANKFRAME_OPENED")
    --f:RegisterEvent("BANKFRAME_CLOSED")
    if (tocVersion >= 20300) then
        f:RegisterEvent("GUILDBANKFRAME_OPENED")
        --f:RegisterEvent("GUILDBANKFRAME_CLOSED")
    end
    f:RegisterEvent("TRADE_SHOW")
    f:RegisterEvent("TRADE_CLOSED")
    f:SetScript("OnEvent", function(self, event, ...)
        --if string.match(event, "_CLOSED") then
            --toggleAll("HIDE");
        --else
            toggleAll("SHOW");
        --end
    end);
end)();
