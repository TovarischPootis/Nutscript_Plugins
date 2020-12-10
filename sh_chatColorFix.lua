PLUGIN.name = "Chat color config fix"
PLUGIN.author = "Sample Name"
PLUGIN.desc = "Fixes an issue of chat color config not working properly"

-- local function nut.chat.getChatColor()
--     local colorTbl = nut.config.get("chatColor")
--     local color = Color(colorTbl.r, colorTbl.g, colorTbl.b)
--     return color
-- end

nut.chat = nut.chat or {}

function nut.chat.getChatColor()
    local colorTbl = nut.config.get("chatColor")
    local color = Color(colorTbl.r, colorTbl.g, colorTbl.b)
    return color
end

hook.Add("InitializedConfig", "nutChatTypes", function()

    nut.chat.register("ic", {
        format = "%s says \"%s\"",
        onGetColor = function(speaker, text)
            -- If you are looking at the speaker, make it greener to easier identify who is talking.
            if (LocalPlayer():GetEyeTrace().Entity == speaker) then
                return nut.config.get("chatListenColor")
            end

            -- Otherwise, use the normal chat color.
            return nut.chat.getChatColor()
        end,
        onCanHear = nut.config.get("chatRange", 280)
    })

    -- Actions and such.
    nut.chat.register("it", {
        onChatAdd = function(speaker, text)
            chat.AddText(nut.chat.getChatColor(), "**"..text)
        end,
        onCanHear = nut.config.get("chatRange", 280),
        prefix = {"/it"},
        font = "nutChatFontItalics",
        filter = "actions",
        deadCanChat = true
    })

    nut.chat.register("looc", {
        onCanSay =  function(speaker, text)
            local delay = nut.config.get("loocDelay", 0)

            -- Only need to check the time if they have spoken in OOC chat before.
            if (delay > 0 and speaker.nutLastLOOC) then
                local lastLOOC = CurTime() - speaker.nutLastLOOC

                -- Use this method of checking time in case the oocDelay config changes.
                if (lastLOOC <= delay) then
                    speaker:notifyLocalized("loocDelay", delay - math.ceil(lastLOOC))

                    return false
                end
            end

            -- Save the last time they spoke in OOC.
            speaker.nutLastLOOC = CurTime()
        end,
        onChatAdd = function(speaker, text)
            chat.AddText(Color(255, 50, 50), "[LOOC] ", nut.chat.getChatColor(), speaker:Name()..": "..text)
        end,
        onCanHear = nut.config.get("chatRange", 280),
        prefix = {".//", "[[", "/looc"},
        noSpaceAfter = true,
        filter = "ooc"
    })
end)