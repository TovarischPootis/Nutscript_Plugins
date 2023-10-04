
local function brokenArmWeaponShake(wep, viewmodel, oldPos, oldAng, pos, ang)
    if not LocalPlayer():getChar() then return end
    local vm_ang = ang
    local jump = math.random(10)
    jump = math.max(jump-4, 1)
    local hitpointStats = LocalPlayer():getChar():getHitpoints()
    local multiplier = (200 - (hitpointStats.left_arm + hitpointStats.right_arm))/20

    local randAng = Angle(math.Rand(-0.02, 0.02)*jump*multiplier, math.Rand(-0.02, 0.02)*jump*multiplier, math.Rand(-0.02, 0.02)*jump*multiplier)
    vm_ang:RotateAroundAxis(vm_ang:Up(), randAng.p)
	vm_ang:RotateAroundAxis(vm_ang:Forward(), randAng.y)
	vm_ang:RotateAroundAxis(vm_ang:Right(), randAng.r)
end

function PLUGIN:Think()
    if not LocalPlayer():getChar() then return end
    local check = false
    for k, v in pairs(LocalPlayer():getChar():getInjuries()) do
        if k == "left_arm" or k == "right_arm" and v.fracture ~= nil then
            check = true
        end
    end
    if check then
        --hook.Add("CalcViewModelView", "nutMedicalFractureShake", brokenArmWeaponShake)
    else
        hook.Remove("CalcViewModelView", "nutMedicalFractureShake")
    end
end