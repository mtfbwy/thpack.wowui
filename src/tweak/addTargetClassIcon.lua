P.ask().answer(nil, function()

    function createBlizButton(sideDots, parent, template)
        local button = CreateFrame("button", nil, parent, template);
        button:SetSize(sideDots, sideDots);

        local highlightTexture = button:CreateTexture(nil, "highlight");
        highlightTexture:SetTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]);
        highlightTexture:SetPoint("topleft", sideDots * -1/64, sideDots * 1/64);
        highlightTexture:SetPoint("bottomright", sideDots * -1/64, sideDots * 1/64);
        button:SetHighlightTexture(highlightTexture);

        local backgroundTexture = button:CreateTexture(nil, "background");
        backgroundTexture:SetTexture([[Interface\Minimap\UI-Minimap-Background]]);
        backgroundTexture:SetVertexColor(0, 0, 0, 0.6);
        backgroundTexture:SetPoint("topleft", sideDots * 4/64, "topleft", sideDots * -4/64);
        backgroundTexture:SetPoint("bottomright", sideDots * -4/64, "topleft", sideDots * 4/64);

        local borderTexture = button:CreateTexture(nil, "overlay");
        borderTexture:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]]);
        borderTexture:SetTexCoord(0, 38/64, 0, 38/64);
        borderTexture:SetAllPoints();

        local artworkTexture = button:CreateTexture(nil, "artwork");
        artworkTexture:SetPoint("topleft", sideDots * 12/64, sideDots * -10/64);
        artworkTexture:SetPoint("bottomright", sideDots * -12/64, sideDots * 14/64);
        button.artworkTexture = artworkTexture;

        return button;
    end

    local classIcon = createBlizButton(40, TargetFrame);
    classIcon:SetPoint("topleft", 115, -3); -- no pixel fix since align to bliz mod
    RaiseFrameLevel(classIcon);
    classIcon.artworkTexture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);

    -- inspect target when click
    classIcon:SetScript("OnMouseDown", function(self, button)
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

    classIcon.onChangeTarget = function(self)
        local unit = "target";
        if UnitIsPlayer(unit) then
            local unitClass = select(2, UnitClass(unit));
            self.artworkTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
            self:Show();
        else
            self:Hide();
        end
    end;

    classIcon:RegisterEvent("PLAYER_TARGET_CHANGED");
    classIcon:SetScript("OnEvent", classIcon.onChangeTarget);

    classIcon:onChangeTarget();
end);
