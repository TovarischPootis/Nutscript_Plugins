local PLUGIN = PLUGIN

PLUGIN.Corpses = PLUGIN.Corpses or {}
PLUGIN.DeathDoor = PLUGIN.DeathDoor or {}
PLUGIN.DefibRecharge = PLUGIN.DefibRecharge or {}

function PLUGIN:getMedicalCorpse(client)
	return self.Corpses[client:getChar()]
end

local function unstuckPlayer(client)
	local Offset = Vector(5, 5, 5)
	for _,ent in pairs(ents.FindInBox(client:GetPos() + client:OBBMins() + Offset, client:GetPos() + client:OBBMaxs() - Offset)) do
		if IsValid(ent) and ent ~= client and ent:IsPlayer() and ent:Alive() then

			client:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			client:SetVelocity(Vector(-10, -10, 0) * 20)

			ent:SetVelocity(Vector(10, 10, 0) * 20)

			timer.Simple(2, function()
				client:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			end)
			break
		end
	end
end

function PLUGIN:UpdateDeathsDoor(client, time)
	PLUGIN.DeathDoor[client:getChar():getID()] = time
end

function PLUGIN:getDeathsDoor(client)
	return PLUGIN.DeathDoor[client:getChar():getID()] or 0
end

function PLUGIN:RevivePlayerDisconnected(client)
    local char = client:getChar()
    local className
	if PLUGIN.Corpses[char] then
		for k, v in ipairs(nut.faction.indices) do
			if (k == client:Team()) then
				points = nut.plugin.list["spawns"].spawns[v.uniqueID] or {}
				break
			end
		end

		if (points) then
			for _, v in ipairs(nut.class.list) do
				if (char:getClass() == v.index) then
					className = v.uniqueID
					break
				end
			end

			points = points[className] or points[""]

			if (points and table.Count(points) > 0) then
				local position = table.Random(points)

				client:SetPos(position)
			end
		end
	end
end

function PLUGIN:CanHearDeadPeople(talker)
	if not talker:getChar() then return false end
	return not IsValid(PLUGIN.Corpses[talker:getChar()])
end

function PLUGIN:RevivePlayerSpawn( client )
	client:UnSpectate()

	if not client:getChar() then
		return
	end

	if IsValid(PLUGIN.Corpses[client:getChar()]) then
		PLUGIN.Corpses[client:getChar()]:Remove()
	end
end

function PLUGIN:ReviveDoPlayerDeath(client)
	if nut.config.get("Toggle Revive", true) == false then
		return
	end

	if not client:getChar() then
		return
	end

	local character = client:getChar()
	local charID = character:getID()

	PLUGIN.Corpses[character] = ents.Create("prop_ragdoll")
	PLUGIN.Corpses[character]:SetNWBool("Reviveable", false)
	PLUGIN.Corpses[character]:SetPos(client:GetPos())
	PLUGIN.Corpses[character]:SetModel(client:GetModel())

	for _,v in pairs(client:GetBodyGroups()) do
		local curBG = client:GetBodygroup(v.id)

		PLUGIN.Corpses[character]:SetBodygroup(v.id, curBG)
	end

	PLUGIN.Corpses[character]:SetSkin(client:GetSkin())
	PLUGIN.Corpses[character]:setNetVar("player", client)
	PLUGIN.Corpses[character]:SetAngles(client:GetAngles())
	PLUGIN.Corpses[character]:Spawn()
	PLUGIN.Corpses[character]:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = PLUGIN.Corpses[character]:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:ApplyForceCenter(client:GetVelocity() * 15);
	end

	PLUGIN.Corpses[character].player = client
	PLUGIN.Corpses[character]:SetNWFloat("Time", CurTime() + nut.config.get("Revive Threshold", 30))
	PLUGIN.Corpses[character]:SetNWBool("Body", true)

	if self.DeathDoor[charID] and self.DeathDoor[charID] < CurTime() or not self.DeathDoor[charID] then
		timer.Simple(0.5, function()
			netstream.Start(nil, "nut_DeadBody", PLUGIN.Corpses[character]:EntIndex())
		end)

		PLUGIN.Corpses[character]:SetNWBool("Reviveable", true)

		timer.Simple(nut.config.get("Revive Threshold", 30), function()
			if IsValid(PLUGIN.Corpses[character]) then
				PLUGIN.Corpses[character]:SetNWBool("Reviveable", false)
				netstream.Start(nil, "nut_DeadBodyRemove", PLUGIN.Corpses[character]:EntIndex())
			end
		end)
	end

	nut.chat.send(client, "me", "falls to the ground due to their injuries.", false)

	if not hook.Run("isInIsoView") then
		client:Spectate(OBS_MODE_CHASE)
		client:SpectateEntity(PLUGIN.Corpses[character])
	end
	client:notify("You will be able to respawn in "..math.Round(nut.config.get("spawnTime", 10)).." seconds.")

	timer.Simple(0.01, function()
		if (client:GetRagdollEntity() ~= nil and client:GetRagdollEntity():IsValid()) then
			client:GetRagdollEntity():Remove()
		end
	end)
end

function PLUGIN:ReviveKeyPress(client, key )
	if ( key == IN_USE ) then
		local traceRes = client:GetEyeTrace()

		if ( IsValid( traceRes.Entity ) and traceRes.Entity:GetClass( ) == "prop_ragdoll" ) then
			local traceEnt = traceRes.Entity

			if not ( IsValid( traceEnt.player ) ) then
				client:notify( "You cannot revive a disconnected player's body." )
				return
			end

			if (not traceEnt.player:getChar() or self.DeathDoor[traceEnt.player:getChar():getID()] ~= nil) and self.DeathDoor[traceEnt.player:getChar():getID()] >= CurTime() then
				client:notify("The victim's injuries are too grave, they cannot be saved...")
				return
			end

			local recharging = self.DefibRecharge[client:getChar():getID()] or false
			local defib = client:getChar():getInv():getFirstItemOfType("defib") or false

			if (defib and defib:getData("power") and not recharging) then
				local timeToComplete = nut.config.get("Revive Time Defib", 3)
				client:setAction("Using Defibrillator...", timeToComplete)
				traceEnt.player:setAction("You are being revived by "..client:GetName().." via Defibrillator", timeToComplete)
				client:doStaredAction(traceEnt.player, function()
					traceEnt.player:UnSpectate()
					self:UpdateDeathsDoor(traceEnt.player, CurTime() + 180)
					netstream.Start(traceEnt.player, "DeathDoorTimer", self.DeathDoor[traceEnt.player:getChar():getID()])
					traceEnt.player:Spawn()
					traceEnt.player:SetHealth( traceEnt.player:GetMaxHealth()* 0.75 )
					traceEnt.player:SetPos(traceEnt:GetPos())
					unstuckPlayer(traceEnt.player)
					client:notify( "You revived "..traceEnt.player:GetName() )
					traceEnt.player:notify( "You were revived by "..client:GetName() )
					netstream.Start(traceEnt.player, "RespawnPrompt", false)
					self.DefibRecharge[client:getChar():getID()] = true
					timer.Simple(nut.config.get("Defib Recharge", 3), function()
						self.DefibRecharge[client:getChar():getID()] = nil
					end)
					traceEnt.player:setNetVar("respawnable", false)
					traceEnt.player:EmitSound( "ambient/energy/zap1.wav" )
				end, timeToComplete, function()
					client:setAction()
					traceEnt.player:setAction()
				end, 100)
			else
				if (defib and defib:getData("power") == false) then
					client:notify("Your Defibrillator is powered off...")
				elseif (recharging) then
					client:notify("Your Defibrillator is recharging...")
				end
				local timeToComplete = nut.config.get("Revive Time", 15)
				client:setAction("Performing CPR...", timeToComplete)
				traceEnt.player:setAction("You are being revived by "..client:GetName().." via CPR", timeToComplete)
				client:doStaredAction(traceEnt.player, function()
					traceEnt.player:UnSpectate()
					self:UpdateDeathsDoor(traceEnt.player, CurTime() + 180)
					netstream.Start(traceEnt.player, "DeathDoorTimer", self.DeathDoor[traceEnt.player:getChar():getID()])
					traceEnt.player:Spawn()
					traceEnt.player:SetHealth(1)
					traceEnt.player:SetPos(traceEnt:GetPos())
					unstuckPlayer(traceEnt.player)
					client:notify( "You revived "..traceEnt.player:GetName() )
					traceEnt.player:notify( "You were revived by "..client:GetName() )
					netstream.Start(traceEnt.player, "RespawnPrompt", false)
					traceEnt.player:setNetVar("respawnable", false)
				end, timeToComplete, function()
					client:setAction()
					traceEnt.player:setAction()
				end, 100)
			end
		end
	end
end