if SERVER then
	nut.db.waitForTablesToLoad()
	:next(function()
		nut.db.query("ALTER TABLE nut_characters ADD COLUMN _rank VARCHAR(255)")
		:catch(function() end)
	end)
end

do
    nut.char.registerVar("rank", {
        default = "",
        noDisplay = true,
        field = "_rank",
        onSet = function(char, value)
            local oldVar = char.vars.rank
                char.vars.rank = value
            netstream.Start(nil, "charSet", "rank", value, char:getID())

            hook.Run("OnCharVarChanged", char, "rank", oldVar, value)
        end,
        onGet = function(char, default)
            return char.vars.rank or default or ""
        end
    })
end