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
        0, 6, 4, 4, 4, 0,
        0, 4, 4, 6, 4, 0,
        4, 6, 4, 4, 4, 6,
        4, 4, 4, 4, 4, 4,
        6, 4, 6, 4, 4, 4,
        0, 4, 4, 4, 6, 0
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
          type = "gravestone",
          shape = "rectangle",
          x = 128,
          y = 259,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 191,
          y = 257,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 256,
          y = 259,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 319,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 255,
          y = 195,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 190,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 118,
          y = 125,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 70,
          y = 127,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 61,
          y = 254,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "gravestone",
          shape = "rectangle",
          x = 316,
          y = 65,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 319,
          y = 214,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 257,
          y = 214,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 192,
          y = 151,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 191,
          y = 67,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 253,
          y = 65,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 128,
          y = 193,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 128,
          y = 279,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mound",
          shape = "rectangle",
          x = 256,
          y = 339,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "statueharp",
          shape = "rectangle",
          x = 94,
          y = 35,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "note2",
          shape = "rectangle",
          x = 257,
          y = 129,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lootcontainer",
          shape = "rectangle",
          x = 96,
          y = 61,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "firepit",
          shape = "rectangle",
          x = 317,
          y = 132,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
