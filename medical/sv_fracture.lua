local PLUGIN = PLUGIN
local charMeta = nut.meta.character
local legTranslate = {[0] = "left_leg", [1] = "right_leg"} -- these exist to easily translate the limb name to the number they represent
local numLegTranslate = {left_leg = 0, right_leg = 1} -- in PlayerFootstep. 2 tables exist to make it simpler and easier to translate back and forth
local armLimbs = {left_arm = 0, right_arm = 1} -- The numbers don't represent anything, they are 0 and 1 simply for convenience.
PLUGIN.fracturedLegChars = PLUGIN.fracturedLegChars or {} -- stores chars with broken legs
PLUGIN.fracturedArmChars = PLUGIN.fracturedArmChars or {} -- stores chars with broken arms
PLUGIN.currentPlayerClip = PLUGIN.currentPlayerClip or {} -- will save every client's current ammo if there arm is fractured. This is to detect if a viewbump is needed
util.AddNetworkString("updateFractureStatus")

--[[apply fracture status to defined limb. If its a leg limb, apply limping effect. If arm limb, apply hand shaking effect.]]
function charMeta:addFracture(limb)
    if not limb then return end

    local injuries = self:getInjuries()
    if not injuries[limb].fracture then
         self:setInjuries(limb,"fracture", PLUGIN.injuryText.fracture[limb][math.random(#PLUGIN.injuryText.fracture[limb])]) -- save the new stats
    end
    local charID = self:getID()
    if numLegTranslate[limb] ~= nil then
        PLUGIN.fracturedLegChars[charID] = PLUGIN.fracturedLegChars[charID] or {}
        PLUGIN.fracturedLegChars[charID][numLegTranslate[limb]] = true
    elseif armLimbs[limb] ~= nil then
        PLUGIN.fracturedArmChars[charID] = PLUGIN.fracturedArmChars[charID] or {}
        PLUGIN.fracturedArmChars[charID][armLimbs[limb]] = true
    elseif limb == "head" then
        self:addConcussion()
    end
end

--[[Sets the character's run speed based on fractures]]
function charMeta:fractureUpdateSpeed()
    local hitpointStats = self:getHitpoints() -- get the player's injury table
    local injuryStats = self:getInjuries() -- get the player's injury table
    local leftLegStat = injuryStats.left_leg.fracture ~= nil and hitpointStats.left_leg or 100
    local rightLegStat = injuryStats.right_leg.fracture ~= nil and hitpointStats.right_leg or 100

    local client = self:getPlayer() -- get the player
	local walkSpeed = nut.config.get("walkSpeed", 130) -- get the walkSpeed set by NS
	local runSpeed = nut.config.get("runSpeed", 235) -- get the runSpeed set by NS
	local debuffMod = 200 - math.Clamp(leftLegStat + rightLegStat, 100, 200) -- at full leg health, is 0, can only get up to 100
	debuffMod = debuffMod / 200 -- turns the number into a decimal between 0 and 0.5
	client:SetRunSpeed(runSpeed - (runSpeed * debuffMod)) -- sets the new runspeed
	client:SetWalkSpeed(walkSpeed - (walkSpeed * (debuffMod / 2))) -- let the debuff for the walk speed be a bit less harsh

    local chestStat = injuryStats.chest.fracture ~= nil and hitpointStats.chest or 100
    local abdomenStat = injuryStats.abdomen.fracture ~= nil and hitpointStats.abdomen or 100
    self:setData("medicalStaminaMod", (chestStat + abdomenStat)/200) --(between 0 and 1)
end

--[[Remove fracture status from defined limb. If no limb is specified, then remove fracture from all limbs. If no fractures are remaining, remove limping effect]]
function charMeta:removeFracture(limb)
    if limb and (not PLUGIN.defaultValues.injuries[limb]) then return end -- if the specified limb doesn't exist then don't do anything.

    local charID = self:getID()
    local injuryTable = {}
    if limb then
        if numLegTranslate[limb] ~= nil then
            if PLUGIN.fracturedLegChars[charID] then
                PLUGIN.fracturedLegChars[charID][numLegTranslate[limb]] = nil
                if table.IsEmpty(PLUGIN.fracturedLegChars[charID]) then
                    PLUGIN.fracturedLegChars[charID] = nil
                end
            end
            self:fractureUpdateSpeed()
        elseif armLimbs[limb] ~= nil then
            if PLUGIN.fracturedArmChars[charID] then
                PLUGIN.fracturedArmChars[charID][armLimbs[limb]] = nil
                if table.IsEmpty(PLUGIN.fracturedArmChars[charID]) then
                    PLUGIN.fracturedArmChars[charID] = nil
                    PLUGIN.currentPlayerClip[self:getPlayer():SteamID()] = nil
                end
            end
        elseif limb == "head" then
            self:removeConcussion()
            self:addTempConcussion(5)
        end
    else
        injuryTable = table.Copy(self:getInjuries())
        for _, value in pairs(injuryTable) do
            value.fracture = nil
        end

        PLUGIN.fracturedArmChars[charID] = nil
        PLUGIN.fracturedLegChars[charID] = nil
        PLUGIN.currentPlayerClip[self:getPlayer():SteamID()] = nil
        self:removeConcussion()
        --self:addTempConcussion(5)
        self:fractureUpdateSpeed()
    end
    self:setInjuries(limb or injuryTable, limb and "fracture" or nil, nil) -- save the new stats
end

--[[Calculate whether fracture should be applied]]
function charMeta:shouldAddFracture(limb, multiplier)
    if charMeta:isImmune("fracture") then return end
    local chance = math.random(100)
    if chance <= (nut.config.get("Fracture Chance", 10) * (multiplier or 1)) then
        self:addFracture(limb)
        if limb == "head" and not charMeta:isImmune("concussion") then self:addTempConcussion(30) end
    else
        if limb == "head" and not charMeta:isImmune("concussion") then self:addTempConcussion(3) end
    end
end
--[[Apply fracture status to newly loaded char, if they have said status on them (network visuals and set to fracture table).
    If there was an oldChar, network to remove any bleed status' to prevent the new char from being fracture when he shouldn't]]
function charMeta:loadFractureStatus(oldChar)
    if oldChar then
        PLUGIN.fracturedLegChars[oldChar:getID()] = nil
    end
    local injuryStats = self:getInjuries()
    local charID = self:getID()
    for k, v in pairs(injuryStats) do
        if v.fracture ~= nil then
            if numLegTranslate[k] ~= nil then
                PLUGIN.fracturedLegChars[charID] = PLUGIN.fracturedLegChars[charID] or {}
                PLUGIN.fracturedLegChars[charID][numLegTranslate[k]] = true
            elseif armLimbs[v] ~= nil then
                PLUGIN.fracturedArmChars[charID] = PLUGIN.fracturedArmChars[charID] or {}
                PLUGIN.fracturedArmChars[charID][armLimbs[v]] = true
            end
        end
    end
end

--[[Triggered on every footstep. If the foot is fractured, apply a viewbump based on how injured the leg is]]
function PLUGIN:fractureStep(client, char, limbNum)
    local charID = char:getID()
    if not self.fracturedLegChars[charID] then return end
    for k in pairs(self.fracturedLegChars[charID]) do
        if k == limbNum then
            local hitpoints = char:getHitpoints()
            local multiplier = hitpoints[legTranslate[limbNum]]
            client:ViewPunch(Angle(0.03*(100-multiplier), 0, 0))
            if client:GetVelocity():LengthSqr() - 5 > (nut.config.get("walkSpeed", 130))^2 then -- -5 is to account for random variation, sometimes the actual speed is a bit higher than the max value
                hitpoints[legTranslate[limbNum]] = math.max(hitpoints[legTranslate[limbNum]] - 1, 1)
                client:SetHealth(math.max(client:Health() - 1, 1))
                char:setHitpoints(hitpoints)
            end
        end
    end
end

--[[Triggered by StartCommand. Bump the player every time they make a shot with primary fire.]]
function PLUGIN:fracturedShoot(client, cmd)
    if not client:IsPlayer() or not client:getChar() then return end
    local char = client:getChar()
    local steamID = client:SteamID()
    if self.fracturedArmChars[char:getID()] == nil then return end
	if (char and client:Alive() and (client:Health() > 0)) then
		local activeWeapon = client:GetActiveWeapon()
		local currentClip = IsValid(activeWeapon) and activeWeapon:Clip1() or nil

		if not currentClip then return end
		if self.currentPlayerClip[steamID] == nil then self.currentPlayerClip[steamID] = currentClip end

		local savedClip = self.currentPlayerClip[steamID]

		if cmd:KeyDown(IN_ATTACK) and currentClip ~= savedClip then
			local hitpointStats = char:getHitpoints()
			local modifier = (200 - math.Clamp(hitpointStats.left_arm + hitpointStats.right_arm, 100, 200)) / 20 --between 0 and 5
			client:ViewPunch(Angle(math.random(-1 * modifier, 1 * modifier), math.random(-2 * modifier,2 * modifier), 0))
			self.currentPlayerClip[steamID] = currentClip
		end
	end
end