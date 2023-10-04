local PLUGIN = PLUGIN

--==MANUAL CONFIGURATIONS==--

PLUGIN.whitelistType = "flag" -- Valid entries: faction, class, flag
PLUGIN.whitelist = {
	--[CLASS_DRIFTER_MEDIC] = true, -- replace with faction/class indices OR the flag, each entry should follow this format (flags have to be in quotes)
	--[FACTION_MEDICAL] = true,
	--[FACTION_STAFF] = true
	["M"] = "Medical Flag.", -- instead of true, set it to the flag description. Flags listed here will be auto-created.
}
PLUGIN.immunity = {
    --[CLASS_DRIFTER_MEDIC] = true, -- replace with faction/class indices OR the flag, each entry should follow this format (flags have to be in quotes)
	--[FACTION_STAFF] = {bleeding = true, fracture = true, concussion = true},
	--[FACTION_MOUSEDROID] = {bleeding = true, fracture = false, concussion = false},
	--[FACTION_DEATHTROOPER] = {bleeding = false, fracture = false, concussion = true}
	--["M"] = "Medical Flag.", -- instead of true, set it to the flag description. Flags listed here will be auto-created.
}

PLUGIN.injuryText = { -- Flair text for diagnosis. Add as many as you wish. This is purely for aesthetic RP purposes.
	["bleeding"] = {
		["head"] = {"Laceration across the right forehead penetrated muscle. ", "Bleeding from the nose.", "Laceration into the temple.."},
		["chest"] = {"Skin deep laceration into the lower chest.", "Deep laceration across the upper chest.", "Puncture into the upper left breast."},
		["abdomen"] = {"Laceration to the upper abdomen penetrated muscle.", "Deep laceration into the lower abdomen. Stomach membrane penetration paired with protruding intestines."},
		["left_arm"] = {"Laceration into the upper arm penetrated muscle.", "Deep laceration into the wrist penetrated muscle."},
		["right_arm"] = {"Laceration into the upper arm penetrated muscle.", "Deep laceration into the wrist penetrated muscle."},
		["left_leg"] = {"Laceration to the left knee has hit bone but not fractured it.", "Laceration into the left calf penetrating muscle.", "Puncture to the upper left thigh."},
		["right_leg"] = {"Laceration to the right knee has hit bone but not fractured it.", "Laceration into the right calf penetrating muscle.", "Puncture to the upper right thigh."}
	},
	["fracture"] = {
		["head"] = {"Fracture to the neurocranium.", "Fracture to the frontal skull bone."},
		["chest"] = {"Fracture to left rib(s).", "Fracture to right rib(s).",},
		["abdomen"] = {"Minor fracture to the lower sternum."},
		["left_arm"] = {"Fractured left humerus.", "Fractured 2nd carpal bone."},
		["right_arm"] = {"Fractured right humerus.", "Fractured 2nd carpal bone."},
		["left_leg"] = {"Major fracture of the left femur.", "Minor fracture of the left tibia and fibula."},
		["right_leg"] = {"Major fracture of the right femur.", "Minor fracture of the right tibia and fibula."}
		},
	["concussion"] = {"Shows slowed reactions to stimuli, trouble staying balanced and minor memory loss due to concussion."},
}

PLUGIN.blacklistDMGTypes = {
	[DMG_BURN] = true,
	[DMG_SHOCK] = true,
	[DMG_ENERGYBEAM] = true,
	[DMG_DROWN] = true,
	[DMG_PARALYZE] = true,
	[DMG_NERVEGAS] = true,
	[DMG_POISON] = true,
	[DMG_RADIATION] = true,
	[DMG_DROWNRECOVER] = true,
	[DMG_SLOWBURN] = true,
}

--==AUTOMATIC CONFIGURATIONS (use the f1 config menu to edit these)==--

--==DIAGNOSIS==--
nut.config.add("Enable Diagnosis", false, "If true, limbs will need to be diagnosed before being able to be healed.", nil, {
	category = "Medical"
})

nut.config.add("Diagnosis Time", 5, "How long it takes, in seconds, to inspect a limb", nil, {
	data = {min = 1, max = 60},
	category = "Medical"
})

--==Bleed==--
nut.config.add("Bleed Chance", 10, "Chance of damage to cause bleeding (in %)", nil, {
	data = {min = 0, max = 100},
	category = "Medical"
})

nut.config.add("Bleed Interval", 5, "Time between each bleed tick (in seconds)", nil, {
	data = {min = 0, max = 100},
	category = "Medical"
})

--==Fracture==--
nut.config.add("Fracture Chance", 10, "Chance of damage to cause a fracture (in %)", nil, {
	data = {min = 0, max = 100},
	category = "Medical"
})

--==Healing==--

nut.config.add("Healing Per Injury", 8, "How long does it take to heal one injury", nil, {
	data = {min = 0, max = 60},
	category = "Medical"
})

nut.config.add("Healing Per Injury Trained", 3, "How long does it take to heal one injury if you medically trained", nil, {
	data = {min = 0, max = 60},
	category = "Medical"
})

nut.config.add("Medical Wastefulness", 5, "How much extra pieces of items do non-medical players use up when tending to injuries", nil, {
	data = {min = 0, max = 60},
	category = "Medical"
})

--==Resurrect==--
nut.config.add("Toggle Revive", true, "If true revive mode will be active.", nil, {
	category = "Revive"
})

nut.config.add("Revive Time", 15, "How long it should take to revive someone without any tools.", nil, {
	data = {min = 1, max = 60},
	category = "Revive"
})

nut.config.add("Revive Time Defib", 3, "How long it should take to revive someone with a defibrillator.", nil, {
	data = {min = 1, max = 60},
	category = "Revive"
})

nut.config.add("Revive Threshold", 30, "How long until a player is no longer able to be revived.", nil, {
	data = {min = 1, max = 60},
	category = "Revive"
})

nut.config.add("Defib Recharge", 3, "How long does a defib recharge.", nil, {
	data = {min = 1, max = 60},
	category = "Revive"
})