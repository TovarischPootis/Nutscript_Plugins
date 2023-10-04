local PLUGIN = PLUGIN
local charMeta = nut.meta.character

--[[Perform the checks for newly loaded characters. If they switch out from an old character, flush them from memory to avoid errors or bloat]]
function PLUGIN:PlayerLoadedChar(client, char, oldChar)
    char:loadBleedStatus(oldChar)
    char:loadFractureStatus(oldChar)
end

function PLUGIN:IsBlacklistedDMGType(enum)
    for dmgtype in pairs(self.blacklistDMGTypes) do
        if bit.band(enum, dmgtype) == enum then return true end
    end
    return false
end

--[[Perform the think functions for each status.]]
function PLUGIN:Think()
    self:bleedThink()
end

--[[convenience function to handle hitpoints and speed post taking damage]]
function charMeta:postDamageUpdate(limb)
    self:setHitpoints(limb, math.max(self:getHitpoints(limb) -1, 1))

    self:fractureUpdateSpeed()
end
--[[Apply status' on bodypart when hit by bullet. Convert the hitgroup # into a string used by the plugin]]
function PLUGIN:ScalePlayerDamage(client, hitgroup, dmginfo)
    local char = client:getChar()
    if not char then return end

    if self:IsBlacklistedDMGType(dmginfo:GetDamageType()) then return end -- prevent effects from triggering from blacklisted damage types

    local limb = self.hitgroupConvert[hitgroup]
    if not limb then limb = "chest" end

    local bleedMultTable = {}
    hook.Run("getBleedChanceMultipliers", client, limb, bleedMultTable)
    local fractureMultTable = {}
    hook.Run("getFractureChanceMultipliers", client, limb, fractureMultTable)

    local bleedMult, fractureMult = 1, 1
    for k, v in pairs(bleedMultTable) do
        bleedMult = math.max(0.1, bleedMult + (v-1))
    end
    for k, v in pairs(fractureMultTable) do
        fractureMult = math.max(0.1, fractureMult + (v-1))
    end

    char:shouldAddBleed(limb, bleedMult)
    char:shouldAddFracture(limb, fractureMult)

    char:postDamageUpdate(limb)
end

--[[This hook detects any time of damage, even non-bullets. But it does not detect which bodypart was hit. Therefore a random limb is selected to be targetted.]]
function PLUGIN:EntityTakeDamage(client, dmginfo)
    if not client:IsPlayer() or dmginfo:IsBulletDamage() or dmginfo:IsFallDamage() then return end -- don't care if the entity is not a player or if its bullet/fall damage (as that is handled by the ScalePlayerDamage/GetFallDamage hook)

    local char = client:getChar()
    if not char then return end

    if self:IsBlacklistedDMGType(dmginfo:GetDamageType()) then return end -- prevent effects from triggering from blacklisted damage types

    local limb = self.hitgroupConvert[math.random(#self.hitgroupConvert)] -- select a random limb to affect

    local bleedMultTable = {}
    hook.Run("getBleedChanceMultipliers", client, limb, bleedMultTable)
    local fractureMultTable = {}
    hook.Run("getFractureChanceMultipliers", client, limb, fractureMultTable)

    local bleedMult, fractureMult = 1, 1
    for k, v in pairs(bleedMultTable) do
        bleedMult = math.max(0.1, bleedMult + (v - 1))
    end
    for k, v in pairs(fractureMultTable) do
        fractureMult = math.max(0.1, fractureMult + (v - 1))
    end

    char:shouldAddBleed(limb, bleedMult)
    char:shouldAddFracture(limb, fractureMult)

    char:postDamageUpdate(limb)
end

--[[Triggers potential limping viewbumps on chars with broken legs]]
function PLUGIN:PlayerFootstep(client, pos, footNum)
    self:fractureStep(client, client:getChar(), footNum)
end

--[[Triggers potential recoil viewbumps on chars with broken arms]]
function PLUGIN:StartCommand(client, cmd)
    self:fracturedShoot(client, cmd)
end

hook.Remove("GetFallDamage", nut.plugin.list["playerinjuries"])

function PLUGIN:GetFallDamage(client, speed)
	local damage = math.max(0, (speed - 580) * (100 / 444))
    client:getChar():shouldAddFracture(math.random(2) == 1 and "left_leg" or "right_leg", math.min(5, (damage/speed)*50))
    return damage
end

function PLUGIN:ResetClient(victim)
    if not (victim.getChar and victim:getChar()) then return end
    local char = victim:getChar()
    char:setHitpoints(PLUGIN.defaultValues.hitpoints)
    char:setInjuries(PLUGIN.defaultValues.injuries)
    char:stopBleeding()
    char:removeFracture()
    char:fractureUpdateSpeed()
end

function PLUGIN:PlayerCanHearPlayersVoice(listener, talker)
	self:CanHearDeadPeople(talker)
end

function PLUGIN:PlayerCanSeePlayersChat(text,teamOnly, listener, speaker )
	self:CanHearDeadPeople(speaker)
end

function PLUGIN:PlayerDisconnected(client)
    self:RevivePlayerDisconnected(client)
    local charID = client:getChar() and client:getChar():getID() or nil
    if charID then
        self.bleedingChars[charID] = nil
        self.fracturedLegChars[charID] = nil
        self.fracturedArmChars[charID] = nil
        self.currentPlayerClip[client:SteamID()] = nil
    end
end

function PLUGIN:DoPlayerDeath( client, attacker, dmg )
	self:ReviveDoPlayerDeath( client, attacker, dmg )
end

function PLUGIN:PlayerDeath(victim, inflictor, attacker)
	local charID = victim:getChar():getID()
	if self.DeathDoor[charID] and self.DeathDoor[charID] > CurTime() then
		self:ResetClient(victim)
	end
end

function PLUGIN:PlayerSpawn(client)
	local character = client:getChar()
	if (nut.config.get("pkActive") and character and character:getData("permakilled")) then
		character:ban()
	end
--[[     if not (self.Corpses[character] and IsValid(self.Corpses[character])) then
        self:ResetClient(client)
    end ]]
	self:RevivePlayerSpawn(client)
	if character then character.deathCause = nil end
end

function PLUGIN:KeyPress(client, key)
	self:ReviveKeyPress(client, key)
end