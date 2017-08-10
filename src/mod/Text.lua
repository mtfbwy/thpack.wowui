T.ask("widget.Color").answer("widget.Text", function(Color)

    local function createText(parent, font, size)
        local text = parent:CreateFontString();
        --fs:SetFont(res.font.COMBAT, 32 * env.on1024, "OUTLINE");
        text:SetFont(font, size, "OUTLINE");
        return text;
    end

    local p = {};

    function p.setAlign(text, horizontal, vertical)
        if horizontal then
            text:SetJustifyH(horizontal);
        end
        if vertical then
            text:SetJustifyV(vertical);
        end
    end

    function p.setColor(text, color)
        text:SetTextColor(Color.toVertex(color));
    end

    return {
        p = p,
        createText = createText,
    };
end);
