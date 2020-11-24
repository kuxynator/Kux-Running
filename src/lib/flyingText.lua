
local function pos_offset( pos, offset )
	return { x=pos.x + offset.x, y=pos.y + offset.y }
end

--- flying-text module
-- @module flyingText
FlyingText = {
	moduleName="flyingText",
	create = function (player, text, color)
		color = color or {0.8,0.8,0.8}
		player.surface.create_entity({
			name = "flying-text",
			position = pos_offset(player.position,{x=-0.5, y=0.2}),
			text = text, color = color
		})
	end
}

Modules.flyingText = FlyingText
return FlyingText