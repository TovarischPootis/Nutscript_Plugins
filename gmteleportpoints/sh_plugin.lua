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
	table.insert(self.tpPoints, {name, pos})
	client:notify("TP Point " .. name .. " added")
	self:saveTPPoints()
end

function PLUGIN:RemovePoint(client, name)
if not name then client:notify("Invalid Info Provided") return end
local posID, properName
	for k, v in pairs(self.tpPoints) do
		if v[1] == name then
		posID = k
		properName = v[1]
		break end
	end
	if not posID then
		for k, v in pairs(self.tpPoints) do
			if (nut.util.stringMatches(v[1], name)) then
				posID = k
				properName = v[1]
				break
			end
		end
	end

	if not posID then client:notify("Invalid TP Point Name Provided") return end
	self.tpPoints[posID] = nil
	self:saveTPPoints()
	client:notify("TP Point " .. properName .. " removed")
end

function PLUGIN:RenamePoint(client, name, newname)
	if not name or not newname then client:notify("Invalid Info Provided") return end
	local properName
	for k, v in pairs(self.tpPoints) do
		if v[1] == name then
		properName = v[1]
		v[1] = newname
		break end
	end
	if not properName then
		for k, v in pairs(self.tpPoints) do
			if (nut.util.stringMatches(v[1], name)) then
				properName = v[1]
				v[1] = newname
				break
			end
		end
	end
	if not properName then client:notify("Invalid TP Point Name Provided") return end
	self:saveTPPoints()
	client:notify("Point " .. properName ..  " has been renamed to " .. newname)
end

function PLUGIN:MoveToPoint(client, name)
	if not name then client:notify("Invalid Info Provided") return end
	local properName, pos
	for k, v in pairs(self.tpPoints) do
		if v[1] == name then
		properName = v[1]
		pos = v[2]
		break end
	end
	if not properName then
		for k, v in pairs(self.tpPoints) do
			if (nut.util.stringMatches(v[1], name)) then
				properName = v[1]
				pos = v[2]
				break
			end
		end
	end
	if not properName then client:notify("Invalid TP Point Name Provided") return end
	client:SetPos(pos)
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

netstream.Hook("GMTPUpdateName", function(client, oldname, newname)
	if not client:IsAdmin() then return end
	PLUGIN:RenamePoint(client, oldname, newname)
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
			table.insert(datatable, v[1])
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