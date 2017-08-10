T.ask("resource", "widget.Color").answer("widget.Div", function(res, Color)

    local FRAME_LEVEL_MAJOR = {
        "BACKGROUND",
        "LOW",
        "MEDIUM",
        "HIGH",
        "DIALOG",
        "FULLSCREEN",
        "FULLSCREEN_DIALOG",
        "TOOLTIP"
    };

    local p = {};

    function p.addBackgroundAndBorder(view, border, extended)
        border = border or 0;
        extended = extended or 0;

        local config = {
            tile = false,
            tileSize = 0,
            bgFile = res.texture.SQUARE,
            edgeFile = res.texture.SQUARE,
            edgeSize = border,
            insets = {
                left    = -extended,
                right   = -extended,
                top     = -extended,
                bottom  = -extended
            },
        };
        if border <= 0 then
            config.edgeFile = nil;
            config.edgeSize = 0;
        end
        view:SetBackdrop(config);
        return view;
    end

    function p.addGlow(view, gap, extended)
        extended = extended or 0;
        if extended > 0 then
            -- 边框与光晕都源于backdrop->edgeFile，因此必须再造一个frame
            -- 光晕的浮动效果暂时就不要想了
            local glow = CreateFrame("Frame", nil, view, nil);
            glow:SetBackdrop({
                edgeFile = res.texture.GLOW1,
                edgeSize = extended,
            });
            local offset = gap + extended;
            glow:SetBackdropBorderColor(Color.toVertex("white"))
            glow:SetPoint("TOPLEFT", -offset, offset);
            glow:SetPoint("BOTTOMRIGHT", offset, -offset);
            view.glow = glow;
        end
        return view;
    end

    function p.setBackgroundColor(view, color)
        view:SetBackdropColor(Color.toVertex(color));
    end

    function p.setBorderColor(view, color)
        view:SetBackdropBorderColor(Color.toVertex(color));
    end

    function p.setForegroundColor(view, color)
        view.foreground:SetVertexColor(Color.toVertex(color));
    end

    function p.setGlowColor(view, color)
        view.glow:SetBackdropBorderColor(Color.toVertex(color));
    end

    function p.setGlowShown(view, enabled)
        if enabled then
            view.glow:Show();
        else
            view.glow:Hide();
        end
    end

    function p.setZ(view, major, minor)
        view:SetFrameStrata(FRAME_LEVEL_MAJOR[major + 1]);
        view:SetFrameLevel(minor + 1);
        if view.glow then
            view.glow:SetFrameStrata(FRAME_LEVEL_MAJOR[major + 1]);
            view.glow:SetFrameLevel(minor);
        end
    end

    return {
        p = p,
    }
end);
