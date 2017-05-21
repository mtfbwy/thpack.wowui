T.ask("api", "ClassIcon").answer(function(api, ClassIcon)
    local button, artTexture = api.createBlizButton(40, TargetFrame);
    button:SetPoint("topleft", 115, -3); -- no pixel fix since relate to bliz mod
    RaiseFrameLevel(button);
    artTexture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);
    button.texture = artTexture;

    button:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local unit = "target";
            if UnitIsPlayer(unit) and not UnitCanAttack("player", unit) then
                if InspectFrame and InspectFrame:IsShown() then
                    InspectFrame:Hide();
                else
                    InspectUnit(unit);
                end
            end
        end
    end);

    local function onChangeTarget(self)
        if ClassIcon.update(self, "target") then
            self:Show();
        else
            self:Hide();
        end
    end

    button:RegisterEvent("PLAYER_TARGET_CHANGED");
    button:SetScript("OnEvent", onChangeTarget);

    onChangeTarget(button);
end);

-- TODO duplicate unit casting bar over its hp bar or name line
-- TODO and change avatar changed to spell icon
