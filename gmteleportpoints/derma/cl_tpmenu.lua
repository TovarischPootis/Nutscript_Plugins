local PLUGIN = PLUGIN
local PANEL = {}


function PANEL:Init()
	self:SetTitle("TP points")
	self:SetSize(500, 400)
	self:Center()
	self:MakePopup()

	local noticeBar = self:Add("DLabel")
	noticeBar:Dock(TOP)
	noticeBar:SetTextColor(color_white)
	noticeBar:SetExpensiveShadow(1, color_black)
	noticeBar:SetContentAlignment(8)
	noticeBar:SetFont("nutChatFont")
	noticeBar:SizeToContents()
	noticeBar:SetText("Left click to TP to the point, Right click for more options...")

	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	self.list:DockMargin(0, 5, 0, 0)
	self.list:SetPadding(5)

	local newPointPanel = self.list:Add("DButton")
		newPointPanel:SetText("Add New Point")
		newPointPanel:SetFont("ChatFont")
		newPointPanel:SetTextColor(color_blue)
		newPointPanel:SetTall(30)
		newPointPanel:Dock( TOP )
		newPointPanel:DockMargin( 0, 0, 0, 5 )

		newPointPanel.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT or code == MOUSE_RIGHT) then
				surface.PlaySound("buttons/blip1.wav")

				Derma_StringRequest(
					"New Point",
					"Enter new TP Point Name",
					"",
					function(text)
						surface.PlaySound("buttons/blip1.wav")
						netstream.Start("GMTPNewPoint", text)
						self:Close()
						table.insert(PLUGIN.TPPoints, {name = text, sound = "", effect = ""})
						vgui.Create("gmTPMenu")
					end
				)
			end
		end

	self:LoadPoints()
end

function PANEL:LoadPoints()
	for k, v in pairs(PLUGIN.TPPoints) do
	local panel = self.list:Add("DButton")
		panel:SetText(v.name)
		panel:SetFont("ChatFont")
		panel:SetTextColor(color_white)
		panel:SetTall(30)
		panel:Dock( TOP )
		panel:DockMargin( 0, 0, 0, 5 )

		panel.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT) then
				surface.PlaySound("buttons/blip1.wav")
				netstream.Start("GMTPMove", v.name)
				self:Close()

			elseif (code == MOUSE_RIGHT) then
				surface.PlaySound("buttons/blip2.wav")

				local menu = DermaMenu()
					menu:AddOption("Rename Point", function()
						Derma_StringRequest(
							"Rename TP Point",
							"Enter new TP Point Name",
							v.name,
							function(text)
							surface.PlaySound("buttons/blip1.wav")
							netstream.Start("GMTPUpdateName", v.name, text)
							self:Close()
							PLUGIN.TPPoints[k].name = text
							vgui.Create("gmTPMenu")
							end
						)
					end):SetImage("icon16/comment.png")
					menu:AddOption("Edit Sound Effect", function()
						Derma_StringRequest(
							"Edit Sound Effect",
							"Enter new sound effect path, set to empty for no sound effect",
							v.sound,
							function(text)
							surface.PlaySound("buttons/blip1.wav")
							netstream.Start("GMTPUpdateSound", v.name, v.sound, text or "")
							self:Close()
							PLUGIN.TPPoints[k].sound = text or ""
							vgui.Create("gmTPMenu")
							end
						)
					end):SetImage("icon16/sound.png")
					menu:AddOption("Edit Particle Effect", function()
						Derma_StringRequest(
							"Edit Particle Effect",
							"Enter new particle effect path, set to empty for no particle effect",
							v.effect,
							function(text)
							surface.PlaySound("buttons/blip1.wav")
							netstream.Start("GMTPUpdateEffect", v.name, v.effect, text or "")
							self:Close()
							PLUGIN.TPPoints[k].effect = text or ""
							vgui.Create("gmTPMenu")
							end
						)
					end):SetImage("icon16/weather_sun.png")
					menu:AddOption("Move to Point", function()
						netstream.Start("GMTPMove", v)
					end):SetImage("icon16/door_in.png")
					menu:AddOption("Delete Point", function()
						netstream.Start("GMTPDelete", v)
						self:Close()
						table.remove(PLUGIN.TPPoints, k)
						vgui.Create("gmTPMenu")
					end):SetImage("icon16/cross.png")
				menu:Open()
			end
		end

		self.list:AddItem(panel)
	end
end

vgui.Register("gmTPMenu", PANEL, "DFrame")

netstream.Hook("gmTPMenu", function(data)
	PLUGIN.TPPoints = {}
	for _, n in pairs(data) do table.insert(PLUGIN.TPPoints, n) end
	table.sort(PLUGIN.TPPoints, function(a,b) return a.name < b.name end)
	areaManager = vgui.Create("gmTPMenu")
end)
