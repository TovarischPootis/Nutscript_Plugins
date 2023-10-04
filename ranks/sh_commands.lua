local PLUGIN = PLUGIN

nut.command.add("charsetrank", {
    syntax = "<string name> <string rank>",
    onRun = function(client, arguments)
        local target = nut.command.findPlayer(client, arguments[1])
        local rank = ""
        for i = 2, #arguments do
            rank = rank .." "..arguments[i]
        end

        if (IsValid(target)) then
            local char = target:getChar()
            char:setRank(rank)
            client:notify("You have set "..target:Name().."'s rank to "..rank..".")
            target:notify("Your rank has been set to "..rank..".")
        end
    end,
    onCheckAccess = function(client)
        return client:getChar():hasFlags(PLUGIN.rankFlag)
    end
})

nut.command.add("promote", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = nut.command.findPlayer(client, arguments[1])

        if (IsValid(target)) then
            local char = target:getChar()
            local curRank = char:getRank()
            local index, rank
            local rankTable = nut.faction.indices[char:getFaction()].rankTable

            if not rankTable then
                client:notify("Target's faction does not have ranks.")
                return
            end

            if curRank == nil then
                rank = rankTable[1]
            else
                index = table.KeyFromValue(rankTable, curRank) or 0
                if (index + 1) > #rankTable then
                    client:notify("This player is already at the highest rank.")
                    return
                end
                rank = rankTable[index + 1]
            end

            char:setRank(rank)
            client:notify("You have set "..target:Name().."'s rank to "..rank..".")
            target:notify("Your rank has been set to "..rank..".")
        end
    end,
    onCheckAccess = function(client)
        return client:getChar():hasFlags(PLUGIN.rankFlag)
    end
})

nut.command.add("demote", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local target = nut.command.findPlayer(client, arguments[1])

        if (IsValid(target)) then
            local char = target:getChar()
            local curRank = char:getRank()
            local index, rank
            local rankTable = nut.faction.indices[char:getFaction()].rankTable

            if not rankTable then
                client:notify("Target's faction does not have ranks.")
                return
            end

            if curRank == nil then
                rank = rankTable[1]
            else
                index = table.KeyFromValue(rankTable, curRank) or 2
                if (index - 1) <= 0 then
                    client:notify("This player is already at the lowest rank.")
                    return
                end
                rank = rankTable[index - 1]
            end

            char:setRank(rank)
            client:notify("You have set "..target:Name().."'s rank to "..rank..".")
            target:notify("Your rank has been set to "..rank..".")
        end
    end,
    onCheckAccess = function(client)
        return client:getChar():hasFlags(PLUGIN.rankFlag)
    end
})