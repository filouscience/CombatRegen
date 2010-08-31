local CombatRegen = {};

local CombatRegen = CreateFrame("Frame", CombatRegen, UIParent);

CombatRegen:RegisterEvent("VARIABLES_LOADED");
CombatRegen:RegisterEvent("UNIT_MANA");

CombatRegen:SetScript("OnEvent", function()
	CombatRegen[event](CombatRegen, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end);

--Init ##############################################
local parsing, startTime, totalTimeNotCasting, totalTime, mana, time, regenContTime, casting, oldMana, timePercent, endTime, expendTime, state;

function CombatRegen:INIT()
	mana, time, regenContTime, casting, oldMana = 0, 0, 0, false, 0;
	totalTimeNotCasting = 0;
	parsing = false;
	timePercent = nil;
	startTime = nil;
	endTime = 0;
	expendTime = 1;
	state = 1;
end

CombatRegen:INIT();

--UI functions ######################################
function CombatRegen:Start()
	if parsing == false then
		text = ("CombatRegen started..");
		DEFAULT_CHAT_FRAME:AddMessage(text);
		parsing = true;
		casting = false;		--debug
		regenContTime = GetTime();	--debug
		startTime = GetTime();
		oldMana = UnitMana("player");
		FSRBar:Show();
		RegenStat:Show();
	end
	state = 2;
end

function CombatRegen:Stop()
	if parsing == true then
		text = ("CombatRegen stopped");
		DEFAULT_CHAT_FRAME:AddMessage(text);
		parsing = false;
		endTime = GetTime();
		if casting == false then
			totalTimeNotCasting = totalTimeNotCasting + (endTime - regenContTime);
		end
	end
	state = 3;
end

function CombatRegen:Reset()
	CombatRegen:INIT();
	state = 1;
	text = ("CombatRegen reset");
	DEFAULT_CHAT_FRAME:AddMessage(text);
	FSRBar:Hide();
	RegenStat:SetValue(0);
	RegenStat:Hide();
end

function CombatRegen:Update()
	if startTime ~= nil then
		if parsing == true then
			time = GetTime();
			if casting == false then
				totalTimeNotCasting = totalTimeNotCasting + (time - regenContTime);
				regenContTime = GetTime();
			end
			totalTime = GetTime() - startTime;
		else
			totalTime = endTime - startTime;
		end
		minuteTime = math.floor((totalTime / 60) * 20) / 20;
		timePercent = math.floor(((totalTimeNotCasting / totalTime) * 100) * 200) / 200;

		RegenStat:SetValue(timePercent);
	else
		RegenStat:SetValue(0);
	end
end

function CombatRegen:Report()
	if startTime ~= nil then
		if parsing == true then
			time = GetTime();
			if casting == false then
				totalTimeNotCasting = totalTimeNotCasting + (time - regenContTime);
				regenContTime = GetTime();
			end
			totalTime = GetTime() - startTime;
		else
			totalTime = endTime - startTime;
		end
		minuteTime = math.floor((totalTime / 60) * 20) / 20;
		timePercent = math.floor(((totalTimeNotCasting / totalTime) * 100) * 200) / 200;

		text = ("CombatRegen non-cast regen in "..timePercent.."% of total time "..minuteTime.." min");
		DEFAULT_CHAT_FRAME:AddMessage(text);
	else
		text = ("CombatRegen no input data");
		DEFAULT_CHAT_FRAME:AddMessage(text);
	end
end

--Slash cmd create #####################################
SLASH_COMBATREGEN1 = '/cmr';
function SlashCmdList.COMBATREGEN(msg, editbox)
if msg == "report" then
	CombatRegen:Report();
	return;
else
	if state == 1 then
		CombatRegen:Start();
		state = 2;
		return;
	elseif state == 2 then
		CombatRegen:Stop();
		state = 3;
		return;
	elseif state == 3 then
		CombatRegen:Reset();
		state = 1;
		return;
	end
end
end


--Core itself #########################################
function CombatRegen:UNIT_MANA(unitid)
	if parsing == true then
		if unitid == "player" then
			mana = UnitMana("player");
			time = GetTime();
			if mana < oldMana then
				if casting == false then
					totalTimeNotCasting = totalTimeNotCasting + (time - regenContTime);
				end
				casting = true;
				expendTime = GetTime();
				FSRBar:SetValue(5);
			--FSRBar:OnUpdate is more accurate
			--[[else
				if time >= (expendTime + 5) then
					if casting == true then
						regenContTime = GetTime();
						FSRBar:SetValue(0);
					end
					casting = false;
				end]]--
			end
			oldMana = mana;
		end
	end
end

--OnLoad announce #######################################
function CombatRegen:VARIABLES_LOADED()
	oldMana = UnitMana("player");
	text = ("CombatRegen loaded");
	DEFAULT_CHAT_FRAME:AddMessage(text);
end



--FRS Bar create ########################################
FSRBar = CreateFrame("StatusBar", FSRBar, UIParent)

FSRBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
FSRBar:GetStatusBarTexture():SetHorizTile(false)
FSRBar:SetMinMaxValues(0, 5)
FSRBar:SetValue(0)
FSRBar:SetWidth(100)
FSRBar:SetHeight(12)
FSRBar:SetPoint("BOTTOM", UIParent, "CENTER", 0, -299)
FSRBar:SetStatusBarColor(1,0,0)
FSRBar:Hide();

local FSRBarBackground = FSRBar:CreateTexture("FSRBarBackground", "BACKGROUND")
FSRBarBackground:SetTexture(1, 1, 1, 0.25)
FSRBarBackground:SetAllPoints()

--RegenStat Bar create #####################################
RegenStat = CreateFrame("StatusBar", RegenStat, UIParent)

RegenStat:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
RegenStat:GetStatusBarTexture():SetHorizTile(false)
RegenStat:SetMinMaxValues(0, 100)
RegenStat:SetValue(0)
RegenStat:SetWidth(100)
RegenStat:SetHeight(12)
RegenStat:SetPoint("TOP", UIParent, "CENTER", 0, -301)
RegenStat:SetStatusBarColor(0,1,0)
RegenStat:Hide();

local RegenStatBackground = RegenStat:CreateTexture("RegenStatBackground", "BACKGROUND")
RegenStatBackground:SetTexture(1, 1, 1, 0.25)
RegenStatBackground:SetAllPoints()

--FSR BAR handlers ##############################################
FSRBar:SetScript("OnUpdate", function(self, elapsed)
	local newValue = (FSRBar:GetValue() - elapsed);
	if(newValue < 0) then
		FSRBar:SetValue(0);
		if casting == true then
			regenContTime = GetTime();
		end
		casting = false;
	else	
		FSRBar:SetValue(newValue);
	end
	CombatRegen:Update();
end)


--RegenStat Bar handlers #########################################
--[[
RegenStat:SetScript("OnValueChanged", function(self, value)
end)
]]--