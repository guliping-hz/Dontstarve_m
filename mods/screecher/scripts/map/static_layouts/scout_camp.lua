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
      filename = "E:/DontStarveSVN/Staging/mods/samplelayout/layout_source/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "E:/DontStarveSVN/Staging/mods/samplelayout/layout_source/dont_starve/tiles.png",
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
        0, 0, 0, 0, 0, 0,
        4, 2, 4, 4, 4, 0,
        4, 2, 4, 4, 4, 0,
        4, 2, 2, 2, 4, 0,
        4, 2, 4, 4, 4, 0,
        4, 2, 4, 4, 4, 0
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
          type = "tent_cone",
          shape = "rectangle",
          x = 32,
          y = 95,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 267,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 31,
          y = 166,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 28,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 31,
          y = 287,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 28,
          y = 355,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 161,
          y = 353,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 161,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 159,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 156,
          y = 100,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer",
          shape = "rectangle",
          x = 242,
          y = 153,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer",
          shape = "rectangle",
          x = 278,
          y = 152,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer",
          shape = "rectangle",
          x = 280,
          y = 117,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer",
          shape = "rectangle",
          x = 242,
          y = 116,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "firepit",
          shape = "rectangle",
          x = 254,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
