local CurrentVersion = 10082;	--last: 10080
-----------------------------------------------------------------

local function ApplyPatchFix(self)
    --Apply fix--
    --None in 1.0.8b
    return;
end

--[[
function Narci_ExtraInfoButton_OnClick(self)
    self:Disable();
    self.Text:SetText(NARCI_SPLASH_MESSAGE1_EXTRA_LINE);
    self:SetHeight(self.Text:GetHeight() + 16);
end
--]]

local FadeFrame = NarciAPI_FadeFrame;
local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

--[[
local function Narci_TryItNow_OnClick(self)
    local text;
    if not self.HasEnabled then
        text  = self.enabledText;   --"|cff7cc576"
    else
        text  = self.disabledText;
    end
    self.Text:SetText(text);
    self:SetHeight(self.Text:GetHeight() + 4);
    self:SetScript("OnLeave", function() return; end);
    self:SetScript("OnEnter", function() return; end);
end

function Narci_TryItNow_DressingRoom(self)
    Narci_TryItNow_OnClick(self);
    if NarcissusDB.DressingRoom then
        Narci_DressingRoomSwitch_OnClick(Narci_DressingRoomSwitch);
    end
end

function Narci_Splash_CameraSafeMode_OnShow(self)
    if IsAddOnLoaded("DynamicCam") then
        self.HasEnabled = false;
        if NarcissusDB.CameraSafeMode then
            Narci_CameraSafeSwitch_OnClick(Narci_CameraSafeSwitch);
        end
        self.Text:SetText(NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT);
    else
        self.HasEnabled = true;
        NarcissusDB.CameraSafeMode = true;
        self.Text:SetText(NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT);
    end
end

function Narci_TryItNow_CameraSafeMode(self)
    local state = self.HasEnabled;
    local text;
    if not state then
        text  = self.enabledText;   --"|cff7cc576"
    else
        text  = self.disabledText;
    end
    Narci_CameraSafeSwitch_OnClick(Narci_CameraSafeSwitch);
    self.Text:SetText(text);
    self:SetHeight(self.Text:GetHeight() + 4);
    self:SetScript("OnLeave", function() return; end);
    self:SetScript("OnEnter", function() return; end);
end


-----------------------------------------------------------------
local Backdrops = {
    [1] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop1",
    [2] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop2",
    [3] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop3",
    [4] = "Interface/AddOns/Narcissus/Art/Splash/Backdrop4",
};
local BackdopIndex = 3;

function Narci_Splash_ChangePhoto()
    local frame = Narci_Splash;
    if not frame.ShowFront then
        frame.BackdropFront:SetTexture(Backdrops[BackdopIndex]);
        --print("front #"..BackdopIndex)
    else
        frame.Backdrop:SetTexture(Backdrops[BackdopIndex]);
        --print("back #"..BackdopIndex)
    end
    if BackdopIndex >= #Backdrops then
        BackdopIndex = 1;
    else
        BackdopIndex = BackdopIndex + 1;
    end
end
--]]

--New Splash--
------------------------------------------------------------------
local playerOffsetX = 0;
local playerOffsetZ = -0.5;
local playerModelInfo;
local PI = math.pi;
local facing = -PI/2.5;
local ModelOffsets = {
    --[raceID] = {Eye male's, female's, male's Z, female's Z}
    [1]  = {1.6, 1.5, -0.58, -0.6},		    -- Human
    [2]  = {1.6, 1.5, -0.54, -0.6},		    -- Orc bow
    [3]  = {1.7, 1.5, -0.3, -0.4},		    -- Dwarf
    [4]  = {1.6, 1.5, -0.67, -0.65},         -- Night Elf
    [5]  = {1.6, 1.5, -0.7, -0.54},		    -- UD **Changed
    [6]  = {1.9, 1.7, -0.6, -0.6},		    -- Tauren
    [7]  = {1.7, 1.7, -0.1, -0.2},		    -- Gnome
    [8]  = {1.6, 1.5, -0.72, -0.6},		    -- Troll  0.9414 too high?  
    [9]  = {1.8, 1.8, -0.32, -0.25},		-- Goblin
    [10] = {1.45, 1.4, -0.58, -0.6},        -- Blood Elf
    [11] = {1.6, 1.5, -0.6, -0.65},		    -- Goat
    [22] = {1.75, 1.5, -0.6, -0.6},         -- Worgen
    [24] = {1.85, 1.7, -0.42, -0.58},		-- Pandaren
    [27] = {1.45, 1.4, -0.72, -0.5},		-- Nightborne
    --[29] = {1, },             -- Void Elf
    --[28] = {490, 491},		-- Highmountain Tauren
    --[30] = {488, 489},		-- Lightforged Draenei
    [31] = {1.6, 1.5, -0.85, -0.76},		    -- Zandalari
    [32] = {1.7, 1.65, -0.7, -0.65},		-- Kul'Tiran
    --[34] = {499, nil},		-- Dark Iron Dwarf
    [35] = {1.7, 1.5, -0.3, -0.2},         -- Vulpera
    --[36] = {495, 498},		-- Mag'har
    --[37] = {929, 931},        -- Mechagnome
}

local AnimationPresets = {
    --Patch 8.3.0 Narcissus 1.0.8
    --[raceID] = {male's, female's}
    --/run SetSplashModelAnimation()
    [1]  = {860, 1240},		    -- Human
    [2]  = {860, 988},		    -- Orc bow
    [3]  = {860, 860},		    -- Dwarf
    [4]  = {860, 52},           -- Night Elf
    [5]  = {944, 860},		    -- UD
    [6]  = {944, 1330},		    -- Tauren
    [7]  = {940, 944},		    -- Gnome
    [8]  = {1330, 860},		    -- Troll
    [9]  = {944, 944},		    -- Goblin
    [10] = {940, 988},          -- Blood Elf
    [11] = {988, 988},		    -- Goat
    [22] = {944, 988},          -- Worgen
    [24] = {732, 1448},		    -- Pandaren
    [27] = {988, 944},  		-- Nightborne
    [31] = {988, 860},		    -- Zandalari
    [32] = {1240, 1330},		-- Kul'Tiran
    [35] = {862, 860},         -- Vulpera 125 4
}

local SplashModelAnimationID = 860;
local function SetModelOffset()
    local unit = "player";
    local _, _, raceID = UnitRace(unit);
    local genderID = UnitSex(unit);
    if genderID and raceID then
        genderID = genderID - 1;
    else
        return
    end
    if raceID == 25 or raceID == 26 then --Pandaren A|H
        raceID = 24;
    elseif raceID == 29 then
        raceID = 10;
    elseif raceID == 37 then
        raceID = 7;
    elseif raceID == 30 then
        raceID = 11;
    elseif raceID == 28 then
        raceID = 6;
    elseif raceID == 34 then
        raceID = 3;
    elseif raceID == 36 then
        raceID = 2;
    elseif raceID == 22 then
        local _, inAlternateForm = HasAlternateForm();
        if not inAlternateForm then
            --Wolf
            raceID = 22;
        else
            raceID = 1;
        end
    end

    --Set offsetX for a few
    if raceID == 11 then
        if genderID == 1 then
            playerOffsetX = 0.2;
        else
            playerOffsetX = -0.06;
        end
    elseif raceID == 2 then
        playerOffsetX = -0.05;
    elseif raceID == 5 then
        if genderID == 1 then
            playerOffsetX = 0;
        else
            playerOffsetX = -0.03;
        end
    elseif raceID == 24 then
        if genderID == 1 then
            playerOffsetX = -0.035;
        end
    elseif raceID == 31 then
        if genderID == 1 then
            playerOffsetX = -0.04;
        end
    elseif raceID == 35 then
        if genderID == 1 then
            playerOffsetX = -0.04;
        else
            playerOffsetX = 0.035;
        end
    elseif raceID == 10 then
        --***Changed
        playerOffsetX = 0.05;
    elseif raceID == 3 then
        if genderID == 1 then
            playerOffsetX = 0.03;
        end
    elseif raceID == 22 then
        if genderID == 1 then
            playerOffsetX = 0.11;
        else
            playerOffsetX = -0.02;
        end
    elseif raceID == 6 then
        if genderID == 1 then
            playerOffsetX = 0.03;
        end
    elseif raceID == 27 then
        if genderID == 1 then
            playerOffsetX = -0.04;
        else
            playerOffsetX = 0.02;
        end
    end
    
    local info = ModelOffsets[raceID];
    if info then
        playerOffsetZ = info[genderID + 2] or playerOffsetZ;
    end

    local animationID = AnimationPresets[raceID][genderID];
    if animationID then
        --defalut 860
        SplashModelAnimationID = animationID;
    end
end


local function SetPlayerModel(model, visualIDs, animationID, fullBody, isReverseSpeed)
    local playerActor = model.narciPlayerActor;
    ------
    playerActor:ClearModel()
    playerActor:SetAlpha(0);
    local camera = model.narciPlayerCamera;
    model:SetActiveCamera(camera);

    --must-do
    playerActor:SetSpellVisualKit(nil)      
    playerActor:SetModelByUnit("player");
    ------

    C_Timer.After(0.0, function()
        playerActor:SetSheathed(true);
        playerActor:SetAlpha(1);
        model:InitializeActor(playerActor, playerModelInfo);   --Re-scale
        local zoom;
        if fullBody then
            playerActor:SetYaw(-3.14/3);
            playerActor:SetPosition(0, 0, 0);
            zoom = 3.8;
        else
            playerActor:SetYaw(facing);
            playerActor:SetPosition(playerOffsetX, 0, playerOffsetZ);
            zoom = NarciAPI_GetCameraZoomDistanceByUnit("player");
        end

        if isReverseSpeed then
            playerActor:SetAnimation(animationID, 0, 0.25, 0);
        else
            playerActor:SetAnimation(animationID, 0, 0.25, 0);
        end
        playerActor:UndressSlot(1); --Remove helm
        playerActor:UndressSlot(17)
        playerActor:UndressSlot(16)
        camera:SetZoomDistance(1);
        camera:SnapAllInterpolatedValues();
        C_Timer.After(0.0, function()
            camera:SetZoomDistance(zoom);
            if visualIDs then
                local _type = type(visualIDs);
                if _type == "number" then
                    playerActor:SetSpellVisualKit(visualIDs);
                elseif _type == "table" then
                    for i = 1, #visualIDs do
                        playerActor:SetSpellVisualKit(visualIDs[i]);
                    end
                end
            else
                playerActor:SetSpellVisualKit(nil);
            end

            --playerActor:SetDesaturation(0.6);
        end)
    end);
end


local function SetSplashModel(self)
    SetModelOffset();
    local model = self;
    local camera, playerActor;
    model:TransitionToModelSceneID(290, 1, 1, true);
    SetupPlayerForModelScene(model, nil, true, true);   --3 sheathWeapon
    playerActor = model:GetPlayerActor();
    playerActor:SetModelByUnit("player");
    model.narciPlayerActor = playerActor;
    camera = model:GetActiveCamera();
    camera.minZoomDistance = 1;
    camera.targetInterpolationAmount = 0.01;
    model.narciPlayerCamera = camera;

    local animationID = SplashModelAnimationID; --52 1448 860
    SetPlayerModel(model, {122669, 112555, 58009}, animationID, false, true);   -- 95630 123912
end

local UpdateFrame = CreateFrame("Frame");
UpdateFrame:Hide();
UpdateFrame.t = 0;
UpdateFrame.duration = 0.5;
local function OnUpdateFunc(self, elapse)
    self.t = self.t + elapse;
    local modelOffset = inOutSine(self.t, self.startX, self.endX, self.duration);
    local frameOffset = inOutSine(self.t, self.textstartX, self.textendX, self.duration);
    local scale = outSine(self.t, self.startScale, self.endScale - self.startScale, self.duration);
    if self.t >= self.duration then
        modelOffset = self.endX;
        frameOffset = self.textendX;
        scale = self.endScale;
        self:Hide();
    end
    self.model:SetPoint("LEFT", modelOffset, 0);
    self.frame:SetPoint("LEFT", frameOffset , 0);
    self.preview:SetScale(scale);
end

UpdateFrame:SetScript("OnUpdate", OnUpdateFunc);
UpdateFrame:SetScript("OnHide", function(self)
    self.t = 0;
end);

local function FlyOutModel(self)
    local clip = self:GetParent().ClipFrame;
    local UpdateFrame = UpdateFrame;
    if not UpdateFrame.frame then
        UpdateFrame.model = clip.ModelScene;
        UpdateFrame.frame = clip.NoteFrame;
        UpdateFrame.preview = clip.Preview;
    end

    if UpdateFrame:IsShown() then return end;
    local clip = self:GetParent().ClipFrame;

    if self.IsExpanded then
        --Hide patch note
        UpdateFrame.startX = 180;
        UpdateFrame.endX = 0;
        UpdateFrame.textstartX = 0;
        UpdateFrame.textendX = -100;
        UpdateFrame.startScale = 1;
        UpdateFrame.endScale = 1;
        FadeFrame(clip.ModelScene, UpdateFrame.duration, "IN");
        FadeFrame(clip.NoteFrame, 0.45, "OUT");
        FadeFrame(clip.Preview, 0.25, "OUT");

        --button visual
        self.Text:SetText(SPLASH_BASE_HEADER);
        self.Text.Bling:Play();
    else
        --Show patch note
        UpdateFrame.startX = 0;
        UpdateFrame.endX = 180;
        UpdateFrame.textstartX = -100;
        UpdateFrame.textendX = 0;
        UpdateFrame.startScale = 1.5;
        UpdateFrame.endScale = 1;
        FadeFrame(clip.ModelScene, UpdateFrame.duration, "OUT");
        FadeFrame(clip.NoteFrame, 0.35, "IN");
        FadeFrame(clip.Preview, 0.5, "IN");

        --button visual
        self.Text:SetText(string.format(NARCI_SPLASH_WHATS_NEW_FORMAT, NARCI_VERSION_INFO));
        self.Text.Bling:Stop();
    end 
    self.IsExpanded = not self.IsExpanded;
    
    UpdateFrame:Show();
end

local function SplashModel_OnShow(self)
    local ModelScene = self.ClipFrame.ModelScene;
    SetSplashModel(ModelScene);
end

local function LogoButton_OnClick(self)
    FlyOutModel(self);
end

local function TryOutButton1_OnEnter(self)
    Narci_CorruptionTooltip:Hide();

    --CharacterFrameCorruption_OnEnter
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:SetMinimumWidth(250);

	local corruption = GetCorruption();
	local corruptionResistance = GetCorruptionResistance();
	local totalCorruption = math.max(corruption - corruptionResistance, 0);

	local noWrap = false;
	local wrap = true;
	local descriptionXOffset = 10;

	GameTooltip_AddColoredLine(GameTooltip, CORRUPTION_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddColoredLine(GameTooltip, CORRUPTION_DESCRIPTION, NORMAL_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredDoubleLine(GameTooltip, CORRUPTION_TOOLTIP_LINE, corruption, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, noWrap);
	GameTooltip_AddColoredDoubleLine(GameTooltip, CORRUPTION_RESISTANCE_TOOLTIP_LINE, corruptionResistance, HIGHLIGHT_FONT_COLOR, HIGHLIGHT_FONT_COLOR, noWrap);
	GameTooltip_AddColoredDoubleLine(GameTooltip, TOTAL_CORRUPTION_TOOLTIP_LINE, totalCorruption, CORRUPTION_COLOR, CORRUPTION_COLOR, noWrap);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

    local corruptionEffects = GetNegativeCorruptionEffectInfo();
    
	local function SortCorruptionEffects(a, b)
        return a.minCorruption < b.minCorruption;
    end

	table.sort(corruptionEffects, SortCorruptionEffects);

	for i = 1, #corruptionEffects do
		local corruptionInfo = corruptionEffects[i];

		if i > 1 then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
		end

		-- We only show 1 effect above the player's current corruption.
		local lastEffect = (corruptionInfo.minCorruption > totalCorruption);

		GameTooltip_AddColoredLine(GameTooltip, CORRUPTION_EFFECT_HEADER:format(corruptionInfo.name, corruptionInfo.minCorruption), lastEffect and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR, noWrap);
		GameTooltip_AddColoredLine(GameTooltip, corruptionInfo.description, lastEffect and GRAY_FONT_COLOR or CORRUPTION_COLOR, wrap, descriptionXOffset);

		if lastEffect then
			break;
		end
	end

	GameTooltip:Show();
end

local function TryOutButton2_OnEnter(self)
    local tooltip = Narci_CorruptionTooltip;
    tooltip:SetParent(Narci_InteractiveSplash)
    tooltip:ClearAllPoints();
    tooltip:SetScale(UIParent:GetEffectiveScale());
    tooltip:SetPoint("CENTER", self, "TOP", 0, -20);
    FadeFrame(tooltip, 0.25, "IN");
end

local function TryOutButton1_OnClick(self)
    self:GetParent().Button2.Tick:Hide();
    self.Tick:Show();
    NarcissusDB.CorruptionTooltip = false;
    Narci:SetUseCorruptionTooltip();
end

local function TryOutButton2_OnClick(self)
    self:GetParent().Button1.Tick:Hide();
    self.Tick:Show();
    NarcissusDB.CorruptionTooltip = true;
    Narci:SetUseCorruptionTooltip();
end

local function TryOutButton1_OnLeave(self)
    Narci_CorruptionTooltip:Hide();
    GameTooltip_Hide();
end

local function TryOutButton2_OnLeave(self)
    local tooltip = Narci_CorruptionTooltip;
    if not tooltip:IsMouseOver() then
        tooltip:Hide();
    end
    GameTooltip_Hide();
end

local Splash = CreateFrame("Frame");
Splash:RegisterEvent("ADDON_LOADED");
Splash:RegisterEvent("PLAYER_ENTERING_WORLD");
Splash:SetScript("OnEvent", function(self, event, ...)
    local event = event;
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "Narcissus" then
            self:UnregisterEvent("ADDON_LOADED");
        else
            return
        end

        if CurrentVersion > NarcissusDB.Version then
            ApplyPatchFix();
            
            if NarcissusDB.Version < 10080 then
                self:RegisterEvent("GARRISON_UPDATE");
            end

            NarcissusDB.Version = CurrentVersion;
        end

    elseif event == "GARRISON_UPDATE" then
        self:UnregisterEvent("GARRISON_UPDATE");
        C_Timer.After(2.5, function()
            if CinematicFrame:IsShown() or MovieFrame:IsShown() then
                self:RegisterEvent("CINEMATIC_STOP");
            else
                FadeFrame(Narci_InteractiveSplash, 0.25, "Forced_IN");
            end
        end);
    elseif event == "CINEMATIC_STOP" then
        self:UnregisterEvent("CINEMATIC_STOP")
        C_Timer.After(2, function()
            FadeFrame(Narci_InteractiveSplash, 0.25, "Forced_IN");
        end);
    elseif event == "PLAYER_ENTERING_WORLD" then
        --Load Model Info
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        playerModelInfo = NarciAPI_GetActorInfoByUnit("player");
        local frame = Narci_InteractiveSplash;
        local genderID = UnitSex("player");
        if genderID == 3 then
            --She Comes
            local ModelScene = frame.ClipFrame.ModelScene;
            ModelScene.Text:SetTexCoord(0, 1, 0.25, 0.5);
            ModelScene.TextHighlight:SetTexCoord(0, 1, 0.75, 1);
            ModelScene.ArrowLeft:SetPoint("RIGHT", ModelScene.Text, "LEFT", 28, 0);
            ModelScene.ArrowRight:SetPoint("LEFT", ModelScene.Text, "RIGHT", -28, 0);
        end
        frame:SetScript("OnShow", SplashModel_OnShow);
        frame.LogoButton:SetScript("OnClick", LogoButton_OnClick);

        local ButtonTab = frame.ClipFrame.Preview.ButtonTab;    --Directly preview\change preferences on splash pane
        ButtonTab.Button1.onEnterFunc = TryOutButton1_OnEnter;
        ButtonTab.Button2.onEnterFunc = TryOutButton2_OnEnter;
        ButtonTab.Button1.onLeaveFunc = TryOutButton1_OnLeave;
        ButtonTab.Button2.onLeaveFunc = TryOutButton2_OnLeave;
        ButtonTab.Button1:SetScript("OnClick", TryOutButton1_OnClick);
        ButtonTab.Button2:SetScript("OnClick", TryOutButton2_OnClick);
    end
end)


local RunDelayedFunction = NarciAPI_RunDelayedFunction;

local function ShowButtonTab(Preview, id)
    --Narcissus 1.0.8
    if id == 2 then
        Preview.ButtonTab:Show();
    else
        Preview.ButtonTab:Hide();
    end
end

function NarciSplash_InteractiveText_OnEnter(self)
    local id = self:GetID() or 1;
    local Preview = self:GetParent():GetParent().Preview;

    self.Marker.scaleIn:Play();
    UIFrameFadeIn(self.Marker, 0.25, self.Marker:GetAlpha(), 1);

    RunDelayedFunction(self, 0.25, function()
        if not Preview.pauseUpdate then
            Preview.pauseUpdate = true;
            Preview.ImageBottom:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Splash\\SplashIMG"..id);
            Preview.ImageBottom:SetAlpha(1);
            C_Timer.After(0, function()
                Preview.ImageTop.fadeOut:Play();
                ShowButtonTab(Preview, id);
                C_Timer.After(0.5, function()
                    Preview.id = id;
                end)
            end)
        end
    end)
end

function NarciSplash_PreviewFadeIn_OnFinished(self)
    local Preview = self:GetParent():GetParent();    --Preview frame
    Preview.pauseUpdate = nil;
    self:GetParent():SetTexture(Preview.ImageBottom:GetTexture())
    self:GetParent():SetAlpha(1);
    Preview.ImageBottom:SetAlpha(0);
    if Preview:GetParent().NoteFrame:IsMouseOver() then
        local button = GetMouseFocus();
        if button then
            if button.isInteractiveText then
                local id = button:GetID();
                if id ~= Preview.id then
                    ShowButtonTab(Preview, id);
                    --------
                    Preview.pauseUpdate = true;
                    Preview.ImageBottom:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Splash\\SplashIMG"..id);
                    Preview.ImageBottom:SetAlpha(1);
                    C_Timer.After(0.2, function()
                        Preview.ImageTop.fadeOut:Play();
                        C_Timer.After(0.5, function()
                            Preview.id = id;
                        end)
                    end) 
                end
            end
        end
    end
end

--Test

function Narci:ShowSplash(animationID)
    FadeFrame(Narci_InteractiveSplash, 0.25, "IN");
    if animationID then
        local playerActor = Narci_InteractiveSplash.ClipFrame.ModelScene.narciPlayerActor;
        playerActor:SetAnimation(animationID, 0, 0.25, 0);
    end
end

--Events Test--
--/run SetSplashModelAnimation()
--[[
local EventListener = CreateFrame("Frame");
--EventListener:RegisterAllEvents()
--EventListener:RegisterEvent("CVAR_UPDATE")
--EventListener:RegisterEvent("CONSOLE_MESSAGE")
--EventListener:RegisterEvent("CHAT_MSG_SYSTEM")
--EventListener:RegisterEvent("PLAYER_STARTED_LOOKING");
--EventListener:RegisterEvent("PLAYER_LEAVING_WORLD");
--EventListener:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
--EventListener:RegisterEvent("PLAYER_FLAGS_CHANGED")
EventListener:RegisterEvent("CRITERIA_UPDATE")
EventListener:SetScript("OnEvent",function(self,event,...)
	if event ~= "COMBAT_LOG_EVENT" and event ~= "COMBAT_LOG_EVENT_UNFILTERED" and event ~= "CHAT_MSG_ADDON"
    and event ~= "UNIT_COMBAT" and event ~= "ACTIONBAR_UPDATE_COOLDOWN" and event ~= "UNIT_AURA"

    and event ~= "GUILD_ROSTER_UPDATE" and event ~= "GUILD_TRADESKILL_UPDATE" and event ~= "GUILD_RANKS_UPDATE"
    and event ~= "UPDATE_MOUSEOVER_UNIT" and event ~= "CURSOR_UPDATE"
    and event ~= "NAME_PLATE_UNIT_ADDED" and event ~= "NAME_PLATE_UNIT_REMOVED" and event ~= "NAME_PLATE_CREATED"
    and event ~= "SPELL_UPDATE_COOLDOWN" and event ~= "SPELL_UPDATE_USABLE"
    and event ~= "BN_FRIEND_INFO_CHANGED" and event ~= "FRIENDLIST_UPDATE"
	and event ~= "MODIFIER_STATE_CHANGED" and event ~= "UPDATE_SHAPESHIFT_FORM" and event ~= "SOCIAL_QUEUE_UPDATE" and event ~= "COMPANION_UPDATE" and event ~= "UPDATE_MOUSEOVER_UNIT"
	and event ~= "COMPANION_UPDATE" and event ~= "UPDATE_INVENTORY_DURABILITY" then
		print("Event: |cFFFFD100"..event)
		local name, value, value2, value3, value4, value5 = ...
		print(name)
		--print(value)
        --print(value2)
        --print("\n")
        print(IsFalling())
    end
end)

--To add a player into the scene, select a player in your sight and click + button.
--Click a selected button will temporarily hide its model.
--Drag a button to change the model's layer level.
--You may also change the race and gender by clicking the portrait.
--]]