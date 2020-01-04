(function()

    function createBlizButton(dots, parent, template)
        local button = CreateFrame("button", nil, parent, template);
        button:SetSize(dots, dots);

        local highlightTexture = button:CreateTexture(nil, "highlight");
        highlightTexture:SetTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]]);
        highlightTexture:SetPoint("topleft", dots * -1/64, dots * 1/64);
        highlightTexture:SetPoint("bottomright", dots * -1/64, dots * 1/64);
        button:SetHighlightTexture(highlightTexture);

        local backgroundTexture = button:CreateTexture(nil, "background");
        backgroundTexture:SetTexture([[Interface\Minimap\UI-Minimap-Background]]);
        backgroundTexture:SetVertexColor(0, 0, 0, 0.6);
        backgroundTexture:SetPoint("topleft", dots * 4/64, "topleft", dots * -4/64);
        backgroundTexture:SetPoint("bottomright", dots * -4/64, "topleft", dots * 4/64);

        local borderTexture = button:CreateTexture(nil, "overlay");
        borderTexture:SetTexture([[Interface\Minimap\MiniMap-TrackingBorder]]);
        borderTexture:SetTexCoord(0, 38/64, 0, 38/64);
        borderTexture:SetAllPoints();

        local artworkTexture = button:CreateTexture(nil, "artwork");
        artworkTexture:SetPoint("topleft", dots * 12/64, dots * -10/64);
        artworkTexture:SetPoint("bottomright", dots * -12/64, dots * 14/64);
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
                    InspectFrameCloseButton:Click();
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
end)();
