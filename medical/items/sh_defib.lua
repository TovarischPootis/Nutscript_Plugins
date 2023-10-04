ITEM.name = "Defibrillator"
ITEM.desc = "A medical device that delivers a therapeutic dose of electrical energy to a patients's affected heart."
ITEM.price = 200
ITEM.uniqueID = "defib"
ITEM.model = "models/weapons/custom/w_defib.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.category = "Medical"

function ITEM:getDesc()
	return self.desc..string.format(" Power: %s",self:getData("power") and "On" or "Off")
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("power", false)) then
			surface.SetDrawColor(110, 255, 110, 100)
		else
			surface.SetDrawColor(255, 110, 110, 100)
		end

		surface.DrawRect(w - 14, h - 14, 8, 8)
	end
end

ITEM.functions.toggle = {
	name = "Toggle",
	tip = "useTip",
	icon = "icon16/connect.png",
	onRun = function(item)
		item:setData("power", !item:getData("power", false), player.GetAll(), false, true)
		item.player:EmitSound("buttons/combine_button"..(item:getData("power") and "5" or "3")..".wav", 70, 150)

		return false
	end
}

ITEM.iconCam = {
	pos = Vector(-0.69906908273697, 267.97384643555, 0),
	ang = Angle(0, 270, -90),
	fov = 2.9411764705882,
}