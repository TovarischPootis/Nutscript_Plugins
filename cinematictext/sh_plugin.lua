PLUGIN.name = "Cinematic Splash Text"
PLUGIN.desc = "Cinematic looking splash text for that extra flair"
PLUGIN.author = "76561198070441753"

nut.util.include("sv_plugin.lua")

nut.config.add("cinematicTextFont", "Arial", "The font used to display cinematic splash texts.", function()
	if (CLIENT) then
		hook.Run("LoadCinematicSplashTextFonts")
	end
end, {category = PLUGIN.name})

nut.config.add("cinematicTextSize", 18, "The font size multiplier used by cinematic splash texts.", function()
	if (CLIENT) then
		hook.Run("LoadCinematicSplashTextFonts")
	end
end, {
    category = PLUGIN.name,
    data = {min = 10, max = 50},
    }
)

nut.config.add("cinematicTextSizeBig", 30, "The big font size multiplier used by cinematic splash texts.", function()
	if (CLIENT) then
		hook.Run("LoadCinematicSplashTextFonts")
	end
end, {
    category = PLUGIN.name,
    data = {min = 10, max = 50},
    }
)

nut.config.add("cinematicTextMusic","music/stingers/industrial_suspense2.wav","The music played upon cinematic splash text appearance.",nil,
{category = PLUGIN.name})

nut.command.add("cinematicmenu", {
    adminOnly = true,
	onRun = function(client)
		net.Start("openCinematicSplashMenu")
        net.Send(client)
	end
})


if CLIENT then
    function PLUGIN:LoadCinematicSplashTextFonts()
        local font = nut.config.get("cinematicTextFont", "Arial")
        local fontSizeBig = nut.config.get("cinematicTextSizeBig", 30)
        local fontSizeNormal = nut.config.get("cinematicTextSize", 18)
        surface.CreateFont("cinematicSplashFontBig", {
            font = font,
            size = ScreenScale(fontSizeBig),
            extended = true,
            weight = 1000
        })

        surface.CreateFont("cinematicSplashFont", {
            font = font,
            size = ScreenScale(fontSizeNormal),
            extended = true,
            weight = 800
        })

        surface.CreateFont("cinematicSplashFontSmall", {
            font = font,
            size = ScreenScale(10),
            extended = true,
            weight = 800
        })
    end

    function PLUGIN:LoadNutFonts()
        self:LoadCinematicSplashTextFonts() -- this will create the fonts upon initial load.
    end
end
