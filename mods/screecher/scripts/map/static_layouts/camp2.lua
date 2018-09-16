return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 12,
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
      width = 12,
      height = 6,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 4, 4, 4, 0, 0, 0, 0, 0,
        0, 0, 0, 4, 4, 4, 4, 0, 0, 0, 0, 0,
        0, 0, 4, 4, 5, 5, 4, 4, 0, 0, 0, 0,
        0, 0, 4, 4, 5, 5, 4, 4, 0, 0, 0, 0,
        0, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0,
        0, 0, 0, 4, 4, 4, 0, 0, 0, 0, 0, 0
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
          x = 319,
          y = 189,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 267,
          y = 146,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 182,
          y = 165,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "note_diary2",
          shape = "rectangle",
          x = 386,
          y = 164,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "camper_fake",
          shape = "rectangle",
          x = 179,
          y = 226,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "batteries",
          shape = "rectangle",
          x = 381,
          y = 251,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
