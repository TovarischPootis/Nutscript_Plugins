ITEM.name = "Medical Stuff"
ITEM.model = "models/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "A Medical Stuff"
ITEM.flag = "M"
ITEM.category = "Medical"
ITEM.genericMedical = false
ITEM.isStackable = true
ITEM.healing = false
ITEM.limbHealing = false
ITEM.bleedingTreat = false
ITEM.fractureTreat = false
ITEM.concussionTreat = false
ITEM.treatAmount = 10
ITEM.maxSize = 50
ITEM.treatString = "doing a medical thing to the "
ITEM.treatSound = "physics/flesh/flesh_squishy_impact_hard1.wav"


local function isMedical(client)
	return (client and client:getChar() and client:getChar():isMedical()) or false
end

ITEM.functions.customQuan = {
	name = "Customize Quantity",
	tip = "Customize this item",
	icon = "icon16/wrench.png",
	onRun = function(item)
		local client = item.player

		client:requestString("Change Quantity", "", function(text)
			local amount = tonumber(text)
			if (amount) then
				item:setData("quantity", math.min(item.maxSize, amount))
			end
		end, item:getData("quantity", 1))

		return false
	end,
	onCanRun = function(item)
		return item.player:IsAdmin()
	end
}

function ITEM:action(client, target, targetChar, limb)
	if not (target and targetChar and limb) then return end

	if self.bleedingTreat then targetChar:stopBleeding(limb) end
	if self.fractureTreat then targetChar:removeFracture(limb) end
	if self.concussionTreat then targetChar:treatConcussion(self.duration) end
	--if self.concussionTreat then targetChar:stopBleeding(limb) end
	target:EmitSound(self.treatSound)
end

function ITEM:getDesc()
	local desc = self.desc
	if (self:getData("quantity", 1) ~= nil) then
		desc = desc.."\nRemaining Uses: "..self:getData("quantity", 1)
	end
	if CLIENT and not (LocalPlayer().getNetVar(LocalPlayer(), "char") and isMedical(LocalPlayer())) then
		desc = desc.."\nYou are not medically trained, therefore you spend "..nut.config.get("Medical Wastefulness", 5).." extra units per use"
	end
	return desc
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		local quantity = item:getData("quantity", 1)

		if (tonumber(quantity) > 1) then
			draw.SimpleText(quantity, "DermaDefault", w - 12, h - 14, Color(255,50,50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		end
	end
end