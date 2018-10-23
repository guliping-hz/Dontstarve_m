local cooking = require "cooking"
--local foods = require "preparedfoods"

local IsDLC1 = IsDLCEnabled(REIGN_OF_GIANTS)
-- local IsDLC2 = IsDLCEnabled(CAPY_DLC)
local IsDLC2 = false
local status, temp = pcall(function()
    return IsDLCEnabled(CAPY_DLC)
end);
if (status) then
    IsDLC2 = temp
end
local useless_products =		--不会记录
{
	'ratatouille', --蹩脚炖菜  完全没价值
	'jammypreserves', --果酱蜜饯  没什么价值
	'mandrakesoup', --曼德拉汤  太好记了，且不常用
	'monsterlasagna',  --
	'wetgoop',--
	'bonestew',--占位置，基本不吃，有一种预定的就好了。肉汤还是加胡萝卜的好    不想出现肉汤的话可将胡萝卜拿起后才点击书按钮
	'hotchili',--不是很实用，不是给定组合就不要做了
}
local function AddRecipes() --基本食谱，感觉最省材料的预设times较大     还需完善
	local Recipes = {
	butterflymuffin ={--20
				{prefablist={butterflywings=1,red_cap=1,twigs=2},times=2},
				{prefablist={butterflywings=1,green_cap=1,twigs=2},times=2},
				{prefablist={butterflywings=1,blue_cap=1,twigs=2},times=2},
				{prefablist={butterflywings=1,carrot=1,twigs=2},times=2},
				{prefablist={butterflywings=1,carrot=2,twigs=1},times=1},
				{prefablist={butterflywings=1,carrot=3},times=1},
			},--**蝴蝶松饼      所用食材：names.butterflywings（蝴蝶翅膀）、not tags.meat（不放肉）、tags.veggie（蔬菜）
	frogglebunwich ={	
				{prefablist={froglegs=1,red_cap=1,twigs=2},times=2},
				{prefablist={froglegs=1,green_cap=1,twigs=2},times=2},
				{prefablist={froglegs=1,blue_cap=1,twigs=2},times=2},
				{prefablist={froglegs=1,carrot=1,twigs=2},times=2},
			},--*（青蛙圆面包三明治）    所用食材：names.froglegs or names.froglegs_cooked（生、熟蛙腿）、tags.veggie（蔬菜）
	taffy ={	
				{prefablist={honey=3,twigs=1},times=2},
				{prefablist={honey=3,berries=1},times=1},
				{prefablist={honey=3,carrot=1},times=1},
				{prefablist={honey=3,red_cap=1},times=1},
				{prefablist={honey=3,green_cap=1},times=1},
				{prefablist={honey=3,blue_cap=1},times=1},
				{prefablist={honey=3,berries_cooked=1},times=12},
				{prefablist={honey=3,carrot_cooked=1},times=12},
				{prefablist={honey=3,red_cap_cooked=1},times=12},
				{prefablist={honey=3,green_cap_cooked=1},times=12},
				{prefablist={honey=3,blue_cap_cooked=1},times=12},
				{prefablist={honey=4},times=1},
			},--***太妃糖	
	pumpkincookie ={	
				{prefablist={pumpkin=1,honey=2,twigs=1},times=2},
				{prefablist={pumpkin_cooked=1,honey=2,twigs=1},times=12},
				{prefablist={pumpkin=1,honey=2,berries=1},times=1},
				{prefablist={pumpkin_cooked=1,honey=2,berries=1},times=12},
				{prefablist={pumpkin=1,honey=2,red_cap=1},times=3},
				{prefablist={pumpkin_cooked=1,honey=2,red_cap=1},times=12},	
				{prefablist={pumpkin=1,honey=2,green_cap=1},times=3},
				{prefablist={pumpkin_cooked=1,honey=2,green_cap=1},times=12},
				{prefablist={pumpkin=1,honey=2,blue_cap=1},times=3},
				{prefablist={pumpkin_cooked=1,honey=2,blue_cap=1},times=12},				
				{prefablist={pumpkin=1,honey=3},times=1},
				{prefablist={pumpkin_cooked=1,honey=3},times=12},
			},--****南瓜曲奇	    所用食材：names.pumpkin or names.pumpkin_cooked（生、熟南瓜）、tags.sweetener and tags.sweetener >= 2（蜂蜜或蜂巢大于等于2）
		
	stuffedeggplant ={	
				{prefablist={eggplant=1,carrot=1,twigs=2},times=2},
				{prefablist={eggplant=1,red_cap=1,twigs=2},times=3},
				{prefablist={eggplant=1,green_cap=1,twigs=2},times=3},
				{prefablist={eggplant=1,blue_cap=1,twigs=2},times=3},
				{prefablist={eggplant_cooked=1,carrot=1,twigs=2},times=12},
				{prefablist={eggplant_cooked=1,red_cap=1,twigs=2},times=12},
				{prefablist={eggplant_cooked=1,green_cap=1,twigs=2},times=12},
				{prefablist={eggplant_cooked=1,blue_cap=1,twigs=2},times=12},
			},--*香酥茄盒    所用食材：names.eggplant or names.eggplant_cooked（生、熟茄子）、tags.veggie and tags.veggie > 1（蔬菜大于1）

	fishsticks ={	
				{prefablist={fish=1,berries=2,twigs=1},times=12},
				{prefablist={fish=1,ice=2,twigs=1},times=12},
				{prefablist={fish=1,red_cap=2,twigs=1},times=12},
				{prefablist={fish=1,green_cap=2,twigs=1},times=12},
				{prefablist={fish=1,blue_cap=2,twigs=1},times=12},
				{prefablist={fish=1,carrot=2,twigs=1},times=12},
				{prefablist={fish=2,berries=1,twigs=1},times=1},
				{prefablist={fish=3,twigs=1},times=1},
			},--***鱼条     所用食材：tags.fish（鱼）、names.twigs and (tags.inedible and tags.inedible <= 1)（树枝且树枝小于等于1）
			
	honeynuggets ={	
				{prefablist={smallmeat=1,honey=1,berries=2},times=12},
				{prefablist={smallmeat=1,honey=1,carrot=2},times=12},
				{prefablist={smallmeat=1,honey=1,red_cap=2},times=12},
				{prefablist={smallmeat=1,honey=1,green_cap=2},times=12},
				{prefablist={smallmeat=1,honey=1,blue_cap=2},times=12},
			},--*甜蜜金砖      所用食材：names.honey（蜂蜜）、tags.meat and tags.meat <= 1.5（肉小于等于1.5，即1大肉、1小肉）、not tags.inedible（不放树枝）

	honeyham ={	
				{prefablist={monstermeat=1,meat=1,honey=1,berries=1},times=2},
				{prefablist={monstermeat=1,meat=1,honey=1,berries_cooked=1},times=99},
				{prefablist={monstermeat=1,meat=1,honey=1,carrot=1},times=2},
				{prefablist={monstermeat=1,meat=1,honey=1,carrot_cooked=1},times=99},
				{prefablist={monstermeat=1,meat=1,honey=1,red_cap=1},times=2},
				{prefablist={monstermeat=1,meat=1,honey=1,red_cap_cooked=1},times=99},
				{prefablist={monstermeat=1,meat=1,honey=1,green_cap=1},times=2},
				{prefablist={monstermeat=1,meat=1,honey=1,green_cap_cooked=1},times=99},
				{prefablist={monstermeat=1,meat=1,honey=1,blue_cap=1},times=2},
				{prefablist={monstermeat=1,meat=1,honey=1,blue_cap_cooked=1},times=99},
				{prefablist={monstermeat=1,meat=1,honey=2},times=3},
			},--***蜜汁火腿	    所用食材：names.honey（蜂蜜）、tags.meat and tags.meat > 1.5（肉大于1.5，即1大肉、1小肉）、not tags.inedible（不放树枝）
	
	dragonpie ={	
				{prefablist={dragonfruit=1,twigs=3},times=3},
				{prefablist={dragonfruit=1,berries=3},times=3},
				{prefablist={dragonfruit=1,carrot=3},times=1},
				{prefablist={dragonfruit=1,red_cap=3},times=1},
				{prefablist={dragonfruit=1,green_cap=3},times=1},
				{prefablist={dragonfruit=1,blue_cap=3},times=1},
				{prefablist={dragonfruit_cooked=1,twigs=3},times=88},
				{prefablist={dragonfruit_cooked=1,berries=3},times=99},
				{prefablist={dragonfruit_cooked=1,carrot=3},times=99},
				{prefablist={dragonfruit_cooked=1,red_cap=3},times=99},
				{prefablist={dragonfruit_cooked=1,green_cap=3},times=99},
				{prefablist={dragonfruit_cooked=1,blue_cap=3},times=99},
			},--****龙派	    所用食材：names.dragonfruit or names.dragonfruit_cooked（生、熟火龙果）、not tags.meat（不放肉）
		
	kabobs ={
			{prefablist={monstermeat=1,berries=2,twigs=1},times=12},
			{prefablist={smallmeat=1,berries=2,twigs=1},times=12},
			},--*肉串	    所用食材：tags.meat（肉）、names.twigs（树枝）、not tags.monster or tags.monster <= 1（没有疯肉或疯肉小于等于1）、tags.inedible and tags.inedible <= 1（树枝小于等于1）
	baconeggs ={	
				{prefablist={monstermeat=1,smallmeat=1,bird_egg=2},times=4},
				{prefablist={monstermeat=1,cookedsmallmeat=1,bird_egg=2},times=9},
				{prefablist={cookedmonstermeat=1,smallmeat=1,bird_egg=2},times=9},
				{prefablist={cookedmonstermeat=1,cookedsmallmeat=1,bird_egg=2},times=9},
				{prefablist={monstermeat=1,meat=1,bird_egg=2},times=3},
				{prefablist={monstermeat=1,cookedmeat=1,bird_egg=2},times=9},
				{prefablist={cookedmonstermeat=1,meat=1,bird_egg=2},times=9},
				{prefablist={cookedmonstermeat=1,cookedmeat=1,bird_egg=2},times=9},
				{prefablist={meat=1,smallmeat=1,bird_egg=2},times=3},
				{prefablist={meat=1,cookedsmallmeat=1,bird_egg=2},times=9},
				{prefablist={cookedmeat=1,cookedsmallmeat=1,bird_egg=2},times=9},
				{prefablist={cookedmeat=1,smallmeat=1,bird_egg=2},times=3},
				{prefablist={smallmeat=3,tallbirdegg=1},times=33},
				{prefablist={smallmeat=3,tallbirdegg_cooked=1},times=33},
				{prefablist={cookedsmallmeat=3,tallbirdegg=1},times=33},
				{prefablist={cookedsmallmeat=3,tallbirdegg_cooked=1},times=33},
			},--培根煎蛋	    所用食材：tags.egg and tags.egg > 1（蛋大于1）、tags.meat and tags.meat > 1（肉大于1，即大于1块大肉）、not tags.veggie（不放蔬菜）
	
	meatballs =	{	
				{prefablist={smallmeat=1,berries=3},times=2},
				{prefablist={smallmeat=1,carrot=3},times=2},
				{prefablist={smallmeat=1,red_cap=3},times=2},
				{prefablist={smallmeat=1,green_cap=3},times=2},
				{prefablist={smallmeat=1,blue_cap=3},times=2},
				{prefablist={monstermeat=1,berries=3},times=20},
				{prefablist={monstermeat=1,carrot=3},times=20},
				{prefablist={monstermeat=1,red_cap=3},times=12},
				{prefablist={monstermeat=1,green_cap=3},times=12},
				{prefablist={monstermeat=1,blue_cap=3},times=12},
				{prefablist={monstermeat=1,ice=3},times=20},	
				{prefablist={meat=1,berries=3},times=2},
				{prefablist={meat=1,ice=3},times=2},
				
			},--肉丸     所用食材：tags.meat（肉）、not tags.inedible（不放树枝）
	
	bonestew ={	
				--{prefablist={monstermeat=1,meat=2,berries=1},times=12},
				{prefablist={monstermeat=1,meat=2,carrot=1},times=12},
				--{prefablist={monstermeat=1,meat=2,red_cap=1},times=12},
				--{prefablist={monstermeat=1,meat=2,green_cap=1},times=12},
				--{prefablist={monstermeat=1,meat=2,blue_cap=1},times=12},
				--{prefablist={monstermeat=1,meat=1,smallmeat=2},times=2},
			},--炖肉	    所用食材：tags.meat and tags.meat >= 3（肉大于等3，即至少3块大肉）、not tags.inedible（不放树枝）

	perogies ={	
			{prefablist={smallmeat=1,bird_egg=1,carrot=2},times=6},
			{prefablist={smallmeat=1,bird_egg=1,red_cap=2},times=6},
			{prefablist={smallmeat=1,bird_egg=1,green_cap=2},times=6},
			{prefablist={smallmeat=1,bird_egg=1,blue_cap=2},times=6},
			{prefablist={smallmeat=1,bird_egg=1,carrot=1,berries=1},times=7},
			{prefablist={monstermeat=1,bird_egg=1,cattot=2},times=6},
			{prefablist={monstermeat=1,bird_egg=1,red_cap=2},times=6},
			{prefablist={monstermeat=1,bird_egg=1,green_cap=2},times=6},
			{prefablist={monstermeat=1,bird_egg=1,blue_cap=2},times=6},
			{prefablist={monstermeat=1,bird_egg=1,cattot=1,berries=1},times=7},
			},--***饺子     所用食材：tags.egg（蛋）、tags.meat（肉）、tags.veggie（蔬菜）、not tags.inedible（不放树枝）

	turkeydinner ={	
				{prefablist={drumstick=2,smallmeat=1,berries=1},times=12},
				{prefablist={drumstick=2,smallmeat=1,carrot=1},times=2},
				{prefablist={drumstick=2,smallmeat=1,red_cap=1},times=12},
				{prefablist={drumstick=2,smallmeat=1,green_cap=1},times=12},
				{prefablist={drumstick=2,smallmeat=1,blue_cap=1},times=12},
				{prefablist={drumstick=2,monstermeat=1,berries=1},times=12},
				{prefablist={drumstick=2,monstermeat=1,carrot=1},times=2},
				{prefablist={drumstick=2,monstermeat=1,red_cap=1},times=12},
				{prefablist={drumstick=2,monstermeat=1,green_cap=1},times=12},
				{prefablist={drumstick=2,monstermeat=1,blue_cap=1},times=12},
			},--火鸡正餐     所用食材：names.drumstick and names.drumstick > 1（鸡腿大于1）、tags.meat and tags.meat > 1（肉大于1，即至少1块大肉）、tags.veggie or tags.fruit（蔬菜或水果）

	fruitmedley ={	
				{prefablist={pomegranate=1,cave_banana=1,durian=1,twigs=1},times=12},
				{prefablist={pomegranate=2,cave_banana=1,durian=1},times=12},
				{prefablist={pomegranate=1,cave_banana=2,durian=1},times=12},
				{prefablist={cave_banana=3,twigs=1},times=13},
			--	{prefablist={cave_banana=4},times=12},
			},--水果拼盘     所用食材：tags.fruit and tags.fruit >= 3（水果大于等于3）、not tags.meat（不放肉）、not tags.veggie（不放蔬菜）

	fishtacos ={	
				{prefablist={corn=1,fish=1,berries=2},times=12},
				{prefablist={corn=1,fish_cooked=1,berries=2},times=12},
				{prefablist={corn=1,fish=1,berries_cooked=2},times=33},
				{prefablist={corn=1,fish_cooked=1,berries_cooked=2},times=55},
				{prefablist={corn=1,fish=1,twigs=2},times=12},
				{prefablist={corn=1,fish_cooked=1,twigs=2},times=33},
				{prefablist={corn_cooked=1,fish=1,twigs=2},times=33},
				{prefablist={corn_cooked=1,fish_cooked=1,twigs=2},times=55},
			},--	（玉米饼包炸鱼）    所用食材：tags.fish（鱼）、names.corn or names.corn_cooked（生、熟玉米）

	waffles ={	
				{prefablist={butter=1,bird_egg=1,berries=2},times=12},
				{prefablist={butter=1,bird_egg=1,berries_cooked=2},times=33},
				{prefablist={butter=1,bird_egg=2,berries=1},times=12},
				{prefablist={butter=1,bird_egg=2,berries_cooked=1},times=33},
				{prefablist={butter=1,bird_egg_cooked=1,berries=2},times=33},
				{prefablist={butter=1,bird_egg_cooked=1,berries_cooked=2},times=55},
				{prefablist={butter=1,bird_egg_cooked=2,berries=1},times=33},
				{prefablist={butter=1,bird_egg_cooked=2,berries_cooked=1},times=55},
				{prefablist={butter=1,bird_egg=1,berries=1,red_cap=1},times=12},
				{prefablist={butter=1,bird_egg=1,berries=1,green_cap=1},times=12},
				{prefablist={butter=1,bird_egg=1,berries=1,blue_cap=1},times=12},
			},--**华夫饼    所用食材：names.butter（黄油）、names.berries or names.berries_cooked（生、熟浆果）、tags.egg（蛋）

	powcake ={	
				{prefablist={corn=1,honey=1,twigs=2},times=12},
				{prefablist={corn_cooked=1,honey=1,twigs=2},times=33},
				{prefablist={corn=1,honey=2,twigs=1},times=10},
				{prefablist={corn_cooked=1,honey=2,twigs=1},times=33},
			},--**粉末蛋糕	芝士蛋糕  所用食材：names.twigs（树枝）、names.honey（蜂蜜）、names.corn or names.corn_cooked（生、熟玉米）

	unagi ={	
				{prefablist={eel=1,cutlichen=1,berries=2},times=12},
				{prefablist={eel=1,cutlichen=1,carrot=2},times=12},
				{prefablist={eel=1,cutlichen=1,red_cap=2},times=12},
				{prefablist={eel=1,cutlichen=1,green_cap=2},times=12},
				{prefablist={eel=1,cutlichen=1,blue_cap=2},times=12},
				{prefablist={eel_cooked=1,cutlichen=1,berries=2},times=12},
				{prefablist={eel=1,cutlichen=1,twigs=2},times=2},
				{prefablist={eel_cooked=1,cutlichen=1,twigs=2},times=2},
			},--鳗鱼料理    所用食材：names.cutlichen（苔藓）、names.eel or names.eel_cooked（生、熟鳗鱼）

	
	}
	local Recipes_ROG={--6
	--ROG	
	flowersalad ={	
				{prefablist={cactusflower=1,carrot=3},times=3},
				{prefablist={cactusflower=1,red_cap=3},times=3},
				{prefablist={cactusflower=1,red_cap_cooked=3},times=33},
				{prefablist={cactusflower=1,green_cap=3},times=3},
				{prefablist={cactusflower=1,green_cap_cooked=3},times=33},
				{prefablist={cactusflower=1,blue_cap=3},times=3},
				{prefablist={cactusflower=1,blue_cap_cooked=3},times=33},
				{prefablist={cactusflower=1,corn=3},times=3},
				{prefablist={cactusflower=1,corn_cooked=3},times=33},
				--{prefablist={cactusflower=1,pumpkin=3},times=12},
				{prefablist={cactusflower=1,eggplant=3},times=3},
				{prefablist={cactusflower=1,carrot_cooked=3},times=33},
			},--**花莎拉    所用食材：names.cactusflower（仙人掌花）、tags.veggie and tags.veggie >= 2（蔬菜大于等于2）、not tags.meat（不放肉）、not tags.inedible（不放树枝）、not tags.egg（不放蛋）、not tags.sweetener（不放蜂蜜或蜂巢）、not tags.fruit（不放水果）

	icecream ={
				{prefablist={goatmilk=1,honey=1,ice=2},times=3},
				{prefablist={goatmilk=1,honey=1,ice=1,berries=1},times=3},
				{prefablist={goatmilk=1,honey=1,ice=1,berries_cooked=2},times=99},
				{prefablist={goatmilk=1,honey=2,ice=1},times=2},
			},--*冰淇淋    所用食材：tags.frozen（冰）、tags.dairy（乳制品）、tags.sweetener（蜂蜜或蜂巢）、not tags.meat（不放肉）、not tags.veggie（不放蔬菜）、not tags.inedible（不放树枝）、not tags.egg（不放蛋）

	watermelonicle ={	
				{prefablist={watermelon=1,ice=1,twigs=2},times=2},
				{prefablist={watermelon=1,ice=2,twigs=1},times=12},
				{prefablist={watermelon=2,ice=1,twigs=1},times=2},
			},--**西瓜冰	    所用食材：names.watermelon（西瓜）、tags.frozen（冰）、names.twigs（树枝）、not tags.meat（不放肉）、not tags.veggie（不放蔬菜）、not tags.egg（不放蛋）

	trailmix ={	
				{prefablist={acorn_cooked=1,berries=3},times=12},
				{prefablist={acorn_cooked=1,berries_cooked=3},times=55},
				{prefablist={acorn_cooked=2,berries=2},times=2},
				{prefablist={acorn_cooked=2,berries_cooked=2},times=33},
			},--***果仁杂烩	    所用食材：names.acorn_cooked（熟橡果）、tags.seed and tags.seed >= 1（种子大于等于1）、names.berries or names.berries_cooked（浆果或熟浆果）、tags.fruit and tags.fruit >= 1（水果大于等于1）、not tags.meat（不放肉）、not tags.veggie（不放蔬菜）、not tags.egg（不放蛋）、not tags.dairy（不放乳制品）
		
	hotchili ={	
				{prefablist={monstermeat=1,smallmeat=1,carrot=2},times=1},
				{prefablist={cookedmonstermeat=1,smallmeat=1,carrot=2},times=2},
				{prefablist={cookedmonstermeat=1,cookedsmallmeat=1,carrot=2},times=3},
				{prefablist={cookedmonstermeat=1,cookedsmallmeat=1,carrot_cooked=2},times=4},
				{prefablist={monstermeat=1,cookedsmallmeat=1,carrot=2},times=2},
			},--*咖喱  辣椒酱    所用食材：tags.meat >= 1.5（肉大于等于1.5）、tags.veggie >= 1.5（蔬菜大于等于1.5）

	guacamole ={	
				{prefablist={mole=1,cactus_meat=1,twigs=2},times=2},
				{prefablist={mole=1,cactus_meat=1,red_cap=1,twigs=1},times=12},
				{prefablist={mole=1,cactus_meat=1,green_cap=1,twigs=1},times=12},
				{prefablist={mole=1,cactus_meat=1,blue_cap=1,twigs=1},times=12},
				{prefablist={mole=1,cactus_meat=1,red_cap=2},times=2},
				{prefablist={mole=1,cactus_meat=1,green_cap=2},times=2},
				{prefablist={mole=1,cactus_meat=1,blue_cap=2},times=2},
			},--*鳄梨酱    所用食材：names.mole（鼹鼠）、names.cactus_meat（仙人掌肉）、not tags.fruit（不放水果）

	}
--SW		
	local Recipes_SW={	--11
	californiaroll ={	
				{prefablist={seaweed=2,fish=1,twigs=1},times=12},
				{prefablist={seaweed=2,fish=2},times=2},
				{prefablist={seaweed=2,tropical_fish=1,twigs=1},times=12},
				{prefablist={seaweed=2,tropical_fish=2},times=12},
			},--加州卷 (names.seaweed and names.seaweed == 2) and (tags.fish and tags.fish >= 1) 
	seafoodgumbo ={	
				{prefablist={fish=4},times=12},
				{prefablist={tropical_fish=4},times=12},
			},--海鲜汤 tags.fish and tags.fish > 2
	bisque ={	{prefablist={limpets=3,ice=1},times=12},
			},--汤  names.limpets and names.limpets == 3 and tags.frozen
	ceviche ={	
				{prefablist={fish=2,ice=2,},times=12},
				{prefablist={fish=3,ice=1,},times=2},
				{prefablist={tropical_fish=2,ice=2,},times=12},
				{prefablist={tropical_fish=3,ice=1,},times=2},
			}, --橘汁腌鱼  tags.fish and tags.fish >= 2 and tags.frozen
	jellyopop ={	
				{prefablist={jellyfish=1,ice=1,twigs=2},times=10},
				{prefablist={jellyfish=1,ice=2,twigs=1},times=11},
			},--果冻 tags.jellyfish and tags.frozen and tags.inedible
	bananapop ={	
				{prefablist={cave_banana=1,ice=1,twigs=2},times=12},
				{prefablist={cave_banana=1,ice=2,twigs=1},times=12},
			},--香蕉冻 names.cave_banana and tags.frozen and tags.inedible
	lobsterbisque ={	
				{prefablist={lobster=1,ice=3},times=10},
				{prefablist={lobster=1,ice=2,twigs=1},times=12},
				{prefablist={lobster=1,ice=1,twigs=2},times=2},
			},	--龙虾汤 names.lobster and tags.frozen
	lobsterdinner ={	
				{prefablist={lobster=1,butter=1,twigs=2},times=1},
				{prefablist={lobster=1,butter=1,berries=2},times=2},
				{prefablist={lobster=1,butter=1,carrot=2},times=2},
				{prefablist={lobster=1,butter=1,red_cap=2},times=2},
				{prefablist={lobster=1,butter=1,green_cap=2},times=2},
				{prefablist={lobster=1,butter=1,blue_cap=2},times=2},
			},	--龙虾套餐  names.lobster and names.butter and not tags.meat and not tags.frozen
	sharkfinsoup ={
				{prefablist={shark_fin=1,twigs=3},times=5},
				{prefablist={shark_fin=1,ice=3},times=10},
				{prefablist={shark_fin=1,berries=3},times=10},
				{prefablist={shark_fin=1,carrot=3},times=10},
				{prefablist={shark_fin=1,red_cap=3},times=10},
				{prefablist={shark_fin=1,green_cap=3},times=10},
				{prefablist={shark_fin=1,blue_cap=3},times=10},
			},--鱼翅汤  names.shark_fin				
	surfnturf ={
				{prefablist={monstermeat=1,fish=3},times=2},
				{prefablist={monstermeat=1,fish_cooked=3},times=55},
				{prefablist={cookedmonstermeat=1,fish=3},times=55},
				{prefablist={cookedmonstermeat=1,fish_cooked=3},times=99},
				{prefablist={monstermeat=1,tropical_fish=3},times=2},
				{prefablist={cookedmonstermeat=1,tropical_fish=3},times=55},
				{prefablist={monstermeat=1,smallmeat=1,fish=2},times=2},
				{prefablist={monstermeat=1,smallmeat=1,tropical_fish=2},times=2},
				{prefablist={cookedmonstermeat=1,smallmeat=1,tropical_fish=2},times=55},
				{prefablist={monstermeat=1,cookedsmallmeat=1,tropical_fish=2},times=55},
				{prefablist={cookedmonstermeat=1,cookedsmallmeat=1,tropical_fish=2},times=99},
			},--海鲜牛排	tags.meat and tags.meat >= 2.5 and tags.fish and tags.fish >= 1.5 and not tags.frozen
	coffee ={	
				{prefablist={coffeebeans_cooked=4},times=4},
				{prefablist={coffeebeans_cooked=3,honey=1},times=12},
				{prefablist={coffeebeans_cooked=3,goatmilk=1},times=2},
			},--速行咖啡 names.coffeebeans_cooked and (names.coffeebeans_cooked == 4 or (names.coffeebeans_cooked == 3 and (tags.dairy or tags.sweetener)))	
	}
	if IsDLC1 or IsDLC2 then
		for k,v in pairs(Recipes_ROG) do
			Recipes[k] = v
		end
		
		if IsDLC2 then
			for k,v in pairs(Recipes_SW) do
				Recipes[k] = v
			end
		end
	end
	--print('ADD Recipes')
	return Recipes
end
--------------------------------------------------------------------------------------------
local SmartCooker = Class(function(self, inst)
	self.inst = inst
	self.invs =  nil
	self.currentkey =0
	self.method = 'hunger'
	self.recipes=AddRecipes()
	self.valid_recipes = {}
	self.specialcookername = self.inst.components.stewer and self.inst.components.stewer.specialcookername 
	self.cookername =  self.inst.components.stewer and self.inst.components.stewer.cookername 
	--print(self.cookername)
	--	self.selected_items = {}
end)

function SmartCooker:OnSave()
	if self.inst:HasTag('A_Acasual_ing') then self:ClearCookpot() end -- 防止填充的材料在下次游戏时可拿出
	return {method = self.method, recipes = self.recipes}
end
function SmartCooker:OnLoad(data)
	if data then
		self.method = data.method or 'hunger'
		self.recipes = data.recipes or AddRecipes()
	end
end
function SmartCooker:SetMethod(mt)
	self.method = mt
	self.currentkey=0
	self:SortTable(self.valid_recipes)
end
function SmartCooker:GetMethod()
	return self.method or 'hunger'
end
--寻找食材
function SmartCooker:SearchIngs(inv,ings)
	if inv==nil then return end
	local items = inv.components.container and inv.components.container.slots
		or inv.components.inventory and inv.components.inventory.itemslots or {}
	for k,item in pairs(items) do
		if item and cooking.IsCookingIngredient(item.prefab) then
			local size = item.components.stackable and item.components.stackable.stacksize or 1
			ings[item.prefab] = ings[item.prefab] and ings[item.prefab] +size or size
		end
	end
end
--匹配食谱
function SmartCooker:FindValidRecipes(invs)
	local ings = {}
	for k,inv in pairs(invs) do
		self:SearchIngs(inv,ings)
	end
	local foods1 = self.specialcookername and cooking.recipes[self.specialcookername] or {}
	local foods2 = self.cookername and cooking.recipes[self.cookername] or {}
	local foods3 = cooking.recipes[self.inst.prefab] or {}
	for food,_ in pairs(self.recipes) do
		local foodinfo = foods3[food] or foods2[food] or foods1[food]
		if foodinfo then
			for i=1,#self.recipes[food] do
				local prefablist = self.recipes[food][i].prefablist
				local times = self.recipes[food][i].times
				local cando = true
				for ing,num in pairs(prefablist) do
					if not ings[ing] or ings[ing]<num then cando=false break end
				end
				if cando then
			--	print('Add  Recipe:  '..food)
					local tb = {name=food,prefablist=prefablist,times=times,hunger=foodinfo.hunger or 0,health=foodinfo.health or 0,sanity=foodinfo.sanity or 0,cooktime=foodinfo.cooktime or 0}
					table.insert(self.valid_recipes,tb)
				end
			end
		end
	end
	self:SortTable(self.valid_recipes)
end
--是否需要重新匹配食谱
function SmartCooker:ShouldStart(invs)
	if not self.invs or self:NoValidRecipes() then return true end
	for i=1,#self.invs do --player  pack  chest
		if self.invs[i] ~= invs[i] then return true end
	end
	return false
end
--取得当前组合
function SmartCooker:GetRecipe()
	return self.valid_recipes[math.max(self.currentkey,1)]
end
--取得有效组合
function SmartCooker:GetValidRecipes()
	return self.valid_recipes
end
--食谱排序
function SmartCooker:SortTable(tb) -- method 选 hunger,health,sanity 
	local fn = function(a,b)  -- best=>worst
		if (a and a[self.method] or 0) == (b and b[self.method] or 0) then
			if (a and a.cooktime or 0) == (b and b.cooktime or 0) then
				if (a and a.name or '') == (b and b.name or '') then
					if (a and a.times or 0) == (b and b.times or 0) then
						if  (a and a.prefablist[1] or '') == (b and b.prefablist[1] or '') then
							if  (a and a.prefablist[2] or '') == (b and b.prefablist[2] or '') then
								if  (a and a.prefablist[3] or '') < (b and b.prefablist[3] or '') then
									return  (a and a.prefablist[4] or '') < (b and b.prefablist[4] or '')
								else
									return  (a and a.prefablist[3] or '') < (b and b.prefablist[3] or '')
								end
							else
								return  (a and a.prefablist[2] or '') < (b and b.prefablist[2] or '')
							end
						else
							return (a and a.prefablist[1] or '') < (b and b.prefablist[1] or '')
						end
					else 
						return (a and a.times or 0) > (b and b.times or 0)
					end
				else
					return (a and a.name or '') < (b and b.name or '')
				end
			else
				return (a and a.cooktime or 0) > (b and b.cooktime or 0) 
			end
		else	
			return (a and a[self.method] or 0) > (b and b[self.method] or 0) 
		end
	end
	table.sort(tb,fn)
	self.inst:PushEvent('permute_tx_bt')
end
--是否有以匹配的食谱
function SmartCooker:NoValidRecipes()
	return #self.valid_recipes == 0
end
--下一种料理的组合
--function SmartCooker:NextRecipes()
--	if self:NoValidRecipes() then return end
--	local product = self:GetRecipe().name
--	for k,v in ipairs(self.valid_recipes) do
--		if v.name ~= product and k > self.currentkey then
--			self.currentkey = k
--			return 
--		end
--	end
--	self.currentkey = 1
--end
--下一组组合
function SmartCooker:NextRecipe(num)
	--if self:NoValidRecipes() then return end
	self.currentkey = self.currentkey+(num or 1)
	self.currentkey = self.currentkey>#self.valid_recipes and 1 or self.currentkey
end
function SmartCooker:PreviousRecipe(num)
	--if self:NoValidRecipes() then return end
	self.currentkey = self.currentkey-(num or 1)
	self.currentkey = self.currentkey< 1 and #self.valid_recipes or self.currentkey
end
--到指定的料理的食谱去
function SmartCooker:ToRecipes(foodname)
	if self:NoValidRecipes() or not foodname then return end
	for k,v in ipairs(self.valid_recipes) do
		if v.name == foodname then
			self.currentkey = k
			return
		end
	end
end
--取得目前组合 信息
function SmartCooker:GetStringInfo()
	if self:NoValidRecipes() or not self.inst:HasTag('A_Acasual_ing') then return '' end
	local product = self:GetRecipe().name
	local keys = {}
	for k,v in ipairs(self.valid_recipes) do
		if v.name == product then
			table.insert(keys,k)
		end
	end
	table.sort(keys) 
	return '[ '..(self.currentkey-keys[1]+1)..' / '..(#keys)..' ]--[ '..self.currentkey..' / '..(#self.valid_recipes)..' ]'
end
--清除匹配的食谱组合
function SmartCooker:ClearRecipes()
	--table.clear(self.selected_items)
	table.clear(self.valid_recipes)
	self.invs = nil
	self.currentkey = 0
end
--最后检测是否可填充满锅   防止作弊行为
function SmartCooker:CanStuffCookpot(prefablist)
	local ings = {}
	for k,inv in pairs(self.invs) do
		self:SearchIngs(inv,ings)
	end
	for ing,num in pairs(prefablist) do --再次检测当前组合是否有足够材料填满   防止把材料放地上导致的bug
		if not ings[ing] or ings[ing]<num then
			return false
		end
	end
	return true
end
--开始   寻找食材  匹配料理组合   用虚拟材料填充锅
function SmartCooker:StuffCookpot(invs)
	if invs and self:ShouldStart(invs) then
		self:ClearRecipes()
		self.invs = invs
		self:FindValidRecipes(self.invs)
		self:NextRecipe()
	end
	if self:NoValidRecipes() then return end
	--table.clear(self.selected_items)
	local recipe = self:GetRecipe()
	
	--添加虚拟材料
	for ing,num in pairs(recipe.prefablist) do
		for i=1,num do -- 1~4
			local selected_item = nil
			for k=3,1,-2 do  --先删箱子  3  1  因为检测物品栏即自动检测背包
				local inv = self.invs[k]
				local c = inv and (inv.components.container or inv.components.inventory)
				if c then
					selected_item =c:FindItem(function(inst) return inst.prefab==ing end)
					if selected_item then --1.1.6版 少了这，会有些组合无效
						break
					end
				end
			end
			--if not selected_item then print("We  Need :"..ing) end
			if selected_item then
				local perish_time = selected_item.components.perishable and selected_item.components.perishable.perishremainingtime
				local item = SpawnPrefab(ing)
				if item then
					if perish_time then item.components.perishable.perishremainingtime = perish_time end
					if item.components.edible then
						item.components.edible.CollectInventoryActions=function() return end
						item.components.edible.CollectUseActions=function() return end
					end
					item.components.inventoryitem.CollectInventoryActions=function() return end
					item.components.inventoryitem.CollectSceneActions=function() return end
					item.components.inventoryitem.CollectPointActions=function() return end
					item.components.inventoryitem.CollectUseActions=function() return end
					item.components.inventoryitem:SetOnActiveItemFn(function() self.inst.components.container:GiveItem(item,nil,nil,true) GetPlayer().components.inventory:SetActiveItem(nil) end)					
					
					self.inst.components.container:GiveItem(item,nil,nil,true)
					self.inst:AddTag('A_Acasual_ing')
					--table.insert(self.selected_items,selected_item)
				end
			end
		end
	end
	--各种原因导致无法填满则把放入的虚拟材料清除
	if not self.inst.components.container:IsFull() then self:ClearCookpot() end
end
--开始烹饪  先清除容器中的真实材料
function SmartCooker:RemoveItemsFromInvs(prefablist)
	for ing,num in pairs(prefablist) do
		for i=1,num do -- 1~4
			for k=3,1,-2 do  --先删箱子  3  1  因为检测物品栏即自动检测背包
				local inv = self.invs[k]
				local c = inv and (inv.components.container or inv.components.inventory)
				if c and c:Has(ing,1) then --能到这一步肯定在打开的容器中有材料的
					c:ConsumeByName(ing, 1)
					break
				end
			end
		end
	end
end
--清除锅中材料
function SmartCooker:ClearCookpot()
	--虚拟材料
	if self.inst:HasTag('A_Acasual_ing') then self.inst:RemoveTag('A_Acasual_ing') self.inst.components.container:DestroyContents() return end
	--真实材料
	local player = GetPlayer()
	for k=1,self.inst.components.container.numslots do 
		local v = self.inst.components.container.slots[k]
		if v then
			if v.prevcontainer and v.prevcontainer.inst~=self.inst and (v.prevcontainer.itemslots or v.prevcontainer.open) then
				v.prevcontainer:GiveItem(v,v.prevslot,nil,true)
			else
				player.components.inventory:GiveItem(v,nil,nil,true)
			end
			self.inst.components.container.slots[k] = nil  
			self.inst:PushEvent("itemlose", {slot = k})			
		end
	end
end
--关闭锅时清除材料和当前可用组合
function SmartCooker:OnCookpotClose()
	if self.inst:HasTag('A_Acasual_ing') then
		self:ClearCookpot()
	end
	self:ClearRecipes()
end
--添加新组合
function SmartCooker:AddNewRecipe(prefablist,product)
	if not prefablist then return end
	if not product or table.contains(useless_products,product) then return end
	local function fx()
		 local sparkleFX = SpawnPrefab("sparklefx")
		  local pos = self.inst:GetPosition()
		  pos.y = pos.y+2
		  sparkleFX.Transform:SetScale(2,2,2)
		  sparkleFX.Transform:SetPosition(pos:Get())
	end
	if self.recipes[product] then
		local prefablists = self.recipes[product]
		for k,v in ipairs(prefablists) do
			local is_this_prefablist = true
			for ing,num in pairs(v.prefablist) do
				if not prefablist[ing] or  prefablist[ing] ~= num then is_this_prefablist=false break end
			end
			if is_this_prefablist then
				v.times = v.times+1
				--print('Add   .   Old_Food    :   '..product..'     Times+1 = '..v.times)
				return
			end
		end
		--没找到相同的组合则插入新组合
		if #prefablists>=18 then --增加到18种组合
			table.sort(prefablists,function(a,b) return (a and a.times or 0) > (b and b.times or 0) end)
			table.remove(prefablists,#prefablists)
		end
		--print('Add    .   Old_Food    :   '..product ..'      New prefablist')
		table.insert(prefablists,{prefablist=prefablist,times=1})
		fx()
	else
		--print('Add   .    New_Food    :   '.. product)
		self.recipes[product] = {{prefablist=prefablist,times=1}}
		fx()
	end
end

---------------------------------------------预测食物----------------------------------------------------

--our naming conventions aren't completely consistent, sadly
local aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}
local null_ingredient = {tags={}}
local function GetIngredientData(prefabname)
	local name = aliases.prefabname or prefabname
	return cooking.ingredients[name] or null_ingredient
end
local function GetIngredientValues(prefablist)
	local prefabs = {}
	local tags = {}
	for k,v in pairs(prefablist) do
		local name = aliases[v] or v
		prefabs[name] = prefabs[name] and prefabs[name] + 1 or 1
		local data = GetIngredientData(name)
		if data then
			for kk, vv in pairs(data.tags) do
				tags[kk] = tags[kk] and tags[kk] + vv or vv
			end
		end
	end
	return {tags = tags, names = prefabs}
end 

function SmartCooker:GetProductInfo()
if not self.inst.components.container:IsFull() then return end
	local spoilage_total = 0
	local spoilage_n = 0
	local ings = {}			
	local product_spoilage = 1
	for k,v in pairs (self.inst.components.container.slots) do
		table.insert(ings, v.prefab)
		if v.components.perishable then
			spoilage_n = spoilage_n + 1
			spoilage_total = spoilage_total + v.components.perishable:GetPercent()
		end
	end
	
	if spoilage_total > 0 then
		product_spoilage = spoilage_total / spoilage_n
		product_spoilage = 1 - (1 - product_spoilage)*.5
		product_spoilage = math.floor(product_spoilage*100+.5)/100
	end

	local cooker = self.specialcookername --or self.cookername or self.inst.prefab
	if not cooker or (cooking.ValidRecipe and not cooking.ValidRecipe(cooker, ings)) then
		cooker = self.cookername or self.inst.prefab
	end
	
	local recipes = cooking.recipes[cooker] or {}
	local ingdata = GetIngredientValues(ings)
	local candidates = {}
	local top_candidates = {}
	local total = 0
	local chance = 1
	
	for k,v in pairs(recipes) do
		if v.test(cooker, ingdata.names, ingdata.tags) then
			table.insert(candidates,v)
		end
	end
	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	if #candidates > 0 then
		--find the set of highest priority recipes
		local idx = 1
		local val = candidates[1].priority or 0

		for k,v in ipairs(candidates) do
			if k > 1 and (v.priority or 0) < val then
				break
			end
			table.insert(top_candidates, v)
		end
	end
	table.sort( top_candidates, function(a,b) return (a.weight or 1) > (b.weight or 1) end )	
	for k,v in pairs(top_candidates) do
		total = total + (v.weight or 1)
	end
	chance = math.floor((top_candidates[1].weight/total*100+.5))/100
	return {name = top_candidates[1].name,chance = chance,product_spoilage=product_spoilage}
end

return SmartCooker