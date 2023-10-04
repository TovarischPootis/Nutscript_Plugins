local PLUGIN = PLUGIN
PLUGIN.isConcussed = PLUGIN.isConcussed or false
PLUGIN.isPilled = PLUGIN.isPilled or false
local startTime = startTime or CurTime()
local duration = duration or 0
local prepilled = prepilled or false
PLUGIN.curDSP = PLUGIN.curDSP or 0

function PLUGIN:getCurDSP()
    return self.curDSP or 0
end

function PLUGIN:setCurDSP(val)
    self.curDSP = val
end
local function drawConcussBlur()
    local multiplier = (120 - LocalPlayer():getChar():getHitpoints("head"))/20
    local timeElapsed = math.min(CurTime() - startTime, duration)
    local fadeout = PLUGIN.isPilled and math.Clamp(0.9^(-timeElapsed + duration), 0, 1) or
        (PLUGIN.isConcussed and not prepilled) and 1 or
            (10 - nut.ease.easeOut(timeElapsed, duration, 0, 10))
    DrawMotionBlur(0.05 , 0.95 * multiplier * fadeout, 0.03)
    LocalPlayer():SetDSP(16)
end

local function setConcussEffects(permanent, dur)
    LocalPlayer():ScreenFade(1, Color(150, 0, 0, 100), 1, 0)
    if permanent then
        hook.Add("HUDPaintBackground", "nutMedicalConcussEffect", drawConcussBlur)
        PLUGIN.isConcussed = true
    else
        startTime= CurTime()
        duration = dur
        hook.Add("HUDPaintBackground", "nutMedicalConcussEffect", drawConcussBlur)
        timer.Simple(dur, function()
            if not PLUGIN.isConcussed then
                hook.Remove("HUDPaintBackground", "nutMedicalConcussEffect")
                LocalPlayer():SetDSP(PLUGIN.curDSP)
            end
        end)
    end
end

local function removeConcussEffects(perma, dur)
    prepilled = false
    if perma then
        PLUGIN.isConcussed = false
        hook.Remove("HUDPaintBackground", "nutMedicalConcussEffect")
        LocalPlayer():SetDSP(PLUGIN.curDSP)
    else
        PLUGIN.isPilled = true
        startTime= CurTime()
        duration = dur
        hook.Add("HUDPaintBackground", "nutMedicalConcussEffect", drawConcussBlur)
        timer.Simple(dur, function()
            PLUGIN.isPilled = false
            if not PLUGIN.isConcussed then
                hook.Remove("HUDPaintBackground", "nutMedicalConcussEffect")
                LocalPlayer():SetDSP(PLUGIN.curDSP)
            end
        end)
    end
end

net.Receive("updateConcussStatus", function()
    local enabled = net.ReadBool() -- is concussed?
    local perma = net.ReadBool() -- is permanent?
    local dur
    if not perma then
        dur = net.ReadUInt(7)
    end
    prepilled = net.ReadBool() or false

    if enabled then
        setConcussEffects(perma, dur)
    else
        removeConcussEffects(perma, dur)
    end
end)

