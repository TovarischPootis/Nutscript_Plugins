local PLUGIN = PLUGIN
PLUGIN.bleedingChars = PLUGIN.bleedingChars or {}
local charMeta = nut.meta.character

util.AddNetworkString("updateBleedStatus")

local function networkBleedInfo(client, isBleeding)
    net.Start("updateBleedStatus")
        net.WriteBool(isBleeding)
    net.Send(client)
end

--[[Handle the bleeding effect every period of time. The function checks if its time to trigger a bleed. If it is not, it returns
    otherwise, it loops through the currentInjuries table of the char in question and reduces of every bleeding bodypart.
    Then, for every bleeding bodypart, it leaves a blood decal. The hitpoints cannot go below 1.
]]
function charMeta:doBleedDamage()
    local charID = self:getID() -- get the charID

    if not PLUGIN.bleedingChars[charID] then return end -- if the charID is not in the bleeding players table then don't do anything
    if PLUGIN.bleedingChars[charID] > CurTime() then return end -- if its not time to bleed the character yet, don't do anything

    local client = self:getPlayer() -- get the client controlling the character
    if not client then return end

    local hitpointStats = self:getHitpoints() -- get the table of hitpoints of the player
    local injuryStats = self:getInjuries() -- get the table of injuries of the player

    for part, stats in pairs(injuryStats) do -- loop through the injuries table
        if stats.bleeding ~= nil then -- if there is a bleeding key in the stats
            hitpointStats[part] = math.max(1, hitpointStats[part] - 1) -- reduce it by 1 to a limit of 1 (injuries and hitpoints use the same keys, so their keys can be used seamlessly)
            local randomA, randomB, randomC, randomD = math.random(1,30), math.random(1,30), math.random(1,10),math.random(1,10)
			util.Decal( "blood", client:GetPos() + Vector(randomA, randomB, 0), client:GetPos() - Vector(randomC, randomD, 50)) -- draw a blood decal
            client:SetHealth(math.max(1, client:Health()-1)) -- reduce the player's health by 1, to a limit of 1
        end
    end
    self:setHitpoints(hitpointStats) -- update the new hitpoints
    PLUGIN.bleedingChars[self:getID()] = CurTime() + nut.config.get("Bleed Interval", 5)
end

--[[Removes the bleeding injury off a limb. If no limb is specified, then all the bleed status' will be removed.
    If, post-removal, there are no bleeds on the char, then the character is listed as not bleeding anymore.
]]
function charMeta:stopBleeding(limb)
    if limb and (not PLUGIN.defaultValues.injuries[limb]) then return end -- if the specified limb doesn't exist then don't do anything.

    --local injuryStats = self:getInjuries() -- get the table of injuries of the player
    local injuryTable = {}
    if not limb then
        injuryTable = table.Copy(self:getInjuries())
        for _, value in pairs(injuryTable) do
            value.bleeding = nil
        end
    end
    self:setInjuries(limb or injuryTable, limb and "bleeding" or nil, nil) -- save the new stats
    local check = false -- check to see if there are any bleeding left

    for _, value in pairs(self:getInjuries()) do
        check = value.bleeding ~= nil and true or check -- if part is bleeding, set check to true. If its not, keep it as is. (if no parts are bleeding, check will stay false)
    end

    if not check then -- if no parts are bleeding
        PLUGIN.bleedingChars[self:getID()] = nil --remove the part from the bleeding chars table
        networkBleedInfo(self:getPlayer(), false)
    end
end

--[[Loop through every bleeding character, check if its time to bleed them, if it is, bleed them]]
function PLUGIN:bleedThink()
    for k, v in pairs(self.bleedingChars) do
        if nut.char.loaded[k] and CurTime() >= v then
            nut.char.loaded[k]:doBleedDamage()
        else
            self.bleedingChars[k] = nil
        end
    end
end

--[[Add bleed status to limb. if its the first bleed status on the char, add them to the bleedChars table
    and network to the client to trigger visual effects]]
function charMeta:addBleed(limb)
    if not limb then return end

    local injuries = self:getInjuries()
    if not injuries[limb].bleeding then
        self:setInjuries(limb,"bleeding", PLUGIN.injuryText.bleeding[limb][math.random(#PLUGIN.injuryText.bleeding[limb])]) -- save the new stats
    end
    if not PLUGIN.bleedingChars[self:getID()] then
        PLUGIN.bleedingChars[self:getID()] = CurTime()
        networkBleedInfo(self:getPlayer(), true)
    end
end

--[[Calculate whether bleed should be applied]]
function charMeta:shouldAddBleed(limb, multiplier)
    if charMeta:isImmune("bleeding") then return end
    local chance = math.random(100)
    if chance <= (nut.config.get("Bleed Chance", 10) * (multiplier or 1)) then
        self:addBleed(limb)
    end
end

--[[Apply bleed status to newly loaded char, if they have said status on them (network visuals and set to bleed table).
    If there was an oldChar, network to remove any bleed status' to prevent the new char from bleeding when he shouldn't]]
function charMeta:loadBleedStatus(oldChar)
    if oldChar then
        networkBleedInfo(oldChar:getPlayer(), false)
        PLUGIN.bleedingChars[oldChar:getID()] = nil
    end
    local injuryStats = self:getInjuries()

    for _, v in pairs(injuryStats) do
        if v.bleeding ~= nil then
            networkBleedInfo(self:getPlayer(), true)
            PLUGIN.bleedingChars[self:getID()] = CurTime()
        end
    end
end