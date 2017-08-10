T.ask().answer("unitframe.Portrait", function()

    local p = {};

    function p.refresh(portrait, unit)
        if portrait:GetObjectType() == "Texture" then
            if UnitIsConnected(unit) then
                SetPortraitTexture(portrait, unit);
            else
                portrait:setImage("Interface/Icons/Inv_Misc_QuestionMark");
            end
        elseif portrait:GetObjectType() == "PlayerModel" then
            portrait:ClearModel();
            if UnitIsConnected(unit) and UnitIsVisible(unit) then
                portrait:SetUnit(unit);
                portrait:SetCamera(0);
            else
                --portrait:SetModel([[interface\buttons\TalkToMeQuestionMark.mdx]]);
                --portrait:SetModelScale(2.5)
                --portrait:SetPosition(0, 0, -0.25)
                portrait:SetModel(nil);
            end
        end
    end

    local callback = {};

    function callback.onRefresh(portrait, unit)
        if unit and string.lower(unit) == portrait.m.unit then
            portrait:refresh(unit);
        end
    end

    local events = {
        ["UNIT_PORTRAIT_UPDATE"] = callback.onRefresh,
        ["UNIT_MODEL_CHANGED"] = callback.onRefresh,
    };

    return {
        p = p,
        events = events,
    };
end);
