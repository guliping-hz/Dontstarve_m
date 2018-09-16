return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 4,
  height = 4,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../layout_source/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../layout_source/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 128,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 4,
      height = 4,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0,
        0, 5, 7, 0,
        0, 7, 7, 0,
        0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "lootcontainer_garbage",
          shape = "rectangle",
          x = 160,
          y = 86,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 94,
          y = 89,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer_cooler",
          shape = "rectangle",
          x = 91,
          y = 124,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer_duffel",
          shape = "rectangle",
          x = 96,
          y = 143,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
