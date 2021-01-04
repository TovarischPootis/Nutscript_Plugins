local PLUGIN = PLUGIN
PLUGIN.name = "Crafting"
PLUGIN.author = "Black Tea (NS 1.0), Rusty Shackleford (NS 1.1)"
PLUGIN.desc = "Allows you craft some items. And it fucking works."

PLUGIN.menuEnabled = false -- menu can be toggled off.
PLUGIN.reqireBlueprint = true

phrases = {}

phrases["crafting"] = "Crafting"
phrases["craftingtable"] = "Crafting Table"
phrases["req_moremat"] = "You need more materials to craft %s."
phrases["req_blueprint"] = "You need a blueprint of %s to craft %s."
phrases["req_morespace"] = "You need more space to get result."
phrases["donecrafting"] = "You have crafted %s."
phrases["icat_material"] = "Materials"
phrases["craft_menu_tip1"] = "You can craft items by clicking the icons in the list."
phrases["craft_menu_tip2"] = "The icon with book means that item needs a blueprint to be crafted."
phrases["crft_text"] = "Crafting %s\n%s\n\nRequirements:\n"


RECIPES = {}
RECIPES.recipes = {}
function RECIPES:Register( tbl )
	if !tbl.CanCraft then
		function tbl:CanCraft( player )
			local mult --used to check if we have multiple of the same item, rather than a stack.
			for k, v in pairs( self.items ) do
				local inv = player:getChar():getInv()
				local item = inv:getFirstItemOfType(k)

				if !inv:getFirstItemOfType(k) then
					if (k == "cube_chip") then
						local pouch = inv:getFirstItemOfType("cube_chip_pouch")
						if pouch and (pouch:getData("chipcount", 0) >= v) then
							continue
						end
					end

					return false
				end

				if (inv:getFirstItemOfType(k) and item:getData("Amount") == nil) then
					local count = inv:getItemCount(k)
					if (count >= v) then
						mult = true
					else
						return false
					end
				end

				if (inv:getFirstItemOfType(k)) then
					if (!mult and tonumber(item:getData("Amount")) < v and allStacks(inv, k) < v) then
						return false
					else
						mult = false
					end
				end
			end
			return true
		end
	end
	if !tbl.ProcessCraftItems then
		function tbl:ProcessCraftItems( player )
			player:EmitSound( "items/ammo_pickup.wav" )

			--used for finding the average quality of all the items that have quality.
			local avgQual = 0
			local total = 0

			local qualities = {
				[1] = "Garbage",
				[2] = "Terrible",
				[3] = "Awful",
				[4] = "Bad",
				[5] = "Poor",
				[6] = "Normal",
				[7] = "Standard",
				[8] = "Decent",
				[9] = "Good",
				[10] = "Great",
				[11] = "Excellent",
				[12] = "Master",
				[14] = "Near-Perfect",
				[15] = "Perfect",
				[16] = "Transcendent"
			}

			for k, v in pairs(self.items) do
				local itemObj = player:getChar():getInv():getFirstItemOfType(k)
				local inventory = player:getChar():getInv()

				if (inventory:getFirstItemOfType(k)) then
					if (itemObj:getData("Amount") == nil) then --non stack items

						local customData = itemObj:getData("custom", {})
						if (customData.quality) then --checks quality data
							avgQual = avgQual + table.KeyFromValue(qualities, customData.quality)
							total = total + 1
						end

						local count = 1
						local part = inventory:getFirstItemOfType(k)
						part:remove()
						while (count < v) do
							part = inventory:getFirstItemOfType(k)

							local customData = part:getData("custom", {})
							if (customData.quality) then
								avgQual = avgQual + table.KeyFromValue(qualities, customData.quality)
								total = total + 1
							end

							part:remove()
							count = count + 1
						end
					end

					if (itemObj:getData("Amount") != nil) then --if we're dealing with quantities
						if (tonumber(itemObj:getData("Amount")) >= v) then --necessary stacks are all in one item
							itemObj:setData("Amount", tonumber(itemObj:getData("Amount")) - v)
							if (tonumber(itemObj:getData("Amount")) == 0) then
								itemObj:remove()
							end
						else --necessary stacks are split across multiple items
                            local all = inventory:getItems()
                            for _, extraStack in pairs (all) do
                                if (k == extraStack.uniqueID) then
                                    local amount = extraStack:getData("Amount", 1)
                                    if (amount <= v) then
                                        v = v - amount
                                        extraStack:remove()
                                    else
                                        extraStack:setData("Amount", amount - v)
                                    end
                                end
                            end
                        end
                    end
                    for k, v in pairs( self.result ) do
                        for i = 1, v do
                            player:getChar():getInv():add(k)
                        end
                    end
                end
            end
            player:notifyLocalized("donecrafting", self.name)

		end
	end
	self.recipes[ tbl.uid ] = tbl
end

--finds the total amount of material in a person's inventory (across multiple items.)
function allStacks(inventory, uid)
	local all = inventory:getItems()
	local quantity = 0

	for k, v in pairs (all) do
		if (uid == v.uniqueID) then
			local amount = v:getData("Amount")
			if (amount != nil) then
				quantity = quantity + amount
			end
		end
	end

	return quantity
end

nut.util.include("sh_menu.lua")
nut.util.include("sh_commands.lua")
nut.util.include("sh_recipies.lua")

function RECIPES:Get( name )
	return self.recipes[ name ]
end
function RECIPES:GetAll()
	return self.recipes
end
function RECIPES:GetItem( item )
	local tblRecipe = self:Get( item )
	return tblRecipe.items
end
function RECIPES:GetResult( item )
	local tblRecipe = self:Get( item )
	return tblRecipe.result
end
function RECIPES:CanCraft( player, item )
	local tblRecipe = self:Get( item )
	if !tblRecipe:CanCraft( player ) then
		return 1
	end
	return 0
end

local entityMeta = FindMetaTable("Entity")
function entityMeta:IsCraftingTable()
	return self:GetClass() == "nut_craftingtable"
end

if CLIENT then
	function PLUGIN:LoadNutFonts(font, genericFont)
		surface.CreateFont("nut_NotiFont", {
			font = font,
			size = 16,
			weight = 500,
			antialias = true
		})
	end
end

if SERVER then
	util.AddNetworkString("nut_CraftItem")
end
net.Receive("nut_CraftItem", function(length, client)
	local item = net.ReadString()
	local cancraft = RECIPES:CanCraft( client, item )
	local tblRecipe = RECIPES:Get( item )
	print(client)
	if cancraft == 0 then
		tblRecipe:ProcessCraftItems( client )
	else
		if cancraft == 2 then
			local name = tblRecipe.name
			client:notifyLocalized("req_blueprint", name, name )
		elseif cancraft == 1 then
			local name = tblRecipe.name
			client:notifyLocalized("req_moremat", name)
			--print(cancraft)
		end
	end
end)

function PLUGIN:LoadData()
	local data = self:getData() or {}
	for k, v in pairs(data) do
		local position = v.pos
		local angles = v.angles
		local entity = ents.Create("nut_craftingtable")
		entity:SetPos(position)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:Activate()
		local phys = entity:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
end

function PLUGIN:SaveData()
	local data = {}
	for k, v in pairs(ents.FindByClass("nut_craftingtable")) do
		data[#data + 1] = {
			pos = v:GetPos(),
			angles = v:GetAngles(),
		}
	end
	self:setData(data)
end
