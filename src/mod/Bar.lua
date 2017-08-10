T.ask("widget.Div").answer("widget.Bar", function(Div)

    local BLIZ_BAR_TEXTURE = "Interface/TargetingFrame/UI-StatusBar";

    local function createBar(parent)
        local bar = CreateFrame("StatusBar", nil, parent, nil);
        table.merge(bar, Div.p);
        bar:addBackgroundAndBorder(0, 0);
        bar:setBackgroundColor("#444444");
        bar:setBorderColor("#444444");
        bar:SetStatusBarTexture(BLIZ_BAR_TEXTURE);
        bar:SetMinMaxValues(0, 1);
        bar:SetValue(0.7749);
        return bar;
    end

    return {
        createBar = createBar,
    };
end);
