local PLUGIN = PLUGIN

if SERVER then
    function PLUGIN:OnCharCreated(client, char)
        local faction = nut.faction.indices[char:getFaction()]


        if not faction.rankTable then char:setRank("") return end

        local rank = faction.rankTable[1]
        char:setRank(rank)
    end

    function PLUGIN:CharacterFactionTransfered(character, oldFaction, faction)
        character:setRank(faction.rankTable and faction.rankTable[1] or "")
    end
end

function PLUGIN:GetDisplayedName(speaker)
    local char = speaker:getChar()
    return char:getRank() ~= "" and char:getRank() .. " " .. char:getName()
end

function PLUGIN:ShouldAllowScoreboardOverride(client, var)
    if var == "name" and client:getChar():getRank() ~= "" then
        return true
    end
end


