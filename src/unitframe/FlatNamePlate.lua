(function()

    local function initialize()
        SetCVar("namePlateMaxDistance", 60);
        SetCVar("namePlateMinScale", 1);
        SetCVar("namePlateMaxScale", 1);
        SetCVar("namePlateLargerScale", 1);
        SetCVar("namePlateSelectedScale", 1);
        SetCVar("namePlateHorizontalScale", 1);
        SetCVar("namePlateVerticalScale", 1);

        SetCVar("namePlateSelfAlpha", 1);
        SetCVar("namePlatePersonalShowAlways", 1);
        SetCVar("namePlatePersonalShowInCombat", 1);
        SetCVar("namePlatePersonalShowWithTarget", 1);
        SetCVar("namePlatePersonalHideDelaySeconds", 2);

        SetCVar("namePlateShowEnemyGuardians", 1);
        SetCVar("namePlateShowEnemyMinions", 1);
        SetCVar("namePlateShowEnemyPets", 1);
        SetCVar("namePlateShowEnemyTotems", 1);
        SetCVar("namePlateShowEnemyMinus", 1);

        SetCVar("namePlateShowFriendlyGuardians", 1);
        SetCVar("namePlateShowFriendlyMinions", 1);
        SetCVar("namePlateShowFriendlyNPCs", 1);
        SetCVar("namePlateShowFriendlyPets", 1);
        SetCVar("namePlateShowFriendlyTotems", 1);

        C_NamePlate.SetNamePlateEnemyClickThrough(false)
        C_NamePlate.SetNamePlateFriendlyClickThrough(false)

        local namePlateWidth = 100; -- blizzard default 128
        local namePlateHeight = 20; -- blizzard default 32
        C_NamePlate.SetNamePlateSelfSize(namePlateWidth, namePlateHeight)
        C_NamePlate.SetNamePlateEnemySize(namePlateWidth, namePlateHeight)

        --NamePlateDriverFrame:UnregisterAllEvents();
        --NamePlateDriverFrame.SetupClassNameplateBars = function()
            -- dummy
        --end;
    end

    local function enableBlizzardNamePlate(blizNamePlate, enabled)
        local children = blizNamePlate:GetChildren();
        if (not children) then
            return;
        end
        if (enabled) then
            children:Show();
        else
            children:Hide();
        end
    end

    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:RegisterEvent("NAME_PLATE_CREATED");
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED");
    f:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
    f:RegisterEvent("PLAYER_ENTERING_WORLD");
    f:RegisterEvent("VARIABLES_LOADED");
    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "VARIABLES_LOADED") then
            -- "PLAYER_ENTERING_WORLD"
            -- "DISPLAY_SIZE_CHANGED"
            initialize();
        elseif (event == "PLAYER_ENTERING_WORLD") then
            if (IsInInstance()) then
                C_NamePlate.SetNamePlateFriendlySize(128, 32);
            else
                C_NamePlate.SetNamePlateFriendlySize(100, 20);
            end
        elseif (event == "NAME_PLATE_CREATED") then
            local namePlate = ...
            local uf = FlatUnitFrame.createUnitFrame(namePlate);
            uf:SetAllPoints(namePlate);
            FlatUnitFrame.stop(uf);
            namePlate.flatUnitFrame = uf;
        elseif (event == "NAME_PLATE_UNIT_ADDED") then
            local unit = ...;
            local namePlate = C_NamePlate.GetNamePlateForUnit(unit);
            local uf = namePlate.flatUnitFrame;
            if (IsInInstance() and UnitIsFriend("player", unit)) then
                enableBlizzardNamePlate(namePlate, true);
                FlatUnitFrame.stop(uf);
            else
                enableBlizzardNamePlate(namePlate, false);
                FlatUnitFrame.setUnit(namePlate.flatUnitFrame, unit);
                FlatUnitFrame.start(uf);
            end
        elseif (event == "NAME_PLATE_UNIT_REMOVED") then
            local unit = ...;
            local namePlate = C_NamePlate.GetNamePlateForUnit(unit);
            local uf = namePlate.flatUnitFrame;
            FlatUnitFrame.setUnit(uf, nil);
            FlatUnitFrame.stop(uf);
        end
    end);
end)(...);
