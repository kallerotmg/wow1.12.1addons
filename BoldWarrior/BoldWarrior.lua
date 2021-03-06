BW = {}
BW.debug = true
BW.announced = 0
BWConfig = {
	BUFFCAP = 24
}

BINDING_HEADER_BW = "BoldWarrior"
BINDING_NAME_BW_CHALLSHOUT = "Challenging Shout"
BINDING_NAME_BW_SAFESW = "Safe Shield Wall"
BINDING_NAME_BW_SAFELS = "Safe Last Stand"
BINDING_NAME_BW_SAFETRINKET = "Safe Trinket (any/all)"
BINDING_NAME_BW_SAFETRINKETANNOUNCE = "Safe Trinket (any/all) with announcement"

BW.announce = "---> "
BW.prep = "[BoldWarrior] "
BW.removableBuffs = {
	"Bloodrage",
	"Thorns",
	"Dampen Magic",
	"Amplify Magic",
	"Abolish Disease",
	"Greater Blessing of Sanctuary",
	"Blessing of Sanctuary",
	"Prayer of Shadow Protection",
	"Blessing of Light",
	"Greater Blessing of Light",
	"Fire Shield",
	"Armor of Faith", -- priest t3
	"Regrowth",
	"Rejuvenation",
	"Renew",
	"Power Word: Shield",
	"Gordok Green Grog",
	"Health II",
	"Armor",
	"Well Fed",
	"Inspiration",
}

BW_TAUNT_LOG = "Your Taunt was resisted by (.+)"
BW_TAUNT_TXT = "Taunt resisted!"

BW_MB_LOG = "(.*)Mocking Blow(.*)"
BW_MB_LOG2 = "Your Mocking Blow (.+) for (.+)"
BW_MB_TXT = "Mocking Blow resisted!"

BW_SW_TXT = "Used Shield Wall!"
BW_LS_TXT = "Used Last Stand!"
BW_CS_TXT = "Used Mass Taunt!"

function BW.OnLoad()
	if UnitClass("player") ~= "Warrior" then return end
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	-- this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	this:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")

	SlashCmdList["BWHELP"] = BW.Help
	SLASH_BWHELP1 = "/bwhelp"
	SlashCmdList["BWBUFFCAP"] = BW.SetBuffCap
	SLASH_BWBUFFCAP1 = "/bwcap"
	SlashCmdList["SAFESW"] = BW.SafeSW
	SLASH_SAFESW1 = "/safesw"
	SlashCmdList["SAFELS"] = BW.SafeLS
	SLASH_SAFELS1 = "/safels"
	SlashCmdList["SAFETRINKET"] = BW.SafeTrinket
	SLASH_SAFETRINKET1 = "/safetrinket"
	SlashCmdList["CHALLSHOUT"] = BW.ChallengingShout
	SLASH_CHALLSHOUT1 = "/aoetaunt"
	SlashCmdList["MOCKING"] = BW.MockingBlow
	SLASH_MOCKING1 = "/mocking"
	SlashCmdList["OVERPOWER"] = BW.Overpower
	SLASH_OVERPOWER1 = "/overpower"
	SlashCmdList["MAKEMACROS"] = BW.MakeMacros
	SLASH_MAKEMACROS1 = "/bwmm"
	SlashCmdList["SAFEUSE"] = BW.SafeUse
	SLASH_SAFEUSE1 = "/safeuse"
end

function BW.OnEvent()
	if event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
		if string.find(arg1, BW_TAUNT_LOG) then
			BC.y(BW_TAUNT_TXT, BW.announce)
		elseif string.find(arg1, BW_MB_LOG) then
			local mbHit = string.find(arg1, BW_MB_LOG2)
			if not mbHit then
				BC.r(BW_MB_TXT, BW.announce)
			end
		end
	end
end

function BW.Help()
	BC.c("/aoetaunt", BW.prep)
	BC.m("Uses and announces Challenging Shout if player has enough rage and it is not on cooldown.", BW.prep)
	BC.c("/safesw", BW.prep)
	BC.m("Safely uses Shield Wall.", BW.prep)
	BC.c("/safels", BW.prep)
	BC.m("Safely uses Last Stand.", BW.prep)
	BC.c("/safetrinket (announce)", BW.prep)
	BC.m("Safely uses whatever trinkets you have equipped.", BW.prep)
	BC.c("/mocking", BW.prep)
	BC.m("Use Mocking Blow from any stance and swap back to defensive stance.", BW.prep)
	BC.c("/overpower", BW.prep)
	BC.m("Use Overpower from any stance and swap back to berserker stance.", BW.prep)
	BC.c("/bwcap (1-32)", BW.prep)
	BC.m("Set your current buff cap (used to determine if /safe(sw/ls/lgg) removes a buff or not.", BW.prep)
	BC.c("/safeuse", BW.prep)
	BC.m("Safely uses an item.", BW.prep)
	BC.c("/bwmm", BW.prep)
	BC.m("Make macros for the commands.", BW.prep)
end

function BW.MakeMacros()
	BC.MakeMacro("AoETaunt", "/aoetaunt", 1, "Ability_BullRush", nil, 1, 1)
	BC.MakeMacro("Shield Wall", "/safesw", 1, "Ability_Warrior_ShieldWal", nil, 1, 1)
	BC.MakeMacro("Last Stand", "/safels", 1, "Spell_Holy_AshesToAshe", nil, 1, 1)
	BC.MakeMacro("Any Trinket", "/safetrinket announce", 1, "Ability_Druid_Enrage", nil, 1, 1)
	BC.MakeMacro("Mocking Blow", "/mocking", 1, "Ability_Warrior_PunishingBlow", nil, 1, 1)
	BC.MakeMacro("Overpower", "/overpower", 1, "Ability_MeleeDamage", nil, 1, 1)
end

function BW.SetBuffCap(buffCap)
	if buffCap ~= "" then
		BWConfig.BUFFCAP = buffCap
		BC.m("Buff cap set to "..buffCap, BW.prep)
	else
		BC.m("Specify the number of buffs eg. /bwcap 24", BW.prep)
		BC.c("Current buff cap: "..BWConfig.BUFFCAP, BW.prep)
	end
end

function BW.ChallengingShout()
	if UnitMana("player") > 9 and GetSpellCooldown(BC.GetSpellId("Challenging Shout"), BOOKTYPE_SPELL) == 0 then
		CastSpellByName("Challenging Shout", 1)
		BC.y(BW_CS_TXT, BW.announce)
	end
end

function BW.SafeSW()
	-- do nothing if on cd.
	if GetSpellCooldown(BC.GetSpellId("Shield Wall"), BOOKTYPE_SPELL) > 0 then
		BC.m("Shield Wall is on cooldown.", BW.prep)
		return
	end
	-- notify if in wrong stance.
	local _,_,defensive, _ = GetShapeshiftFormInfo(2)
	if not defensive then
		BC.m("You need to be in defensive stance to Shield Wall", BW.prep)
		return
	end
	-- if below cap, sw.
	if not UnitBuff("player", BWConfig.BUFFCAP) then
		CastSpellByName("Shield Wall")
		BC.y(BW_SW_TXT, BW.announce)
		return
	end
	-- meni buffs, need to remove one.
	if not BW.RemoveABuff() then
		BC.m("Could not find a buff to remove, using Shield Wall anyway.", BW.prep)
	end
	CastSpellByName("Shield Wall")
	BC.y(BW_SW_TXT, BW.announce)
end

function BW.SafeLS()
	-- do nothing if on cd.
	local LSId = BC.GetSpellId("Last Stand")
	if LSId then	
		if GetSpellCooldown(LSId, 1, BOOKTYPE_SPELL) > 0 then
			BC.m("Last stand is on cooldown.", BW.prep)
			return
		end
	else
		BC.m("You do not have Last Stand.", BW.prep)
	end
	-- if below cap, ls.
	if not UnitBuff("player", BWConfig.BUFFCAP) then
		CastSpellByName("Last Stand")
		BC.y(BW_LS_TXT, BW.announce)
		return
	end
	-- meni buffs, need to remove one.
	if not BW.RemoveABuff() then
		BC.m("Could not find a buff to remove, using Last Stand anyway.", BW.prep)
	end
	CastSpellByName("Last Stand")
	BC.y(BW_LS_TXT, BW.announce)
end

function BW.SafePopTrinket(announce)
	local trink1, trink2 = {}, {}
	trink1.link = GetInventoryItemLink("player", 13)
	trink1.CDStart, _, trink1.hasUse = GetInventoryItemCooldown("player", 13)

	if trink1.hasUse == 1 and trink1.CDStart == 0 then
		if not UnitBuff("player", BWConfig.BUFFCAP) then
			UseInventoryItem(13)
		else
			if not BW.RemoveABuff() then
				BC.m("Could not find a buff to remove, using "..trink1.link.." anyway.", BW.prep)
			end
			UseInventoryItem(13)
		end
		if announce and (GetTime() - BW.announced) > 1 then
			BW.announced = GetTime()
			BC.y("Using "..trink1.link.."!", BW.announce)
		end
		return
	end

	trink2.link = GetInventoryItemLink("player", 14)
	trink2.CDStart, _, trink2.hasUse = GetInventoryItemCooldown("player", 14)

	if trink2.hasUse == 1 and trink2.CDStart == 0 then
		if not UnitBuff("player", BWConfig.BUFFCAP) then
			UseInventoryItem(14)
		else
			if not BW.RemoveABuff() then
				BC.m("Could not find a buff to remove, using "..trink2.link.." anyway.", BW.prep)
			end
			UseInventoryItem(14)
		end
		if announce and (GetTime() - BW.announced) > 1 then
			BW.announced = GetTime()
			BC.y("Using "..trink2.link.."!", BW.announce)
		end
		return
	end
end

function BW.SafeUse(item)
	if not UnitBuff("player", BWConfig.BUFFCAP) then
		BC.UseItemByName(item)
	else
		if not BW.RemoveABuff() then
			BC.m("Could not find a buff to remove, using "..item.." anyway.", BW.prep)
		end
		BC.UseItemByName(item)
	end
end

function BW.SafeTrinket(msg)
	if msg ~= "" then
		BW.SafePopTrinket(1)
	else
		BW.SafePopTrinket()
	end
end

function BW.RemoveABuff()
	for k,buff in pairs(BW.removableBuffs) do
		local i = BC.BuffIndexByName(buff)
		if i then
			CancelPlayerBuff(i)
			BC.m("Removed "..buff..".", BW.prep)
			return true
		end
	end
	return false
end

function BW.MockingBlow()
	if UnitMana("player") < 10 then
		return
	end
	local mockingId = BC.GetSpellId("Mocking Blow")
	local _,_,battle, _ = GetShapeshiftFormInfo(1)
	local _,_,defensive, _ = GetShapeshiftFormInfo(2)
	if GetSpellCooldown(mockingId, 1, BOOKTYPE_SPELL) > 0 then
		if not defensive then 
			CastSpellByName("Defensive Stance")
		end
		return
	end
	if not battle then
		CastSpellByName("Battle Stance")
	end
	CastSpellByName("Mocking Blow")
end

function BW.Overpower()
	if UnitMana("player") < 5 then
		return
	end
	local OPId = BC.GetSpellId("Overpower")
	local _,_,battle, _ = GetShapeshiftFormInfo(1)
	local _,_,berserker, _ = GetShapeshiftFormInfo(3)
	if GetSpellCooldown(OPId, 1, BOOKTYPE_SPELL) > 0 then
		if not berserker then 
			CastSpellByName("Berserker Stance")
		end
		return
	end
	if not battle then
		CastSpellByName("Battle Stance")
	end
	CastSpellByName("Overpower")
end