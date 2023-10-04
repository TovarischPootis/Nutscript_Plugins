nut.char = nut.char or {}
local PLUGIN = PLUGIN

if SERVER then
	nut.db.waitForTablesToLoad()
	:next(function()
		nut.db.query("ALTER TABLE nut_characters ADD COLUMN _injuries VARCHAR(255)")
		:catch(function() end)
	end):next(function()
		nut.db.query("ALTER TABLE nut_characters ADD COLUMN _hitpoints VARCHAR(255)")
		:catch(function() end)
	end)
end
do
	nut.char.registerVar("injuries", {
		field = "_injuries",
		default = PLUGIN.defaultValues.injuries,
		onSet = function(char, data, secData, triData)
			if not secData then -- data is injuryTable
				char.vars.injuries = data
			else
				-- data is limb, secData is status, triData is nil or desc
				local injuries = table.Copy(char.vars.injuries)
				injuries[data][secData] = triData

				char.vars.injuries = injuries
			end
		end,
		onGet = function(char, limb, default)

--[[ 			local value = char.vars.injuries[limb]

			if (value ~= nil) then
				return value
			end

			if (limb == nil) then
				return char.vars.injuries or nut.char.vars.injuries.default or nil
			end

			return default ]]

			local injuries = char.vars.injuries
			if limb and char.vars.injuries[limb] ~= nil then
				return char.vars.injuries[limb]
			elseif limb == nil then
				return injuries or default or nil
			else
				return default
			end
		end
	})

    nut.char.registerVar("hitpoints", {
		field = "_hitpoints",
		default = PLUGIN.defaultValues.hitpoints,
		onSet = function(char, data, secData)
			if not secData then
				char.vars.hitpoints = data
			else
				local hitpoints = table.Copy(char.vars.hitpoints)
				hitpoints[data] = secData

				char.vars.hitpoints = hitpoints
			end
		end,
		onGet = function(char, limb, default)
			--[[ local value = char.vars.hitpoints[limb]

			if (value ~= nil) then
				return value
			end

			if (limb == nil) then
				return char.vars.hitpoints or nut.char.vars.hitpoints.default or nil
			end

			return default or limb ]]
			local hitpoints = char.vars.hitpoints
			if limb and char.vars.hitpoints[limb] ~= nil then
				return char.vars.hitpoints[limb]
			elseif limb == nil then
				return hitpoints or default or nil
			else
				return default or limb
			end
		end
	})
end
