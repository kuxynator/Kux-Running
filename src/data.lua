data:extend({
	{
		type = "custom-input",
		name = "Kux-Running_hotkey-ToggleSpeedMode",
		key_sequence = "F6",
		consuming = "none"
	},
	{
		type = "custom-input",
		name = "Kux-Running_hotkey-ToggleAccelerationMode",
		key_sequence = "F7",
		consuming = "none"
	},
	{
		type = "custom-input",
		name = "Kux-Running_hotkey-ToggleHover",
		key_sequence = "H",
		consuming = "none"
	},
	{
		type = "custom-input",
		name = "Kux-Running_hotkey-ToggleZoom",
		key_sequence = "Y", -- use Y for Z, because Factorio seems to swap Y and Z
		consuming = "none"
	},
})

local nuclearFuelItem=data.raw.item["nuclear-fuel"]
--local movementFuel=table.deepcopy(nuclearFuel)
--print(serpent.block(nuclearFuel))
local movementFuelItem = {
	--fuel_acceleration_multiplier = 2.5,
	--fuel_category = "chemical",
	--fuel_top_speed_multiplier = 1.1499999999999999,
	--fuel_value = "1.21GJ",
	icon = "__Kux-Running__/graphics/icons/blue-fuel.png",
	icon_mipmaps = 4,
	icon_size = 64,
	name = "movement-fuel",
	order = "q[uranium-rocket-fuel]",
	pictures = {
	  layers = {
		{
		  filename = "__Kux-Running__/graphics/icons/blue-fuel.png",
		  mipmap_count = 4,
		  scale = 0.25,
		  size = 64
		},
		{
		  draw_as_light = true,
		  filename = "__base__/graphics/icons/nuclear-fuel-light.png",
		  flags = {
			"light"
		  },
		  mipmap_count = 4,
		  scale = 0.25,
		  size = 64
		}
	  }
	},
	stack_size = 1000,
	type = "item",
	group="combat",
	subgroup = "armor"
  }

local nuclearFuelRecipe=data.raw.recipe["nuclear-fuel"]
--print(serpent.block(nuclearFuelRecipe))
local movementFuelRecipe1 = {
	category = "crafting",
	enabled = true,
	energy_required = 10,
	icon = "__Kux-Running__/graphics/icons/blue-fuel.png", --TODO blue-fuel-coal.png
	icon_mipmaps = 4,
	icon_size = 64,
	ingredients = {
	  {"coal",50}
	},
	name = "movement-fuel",
	results = {
		{"movement-fuel",10},
		{"coal",40},
	},
	type = "recipe",
	group="combat",
	subgroup = "armor"
  }
  data:extend({movementFuelItem, movementFuelRecipe1})