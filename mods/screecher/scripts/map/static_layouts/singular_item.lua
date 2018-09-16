return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 6,
  height = 6,
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
      width = 6,
      height = 6,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 6, 6, 0, 0,
        0, 6, 6, 6, 6, 0,
        6, 6, 5, 5, 6, 6,
        6, 5, 5, 5, 6, 6,
        0, 6, 6, 5, 6, 0,
        0, 0, 6, 6, 6, 0
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
          type = "item",
          shape = "rectangle",
          x = 158,
          y = 159,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 233,
          y = 147,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer_duffel",
          shape = "rectangle",
          x = 209,
          y = 122,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 244,
          y = 163,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 223,
          y = 197,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
