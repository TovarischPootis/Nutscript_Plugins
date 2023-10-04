local PLUGIN = PLUGIN
util.AddNetworkString("drawMedicalHealthMenu")
util.AddNetworkString("requestMedicalInfoUpdate")
util.AddNetworkString("requestAdministerMed")
util.AddNetworkString("diagnoseDirect")
util.AddNetworkString("endHealingWithMenu")
util.AddNetworkString("healingTargetMenu")

PLUGIN.healPartners = {}

local function startHealing(client, target)
    PLUGIN.healPartners[client] = target
    client:Freeze(true)
    target:Freeze(true)
end

local function endHealing(client, target)

    PLUGIN.healPartners[client] = nil

    local clientcheck, targetcheck = false, false

    for k, v in pairs(PLUGIN.healPartners) do
        if v == client then clientcheck = true end
        if v == target then targetcheck = true end
    end

    if not clientcheck then client:Freeze(false) end
    if not targetcheck then target:Freeze(false) end

    net.Start("healingTargetMenu")
    net.WriteBool(false)
    net.Send(client)

    net.Start("healingTargetMenu")
    net.WriteBool(false)
    net.Send(target)
end

function PLUGIN:sendMedicalMenu(client, target)
    startHealing(client, target)
    local char = client:getChar()
    local targetChar = target:getChar()
    net.Start("drawMedicalHealthMenu")
    net.WriteString(char:isMedical() and "Tend to injuries" or "Apply First Aid")
    net.WriteString(tostring(targetChar:getID()))
    net.WriteUInt(math.ceil((target:Health()/target:GetMaxHealth())*100), 7)

    local hitpoints = targetChar:getHitpoints()
    local injuries = targetChar:getInjuries()
    local tableToSend = table.Copy(injuries)
    for k in pairs(self.defaultValues.hitpoints) do
        tableToSend[k].hitpoints = hitpoints[k]
    end
    net.WriteTable(tableToSend)
    net.WriteEntity(target)
    net.Send(client)

    net.Start("healingTargetMenu")
    net.WriteBool(true)
    net.Send(target)
end

net.Receive("requestMedicalInfoUpdate", function(_, client)
    local targetIDString = net.ReadString()
    local targetID = tonumber(targetIDString)
    local targetChar = nut.char.loaded[targetID]
    local target = targetChar:getPlayer()
    local info = net.ReadString() -- could be limb,
    if not (targetChar and info) then return end -- don't run code if the target char or request type are missing

    local timeToComplete = nut.config.add("Diagnosis Time", 5)
    if PLUGIN.defaultValues.hitpoints[info] ~= nil then -- if info was a limb
        target:setAction("The medical assistant is diagnosing your "..PLUGIN:fixedLimbText(info), timeToComplete)
        client:setAction("Diagnosing patient's "..PLUGIN:fixedLimbText(info), timeToComplete, function()
            net.Start("requestMedicalInfoUpdate")
            net.WriteString(targetIDString)
            net.WriteString(info)

            local hitpoints = targetChar:getHitpoints()[info]
            local injuries = targetChar:getInjuries()[info]

            net.WriteUInt(hitpoints, 7) -- send hitpoints data
            net.WriteUInt(table.Count(injuries), 2) -- could only be 0-3
            for injury, desc in pairs(injuries) do
                net.WriteString(injury)
                net.WriteString(desc)
            end
            net.Send(client)
        end)
    elseif info == "hp" then
        target:setAction("The medical assistant is diagnosing your vitals", timeToComplete)
        client:setAction("Diagnosing patient's vitals", timeToComplete, function()
            net.Start("requestMedicalInfoUpdate")
            net.WriteString(targetIDString)
            net.WriteString("hp")
            net.WriteUInt(math.ceil(targetChar:getPlayer():Health()/targetChar:getPlayer():GetMaxHealth()*100), 7)
            net.Send(client)
        end)
    elseif info == "curLimb" then
        local curLimb = net.ReadString()
        target:setAction("The medical assistant is diagnosing your "..PLUGIN:fixedLimbText(curLimb).."'s efficiency", timeToComplete)
        client:setAction("Diagnosing patient's "..PLUGIN:fixedLimbText(curLimb).."'s efficiency", timeToComplete, function()
            local hitpoints = targetChar:getHitpoints(curLimb)
            net.Start("requestMedicalInfoUpdate")
            net.WriteString(targetIDString)
            net.WriteString("curLimb")
            net.WriteUInt(hitpoints, 7)
            net.Send(client)
        end)
    end
end)

net.Receive("requestAdministerMed", function(_, client)
    local targetID = net.ReadString()
    local targetChar = nut.char.loaded[tonumber(targetID)]
    local target = targetChar:getPlayer()
    local limb = net.ReadString()
    local itemID = net.ReadString()
    local item = nut.item.instances[tonumber(itemID)]
    local char = client:getChar()

    if not (targetChar and limb and item and char) then return end
    if item.invID ~= char:getInv():getID() then return end -- don't run code if the item is not actually in the char's inventory
    if not (PLUGIN.healPartners[client] and PLUGIN.healPartners[client] == target) then return end -- don't run code if the the target is not the healpartner of the healer
    if PLUGIN.defaultValues.hitpoints[limb] ~= nil then
        local timeToTreat = char:isMedical() and nut.config.get("Healing Per Injury Trained", 3) or nut.config.get("Healing Per Injury", 8)
        target:setAction("The medical assistant is"..item.treatString..PLUGIN:fixedLimbText(limb), timeToTreat)
        client:setAction(item.treatString..PLUGIN:fixedLimbText(limb), timeToTreat, function()
            local amount = char:isMedical() and 1 or nut.config.get("Medical Wastefulness", 5)
            item:action(client, targetChar:getPlayer(), targetChar, limb)
            item:setData("quantity", math.max(item:getData("quantity", 1) - amount, 0))
            if item:getData("quantity", 1) == 0 then item:remove() end
            hook.Run("updateMedicalSkill", char)

            if not nut.config.get("Enable Diagnosis", false) then
                net.Start("requestMedicalInfoUpdate")
                net.WriteString(targetID)
                net.WriteString(limb)

                local hitpoints = targetChar:getHitpoints()[limb]
                local injuries = targetChar:getInjuries()[limb]

                net.WriteUInt(hitpoints, 7) -- send hitpoints data
                net.WriteUInt(table.Count(injuries), 2) -- could only be 0-3
                for injury, desc in pairs(injuries) do
                    net.WriteString(injury)
                    net.WriteString(desc)
                end
                net.Send(client)
            end
        end)
    end
end)

net.Receive("diagnoseDirect", function(_, client)
    local target = net.ReadEntity() or nil
    if not target or not target:IsPlayer() or target:GetClass() == "worldspawn" then
        target = client
    end
    PLUGIN:sendMedicalMenu(client, target)
end)

net.Receive("endHealingWithMenu", function(_, client)
    local target = net.ReadEntity() or nil
    if not target or target:GetClass() == "worldspawn" then
        for k, v in pairs(PLUGIN.healPartners) do
            if v == client then
                client = k
                target = v
            end
        end
    end
    endHealing(client, target)
end)