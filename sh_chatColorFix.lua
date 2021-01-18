PLUGIN.name = "Chat color config fix"
PLUGIN.author = "Sample Name"
PLUGIN.desc = "Fixes an issue of chat color config not working properly"

nut.config = nut.config or {}
nut.config.stored = nut.config.stored or {}

function nut.config.get(key, default)
    local config = nut.config.stored[key]

	if (config) then
        if (config.value != nil) then
            if key == "chatColor" || key == "chatListenColor" then
                return Color(config.value.r, config.value.g, config.value.b)
            else
                return config.value
            end
		elseif (config.default != nil) then
            if key == "chatColor" || key == "chatListenColor" then
                return Color(config.default.r, config.default.g, config.default.b)
            else
                return config.default
            end
		end
	end

	return default
end