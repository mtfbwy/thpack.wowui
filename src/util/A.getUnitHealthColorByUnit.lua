A = A or {};

A.getUnitHealthColorByUnit = A.getUnitHealthColorByUnit or function(unit)
    local currentHealth = UnitHealth(unit);
    local maxHealth = UnitHealthMax(unit);
    local healthRate = currentHealth / maxHealth;
    return A.getUnitHealthColorByRate(healthRate);
end;

A.getUnitHealthColorByRate = A.getUnitHealthColorByRate or function(healthRate)
    -- color gradient is difficult to distinguish
    if (healthRate < 0.2) then
        -- 斩杀线
        return Color.pick("#ff0000");
    elseif (healthRate < 0.4) then
        return Color.pick("#ffff00");
    else
        return Color.pick("#ffffff");
    end
end;

A.getUnitManaTypeColorByUnit = A.getUnitManaTypeColorByUnit or function(unit)
    local typ = UnitPowerType(unit);
    if (typ == 0) then
        return Color.pick("royalblue");
    elseif (typ == 1) then
        return Color.pick("firebrick");
    elseif (typ == 2) then
        return Color.pick("coral");
    elseif (typ == 3) then
        return Color.pick("gold");
    elseif (typ == 6) then
        return Color.pick("turquoise");
    else
        return Color.pick("white");
    end
end;
