T.ask("env").answer("widget.Button", function(env)

    local p = {};

    -- play visual effect instead of true size change to avoid taint
    function p.setPressed(button, pressed)
        local EXTENDED = -4 * env.pixel;
        button.m = button.m or {};
        if button.m.pressed == nil then
            button.m.width = button:GetWidth();
            button.m.height = button:GetHeight();
        end
        button.m.pressed = pressed or false;
        button:SetSize(
            pressed and button.m.width + EXTENDED or button.m.width,
            pressed and button.m.height + EXTENDED or button.m.height);
    end

    return {
        p = p,
    };
end);
