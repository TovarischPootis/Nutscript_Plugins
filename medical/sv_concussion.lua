local PLUGIN = PLUGIN
local charMeta = nut.meta.character
util.AddNetworkString("updateConcussStatus")

function charMeta:addTempConcussion(duration, forpill)
    if self:isImmune("concussion") then return end
    net.Start("updateConcussStatus")
    net.WriteBool(true) -- is concussed?
    net.WriteBool(false) -- is permanent?
    net.WriteUInt(duration, 7)
    net.WriteBool(forpill or false)
    net.Send(self:getPlayer())
end

function charMeta:addConcussion()
    if self:isImmune("concussion") then return end
    local headInjuries = self:getInjuries("head")
    if not headInjuries.concussion then
        self:setInjuries("head", "concussion", PLUGIN.injuryText.concussion[math.random(#PLUGIN.injuryText.concussion)])
        net.Start("updateConcussStatus")
            net.WriteBool(true) -- is concussed?
            net.WriteBool(true) -- is permanent?
        net.Send(self:getPlayer())
    end
end

function charMeta:removeConcussion()
    self:setInjuries("head", "concussion", nil)
    net.Start("updateConcussStatus")
        net.WriteBool(false) -- is concussed?
        net.WriteBool(true) -- is permanent?
    net.Send(self:getPlayer())
end

function charMeta:treatConcussion(duration)
    self:addTempConcussion(3, true)
    timer.Simple(3, function()
        net.Start("updateConcussStatus")
            net.WriteBool(false) -- is concussed?
            net.WriteBool(false) -- is permanent?
            net.WriteUInt(duration-3, 7)
        net.Send(self:getPlayer())
    end)
end