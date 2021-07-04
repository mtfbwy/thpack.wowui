-- team fortress styled scoreboard for wow battleground

-- alliance color: 0.62, 0.8, 0.98
-- horde color: 1, 0.25, 0.2
-- banner: 368 * 30
-- vertical rule: 2 * 370
-- board: 348 * 400
-- horizontal: 20 + 348 + 9 + 2 + 9 + 348 + 20

local Placer = {};

function Placer.createScoreboardView()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetFrameStrata("DIALOG");
    f:SetPoint("CENTER");
    f:SetSize(756, 400);

    local bg = f:CreateTexture(nil, "BACKGROUND");
    bg:SetColorTexture(0, 0, 0, 0.4);
    bg:SetAllPoints();

    local allianceBanner = Placer.createBannerView(f, "alliance");
    allianceBanner:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 8);
    f.allianceBanner = allianceBanner;

    local hordeBanner = Placer.createBannerView(f, "horde");
    hordeBanner:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, 8);
    f.hordeBanner = hordeBanner;

    local vr = f:CreateTexture(nil, "BACKGROUND");
    vr:SetColorTexture(0, 0, 0, 1);
    vr:SetPoint("TOP", 0, -12);
    vr:SetPoint("BOTTOM", 0, 18);
    vr:SetWidth(2);

    local allianceBoardView = Placer.createBoardView(f, "alliance");
    allianceBoardView:SetPoint("TOPLEFT", 20, 0);
    f.allianceBoardView = allianceBoardView;

    local hordeBoardView = Placer.createBoardView(f, "horde");
    hordeBoardView:SetPoint("TOPRIGHT", -20, 0);
    f.hordeBoardView = hordeBoardView;

    local playerIndicator = f:CreateTexture(nil, "BACKGROUND");
    playerIndicator:SetColorTexture(1, 1, 1, 0.4)
    playerIndicator:SetSize(348, 22);
    playerIndicator:Hide();
    f.playerIndicator = playerIndicator;

    return f;
end

function Placer.createBannerView(scoreboard, faction)
    local f = CreateFrame("Frame", nil, scoreboard, nil);
    f:SetSize(368, 30);

    local bgTexture = f:CreateTexture(nil, "BACKGROUND");
    bgTexture:SetAllPoints();

    local titleText = f:CreateFontString(nil , "MEDIUM");
    titleText:SetFont(STANDARD_TEXT_FONT, 50);
    titleText:SetVertexColor(0.93, 0.89, 0.78);

    local numPlayersText = f:CreateFontString(nil, "MEDIUM");
    numPlayersText:SetFont(STANDARD_TEXT_FONT, 16);
    numPlayersText:SetJustifyH("LEFT");
    numPlayersText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, 3);
    f.numPlayersText = numPlayersText;

    local numKillsText = f:CreateFontString(nil, "MEDIUM");
    numKillsText:SetFont(DAMAGE_TEXT_FONT, 24);
    f.numKillsText = numKillsText;

    local scoreText = f:CreateFontString(nil, "MEDIUM");
    scoreText:SetFont(STANDARD_TEXT_FONT, 40);
    scoreText:SetVertexColor(0.93, 0.89, 0.78);
    f.scoreText = scoreText;

    if (faction == "alliance") then
        bgTexture:SetColorTexture(0.62, 0.8, 0.98, 0.4);
        titleText:SetJustifyH("LEFT");
        titleText:SetText("Alliance");
        titleText:SetPoint("BOTTOMLEFT", 20, 12);
        numKillsText:SetJustifyH("RIGHT");
        numKillsText:SetPoint("BOTTOMRIGHT", -4, 3);
    elseif (faction == "horde") then
        bgTexture:SetColorTexture(1, 0.25, 0.2, 0.4);
        titleText:SetJustifyH("RIGHT");
        titleText:SetText("Horde");
        titleText:SetPoint("BOTTOMRIGHT", -20, 12);
        numKillsText:SetJustifyH("LEFT");
        numKillsText:SetPoint("BOTTOMLEFT", 4, 3);
    end

    return f;
end

function Placer.createBoardView(scoreboard, faction)
    local f = CreateFrame("Frame", nil, scoreboard, nil);
    f:SetSize(348, 400);

    local hr = f:CreateTexture(nil, "BACKGROUND");
    hr:SetColorTexture(1, 1, 1, 0.4);
    hr:SetPoint("TOP", 0, -27);
    hr:SetSize(348, 1);

    local header = Placer.createRowView(f);
    header:SetPoint("BOTTOMLEFT", hr, "BOTTOMLEFT", 0, 2);
    header.seqRankText:SetFont(STANDARD_TEXT_FONT, 12);
    header.seqRankText:SetText("#");
    --header.classTexture:SetTexture("Interface/Icons/INV_Banner_01");
    header.classTexture:SetTexture(nil);
    header.nameText:SetFont(STANDARD_TEXT_FONT, 12);
    header.nameText:SetText("Name");
    header.rankText:SetFont(STANDARD_TEXT_FONT, 12);
    header.rankText:SetText("R");
    header.killsText:SetFont(STANDARD_TEXT_FONT, 12);
    header.killsText:SetText("K");
    header.deathsText:SetFont(STANDARD_TEXT_FONT, 12);
    header.deathsText:SetText("D");
    header.hkText:SetFont(STANDARD_TEXT_FONT, 12);
    header.hkText:SetText("hK");

    f.faction = faction;
    f.dy = -25;
    f.rowViews = {};

    return f;
end

function Placer.createRowView(boardView, faction)
    local r, g, b;
    if (faction == "alliance") then
        r, g, b = 0.62, 0.8, 0.98;
    elseif (faction == "horde") then
        r, g, b = 1, 0.25, 0.2;
    else
        r, g, b = 0.93, 0.89, 0.78;
    end
    local f = CreateFrame("Frame", nil, boardView, nil);
    f:SetSize(348, 22);

    local rowIndex = array.size(boardView.rowViews)

    local seqRankText = f:CreateFontString(nil, "MEDIUM");
    seqRankText:SetFont(DAMAGE_TEXT_FONT, 12);
    seqRankText:SetJustifyH("RIGHT");
    seqRankText:SetVertexColor(r, g, b);
    seqRankText:SetPoint("BOTTOMLEFT", 2, 0);
    seqRankText:SetWidth(20);
    f.seqRankText = seqRankText;

    local classTexture = f:CreateTexture(nil, "MEDIUM");
    --classTexture:SetTexture("Interface/WorldStateFrame/Icons-Classes");
    classTexture:SetPoint("BOTTOMLEFT", 32, -1);
    classTexture:SetSize(16, 16);
    f.classTexture = classTexture;

    local nameText = f:CreateFontString(nil, "MEDIUM");
    nameText:SetFont(STANDARD_TEXT_FONT, 16);
    nameText:SetJustifyH("LEFT");
    nameText:SetVertexColor(r, g, b);
    nameText:SetPoint("BOTTOMLEFT", 48, 0);
    f.nameText = nameText;

    local rankText = f:CreateFontString(nil, "MEDIUM");
    rankText:SetFont(DAMAGE_TEXT_FONT, 14);
    rankText:SetJustifyH("LEFT");
    rankText:SetVertexColor(r, g, b);
    rankText:SetPoint("BOTTOMRIGHT", -88, 0);
    rankText:SetWidth(28);
    f.rankText = rankText;

    local killsText = f:CreateFontString(nil, "MEDIUM");
    killsText:SetFont(DAMAGE_TEXT_FONT, 16);
    killsText:SetJustifyH("RIGHT");
    killsText:SetVertexColor(r, g, b);
    killsText:SetPoint("BOTTOMRIGHT", -66, 0);
    killsText:SetWidth(24);
    f.killsText = killsText;

    local deathsText = f:CreateFontString(nil, "MEDIUM");
    deathsText:SetFont(DAMAGE_TEXT_FONT, 16);
    deathsText:SetJustifyH("RIGHT");
    deathsText:SetVertexColor(r, g, b);
    deathsText:SetPoint("BOTTOMRIGHT", -38, 0);
    deathsText:SetWidth(24);
    f.deathsText = deathsText;

    local hkText = f:CreateFontString(nil, "MEDIUM");
    hkText:SetFont(DAMAGE_TEXT_FONT, 16);
    hkText:SetJustifyH("RIGHT");
    hkText:SetVertexColor(r, g, b);
    hkText:SetPoint("BOTTOMRIGHT", -4, 0);
    hkText:SetWidth(24);
    f.hkText = hkText;

    return f;
end

function Placer.getOrCreateRowView(boardView, index)
    while (array.size(boardView.rows) <= index) do
        local rowView = Placer.createRowView(boardView, boardView.faction);
        rowView:SetPoint("TOPLEFT", boardView, "TOPLEFT", 0, boardView.dy - 22 * array.size(boardView.rows));
        array.insert(boardView.rowViews, rowView);
    end
    return boardView.rowViews[index];
end

--------

function Placer.refreshScoreboard(scoreboard)
    local numScores = GetNumBattlefieldScores();
    local numAlliances = 0;
    local numHordes = 0;
    local numAllianceKills = 0;
    local numHordeKills = 0;
    for i = 1, numScores do
        local name, kills, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone, bgRating = GetBattlefieldScore(i);
        if (faction) then
            local isPlayer = name == UnitName("player");
            local pvpRank = select(2, GetPVPRankInfo(rank, faction));
            if (faction == 0) then
                -- horde
                numHordes = numHordes + 1;
                numHordeKills = numHordeKills + kills;
                local rowView;
                if (numHordes <= 15) then
                    rowView = Placer.getOrCreateRowView(scoreboard.hordeBoardView, numHordes);
                elseif (isPlayer) then
                    rowView = Placer.getOrCreateRowView(scoreboard.hordeBoardView, 15);
                end
                if (rowView) then
                    Placer.refreshRowView(rowView,
                            numHordes, name, classToken, pvpRank, kills, deaths, honorableKills);
                    if (isPlayer) then
                        local indicator = scoreboard.playerIndicator;
                        indicator:ClearAllPoints();
                        indicator:SetPoint("BOTTOMLEFT", rowView, "BOTTOMLEFT", 0, -4);
                        indicator:Show();
                    end
                end
            elseif (faction == 1) then
                -- alliance
                numAlliances = numAlliances + 1;
                numAllianceKills = numAllianceKills + kills;
                local rowView;
                if (numAlliances <= 15) then
                    rowView = Placer.getOrCreateRowView(scoreboard.allianceBoardView, numAlliances);
                elseif (isPlayer) then
                    rowView = Placer.getOrCreateRowView(scoreboard.allianceBoardView, 15);
                end
                if (rowView) then
                    Placer.refreshRowView(rowView,
                            numAlliances, name, classToken, pvpRank, kills, deaths, honorableKills);
                    if (isPlayer) then
                        local indicator = scoreboard.playerIndicator;
                        indicator:ClearAllPoints();
                        indicator:SetPoint("BOTTOMLEFT", rowView, "BOTTOMLEFT", 0, -4);
                        indicator:Show();
                    end
                end
            end
        end
    end
    scoreboard.allianceBanner.numPlayersText:SetText(numAlliances .. " player(s)");
    scoreboard.allianceBanner.numKillsText:SetText(numAllianceKills);
    scoreboard.hordeBanner.numPlayersText:SetText(numHordes .. " player(s)");
    scoreboard.hordeBanner.numKillsText:SetText(numHordeKills);

    -- TODO update alliance vs horde scores
end

function Placer.refreshRowView(rowView, seqRank, name, classToken, pvpRank, k, d, hk)
    local MAX_ROWS = 15;

    rowView.seqRankText:SetText(seqRank);
    if (classToken) then
        rowView.classTexture:SetTexture("Interface/Glues/CharacterCreate/UI-CharacterCreate-Classes");
        rowView.classTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classToken]));
    else
        rowView.classTexture:SetTexture(nil);
    end
    rowView.nameText:SetText(name);
    rowView.rankText:SetText(pvpRank and ("R" .. pvpRank));
    rowView.killsText:SetText(k);
    rowView.deathsText:SetText(d);
    rowView.hkText:SetText(hk);
end

function Placer.resetScoreboard(scoreboard)
    Placer.resetBoardView(scoreboard.allianceBoardView);
    Placer.resetBoardView(scoreboard.hordeBoardView);
    scoreboard.playerIndicator:Hide();
end

function Placer.resetBoardView(boardView)
    local numRowViews = array.size(boardView.rowViews);
    for i = 1, numRowViews do
        local rowView = Placer.getOrCreateRowView(boardView, i);
        Placer.refreshRowView(rowView, nil, nil, nil, nil, nil, nil, nil);
    end
end

--------

local scoreboard = Placer.createScoreboardView();
scoreboard:Hide();

scoreboard:RegisterEvent("PLAYER_ENTERING_WORLD");
scoreboard:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
scoreboard:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance();
        if (inInstance and instanceType == "pvp") then
            Placer.resetScoreboard(self);
        end
    elseif (event == "UPDATE_BATTLEFIELD_SCORE") then
        Placer.refreshScoreboard(scoreboard);
    end
end);

function hideScoreboard()
    scoreboard:Hide();
end

function showScoreboard()
    scoreboard:Show();
    RequestBattlefieldScoreData();
end
