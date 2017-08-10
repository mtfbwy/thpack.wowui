T.ask("widget.Color").answer("widget.Image", function(Color)

    local IMAGE_LEVEL_MAJOR = {
        "BACKGROUND",
        "BORDER",
        "ARTWORK",
        "OVERLAY",
        "HIGHLIGHT",
    };

    local function createImage(parent, major, minor)
        return parent:CreateTexture(nil, IMAGE_LEVEL_MAJOR[major], nil, minor);
    end

    local function createCroppedImage(...)
        local image = createImage(...);
        image:SetTexCoord(5/64, 59/64, 5/64, 59/64);
        return image;
    end

    local p = {};

    function p.setImage(image, path)
        image:SetTexture(path);
    end

    function p.setCroppedImage(image, path)
        image:SetTexCoord(5/64, 59/64, 5/64, 59/64);
        image:SetTexture(path);
    end

    function p.setUnitClassImage(image, unit)
        local unitClass = select(2, UnitClass(unit));
        if CLASS_ICON_TCOORDS[unitClass] == nil then
            return
        end
        image:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]));
        local PATH = "Interface/WorldStateFrame/Icons-Classes";
        if image:GetTexture() ~= PATH then
            image:SetTexture(PATH);
        end
    end

    function p.setBlackout(image, enabled)
        image.m = image.m or {};
        image.m.blackout = enabled;
        image:SetDesaturated(enabled);
    end

    function p.setRedout(image, enabled)
        image.m = image.m or {};
        image.m.redout = enabled;
        image:SetVertexColor(Color.toVertex(enabled and "red" or "white"));
    end

    function p.toggleRedout(image)
        p.setRedout(image, not image.m.redout);
    end

    return {
        p = p,
        createImage = createImage,
        createCroppedImage = createCroppedImage,
    };
end);
