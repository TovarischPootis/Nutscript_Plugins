local RECIPE = {}
RECIPE.uid = "nut_flashlight"
RECIPE.name = "Flashlight"
RECIPE.category = "Light Sources"
RECIPE.model = Model( "models/maxofs2d/lamp_flashlight.mdl" )
RECIPE.desc = "A handheld device that illuminates an area."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 1
}
RECIPE.result = {
	["flashlight"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_radio"
RECIPE.name = "Radio"
RECIPE.category = "Communication"
RECIPE.model = Model( "models/gibs/shield_scanner_gib1.mdl" )
RECIPE.desc = "A handheld radio that can receive from various frequencies."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 1
}
RECIPE.result = {
	["radio"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_radio_stationary"
RECIPE.name = "Stationary Radio"
RECIPE.category = "Communication"
RECIPE.model = Model( "models/props_lab/citizenradio.mdl" )
RECIPE.desc = "A stationary radio that can receive from various frequencies."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 2
}
RECIPE.result = {
	["comm_radio_stationary"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_ammo"
RECIPE.name = "60 Bullets"
RECIPE.category = "Ammunition"
RECIPE.model = Model( "models/Items/grenadeAmmo.mdl" )
RECIPE.desc = "A box of ammo for a firearm."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 1,
	["iron_bar"] = 1
}
RECIPE.result = {
	["ammo_generic"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_knife"
RECIPE.name = "Knife"
RECIPE.category = "Weapons"
RECIPE.model = Model( "models/weapons/tfa_nmrih/w_me_kitknife.mdl" )
RECIPE.desc = "A razor-sharp chef's knife."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 1,
	["iron_bar"] = 1
}
RECIPE.result = {
	["kitchenknife"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_walther"
RECIPE.name = "Walther P38"
RECIPE.category = "Weapons"
RECIPE.model = Model( "models/weapons/w_waw_waltherp38.mdl" )
RECIPE.desc = "The Walther P38 is a 9mm semi-automatic pistol developed by Walther arms."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 2,
	["iron_bar"] = 2
}
RECIPE.result = {
	["p38"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_kar98k"
RECIPE.name = "Kar98k"
RECIPE.category = "Weapons"
RECIPE.model = Model( "models/weapons/dpi_weapon_perm/w_tfa_pig_kar98k.mdl" )
RECIPE.desc = "A bolt action rifle chambered in 7.62×57mm Mauser, the standard used by Wehrmacht forces."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 3,
	["iron_bar"] = 3
}
RECIPE.result = {
	["kar98k"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_mp40"
RECIPE.name = "MP 40"
RECIPE.category = "Weapons"
RECIPE.model = Model( "models/weapons/doi_weapons_prem/w_tfa_pig_mp40.mdl" )
RECIPE.desc = "A fully automatic submachinegun rifled in 9×19mm Parabellum, used standardly by Wehrmacht forces."
RECIPE.noBlueprint = true
RECIPE.items = {
	["copper_bar"] = 4,
	["iron_bar"] = 6
}
RECIPE.result = {
	["mp40"] = 1
}
RECIPES:Register( RECIPE )
//
local RECIPE = {}
RECIPE.uid = "nut_lumber"
RECIPE.name = "Lumber"
RECIPE.category = "Refining"
RECIPE.model = Model( "models/props_phx/construct/wood/wood_boardx1.mdl" )
RECIPE.desc = "Chopped lumber."
RECIPE.noBlueprint = true
RECIPE.items = {
	["wood"] = 2
}
RECIPE.result = {
	["lumber"] = 1
}
RECIPES:Register( RECIPE )