T.ask("api").answer("addTargetFrameClassIcon", function(api)
    local button, artTexture = api.createBlizButton(40, TargetFrame);
    button:SetPoint("topleft", 115, -3); -- no pixel fix since relate to bliz mod
    RaiseFrameLevel(button);
    artTexture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);
    button.artTexture = artTexture;

    button:SetScript("OnMouseDown", function(self, button)
        if not UnitCanAttack("player", "target") and UnitIsPlayer("target") then
            if button == "LeftButton" then
                if InspectFrame and InspectFrame:IsShown() then
                    InspectFrame:Hide();
                else
                    InspectUnit("target");
                end
            end
        end
    end);

    local function updateClassIcon(unit, button)
        if UnitIsPlayer(unit) then
            local unitClass = select(2, UnitClass(unit));
            button.artTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
            button:Show();
        else
            button:Hide();
        end
    end

    button:RegisterEvent("PLAYER_TARGET_CHANGED");
    button:SetScript("OnEvent", function(self, event, ...)
        updateClassIcon("target", button);
    end);

    updateClassIcon("target", button);
end);

-- TODO duplicate unit casting bar over its hp bar or name line
-- TODO and change avatar changed to spell icon
