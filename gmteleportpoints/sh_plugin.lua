local PLUGIN = PLUGIN

PLUGIN.name = "GM Teleport Points"
PLUGIN.desc = "Allow GMs to teleport to predefined points on the map"
PLUGIN.author = "Tov. Pootis"

if SERVER then

PLUGIN.tpPoints = PLUGIN.tpPoints or {}

function PLUGIN:saveTPPoints()
	nut.data.set("TPPoints", self.tpPoints, false, false)
	end

function PLUGIN:loadTPPoints()
		self.tpPoints = nut.data.get("TPPoints", {}, false, false)
	end

function PLUGIN:LoadData()
	self:loadTPPoints()
end

function PLUGIN:AddPoint(client, name, pos)
	if not name or not pos then client:notify("Invalid Info Provided") return end
	table.insert(self.tpPoints, {name = name, pos = pos, sound = "", effect = ""})
	client:notify("TP Point " .. name .. " added")
	self:saveTPPoints()
end

function PLUGIN:RemovePoint(client, name)
	if not name then client:notify("Invalid Info Provided") return end

	local posID, properName
	for k, v in pairs(self.tpPoints) do
		if v.name == name then
		posID = k
		properName = v.name
		break end
	end
	if not posID then
		for k, v in pairs(self.tpPoints) do
			if (nut.util.stringMatches(v[1], name)) then
				posID = k
				properName = v.name
				break
			end
		end
	end

	if not posID then client:notify("Invalid TP Point Name Provided") return end
	self.tpPoints[posID] = nil
	self:saveTPPoints()
	client:notify("TP Point " .. properName .. " removed")
end

function PLUGIN:RenamePoint(client, name, newName)
	if not name or not newName then client:notify("Invalid Info Provided") return end
	local properName
	for k, v in pairs(self.tpPoints) do
		if v.name == name then
		properName = v.name
		v.name = newName
		break end
	end
	if not properName then
		for k, v in pairs(self.tpPoints) do
			if (nut.util.stringMatches(v.name, name)) then
				properName = v.name
				v.name = newName
				break
			end
		end
	end
	if not properName then client:notify("Invalid TP Point Name Provided") return end
	self:saveTPPoints()
	client:notify("Point " .. properName ..  " has been renamed to " .. newName)
end

function PLUGIN:UpdateSound(client, name, sound, newSound)
	if not sound or not newSound then client:notify("Invalid Info Provided") return end
	local properSound
	for k, v in pairs(self.tpPoints) do
		print(v.name)
		if v.name == name then
		properSound = v.sound
		v.sound = newSound
		break end
	end
	if not properSound then client:notify("Invalid Sound Path Provided") return end
	self:saveTPPoints()
	client:notify("Point " .. name .. "'s sound effect was updated to" .. newSound)
end

function PLUGIN:UpdateEffect(client, name, effect, newEffect)
	if not effect or not newEffect then client:notify("Invalid Info Provided") return end
	local properEffect
	for k, v in pairs(self.tpPoints) do
		if v.name == name then
		properEffect = v.effect
		v.effect = newEffect
		break end
	end
	if not properEffect then client:notify("Invalid Effect Path Provided") return end
	self:saveTPPoints()
	client:notify("Point " .. name .. "'s effect was updated to" .. newEffect)
end

function PLUGIN:MoveToPoint(client, name)
	if not name then client:notify("Invalid Info Provided") return end
	local properName, pos, sound, effect
	for k, v in pairs(self.tpPoints) do
		if v.name == name then
		properName = v.name
		pos = v.pos
		sound = v.sound
		effect = v.effect
		break end
	end
	if not properName then
		for k, v in pairs(self.tpPoints) do
			if (nut.util.stringMatches(v.name, name)) then
				properName = v.name
				pos = v.pos
				sound = v.sound
				effect = v.effect
				break
			end
		end
	end
	if not properName then client:notify("Invalid TP Point Name Provided") return end
	if effect and effect ~= "" then
		local effectData = EffectData()
		effectData:SetOrigin(client:GetPos())
		util.Effect(effect, effectData)
	end
	client:SetPos(pos)
	if sound and sound ~= "" then client:EmitSound(sound) end
	if effect and effect ~= "" then
		local effectData = EffectData()
		effectData:SetOrigin(client:GetPos())
		util.Effect(effect, effectData)
	end

	client:notify("Moved to " .. properName)
end

netstream.Hook("GMTPMove", function(client, name)
	if not client:IsAdmin() then return end
	PLUGIN:MoveToPoint(client, name)
end)

netstream.Hook("GMTPNewPoint", function(client, name)
	if not client:IsAdmin() then return end
	local pos = client:GetPos()
	PLUGIN:AddPoint(client, name, pos)
end)

netstream.Hook("GMTPUpdateName", function(client, oldName, newName)
	if not client:IsAdmin() then return end
	PLUGIN:RenamePoint(client, oldName, newName)
end)

netstream.Hook("GMTPUpdateSound", function(client, name, oldSound, newSound)
	if not client:IsAdmin() then return end
	PLUGIN:UpdateSound(client, name, oldSound, newSound)
end)

netstream.Hook("GMTPUpdateEffect", function(client, name, oldEffect, newEffect)
	if not client:IsAdmin() then return end
	PLUGIN:UpdateEffect(client, name, oldEffect, newEffect)
end)

netstream.Hook("GMTPDelete", function(client, name)
	if not client:IsAdmin() then return end
	PLUGIN:RemovePoint(client, name)
end)

end

nut.command.add("gmtpadd", {
	adminOnly = true,
	syntax = "<string pos name>",
	onRun = function(client, arguments)
		local pos = client:GetPos()
		local name = table.concat(arguments, " ", 1)
		PLUGIN:AddPoint(client, name, pos)
	end
})

nut.command.add("gmtpremove", {
	adminOnly = true,
	syntax = "<string pos name>",
	onRun = function(client, arguments)
		local name = table.concat(arguments, " ", 1)
		PLUGIN:RemovePoint(client, name)
	end
})

nut.command.add("gmtpnewname", {
	adminOnly = true,
	syntax = "<string pos name>",
	onRun = function(client, arguments)
		local name = table.concat(arguments, " ", 1)
		netstream.Start("gmTPNewName", name)
	end
})

nut.command.add("gmtpmenu", {
	adminOnly = true,
	onRun = function(client, arguments)
		local datatable = {}
		for k, v in pairs(PLUGIN.tpPoints) do
			table.insert(datatable, {name = v.name, sound = v.sound, effect = v.effect})
		end
		netstream.Start(client, "gmTPMenu", datatable )
	end
})

nut.command.add("gmtpmoveto", {
	adminOnly = true,
	syntax = "<string name>",
	onRun = function(client, arguments)
		local name = table.concat(arguments, " ", 1)
		print(name)
		PLUGIN:MoveToPoint(client, name)
	end
})

if CLIENT then
	netstream.Hook("gmTPNewName", function(name)
		Derma_StringRequest(
			"Rename TP Point",
			"Enter new TP Point Name",
			name,
			function(text)
				surface.PlaySound("buttons/blip1.wav")
				netstream.Start("GMTPUpdateName", name, text)
			end
		)
	end)
end