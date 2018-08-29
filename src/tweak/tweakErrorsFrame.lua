P.ask("res").answer("tweakErrorsFrame", function(res)
    UIErrorsFrame:ClearAllPoints();
    UIErrorsFrame:SetPoint("TOP", 0, -40 * res.dip);
end);
