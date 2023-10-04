PLUGIN.name = "Death Screen"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "'You have died' message."

if SERVER then
	local calledForPlayer = {}
	function PLUGIN:PlayerDeathThink(client)
		if (client:getChar()) then
			local deathTime = client:getNetVar("deathTime")
			if (deathTime and deathTime <= CurTime()) and not calledForPlayer[client] then
				netstream.Start(client, "RespawnPrompt", true)
				client:setNetVar("respawnable", true)
				calledForPlayer[client] = true
			end
		end

		return false
	end

	function PLUGIN:PlayerButtonDown(client, button)
		if not client:Alive() and client:getNetVar("respawnable", false) == true and button == KEY_SPACE then
			if client:getNetVar("deathTime") > CurTime() then return end
			if hook.Run("onAttemptToRespawn", client) == false then return end
			nut.plugin.list["medical"]:ResetClient(client)
			netstream.Start(client, "RespawnPrompt", false)
			client:setNetVar("respawnable", false)
			if nut.config.get("pkActive") and client:getChar().deathCause then
				local char = client:getChar()
				if (char.deathCause:IsWorld() or char.deathCause == client) and not nut.config.get("pkWorld") then
					client:Spawn()
					return
				end
				char:setData("permakilled", true)
				netstream.Start(nil, "nut_DeadBodyRemove", nut.plugin.list["medical"].Corpses[char]:EntIndex())
			end
			client:Spawn()
		end
	end

	function PLUGIN:PlayerSpawn(client)
		calledForPlayer[client] = nil
	end
end
if (CLIENT) then
	local respawnPrompt = false
	local niceAlpha = 0
	netstream.Hook("RespawnPrompt", function(bool)
		respawnPrompt = bool
		niceAlpha = 0
	end)

	function PLUGIN:HUDPaint()
		if respawnPrompt then
			niceAlpha = math.min(niceAlpha + 1, 255)
			local text = hook.Run("getRespawnPromptText") or (nut.config.get("pkActive") and "Press Space to retire. (WARNING! PK MODE IS ACTIVE, YOU RISK A PK IF YOU DO NOT WAIT TO BE REVIVED)") or "Press Space to respawn"
			local sinWave = math.abs(math.sin(CurTime() * 0.5) * 255)
			draw.SimpleTextOutlined( text, "nutMediumFont", ScrW( ) * 0.5, ScrH( ) * 0.8, Color( sinWave, sinWave, 200, niceAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 75, 75, 255, 100 ) )

		end
	end
end
