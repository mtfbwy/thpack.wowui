P.ask("Env").answer("tweakErrorsFrame", function(Env)
    UIErrorsFrame:ClearAllPoints();
    UIErrorsFrame:SetPoint("TOP", 0, -40 * Env.dip);
end);
