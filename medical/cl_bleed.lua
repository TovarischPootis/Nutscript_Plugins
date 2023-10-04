local PLUGIN = PLUGIN
PLUGIN.isBleeding = isBleeding or false

local bleedTime = bleedTime or nil
local bleedStart = CurTime()
local bleedEnd = nut.config.get("Bleed Interval", 5)
local bleedVignette = nut.util.getMaterial("medical/screendamage.png")
local curAlpha = 255
local scrW, scrH = ScrW(), ScrH()

local function drawBleedSplash()
    bleedTime = math.min(CurTime() - bleedStart, bleedEnd)
    curAlpha = 255 - nut.ease.easeOut(bleedTime, bleedEnd, 0, 255)
    if bleedTime >= bleedEnd then
        curAlpha = 255
        bleedStart = CurTime()
    end
    surface.SetDrawColor(255, 255, 255, curAlpha)
	surface.SetMaterial(bleedVignette)
	surface.DrawTexturedRect(0, 0, scrW, scrH)
end

net.Receive("updateBleedStatus", function()
    PLUGIN.isBleeding = net.ReadBool()
    if PLUGIN.isBleeding ~= false then
        bleedStart = CurTime()
        bleedEnd = nut.config.get("Bleed Interval", 5)
        hook.Add("HUDPaintBackground", "nutMedicalDrawBleedEffect", drawBleedSplash)
    else
        hook.Remove("HUDPaintBackground", "nutMedicalDrawBleedEffect")
    end
end)