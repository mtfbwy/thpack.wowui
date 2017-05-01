T.ask("api").answer("TargetFrameClassIcon", function(api)
    local button, artTexture = api.createBlizButton(40, TargetFrame);
    button:SetPoint("topleft", 115, -3); -- no pixel fix since relate to bliz mod
    RaiseFrameLevel(button);
    artTexture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);

    button:SetScript("OnMouseDown", function(self, button)
        if not UnitCanAttack("player", "target") and UnitIsPlayer("target") then
            InspectUnit("target");
        end
    end);

    local function updateClassIcon(unit, button, artTexture)
        if UnitIsPlayer(unit) then
            local unitClass = select(2, UnitClass(unit));
            artTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
            button:Show();
        else
            button:Hide();
        end
    end

    button:RegisterEvent("PLAYER_TARGET_CHANGED");
    button:SetScript("OnEvent", function(self, event, ...)
        updateClassIcon("target", button, artTexture);
    end);

    updateClassIcon("target", button, artTexture);
end);
