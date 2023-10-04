ITEM.name = "Ampule of Morphine"
ITEM.model = "models/carlsmei/escapefromtarkov/medical/morphine.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "An auto-injector needle with multiple small Morphine Ampules, used as a painkiller and relaxant"
ITEM.genericMedical = true
ITEM.healAmount = 2
ITEM.healing = true
ITEM.price = 100
ITEM.uniqueID = "medical_morphine"
ITEM.treatString = "Injecting a shot of Morphine to the "
ITEM.treatSound = "items/medshot4.wav"

function ITEM:action(client, target, targetChar)
    target:ScreenFade(1, Color(0, 255, 0, 100), 1, 0)
    target:EmitSound(self.treatSound)
    local healAmount = self.healAmount
    target:SetHealth(math.min(target:Health() + (healAmount*10), target:GetMaxHealth()))
    timer.Create("RegenerateHPMorphine"..targetChar:getID(), 5, 30, function()
        if target:Health() < target:GetMaxHealth() then
            target:SetHealth(math.min(target:Health() + healAmount, target:GetMaxHealth()))
            target:ScreenFade(1, Color(0, 255, 0, 25), 0.75, 0)
        else
            timer.Remove("RegenerateHPMorphine"..target:getChar():getID())
        end
    end)
end
ITEM.maxSize = 20