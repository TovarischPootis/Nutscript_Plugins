local PLUGIN = PLUGIN

surface.CreateFont("healMenuFont", {
	 font = nut.config.get("font"),
	 size = 35,
	 weight = 500,
	 blursize = 0,
	 scanlines = 0,
	 antialias = true
})

local limbTable = {head = 1, chest = 2, abdomen = 3, left_arm = 4, right_arm = 5, left_leg = 6, right_leg = 7}

local ScrW, ScrH = ScrW(), ScrH()
local menuWide = ScrW*0.2
local targetID = targetID or nil
local targetHP = targetHP or 0
local targetTable = targetTable or nil
local targetEnt
local curLimb = "head"
local floor, sin, abs = math.floor, math.sin, math.abs
local inv = {}
local legsConVar

local function drawAdministerMeds(panel, category)
    local data = {}
    for _, item in pairs(inv:getItems()) do
        if item[category] == true  and not data[item.uniqueID] then
            data[item.uniqueID] = item
        end
    end
    local itemmenu = panel:GetParent():Add("MedicalSelectTreatmentMedMenu")
    itemmenu:drawMeds(data)
end

local function requestMedicalInfoUpdate(infoType, curlimb)
    net.Start("requestMedicalInfoUpdate")
    net.WriteString(targetID)
    net.WriteString(infoType)
    if curlimb then
        net.WriteString(curlimb )
    end
    net.SendToServer()
end

local function requestAdministerMed(item, limb)
    net.Start("requestAdministerMed")
    net.WriteString(targetID)
    net.WriteString(limb)
    net.WriteString(tostring(item:getID()))
    net.SendToServer()
end

local function properLimbOrder(panel, curnum)
    for limb, order in pairs(limbTable) do
        if order == curnum then
            panel.buttons[limb] = vgui.Create("MedicalLimbButton")
            panel.buttons[limb]:setLimb(limb)
            panel:Add(panel.buttons[limb])
            panel.buttons[limb]:InvalidateLayout(true)
            panel.buttons[limb]:SetTall(ScrH/(table.Count(limbTable)))

            curnum = curnum + 1
        end
    end
    if curnum ~= 8 then
        properLimbOrder(panel, curnum)
    end
end

local function lookAtTarget(client, pos, angles, fov) -- custom function that sets the camera when in menu
        if not savedView then savedView = {} end
        local aimVector = targetEnt:GetAimVector()
        local targetPos = targetEnt:GetShootPos()
        local origin = targetPos + (aimVector *  60)
        local x, y, z = origin[1], origin[2], targetPos[3]
        savedView.origin = Vector(x, y, z)
        local newAngles = (targetPos - origin):Angle() -- the angle of the camera, get the angle between the player's position and where they are looking at
        local pitch, yaw, roll = 10, newAngles[2], newAngles[3] -- saves the angles of the camera, but keeps the pitch constant, that way the camera is always looking at the player
        savedView.angles = Angle(pitch, yaw, roll)
        savedView.drawviewer = targetEnt == client and true or false -- draw's the player's playermodel
	return savedView
end

local function hideSWEPwhileinMenu()
    return Vector(0,0,0), Angle(0,0,0)
end

local function toggleViewHooks(enabled)
    if enabled then
        hook.Add("CalcView", "nutMedicalHealMenu", lookAtTarget)
        hook.Add("CalcViewModelView", "nutMedicalHealMenu", hideSWEPwhileinMenu)
        if ConVarExists("cl_legs") then
            local legs = GetConVar("cl_legs")
            legsConVar = legs:GetBool()
            legs:SetBool(false)
        end
    else
        hook.Remove("CalcView", "nutMedicalHealMenu")
        hook.Remove("CalcViewModelView", "nutMedicalHealMenu")
        if ConVarExists("cl_legs") then
            GetConVar("cl_legs"):SetBool(legsConVar)
        end
    end
end

local PANEL = {} -- left side button

function PANEL:Init()
    self.isDButton = true
    self:SetIsToggle(true)
end

function PANEL:Paint(w, h)
    local isInjured = table.Count(targetTable[self.limb]) > 1
    self.curColor = math.Approach(self.curColor, self:GetToggle() and 215 or 150, 1)

     for i = 0, w do
        surface.SetDrawColor(self.curColor, isInjured and 0 or self.curColor, isInjured and 0 or self.curColor, (0.1*sin(2*CurTime())+0.9) *(255 - floor(255*(i/w))))
        surface.DrawRect(i, 0, 1, h)
    end

end

function PANEL:setLimb(limb)
    assert(limb and isstring(limb), "limb for ".. self:GetClassName().. " was incorrect")
    self.limb = limb
    self.curColor = 150

    if limb == "head" then
        self:SetToggle(true)
        self.curColor = 215
    end

    self.DoClick = function()
        PLUGIN:updateCurLimb(limb)
        self:SetToggle(true)
        for _, v in pairs(self:GetParent():GetChildren()) do
            if v ~= self then
                v:SetToggle(false)
            end
        end
    end
    self.DoRightClick = function()
        Derma_Query("Rediagnose limb?", "Rediagnose limb?",
        "Yes", function()
            requestMedicalInfoUpdate(limb)
        end,
        "No", function() end)
    end
    self:SetFont("healMenuFont")
    self:SetText(PLUGIN:fixedLimbText(limb))
end

vgui.Register("MedicalLimbButton", PANEL, "DButton")

PANEL = {}

function PANEL:Init()
    if nut.gui.medicalLimbSelectionMenu then
        nut.gui.medicalLimbSelectionMenu:Remove()
    end
    nut.gui.medicalLimbSelectionMenu = self
    self.buttons = {}
    properLimbOrder(self, 1)
end

vgui.Register("MedicalLimbSelectionMenu", PANEL, "DListLayout")

PANEL = {}

function PANEL:Init()
    if nut.gui.healthMenuTreatMenu then
        nut.gui.healthMenuTreatMenu:Remove()
    end

    nut.gui.healthMenuTreatMenu = self
    self.childCount = 0
    --HP button
    self.healthButton = self:Add("DButton")
    self.healthButton.isDButton = true
    self.healthButton:SetFont("healMenuFont")
    self.healthButton:SetText("Patient Blood Level: ".. targetHP.. "%")

    self.healthButton:SizeToContents()
    self.healthButton.DoClick = function()
        drawAdministerMeds(self, "healing")
    end
    self.healthButton.DoRightClick = function()
        Derma_Query("Rediagnose blood level?", "Rediagnose blood level?",
        "Yes", function()
            requestMedicalInfoUpdate("hp")
        end,
        "No", function() end)
    end
    self.healthButton.Paint = function(this, w, h)
    for i = 0, w do
        hp = targetHP/100
        surface.SetDrawColor(215*(1-hp), 0.5*215*hp, 0, (0.1*sin(2*CurTime())+0.9) * (255 - (255 - floor(255*(i/w)))))
        surface.DrawRect(i, 0, 1, h)
    end
    end
    self.healthButton:Dock(TOP)
    self.childCount = self.childCount + 1

    --Limbs button label
    self.limbLabel = self:Add("DLabel")
    self.limbLabel:SetFont("healMenuFont")
    self.limbLabel:SetText(PLUGIN:fixedLimbText(curLimb))
    self.limbLabel:SizeToContents()
    self.limbLabel:Dock(TOP)
    self.childCount = self.childCount + 1

    --Limbs buttons
    local healthyCheck = false

    for injury, desc in pairs(targetTable[curLimb]) do
        if injury ~= "hitpoints" then
            self:addInjuryField(injury, desc)
            healthyCheck = true
        end
    end

    if not healthyCheck then
        self.healthyLabel = self:Add("DLabel")
        self.healthyLabel:SetFont("healMenuFont")
        self.healthyLabel:SetText("Limb unaffected by injuries")
        self.healthyLabel:SizeToContents()
        self.healthyLabel:Dock(TOP)
        self.childCount = self.childCount + 1
    end

    -- limb hitpoints button
    self.hitpointButton = self:Add("DButton")
    self.hitpointButton.isDButton = true
    self.hitpointButton:SetFont("healMenuFont")
    self.hitpointButton:SetText("Limb Efficiency: ".. targetTable[curLimb].hitpoints)
    self.hitpointButton:SizeToContents()
    self.hitpointButton.DoClick = function()
        drawAdministerMeds(self, "limbHealing")
    end
    self.hitpointButton.DoRightClick = function()
        Derma_Query("Rediagnose limb efficiency?", "Rediagnose limb efficiency?",
        "Yes", function()
            requestMedicalInfoUpdate("curLimb", curLimb)
        end,
        "No", function() end)
    end
    self.hitpointButton.Paint = function(this, w, h)
        for i = 0, w do
            hp = targetTable[curLimb].hitpoints/100
            surface.SetDrawColor(215*(1-hp), 0.5*215*hp, 0, (0.1*sin(2*CurTime())+0.9) * (255 - (255 - floor(255*(i/w)))))
            surface.DrawRect(i, 0, 1, h)
        end
    end
    self.hitpointButton:Dock(TOP)
    self.childCount = self.childCount + 1

    self.closebutton = self:Add("DButton")
    self.closebutton.isDButton = true
    self.closebutton:SetFont("healMenuFont")
    self.closebutton:SetText("Exit Menu")
    self.closebutton:SizeToContents()
    self.closebutton.DoClick = function()
        Derma_Query("Exit Menu?", "",
        "Yes", function()
            self:GetParent():Remove()
            nut.gui.healthMenu:Remove()
            toggleViewHooks(false)
        end,
        "No", function() end)
    end
    self.closebutton.Paint = function(this, w, h)
        for i = 0, w do
            surface.SetDrawColor(255,255,255, (0.1*sin(2*CurTime())+0.9) * (255 - (255 - floor(255*(i/w)))))
            surface.DrawRect(i, 0, 1, h)
        end
    end
    self.closebutton:Dock(TOP)
    self.childCount = self.childCount + 1

    self:InvalidateChildren(true)
    for _, v in pairs(self:GetChildren()) do
        v:DockMargin(v.isDButton and 0 or (menuWide/2 - v:GetContentSize()/2), v.isDButton and 0 or ScrH/(2*(self.childCount + 4)), 0, v.isDButton and 0 or ScrH/(2*(self.childCount + 4)))
        if v.isDButton then
            v:SetTall(ScrH/(self.childCount + 1))
        end
    end
end

function PANEL:addInjuryField(injury, desc)
    assert(injury and desc, "injury either missing name or desc, go fix it")

    self[injury.."Button"] = self:Add("DButton")
    self[injury.."Button"].isDButton = true
    self[injury.."Button"]:SetFont("healMenuFont")
    self[injury.."Button"]:SetText(PLUGIN:fixedLimbText(injury)..": "..desc)
    self[injury.."Button"]:SetWrap(true)
    self[injury.."Button"]:SizeToContents()
    self[injury.."Button"].DoClick = function()
        drawAdministerMeds(self, injury.."Treat")
    end
    self[injury.."Button"].Paint = function(this, w, h)
        for i = 0, w do
            hp = targetTable[curLimb].hitpoints/100
            surface.SetDrawColor(150*(1-hp)+65, 0, 0, (0.1*sin(2*CurTime())+0.9) * (255 - (255 - floor(255*(i/w)))))
            surface.DrawRect(i, 0, 1, h)
        end
    end
    self[injury.."Button"]:Dock(TOP)
    self.childCount = self.childCount + 1
end

function PANEL:Paint()
end

vgui.Register("MedicalLimbTreatmentMenu", PANEL, "DPanel")

PANEL = {}

function PANEL:Init()
    if nut.gui.selectMedToTreat then
        nut.gui.selectMedToTreat:Remove()
    end

    nut.gui.selectMedToTreat = self
    self:SetPos(menuWide, ScrH*0.6)
    self:SetSize(ScrW - (2*menuWide), ScrH*0.4)
end

function PANEL:drawMeds(data)
    for k, item in pairs(data) do
        self["option"..k] = self:Add("DButton")
        self["option"..k]:SetFont("healMenuFont")
        self["option"..k]:SetText("Administer "..item.name)
        self["option"..k].DoClick = function()
            Derma_Query("Administer"..item.name.."?", "Administer"..item.name.."?",
            "Yes", function()
               requestAdministerMed(item, curLimb)
               self:Remove()
               inv = LocalPlayer():getChar():getInv()
            end,
            "No", function() end)
        end
        self["option"..k].Paint = function(this, w, h)
            for i = 0, w do
                local newi = abs(i- (w/2))
                surface.SetDrawColor(215, 215, 215, (0.1*sin(2*CurTime())+0.9) *
                (128 - 255*(newi/w)))
                surface.DrawRect(i, 0, 1, h)
            end
        end
        self["option"..k]:SetTall((ScrH*0.4)/(#self:GetChildren() + 1))
        self["option"..k]:Dock(BOTTOM)
    end
end

function PANEL:Paint()
end

vgui.Register("MedicalSelectTreatmentMedMenu", PANEL, "DPanel")

PANEL = {}

function PANEL:Init()
    if nut.gui.healthMenu then
        nut.gui.healthMenu:Remove()
    end
    nut.gui.healthMenu = self

    self:SetSize(ScrW, ScrH)

    self.limbSelectionMenu = self:Add("MedicalLimbSelectionMenu")
    self.limbSelectionMenu:SetSize(menuWide, ScrH)

    self.limbTreatmentMenu = self:Add("MedicalLimbTreatmentMenu")
    self.limbTreatmentMenu:SetSize(menuWide, ScrH)
    self.limbTreatmentMenu:SetPos(ScrW-menuWide, 0)

    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
end

function PANEL:Paint()
end

function PANEL:OnRemove()
    net.Start("endHealingWithMenu")
    net.WriteEntity(targetEnt)
    net.SendToServer()

    if nut.gui.menu then nut.gui.menu:Remove() end
end

function PLUGIN:updateCurLimb(limb)
    if not nut.gui.healthMenu then return end
    if nut.gui.selectMedToTreat then
        nut.gui.selectMedToTreat:Remove()
    end

    curLimb = limb
    nut.gui.healthMenu.limbTreatmentMenu = nut.gui.healthMenu:Add("MedicalLimbTreatmentMenu")
    nut.gui.healthMenu.limbTreatmentMenu:SetSize(menuWide, ScrH)
    nut.gui.healthMenu.limbTreatmentMenu:SetPos(ScrW-menuWide, 0)
end

vgui.Register("MedicalHealthMenu", PANEL, "DFrame")

net.Receive("drawMedicalHealthMenu", function()
    local title = net.ReadString()
    targetID = net.ReadString()
    targetHP = net.ReadUInt(7)
    targetTable = net.ReadTable()
    targetEnt = net.ReadEntity()

    inv = LocalPlayer():getChar():getInv()
    curLimb = "head"

    local healthMenu = vgui.Create("MedicalHealthMenu")
    healthMenu:SetTitle(title)
    toggleViewHooks(true)
end)

net.Receive("requestMedicalInfoUpdate", function()
    local id = net.ReadString()
    if id ~= targetID then return end
    local info = net.ReadString()

    if PLUGIN.defaultValues.hitpoints[info] ~= nil then -- if info was a limb
        local hitpoints = net.ReadUInt(7)
        local injuries = {}
        local injuryCount = net.ReadUInt(2)

        if injuryCount > 0 then
            for _ = 1, injuryCount do
                local index = net.ReadString()
                injuries[index] = net.ReadString()
            end
        end

        targetTable[info] = injuries
        targetTable[info].hitpoints = hitpoints

        for k, v in pairs(nut.gui.medicalLimbSelectionMenu:GetChildren()) do
            if v.limb == info and v:GetToggle() then
                v:setLimb(info)
            end
        end
    elseif info == "hp" then
        targetHP = net.ReadUInt(7)
        nut.gui.healthMenuTreatMenu.healthButton:SetText("Patient Blood Level: ".. targetHP.. "%")
    elseif info == "curLimb" then
        targetTable[curLimb].hitpoints = net.ReadUInt(7)
        nut.gui.healthMenuTreatMenu.hitpointButton:SetText("Limb Efficiency: ".. targetTable[curLimb].hitpoints)
    end
end)

nut.playerInteract.addFunc("diagnose", {
	name = "Administer First Aid",
	callback = function(target)
		net.Start("diagnoseDirect")
        net.WriteEntity(target)
        net.SendToServer()
	end,
	canSee = function()
		return true
	end
})

PANEL = {}

function PANEL:Init()
    if nut.gui.healthMenuPatientMenu then
        nut.gui.healthMenuPatientMenu:Remove()
    end
    nut.gui.healthMenuPatientMenu = self
    self:SetSize(ScrW, ScrH)
    self.quitButton = self:Add("DButton")
    self.quitButton:SetTall(ScrH*0.2)
    self.quitButton:SetFont("healMenuFont")
    self.quitButton:SetText("Cancel Treatment")
    self.quitButton:Dock(BOTTOM)
    self.quitButton:DockMargin(ScrH*0.25, 0, ScrH*0.25, 0)
    self.quitButton.Paint = function(this, w, h)
        for i = 0, w do
            local newi = abs(i- (w/2))
            surface.SetDrawColor(215, 215, 215, (0.1*sin(2*CurTime())+0.9) *
            (128 - 255*(newi/w)))
            surface.DrawRect(i, 0, 1, h)
        end
    end
    self.quitButton.DoClick = function()
        Derma_Query("Cancel Treatment?", "",
        "Yes", function()
            self:Remove()
            net.Start("endHealingWithMenu")
            net.SendToServer()
        end,
        "No", function() end)
    end

    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDraggable(false)
    self:ShowCloseButton(false)
end

function PANEL:Paint()
end

vgui.Register("MedicalPatientScreen", PANEL, "DFrame")

net.Receive("healingTargetMenu", function()
    local isHealed = net.ReadBool()

    if isHealed then
        if targetEnt ~= LocalPlayer() then
            vgui.Create("MedicalPatientScreen")
        end
    else
        if nut.gui.healthMenuPatientMenu then nut.gui.healthMenuPatientMenu:Remove() end
        if nut.gui.healthMenu then nut.gui.healthMenu:Remove() end
        toggleViewHooks(false)
    end
end)

hook.Add("CreateMenuButtons", "nutSelfHealth", function(tabs)
	tabs["Health"] = function(panel)
		timer.Simple(0, function()
            if not IsValid(nut.gui.healthMenu) then
                net.Start("diagnoseDirect")
                net.SendToServer()
            end
		end)
	end
end)