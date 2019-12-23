A = A or {};

-- TargetFrame_CheckFaction()
-- UnitIsEnemy()
-- UnitIsFriend()
-- UnitIsDead()
-- UnitIsGhose()
-- UnitReaction()
-- UnitSelectionColor()
A.getUnitNameColorByUnit = A.getUnitNameColorByUnit or function(unit)
    if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
        -- kind of bright gray
        return Color.pick("#999999");
    end

    -- tuned color as text fore color
    local red = Color.fromVertex(0.8, 0.2, 0.2);
    local green = Color.fromVertex(0.2, 0.6, 0.2);
    local blue = Color.pick("#5582fa");
    local yellow = Color.fromVertex(0.6, 0.6, 0.2);

    if (UnitIsPlayer(unit)) then
        -- horde against alliance
        if (UnitCanAttack(unit, "player")) then
            if (UnitCanAttack("player", unit)) then
                return red;
            else
                -- only he can attack! (in enemy-occupied territory)
                return Color.pick("#ff4500");
            end
        elseif (UnitCanAttack("player", unit)) then
            -- i feel safe
            return yellow;
        else
            -- friend
            if (UnitIsPVP(unit)) then
                return green;
            else
                return blue;
            end
        end
    else
        -- npc or pet or summonee
        if (UnitIsEnemy("player", unit)) then
            return red;
        elseif (UnitIsFriend("player", unit)) then
            return green;
        else
            return yellow;
        end
    end
end;
