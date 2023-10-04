ITEM.name = "Ampule of Erythropoietin"
ITEM.model = "models/carlsmei/escapefromtarkov/medical/sj1.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "An auto-injector needle with multiple ampules of various medical drugs, such as recombinant erythropoietins and sargramostims, used as for bone marrow stimulation and blood cell production"
ITEM.genericMedical = true
ITEM.healAmount = 5
ITEM.price = 100
ITEM.uniqueID = "medical_salve"
ITEM.limbHealing = true
ITEM.maxSize = 20
ITEM.treatString = "Applying Erythropoietin medication to the "
ITEM.treatSound = "physics/flesh/flesh_bloody_impact_hard1.wav"

function ITEM:action(client, target, targetChar, limb)
	target:ScreenFade(1, Color(0, 255, 255, 100), 0.4, 0)
	target:EmitSound(self.treatSound)
    local healAmount = self.healAmount
	timer.Create("RegenerateLimbSalve"..targetChar:getID(), 3, 30, function()
        if targetChar:getHitpoints(limb) < 100 then
            targetChar:setHitpoints(limb, math.min(targetChar:getHitpoints(limb) + healAmount), 100)
        else
            timer.Remove("RegenerateLimbSalve"..targetChar:getID())
        end
    end)
end