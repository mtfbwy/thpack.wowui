T.ask("env").answer("tweakErrorsFrame", function(env)
    UIErrorsFrame:ClearAllPoints();
    UIErrorsFrame:SetPoint("top", 0, -40 * env.on1024);
end);
