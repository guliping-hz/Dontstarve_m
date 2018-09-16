return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 8,
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
      width = 8,
      height = 6,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 6, 6, 6, 0, 0, 0,
        0, 6, 6, 6, 6, 6, 0, 0,
        6, 6, 5, 5, 6, 6, 0, 0,
        6, 6, 5, 5, 6, 6, 0, 0,
        6, 6, 6, 6, 6, 6, 0, 0,
        0, 6, 6, 6, 0, 0, 0, 0
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
          type = "firepit",
          shape = "rectangle",
          x = 191,
          y = 189,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "spawnpoint",
          shape = "rectangle",
          x = 165,
          y = 190,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 239,
          y = 177,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sitting_log",
          shape = "rectangle",
          x = 224,
          y = 137,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 139,
          y = 146,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "batteries",
          shape = "rectangle",
          x = 106,
          y = 251,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 262,
          y = 48,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "note1",
          shape = "rectangle",
          x = 134,
          y = 250,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flashlightloot",
          shape = "rectangle",
          x = 103,
          y = 166,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 251,
          y = 190,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "letters_dark",
          shape = "rectangle",
          x = 16,
          y = 154,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 258,
          y = 177,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 264,
          y = 191,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 252,
          y = 205,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
