local PLUGIN = PLUGIN
local motionBlur = 0
local CVAR_nut_lowhealth_enabled = CreateClientConVar("nut_lowhealth_enabled", 1, true, true, "Enable Low Health Effects (0 = OFF/1 = ON)")
local CVAR_nut_lowhealth_heartbeat_sound = CreateClientConVar("nut_lowhealth_heartbeat_sound", 1, true, true, "Toggle Heartbeat Sounds (0 = OFF/1 = ON)")
local CVAR_nut_lowhealth_redflash = CreateClientConVar("nut_lowhealth_redflash", 1, true, true, "Toggle Red Flashing (0 = OFF/1 = ON)")
local CVAR_nut_lowhealth_vignette = CreateClientConVar("nut_lowhealth_vignette", 1, true, true, "Toggle Low Health Vignette (0 = OFF/1 = ON)")
local CVAR_nut_lowhealth_muffle_sound = CreateClientConVar("nut_lowhealth_muffle_sound", 20, true, true, "Toggle Low Health Sound Muffling (0 = OFF/1 = ON)")
local CVAR_nut_lowhealth_decolour = CreateClientConVar("nut_lowhealth_decolour", 1, true, true, "Toggle Low Health Decolouration (0 = OFF/1 = ON)")
local CVAR_nut_lowhealth_threshold = CreateClientConVar("nut_lowhealth_threshold", 1, true, true, "Set Low Health Effect Threshold")

local settingsTable = {
	{CVAR_nut_lowhealth_enabled, "nut_lowhealth_enabled", "Enable Low Health Effects"},
	{CVAR_nut_lowhealth_heartbeat_sound, "nut_lowhealth_heartbeat_sound", "Toggle Heartbeat Sounds"},
	{CVAR_nut_lowhealth_redflash, "nut_lowhealth_redflash", "Toggle Red Flashing"},
	{CVAR_nut_lowhealth_vignette, "nut_lowhealth_vignette", "Toggle Low Health Vignette"},
	{CVAR_nut_lowhealth_muffle_sound, "nut_lowhealth_muffle_sound", "Toggle Low Health Sound Muffling"},
	{CVAR_nut_lowhealth_decolour, "nut_lowhealth_decolour", "Toggle Low Health Decolouration"},
	{CVAR_nut_lowhealth_threshold, "nut_lowhealth_threshold", "Set Low Health Effect Threshold"},
}

local PANEL = {}

function PANEL:Init()
	self:SetTitle("Set Low Health Effect Threshold")
	self:SetSize(ScrW() * 0.25, ScrH() * 0.1)
	self:Center()
	self:MakePopup()

	local thresholdslider = self:Add("DNumSlider")
	thresholdslider:Dock(TOP)
	thresholdslider:SetText("Threshold") -- Set the text above the slider
	thresholdslider:SetMin(0)				 -- Set the minimum number you can slide to
	thresholdslider:SetMax(100)				-- Set the maximum number you can slide to
	thresholdslider:SetDecimals(0)			 -- Decimal places - zero for whole number
	thresholdslider:SetConVar("nut_lowhealth_threshold") -- Changes the ConVar when you slide
	thresholdslider:DockMargin(10, 0, 0, 5)
end

vgui.Register("nutLowHealthThreshold", PANEL, "DFrame")

function PLUGIN:SetupQuickMenu(menu) -- adds a new option in the C quickmenu (the same one where to toggle thirdperson)
	for _, v in ipairs(settingsTable) do
		if v[1] ~= CVAR_nut_lowhealth_threshold then
			menu:addCheck(v[3], function(panel, state)
				if (state) then
					RunConsoleCommand(v[2], "1")
				else
					RunConsoleCommand(v[2], "0")
				end
			end, v[1]:GetBool())
		else
			menu:addButton(v[3], function()
				if (nut.gui.lowhealththreshold and nut.gui.lowhealththreshold:IsVisible()) then
					nut.gui.lowhealththreshold:Close()
					nut.gui.lowhealththreshold = nil
				end

				nut.gui.lowhealththreshold = vgui.Create("nutLowHealthThreshold")
			end)
		end
	end

	menu:addSpacer()
end

--====--

local intensity = 1
local hpwait, hpalpha = 0, 0

local vig = nut.util.getMaterial("nutscript/gui/vignette.png")

local clr = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

local function LowHP_HUDPaint()
	local nut_lowhealth_enabled = GetConVar("nut_lowhealth_enabled"):GetBool()
	if nut_lowhealth_enabled == false then
		return
	end
	local nut_lowhealth_threshold = GetConVar("nut_lowhealth_threshold"):GetInt()
	local nut_lowhealth_muffle_sound = GetConVar("nut_lowhealth_muffle_sound"):GetBool()
	local nut_lowhealth_vignette = GetConVar("nut_lowhealth_vignette"):GetBool()
	local nut_lowhealth_heartbeat_sound = GetConVar("nut_lowhealth_heartbeat_sound"):GetBool()
	local nut_lowhealth_redflash = GetConVar("nut_lowhealth_redflash"):GetBool()
	local nut_lowhealth_decolour = GetConVar("nut_lowhealth_decolour"):GetBool()

	local client = LocalPlayer()
	local hp = client:Health()
	local x, y = ScrW(), ScrH()
	local FT = FrameTime()
	if nut_lowhealth_muffle_sound then
		if hp <= nut_lowhealth_threshold and client:getChar() then
			if not client.lastDSP then
				client:SetDSP(15)
				client.lastDSP = 15
				PLUGIN.curDSP = 15
			end
		else
			if client.lastDSP then
				client:SetDSP(0)
				client.lastDSP = nil
				PLUGIN.curDSP = 0
			end
		end
	end

	intensity = math.Approach(intensity, math.Clamp(1 - math.Clamp(hp / nut_lowhealth_threshold, 0, 1), 0, 1), FT * 0.25)

	if intensity > 0 then
		if nut_lowhealth_vignette == true then
			surface.SetDrawColor(0, 0, 0, 255 * intensity)
			surface.SetMaterial(vig)
			--surface.SetMaterial(nut.util.getMaterial("effects/splashwake1"))
			surface.DrawTexturedRect(0, 0, x, y)
		end

		if nut_lowhealth_decolour == true then
		clr[ "$pp_colour_colour" ] = 1 - intensity
		DrawColorModify(clr)
		end

		if client:Alive() then
			local CT = CurTime()

			if CT > hpwait then
				if nut_lowhealth_heartbeat_sound == true then
				client:EmitSound("physics/wood/wood_box_footstep4.wav", 75 * intensity, 100 + 20 * intensity, 1, CHAN_AUTO)
				end
			hpwait = CT + (0.9 - (0.5 * intensity ))
			end

			if nut_lowhealth_redflash == true then
				surface.SetDrawColor(255, 0, 0, (100 * intensity) * hpalpha)
				surface.DrawTexturedRect(0, 0, x, y)

				if CT < hpwait - 0.4 then
					hpalpha = math.Approach(hpalpha, 1, FrameTime() * 10)
				else
					hpalpha = math.Approach(hpalpha, 0.33, FrameTime() * 10)
				end
			end
		end
	end
end

hook.Add("HUDPaint", "nutMedicalLowHPEffects",LowHP_HUDPaint)

function PLUGIN:GetMotionBlurValues( x, y, fwd, spin )

    local client = LocalPlayer()

    blur, rate, MotionBlurAmount = 0, 0.05, math.Clamp( 1 - ( client:Health() / GetConVar("nut_lowhealth_threshold"):GetInt() ),0, 0.15 )

    motionBlur = math.Approach(motionBlur, MotionBlurAmount, FrameTime() * rate )
    return blur, blur, math.max(fwd, motionBlur), spin
end

gameevent.Listen( "player_spawn" )

hook.Add("player_spawn", "AnnounceConnection", function( )
	intensity = 0
end)