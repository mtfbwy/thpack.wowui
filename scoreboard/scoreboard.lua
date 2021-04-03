local addonName, addon = ...;

local NameList = {};

function NameList.newList(parent, r, g, b)
    local f = CreateFrame("Frame", nil, parent, nil);
    f.WIDTH = 348;
    f.ROW_HEIGHT = 22;
    f.R = r;
    f.G = g;
    f.B = b;
    f:SetSize(f.WIDTH, 400);

    local playerIndicator = f:CreateTexture(nil, "BACKGROUND");
    playerIndicator:SetColorTexture(1, 1, 1, 0.4)
    playerIndicator:SetSize(f.WIDTH, f.ROW_HEIGHT);
    playerIndicator:Hide();
    f.playerIndicator = playerIndicator;

    local hr = f:CreateTexture(nil, "BACKGROUND");
    hr:SetColorTexture(1, 1, 1, 0.4);
    hr:SetPoint("TOP", 0, -27);
    hr:SetSize(f.WIDTH, 1);

    local header = NameList.newRow(f, f.WIDTH, f.ROW_HEIGHT, 0.93, 0.89, 0.78);
    header:SetPoint("BOTTOMLEFT", hr, "BOTTOMLEFT", 0, 2);
    header.indexText:SetFont(STANDARD_TEXT_FONT, 12);
    header.indexText:SetText("#");
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

    f.rows = {};

    return f;
end

function NameList.reset(self)
    local numRows = #self.rows;
    for i = 1, numRows do
        local row = NameList.getRow(self, i);
        NameList.setRowData(row, nil, nil, nil, nil, nil, nil, nil);
    end
    self.playerIndicator:Hide();
end

function NameList.getRow(self, index)
    while (#self.rows < index) do
        local row = NameList.newRow(self, self.WIDTH, self.ROW_HEIGHT, self.R, self.G, self.B);
        row:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -25 - #self.rows * 22);
        table.insert(self.rows, row);
    end
    return self.rows[index];
end

function NameList.setRowData(self, index, name, classToken, rank, k, d, hk)
    local MAX_ROWS = 15;

    local isPlayer = name == UnitName("player");
    local row;
    if (not index) then
        return;
    if (index <= MAX_ROWS) then
        row = NameList.getRow(self, index);
    elseif (isPlayer) then
        row = NameList.getRow(self, MAX_ROWS);
    else
        return;
    end

    row.indexText:SetText(index);
    if (classToken) then
        row.classTexture:SetTexture("Interface/Glues/CharacterCreate/UI-CharacterCreate-Classes");
        row.classTexture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classToken]));
    else
        row.classTexture:SetTexture(nil);
    end
    row.nameText:SetText(name);
    row.rankText:SetText(rank and ("R" .. rank));
    row.killsText:SetText(k);
    row.deathsText:SetText(d);
    row.hkText:SetText(hk);

    if (isPlayer) then
        local indicator = row:GetParent().playerIndicator;
        indicator:ClearAllPoints();
        indicator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, -4);
        indicator:Show();
    end
end

function NameList.newRow(self, width, height, r, g, b)
    local row = CreateFrame("Frame", nil, self, nil);
    row:SetSize(width, height);

    local indexText = row:CreateFontString(nil, "MEDIUM");
    indexText:SetFont(DAMAGE_TEXT_FONT, 12);
    indexText:SetJustifyH("RIGHT");
    indexText:SetVertexColor(r, g, b);
    indexText:SetPoint("BOTTOMLEFT", 2, 0);
    indexText:SetWidth(20);
    row.indexText = indexText;

    local classTexture = row:CreateTexture(nil, "MEDIUM");
    --classTexture:SetTexture("Interface/WorldStateFrame/Icons-Classes");
    classTexture:SetPoint("BOTTOMLEFT", 32, -1);
    classTexture:SetSize(16, 16);
    row.classTexture = classTexture;

    local nameText = row:CreateFontString(nil, "MEDIUM");
    nameText:SetFont(STANDARD_TEXT_FONT, 16);
    nameText:SetJustifyH("LEFT");
    nameText:SetVertexColor(r, g, b);
    nameText:SetPoint("BOTTOMLEFT", 48, 0);
    row.nameText = nameText;

    local rankText = row:CreateFontString(nil, "MEDIUM");
    rankText:SetFont(DAMAGE_TEXT_FONT, 14);
    rankText:SetJustifyH("LEFT");
    rankText:SetVertexColor(r, g, b);
    rankText:SetPoint("BOTTOMRIGHT", -88, 0);
    rankText:SetWidth(28);
    row.rankText = rankText;

    local killsText = row:CreateFontString(nil, "MEDIUM");
    killsText:SetFont(DAMAGE_TEXT_FONT, 16);
    killsText:SetJustifyH("RIGHT");
    killsText:SetVertexColor(r, g, b);
    killsText:SetPoint("BOTTOMRIGHT", -66, 0);
    killsText:SetWidth(24);
    row.killsText = killsText;

    local deathsText = row:CreateFontString(nil, "MEDIUM");
    deathsText:SetFont(DAMAGE_TEXT_FONT, 16);
    deathsText:SetJustifyH("RIGHT");
    deathsText:SetVertexColor(r, g, b);
    deathsText:SetPoint("BOTTOMRIGHT", -38, 0);
    deathsText:SetWidth(24);
    row.deathsText = deathsText;

    local hkText = row:CreateFontString(nil, "MEDIUM");
    hkText:SetFont(DAMAGE_TEXT_FONT, 16);
    hkText:SetJustifyH("RIGHT");
    hkText:SetVertexColor(r, g, b);
    hkText:SetPoint("BOTTOMRIGHT", -4, 0);
    hkText:SetWidth(24);
    row.hkText = hkText;

    return row;
end

addon.Scoreboard = {};
local Scoreboard = addon.Scoreboard;

function Scoreboard.newScoreboard()
    local f = CreateFrame("Frame", nil, UIParent, nil);
    f:SetFrameStrata("DIALOG");
    f:SetPoint("CENTER");
    f:SetSize(756, 400);

    local bg = f:CreateTexture(nil, "BACKGROUND");
    bg:SetColorTexture(0, 0, 0, 0.4);
    bg:SetAllPoints();

    local vr = f:CreateTexture(nil, "BACKGROUND");
    vr:SetColorTexture(0, 0, 0, 1);
    vr:SetPoint("TOP", 0, -12);
    vr:SetPoint("BOTTOM", 0, 18);
    vr:SetWidth(2);

    local allianceListFrame = NameList.newList(f, 0.62, 0.8, 0.98);
    allianceListFrame:SetPoint("TOPLEFT", 20, 0);
    f.allianceListFrame = allianceListFrame;

    local hordeListFrame = NameList.newList(f, 1, 0.25, 0.2);
    hordeListFrame:SetPoint("TOPRIGHT", -20, 0);
    f.hordeListFrame = hordeListFrame;

    f.allianceBanner = Scoreboard.newBanner(f, "alliance");
    f.hordeBanner = Scoreboard.newBanner(f, "horde");

    return f;
end

function Scoreboard.newBanner(self, faction)
    local banner = CreateFrame("Frame", nil, self, nil);
    banner:SetSize(368, 30);

    local bgTexture = banner:CreateTexture(nil, "BACKGROUND");
    bgTexture:SetAllPoints();

    local titleText = banner:CreateFontString(nil , "MEDIUM");
    titleText:SetFont(STANDARD_TEXT_FONT, 50);
    titleText:SetVertexColor(0.93, 0.89, 0.78);

    local numPlayersText = banner:CreateFontString(nil, "MEDIUM");
    numPlayersText:SetFont(STANDARD_TEXT_FONT, 16);
    numPlayersText:SetJustifyH("LEFT");
    numPlayersText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, 3);
    banner.numPlayersText = numPlayersText;

    local numKillsText = banner:CreateFontString(nil, "MEDIUM");
    numKillsText:SetFont(DAMAGE_TEXT_FONT, 24);
    banner.numKillsText = numKillsText;

    local scoreText = banner:CreateFontString(nil, "MEDIUM");
    scoreText:SetFont(STANDARD_TEXT_FONT, 40);
    scoreText:SetVertexColor(0.93, 0.89, 0.78);
    banner.scoreText = scoreText;

    if (faction == "alliance") then
        banner:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8);
        bgTexture:SetColorTexture(0.62, 0.8, 0.98, 0.4);
        titleText:SetJustifyH("LEFT");
        titleText:SetText("Alliance");
        titleText:SetPoint("BOTTOMLEFT", banner, "BOTTOMLEFT", 20, 12);
        numKillsText:SetJustifyH("RIGHT");
        numKillsText:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", -4, 3);
    elseif (faction == "horde") then
        banner:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 8);
        bgTexture:SetColorTexture(1, 0.25, 0.2, 0.4);
        titleText:SetJustifyH("RIGHT");
        titleText:SetText("Horde");
        titleText:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", -20, 12);
        numKillsText:SetJustifyH("LEFT");
        numKillsText:SetPoint("BOTTOMLEFT", banner, "BOTTOMLEFT", 4, 3);
    end

    return banner;
end

function Scoreboard.refresh(self)
    local numScores = GetNumBattlefieldScores();
    local numAlliances = 0;
    local numHordes = 0;
    local numAllianceKills = 0;
    local numHordeKills = 0;
    for i = 1, numScores do
        local name, kills, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone, bgRating = GetBattlefieldScore(i);
        if (faction) then
            rank = select(2, GetPVPRankInfo(rank, faction));
            if (faction == 0) then
                -- horde
                numHordes = numHordes + 1;
                numHordeKills = numHordeKills + kills;
                NameList.setRowData(self.hordeListFrame, numHordes, name, classToken, rank, kills, deaths, honorableKills);
            elseif (faction == 1) then
                -- alliance
                numAlliances = numAlliances + 1;
                numAllianceKills = numAllianceKills + kills;
                NameList.setRowData(self.allianceListFrame, numAlliances, name, classToken, rank, kills, deaths, honorableKills);
            end
        end
    end
    self.allianceBanner.numPlayersText:SetText(numAlliances .. " player(s)");
    self.allianceBanner.numKillsText:SetText(numAllianceKills);
    self.hordeBanner.numPlayersText:SetText(numHordes .. " player(s)");
    self.hordeBanner.numKillsText:SetText(numHordeKills);

    -- TODO update alliance vs horde scores
end

local scoreboard = Scoreboard.newScoreboard();
scoreboard:Hide();

scoreboard:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        local inInstance, instanceType = IsInInstance();
        if (inInstance and instanceType == "pvp") then
            NameList.reset(self.allianceListFrame);
            NameList.reset(self.hordeListFrame);
        end
    elseif (event == "UPDATE_BATTLEFIELD_SCORE") then
        Scoreboard.refresh(scoreboard);
    end
end)

scoreboard:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
scoreboard:RegisterEvent("PLAYER_ENTERING_WORLD");

function hideScoreboard()
    scoreboard:Hide();
end

function showScoreboard()
    scoreboard:Show();
    RequestBattlefieldScoreData();
end
