(function()

    local BLIZZARD_NAME_PLATE_WIDTH = 128;
    local BLIZZARD_NAME_PLATE_HEIGHT = 32;

    -- the click region
    local FLAT_NAME_PLATE_WIDTH = 100;
    local FLAT_NAME_PLATE_HEIGHT = 20;

    local function initialize()
        SetCVar("nameplateMaxDistance", 50);

        SetCVar("nameplateOtherTopInset", GetCVarDefault("nameplateOtherTopInset"));
        SetCVar("nameplateOtherBottomInset", GetCVarDefault("nameplateOtherBottomInset"));

        SetCVar("nameplateMinScale", 1);
        SetCVar("nameplateMaxScale", 1);
        SetCVar("nameplateLargerScale", 1);
        SetCVar("nameplateMinAlpha", 0.9);
        SetCVar("nameplateSelectedScale", 1);
        SetCVar("nameplateHorizontalScale", 1);
        SetCVar("nameplateVerticalScale", 1);

        SetCVar("nameplateSelfAlpha", 1);
        SetCVar("nameplatePersonalShowAlways", 1);
        SetCVar("nameplatePersonalShowWithTarget", 1);

        SetCVar("nameplateShowEnemies", 1);
        SetCVar("nameplateShowEnemyMinions", 1);
        SetCVar("nameplateShowEnemyPets", 1);
        SetCVar("nameplateShowEnemyGuardians", 1);
        SetCVar("nameplateShowEnemyTotems", 1);

        SetCVar("nameplateShowFriends", 1);
        SetCVar("nameplateShowFriendlyMinions", 1);
        SetCVar("nameplateShowFriendlyPets", 1);
        SetCVar("nameplateShowFriendlyGuardians", 1);
        SetCVar("nameplateShowFriendlyTotems", 1);
        SetCVar("ShowClassColorInFriendlyNameplate", 0);

        C_NamePlate.SetNamePlateEnemyClickThrough(false)
        C_NamePlate.SetNamePlateFriendlyClickThrough(false)

        C_NamePlate.SetNamePlateSelfSize(FLAT_NAME_PLATE_WIDTH, FLAT_NAME_PLATE_HEIGHT)
        C_NamePlate.SetNamePlateEnemySize(FLAT_NAME_PLATE_WIDTH, FLAT_NAME_PLATE_HEIGHT)
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
    f:RegisterEvent("DISPLAY_SIZE_CHANGED");
    f:SetScript("OnEvent", function(self, event, ...)
        if (event == "VARIABLES_LOADED") then
            initialize();
        elseif (event == "PLAYER_ENTERING_WORLD") then
            if (IsInInstance()) then
                C_NamePlate.SetNamePlateFriendlySize(BLIZZARD_NAME_PLATE_WIDTH, BLIZZARD_NAME_PLATE_HEIGHT);
            else
                C_NamePlate.SetNamePlateFriendlySize(FLAT_NAME_PLATE_WIDTH, FLAT_NAME_PLATE_HEIGHT);
            end
        elseif (event == "DISPLAY_SIZE_CHANGED") then
            for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
                local unit = namePlate.namePlateUnitToken;
                if (not IsInInstance() or not UnitIsFriend("player", unit)) then
                    enableBlizzardNamePlate(namePlate, false);
                end
            end
        elseif (event == "NAME_PLATE_CREATED") then
            local namePlate = ...
            local uf = FlatUnitFrame.createUnitFrame(namePlate);
            uf:SetPoint("BOTTOM", namePlate, "BOTTOM");
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
