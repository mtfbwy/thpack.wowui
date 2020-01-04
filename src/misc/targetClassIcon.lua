(function()
    local classIcon = A.createBlizzardRoundButton(TargetFrame, nil, 40);
    classIcon:SetPoint("topleft", 115, -3); -- no pixel fix since align to bliz mod
    RaiseFrameLevel(classIcon);
    classIcon.artworkTexture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);

    -- inspect target when click
    classIcon:SetScript("OnMouseDown", function(self, button)
        if (button == "LeftButton") then
            local unit = "target";
            if (UnitIsPlayer(unit)) and not UnitCanAttack("player", unit) then
                if (InspectFrame and InspectFrame:IsShown()) then
                    InspectFrameCloseButton:Click();
                else
                    InspectUnit(unit);
                end
            end
        end
    end);

    function classIcon:onChangeTarget()
        local unit = "target";
        if (UnitIsPlayer(unit)) then
            local unitClass = select(2, UnitClass(unit));
            self.artworkTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
            self:Show();
        else
            self:Hide();
        end
    end

    classIcon:RegisterEvent("PLAYER_TARGET_CHANGED");
    classIcon:SetScript("OnEvent", classIcon.onChangeTarget);

    classIcon:onChangeTarget();
end)();
