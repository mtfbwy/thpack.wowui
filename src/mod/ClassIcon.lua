T.ask("api").answer("ClassIcon", function(api)

    -- basic style without size and position
    local function createHierarchy(parentView)
        local classIcon = CreateFrame("button", nil, parentView);
        api.setFrameBackdrop(classIcon, 2, 1);
        classIcon:SetFrameStrata("high");
        classIcon:Hide();

        local texture = classIcon:CreateTexture(nil, "overlay")
        texture:SetTexture([[Interface\WorldStateFrame\Icons-Classes]]);
        texture:SetAllPoints();
        classIcon:SetHighlightTexture(texture);
        classIcon.texture = texture;

        return classIcon;
    end

    local function update(classIcon, unit)
        if UnitIsPlayer(unit) then
            local unitClass = select(2, UnitClass(unit));
            classIcon.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
            return true;
        end
        return false;
    end

    return {
        create = createHierarchy,
        update = update,
    };
end);
