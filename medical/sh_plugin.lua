PLUGIN.name = "Medical System v4"
PLUGIN.desc = "Ranging from injuries to treatment, it'll have it all"
PLUGIN.author = "76561198070441753"
PLUGIN.defaultValues = {}
local PLUGIN = PLUGIN

PLUGIN.defaultValues.hitpoints = {
    ["head"] = 100,
    ["chest"] = 100,
    ["abdomen"] = 100,
    ["left_leg"] = 100,
    ["right_leg"] = 100,
    ["left_arm"] = 100,
    ["right_arm"] = 100,
}

PLUGIN.defaultValues.injuries = {
    ["head"] = {},
    ["chest"] = {},
    ["abdomen"] = {},
    ["left_leg"] = {},
    ["right_leg"] = {},
    ["left_arm"] = {},
    ["right_arm"] = {},
}

PLUGIN.hitgroupConvert = {
    [HITGROUP_HEAD] = "head",
    [HITGROUP_CHEST] = "chest",
    [HITGROUP_STOMACH] = "abdomen",
    [HITGROUP_LEFTARM] = "left_arm",
    [HITGROUP_RIGHTARM] = "right_arm",
    [HITGROUP_LEFTLEG] = "left_leg",
    [HITGROUP_RIGHTLEG] = "right_leg"
}

nut.util.include("sh_database.lua")
nut.util.include("sh_configs.lua")

function PLUGIN:InitializedPlugins()
	assert(self.whitelistType and isstring(self.whitelistType), "Your whitelistType setup is invalid. You will have errors. Go fix it")
	if self.whitelistType == "flag" then
		for k, v in pairs(self.whitelist) do
			nut.flag.add(k, v)
		end
	end
end

local charMeta = nut.meta.character

function charMeta:isMedical()

	if PLUGIN.whitelistType == "faction" then
		return PLUGIN.whitelist[self:getFaction()] ~= nil
	elseif PLUGIN.whitelistType == "class" then
		return PLUGIN.whitelist[self:getClass()] ~= nil
	elseif PLUGIN.whitelistType == "flag" then
		for k in pairs(PLUGIN.whitelist) do
			if self:hasFlags(k) then return true end
		end
	end

    return hook.Run("isCharMedical", self) or false
end

function charMeta:isImmune(injuryType)
    if injuryType then
        return PLUGIN.immunity[self:getFaction()] and PLUGIN.immunity[self:getFaction()][injuryType] or false
    else
        local immune = true
        if not PLUGIN.immunity[self:getFaction()] then return false end
        for k, v in pairs(PLUGIN.immunity[self:getFaction()]) do
            if v == false then immune = false break end
        end
        return immune
    end
end

function PLUGIN:fixedLimbText(text)
    return text:gsub("_", " "):gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
end

nut.util.include("sv_concussion.lua")
nut.util.include("sv_bleed.lua")
nut.util.include("sv_plugin.lua")
nut.util.include("sv_fracture.lua")
nut.util.include("sv_revive.lua")
nut.util.include("sv_healing.lua")

nut.util.include("cl_concussion.lua")
nut.util.include("cl_bleed.lua")
nut.util.include("cl_fracture.lua")
nut.util.include("cl_lowhealth.lua")
nut.util.include("cl_revive.lua")
nut.util.include("cl_healmenu.lua")

nut.command.add("resetbodytable", {
    adminOnly = true,
    syntax = "<string pos name>",
    onRun = function(client, arguments)
        if arguments[1] == "*" then
            for _, target in pairs(player.GetAll()) do
                PLUGIN:ResetClient(target)
                target:notify( "Your health values have been reset")
            end
            client:notify("Everyone's health values have been reset")
        elseif arguments[1] ~= nil and arguments[1] ~= "" then
            local target = nut.command.findPlayer(client, arguments[1])
            if target then
                PLUGIN:ResetClient(target)
                if client ~= target then
                    client:notify(target:Nick() .. "'s health values have been reset")
                end
                target:notify( "Your health values have been reset")
            end
        else
            PLUGIN:ResetClient(client)
            client:notify( "Your health values have been reset")
        end
    end
})

nut.command.add("debugmedicalinfo", {
    adminOnly = true,
    syntax = "<string pos name>",
    onRun = function()
        for _, v in pairs(player.GetAll()) do
            print(v:Nick())
            PrintTable(v:getChar():getInjuries())
            PrintTable(v:getChar():getHitpoints())
        end
    end
})

nut.command.add("gotopos", {
    adminOnly = true,
    syntax = "<string pos name>",
    onRun = function(client, arguments)
        local x, y, z = arguments[1], arguments[2], arguments[3]
        client:SetPos(Vector(x, y, z))
    end
})

nut.command.add("healmenu", {
    adminOnly = true,
    syntax = "<string pos name>",
    onRun = function(client, arguments)

        PLUGIN:sendMedicalMenu(client, arguments[1] and nut.command.findPlayer(client, arguments[1]) or client)
    end
})