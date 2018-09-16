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
        0, 6, 6, 0,
        0, 6, 6, 0,
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
          type = "log_chunk",
          shape = "rectangle",
          x = 88,
          y = 105,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sitting_log",
          shape = "rectangle",
          x = 133,
          y = 97,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer_garbage",
          shape = "rectangle",
          x = 126,
          y = 144,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer_junkpile",
          shape = "rectangle",
          x = 164,
          y = 152,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 74,
          y = 125,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 94,
          y = 126,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 109,
          y = 85,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
