local AFK = CreateFrame("Frame");
AFK:RegisterEvent("CHAT_MSG_SYSTEM")
--local UnitIsAFK = UnitIsAFK;

local AFK_MSG = string.format(MARKED_AFK_MESSAGE, DEFAULT_AFK_MESSAGE)

AFK:SetScript("OnEvent",function(self,event,...)
    if not NarcissusDB or not NarcissusDB.AFKScreen then return; end
    --[[
    if IsInCinematicScene() or InCinematic() then
        print("Play Cinematic");
    end
    --]]
    local name = ...
    if name == AFK_MSG and not(C_PvP.IsActiveBattlefield() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
        if not Narci.isActive then
            Narci_MinimapButton:Click();
            Narci.isAFK = true;
            C_Timer.After(2, function()
                Narci_Character.AutoStand:Play();
            end)
            C_Timer.After(0.6, function()
                PhotoModeController:SetAlpha(0);
                if IsResting() then
                    DoEmote("Read", "none");
                end
            end)
        end
    end
end)

--Override other AFK screens--
local function NullifyEvent(frame)
    if not frame then   return; end
    frame:SetScript("OnEvent", function()   return; end);
end

--[[
/run print(A1=DressUpFrame.ModelScene:GetPlayerActor():GetModelFileID())
1968587 Straight
917116  Stoop
--]]
