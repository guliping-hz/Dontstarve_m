

        Assets = 
{
        Asset( "IMAGE", "minimap/koalefant_winter.tex" ),
        Asset( "ATLAS", "minimap/koalefant_winter.xml" ),
        Asset( "IMAGE", "minimap/koalefant_summer.tex" ),
        Asset( "ATLAS", "minimap/koalefant_summer.xml" ),
        Asset( "IMAGE", "minimap/babybeefalo.tex" ),
        Asset( "ATLAS", "minimap/babybeefalo.xml" ),
        Asset( "IMAGE", "minimap/moose.tex" ),
        Asset( "ATLAS", "minimap/moose.xml" ),
        Asset( "IMAGE", "minimap/dragonfly.tex" ),
        Asset( "ATLAS", "minimap/dragonfly.xml" ),
        Asset( "IMAGE", "minimap/deerclops.tex" ),
        Asset( "ATLAS", "minimap/deerclops.xml" ),
        Asset( "IMAGE", "minimap/bearger.tex" ),
        Asset( "ATLAS", "minimap/bearger.xml" ),
        Asset( "IMAGE", "minimap/beefalo.tex" ),
        Asset( "ATLAS", "minimap/beefalo.xml" ),
        Asset( "IMAGE", "minimap/carrot_planted.tex" ),
        Asset( "ATLAS", "minimap/carrot_planted.xml" ),	
        Asset( "IMAGE", "minimap/flint.tex" ),
        Asset( "ATLAS", "minimap/flint.xml" ),
        Asset( "IMAGE", "minimap/rabbithole.tex" ),
        Asset( "ATLAS", "minimap/rabbithole.xml" ),
        Asset( "IMAGE", "minimap/rocky.tex" ),
        Asset( "ATLAS", "minimap/rocky.xml" ),
        Asset( "IMAGE", "minimap/chester_eyebone.tex" ),
        Asset( "ATLAS", "minimap/chester_eyebone.xml" ),
        Asset( "IMAGE", "minimap/red_mushroom.tex" ),
        Asset( "ATLAS", "minimap/red_mushroom.xml" ),
        Asset( "IMAGE", "minimap/green_mushroom.tex" ),
        Asset( "ATLAS", "minimap/green_mushroom.xml" ),
        Asset( "IMAGE", "minimap/blue_mushroom.tex" ),
        Asset( "ATLAS", "minimap/blue_mushroom.xml" ),
        Asset( "IMAGE", "minimap/lightninggoat.tex" ),
        Asset( "ATLAS", "minimap/lightninggoat.xml" ),
        Asset( "IMAGE", "minimap/mandrake.tex" ),
        Asset( "ATLAS", "minimap/mandrake.xml" ),
        Asset( "IMAGE", "minimap/molehill.tex" ),
        Asset( "ATLAS", "minimap/molehill.xml" ),
}

local babybeefalo = (GetModConfigData("babybeefalo")=="true")
local beefalo = (GetModConfigData("beefalo")=="true")
local moose = (GetModConfigData("moose")=="true")
local dragonfly = (GetModConfigData("dragonfly")=="true")
local deerclops = (GetModConfigData("deerclops")=="true")
local bearger = (GetModConfigData("bearger")=="true")
local carrot_planted = (GetModConfigData("carrot_planted")=="true")
local chester_eyebone = (GetModConfigData("chester_eyebone")=="true")
local flint = (GetModConfigData("flint")=="true")
local rabbithole = (GetModConfigData("rabbithole")=="true")
local rocky = (GetModConfigData("rocky")=="true")
local red_mushroom = (GetModConfigData("red_mushroom")=="true")
local green_mushroom = (GetModConfigData("green_mushroom")=="true")
local blue_mushroom = (GetModConfigData("blue_mushroom")=="true")
local lightninggoat = (GetModConfigData("lightninggoat")=="true")
local mandrake = (GetModConfigData("mandrake")=="true")
local molehill = (GetModConfigData("molehill")=="true")
local s_koalefant = (GetModConfigData("s_koalefant")=="true")
local w_koalefant = (GetModConfigData("w_koalefant")=="true")


function AddMap(inst)
        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon( inst.prefab .. ".tex" )
end
        if w_koalefant then AddMinimapAtlas("minimap/koalefant_winter.xml")
end
        if s_koalefant then AddMinimapAtlas("minimap/koalefant_summer.xml")
end
        if babybeefalo then AddMinimapAtlas("minimap/babybeefalo.xml")
end 
        if beefalo then AddMinimapAtlas("minimap/beefalo.xml")
end
        if moose then AddMinimapAtlas("minimap/moose.xml")
end
        if dragonfly then AddMinimapAtlas("minimap/dragonfly.xml")
end
        if deerclops then AddMinimapAtlas("minimap/deerclops.xml")
end
        if bearger then AddMinimapAtlas("minimap/bearger.xml")
end
        if carrot_planted then AddMinimapAtlas("minimap/carrot_planted.xml")
end
        if chester_eyebone then AddMinimapAtlas("minimap/chester_eyebone.xml")
end
        if flint then AddMinimapAtlas("minimap/flint.xml")
end
        if rabbithole then AddMinimapAtlas("minimap/rabbithole.xml")
end
        if rocky then AddMinimapAtlas("minimap/rocky.xml")
end
        if red_mushroom then AddMinimapAtlas("minimap/red_mushroom.xml")
end
        if green_mushroom then AddMinimapAtlas("minimap/green_mushroom.xml")
end
        if blue_mushroom then AddMinimapAtlas("minimap/blue_mushroom.xml")
end
        if lightninggoat then AddMinimapAtlas("minimap/lightninggoat.xml")
end
        if mandrake then AddMinimapAtlas("minimap/mandrake.xml")
end
        if molehill then AddMinimapAtlas("minimap/molehill.xml")
end

AddPrefabPostInit("babybeefalo", AddMap)
AddPrefabPostInit("moose", AddMap)
AddPrefabPostInit("dragonfly", AddMap)
AddPrefabPostInit("deerclops", AddMap)
AddPrefabPostInit("bearger", AddMap)
AddPrefabPostInit("beefalo", AddMap)
AddPrefabPostInit("carrot_planted", AddMap)
AddPrefabPostInit("chester_eyebone", AddMap)
AddPrefabPostInit("flint", AddMap)
AddPrefabPostInit("rabbithole", AddMap)
AddPrefabPostInit("rocky", AddMap)
AddPrefabPostInit("red_mushroom", AddMap)
AddPrefabPostInit("green_mushroom", AddMap)
AddPrefabPostInit("blue_mushroom", AddMap)
AddPrefabPostInit("lightninggoat", AddMap)
AddPrefabPostInit("mandrake", AddMap)
AddPrefabPostInit("molehill", AddMap)
AddPrefabPostInit("koalefant_summer", AddMap)
AddPrefabPostInit("koalefant_winter", AddMap)