local PLUGIN = PLUGIN

PLUGIN.DeathDoorTimer = 0

surface.CreateFont( "ReviveText", {
	font = "Trebuchet MS",
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

local function ReviveDrawDeadPlayers()
    local char = LocalPlayer():getChar()
	if (char) then
		local DDCountdown = PLUGIN.DeathDoorTimer - CurTime()

		if DDCountdown > 0 then
			draw.SimpleText("Death's Door: "..tostring(math.ceil(DDCountdown)), "ReviveText", 50, 50, Color(249, 255, 239))
		end

		if not char:isMedical() then return end

		for _, v in pairs(ents.FindByClass("prop_ragdoll")) do
			if LocalPlayer():GetPos():Distance(v:GetPos()) > 512 then break end

			if IsValid(v) and v.isDeadBody then
		 	local Pos = v:GetPos():ToScreen()
				draw.RoundedBox(0, Pos.x, Pos.y, 10, 40, Color(175, 100, 100))
				draw.RoundedBox(0, Pos.x - 15, Pos.y + 15, 40, 10, Color(175, 100, 100))

				draw.SimpleText("Time Left: "..math.Round(v:GetNWFloat("Time") - CurTime()), "ReviveText", Pos.x, Pos.y - 20, Color(249, 255, 239), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
end

hook.Add("HUDPaint","nutMedicalDrawDeadPlayers", ReviveDrawDeadPlayers)

netstream.Hook("nut_DeadBody", function( index )
	local ragdoll = Entity(index)

	if IsValid(ragdoll) then
		ragdoll.isDeadBody = true
	end
end)

netstream.Hook("nut_DeadBodyRemove", function( index )
	local ragdoll = Entity(index)

	if IsValid(ragdoll) then
		ragdoll.isDeadBody = false
	end
end)

netstream.Hook("DeathDoorTimer", function(data)
	PLUGIN.DeathDoorTimer = data
end)

function PLUGIN:getDeathsDoor()
	return PLUGIN.DeathDoorTimer or 0
end