A = A or {};

A.getColoredString = A.getColoredString or function(color, s)
    return string.format("|cff%06x%s|r", color:toInt24(), s);
end;
