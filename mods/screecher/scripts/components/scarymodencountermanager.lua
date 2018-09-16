local dspfreq = 1200
local shamblerdsp =
{
	--["set_music"] = dspfreq,
	["set_ambience"] = dspfreq,
	--["set_sfx/HUD"] = freq,
	["set_sfx/movement"] = dspfreq,
	--["set_sfx/creature"] = dspfreq,
	["set_sfx/player"] = dspfreq,
	["set_sfx/sfx"] = dspfreq,
	["set_sfx/voice"] = dspfreq,
	["set_sfx/set_ambience"] = dspfreq,
}

local finaldspfreq = 500
local finaldsp =
{
	["set_music"] = finaldspfreq,
	["set_ambience"] = finaldspfreq,
	--["set_sfx/HUD"] = freq,
	["set_sfx/movement"] = finaldspfreq,
	--["set_sfx/creature"] = dspfreq,
	["set_sfx/player"] = 2000,
	["set_sfx/sfx"] = finaldspfreq,
	["set_sfx/voice"] = finaldspfreq,
	["set_sfx/set_ambience"] = finaldspfreq,
}

local notedspfreq = 500
local notedsp =
{
	["set_music"] = notedspfreq,
	["set_ambience"] = notedspfreq,
	--["set_sfx/HUD"] = freq,
	["set_sfx/movement"] = notedspfreq,
	--["set_sfx/creature"] = dspfreq,
	["set_sfx/player"] = 2000,
	["set_sfx/sfx"] = notedspfreq,
	["set_sfx/voice"] = notedspfreq,
	["set_sfx/set_ambience"] = notedspfreq,
}

local phases = {
	["Wakeup"] = {
		values = {
			stoptime = 0,
			length = 10,
		},
		init = function(manager, values)
			local player = GetPlayer()
			local delay = 0.1

			player:DoTaskInTime(delay, function()
                player.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream")
			end)

			delay = delay + 3

			player:DoTaskInTime(delay, function()
				--Start playing the breathing sound
				player:PushEvent("change_breathing", {intensity = 1, duration=-1})
				player.components.talker:Say("What was that sound?", 2.5, false)
			end)

			delay = delay + 2

			player:DoTaskInTime(delay, function()
			    local x,y,z = player.Transform:GetWorldPosition()
			    local ents = TheSim:FindEntities(x,y,z, 2, "scarymod_campfire")
			    for k, v in pairs(ents) do
			    	if v.components.burnable then
			    		v.components.burnable:Ignite()
			    		v:RemoveTag("CLICK")
			    	end
			    end
			end)

			delay = delay + 2

			player:DoTaskInTime(delay, function()
				player.components.talker:Say("I should go check it out.", 2.5, false)
			end)

			values.stoptime = GetTime() + values.length
		end,
		update = function(manager, values)
			if GetTime() > values.stoptime then
				manager:NextBeat()
			end
            local player = GetPlayer()
            local flashlight_ent = player.FlashlightEnt()
            if flashlight_ent then
				manager:ChangeBeat(3)
			end
		end,
		cleanup = function(manager, values)
		end,
	},
	["Start"] = {
		values = {
			tutorialtext = "Find a flashlight (spacebar to interact)"
		},
		init = function(manager, values)
			GetPlayer().HUD.tutorialtext:SetTutorialText(values.tutorialtext)
			GetPlayer().HUD.tutorialtext:FadeIn()
            manager.inst:ListenForEvent("showflashlight", function()

				manager:NextBeat()

				--Use Debug Key 'I', it's easier. ;)
				--manager:ChangeBeat(9)
				--c_gonext("generator")
            end)

		end,
		update = function(manager, values)
		end,
		cleanup = function(manager, values)
			GetPlayer().HUD.tutorialtext:FadeOut()
			GetPlayer().HUD.batteryindicator:FadeIn()
		end,
	},
	["TeachToggle"] = {
		values = {
			tutorialtext = "Right-click to toggle flashlight",
            transition = 0.8,
		},
		init = function(manager, values)
            local player = GetPlayer()
            local flashlight_ent = player.FlashlightEnt()
            player:DoTaskInTime(values.transition, function()
                if not flashlight_ent.components.flicker.ison then
                    GetPlayer().HUD.tutorialtext:SetTutorialText(values.tutorialtext)
                    GetPlayer().HUD.tutorialtext:FadeIn()
                end
            end)
		end,
		update = function(manager, values)
            local flashlight_ent = GetPlayer().FlashlightEnt()
            if flashlight_ent then
				if flashlight_ent.components.flicker.ison then
					manager:NextBeat()
				end
            end
		end,
		cleanup = function(manager, values)
            GetPlayer().HUD.tutorialtext:FadeOut()
		end,
	},
	["TeachFires"] = {
		values = {
			tutorialtext = "Light campfires to conserve battery",
            stoptime = 0,
            length = 5,
            transition = 0.8,
		},
		init = function(manager, values)
            values.stoptime = GetTime() + values.length

            local player = GetPlayer()
            local flashlight_ent = player.FlashlightEnt()
            player:DoTaskInTime(values.transition, function()
                GetPlayer().HUD.tutorialtext:SetTutorialText(values.tutorialtext)
				GetPlayer().HUD.tutorialtext:FadeIn()
            end)
		end,
		update = function(manager, values)
			if GetTime() > values.stoptime then
				manager:NextBeat()
			end
		end,
		cleanup = function(manager, values)
            GetPlayer().HUD.tutorialtext:FadeOut()
		end,
	},
    ["TeachRoad"] = {
        values = {
            stoptime = 0,
            length = TUNING.TIME_TO_TEACH_ROAD,
            leftcamp = false,
        },
        init = function(manager, values)
            values.posx, values.posy, values.posz = GetPlayer():GetPosition()
            values.stoptime = GetTime() + values.length
        end,
        update = function(manager, values)
            local origin = Vector3(GetPlayer().homefirepit.Transform:GetWorldPosition())
            local dist_sq = distsq(origin, GetPlayer():GetPosition())
            if dist_sq > TUNING.DIST_TO_CANCEL_TEACH_ROAD  then
                values.leftcamp = true
            end
            if GetTime() > values.stoptime and not values.leftcamp then
                GetPlayer().components.talker:Say("I wonder if anyone's down that road.", 2.5, false)
                values.leftcamp = true
            end
        end,
        cleanup = function(manager, values)
        end,
    },
	["FirstCamper"] = {
		values = {
		},
		init = function(manager, values)
            manager.inst:ListenForEvent("firstcamperactivated", function()
            	GetPlayer():PushEvent("change_breathing", {intensity = 2, duration=4})
                if manager.campers_encountered < 1 then manager.campers_encountered = 1 end
            end)
		end,
		update = function(manager, values)
			if manager.campers_encountered == 1 or manager.area.story == "Camp2_Task" then
                GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.FIRST_MUSIC_INCREASE)
				manager:NextBeat()
	        end
		end,
		cleanup = function(manager, values)
            -- Make sure the camper count is correct
            if not manager.campers_encountered == 1 then manager.campers_encountered = 1 end
		end,
	},
    ["SecondCamper"] = {
        values = {
        },
        init = function(manager, values)
            manager.inst:ListenForEvent("secondcamperactivated", function()
                if manager.campers_encountered < 2 then manager.campers_encountered = 2 end
            end)
        end,
        update = function(manager, values)
            if manager.campers_encountered == 2 or manager.area.story == "Camp2_to_3" then
                GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.SECOND_MUSIC_INCREASE)
                manager:NextBeat()
            end
        end,
        cleanup = function(manager, values)
            -- Make sure the camper count is correct
            if not manager.campers_encountered == 2 then manager.campers_encountered = 2 end
        end,
    },
    ["StalkCamper"] = {
        values = {
        	num_stalkers_avoided = 0
        },
        init = function(manager, values)
        	GetPlayer():PushEvent("change_breathing", {intensity = 2, duration=-1})
        end,
        update = function(manager, values)
            --if manager.area.story == "Camp3_Task" then
            if manager.area.story == "Camp5_Task" then
                --GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.SECOND_MUSIC_INCREASE)
                manager:NextBeat()
            end

			if manager.shamblers[1] == nil then
				if manager.time_since_last_shambler > manager.time_between_shamblers then
					if values.num_stalkers_avoided >= 2 then

						-- on the third shambler onward...
						if not manager.hasseenkiller then
							manager:WantToSpawnShambler("killer")
						else
							if values.num_stalkers_avoided > 3 and values.num_stalkers_avoided % 3 == 0 then
								manager:WantToSpawnShambler("killer")
							else
								manager:WantToSpawnShambler("teaser")
							end
						end

						manager.hasseenkiller = true
					else
						manager:WantToSpawnShambler("teaser")
					end
				end
			end

			if #manager.shamblers == 0 then
				return
			end

			-- If the player gets too far from this guy, remove him
			local dist_sq = distsq(manager.shamblers[1]:GetPosition(), GetPlayer():GetPosition())
			if dist_sq > ((TUNING.SHAMBLER_DESPAWN_DIST) * (TUNING.SHAMBLER_DESPAWN_DIST))  then
				manager:RemoveShambler(manager.shamblers[1])
				return
			end
			manager:CheckShamblersForVisBlocking()
        end,
        avoidedshambler = function(manager, values)
        	values.num_stalkers_avoided = values.num_stalkers_avoided + 1

        	if manager.hasseenkiller then
				--now make it more rare to spawn shamblers
				TUNING.MIN_TIME_BETWEEN_ADD_SHAMBLER = TUNING.MIN_TIME_BETWEEN_ADD_SHAMBLER2
				TUNING.MAX_TIME_BETWEEN_ADD_SHAMBLER = TUNING.MAX_TIME_BETWEEN_ADD_SHAMBLER2
			end
        end,
        cleanup = function(manager, values)
        	GetPlayer():PushEvent("change_breathing", {intensity = 1, duration=-1})
        end,
    },
	["NoteWatch1"] = {
		values = {
			numnotes = 0,
            blewoutfire = false,
            shamblerspawndelay = 1.7,
            shamblerspawntime = 0,
            spawnedshambler = false,
            finishedshambler = false,
			player_start_pos = nil,
		},
		init = function(manager, values)
			values.numnotes = manager.lore_found
            manager.inst:ListenForEvent("shownote", function(inst, data)
                if data.note == 3 then --3 is the "Eats the light, feeds in the dark" note
                	GetPlayer().SoundEmitter:PlaySound("scary_mod/music/hit_light_piano")
                end
            end)
            manager.inst:ListenForEvent("hidenote", function(inst, data)
                if data.note == 3 then --3 is the "Eats the light, feeds in the dark" note
                	manager:KillAllShamblers()
					manager.inst:DoTaskInTime(1.4, function()                 	
						GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/blowout")
					end)

                    manager.inst:DoTaskInTime(1.7, function() 
		               	--GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/tension")
                    	GetPlayer():PushEvent("change_default_breathing", {intensity = 2})
                        local player = GetPlayer()
                        local x,y,z = player.Transform:GetWorldPosition()
                        local ents = TheSim:FindEntities(x,y,z, 20, "campfire")
                        for k, v in pairs(ents) do
                            if v.components.burnable then
                                v.components.burnable:Extinguish()
                                v:DoTaskInTime(2, function()
                                	v.components.activatable.inactive = true
                                	v:AddTag("CLICK")
                                end)
                            end
                        end

                        manager.inst:DoTaskInTime(0.5, function() 
	                        local flashlight_ent = player.FlashlightEnt()
	                        if flashlight_ent then
	                            local flicker = flashlight_ent.components.flicker
	                            flicker:ForceStartFlicker(1)
	                            manager.inst:DoTaskInTime(1.0, function() 
		                            if flicker.ison and flicker.cantoggle then
		                                flicker:ToggleFlashlight()
			                            GetPlayer().components.talker:Say("Shit! My flashlight!", 2, false)
		                                GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/flashlight_out")
		                            end
		                        end)
	                        end
	                    end)
	                    GetPlayer().HUD.externalblockmap = true
	                    GetPlayer():DoTaskInTime(5, function()
	                    	GetPlayer().HUD.externalblockmap = false
	                    end)
                        values.blewoutfire = true
                        values.shamblerspawntime = GetTime() + values.shamblerspawndelay
                        GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.THIRD_MUSIC_INCREASE)
                    end)
                end
            end)
		end,
		update = function(manager, values)
			if values.blewoutfire and GetTime() > values.shamblerspawntime then

                if not values.spawnedshambler then

					-- only play the scream once for this encounter
					manager.inst:DoTaskInTime(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("scary_mod/kid/scared_female") end)

                    if manager.shamblers[1] == nil then
                        manager:WantToSpawnShambler("observer")
                    end

                    if #manager.shamblers == 0 then
                        return
                    end

                    -- If the player gets too far from this guy, remove him
                    values.spawnedshambler = true
					values.player_start_pos = GetPlayer():GetPosition()
				else
					local dist_sq = distsq(values.player_start_pos, GetPlayer():GetPosition())
                    if dist_sq > ((TUNING.SHAMBLER_OBSERVER_DESPAWN_DISTANCE) * (TUNING.SHAMBLER_OBSERVER_DESPAWN_DISTANCE))  then
						manager.want_shambler = false
						values.finishedshambler = true
						manager:SawShambler(nil) -- this removes all the shamblers and resets the timer
						manager.inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_eat_last")
						manager.inst:DoTaskInTime(1.8, function(inst) inst.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream") end)
                    end
                end
            end
            if values.finishedshambler or manager.area.story == "Camp3_to_4" then
                manager:NextBeat()
			end
		end,
        avoidedshambler = function(manager, values)
            GetPlayer():PushEvent("change_breathing", {intensity = 3, duration=6})
            values.finishedshambler = true
        end,
		cleanup = function(manager, values)
            -- Make sure we've ramped up the music
            GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.THIRD_MUSIC_INCREASE)
            if manager.shamblers[1] then
                manager:RemoveShambler(manager.shamblers[1])
            end
		end,
	},
    ["ThirdCamper"] = {
        values = {
        },
        init = function(manager, values)
            manager.inst:ListenForEvent("thirdcamperdead", function()
                if manager.campers_encountered < 3 then manager.campers_encountered = 3 end
            end)
        end,
        update = function(manager, values)
            if manager.campers_encountered == 3 or manager.area.story == "Camp4_Task" then
                --GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.FOURTH_MUSIC_INCREASE)
                manager:NextBeat()
            end
        end,
        cleanup = function(manager, values)
            -- Make sure the camper count is correct
            if not manager.campers_encountered == 3 then manager.campers_encountered = 3 end
        end,
    },
	["InvisibleStalking"] = {
		values = {
			next_stalk = 0,
			current_delay = 0,
		},
		init = function(manager, values)
			values.current_delay = math.random(TUNING.INVISIBLE_STALK_MIN_DELAY, TUNING.INVISIBLE_STALK_MAX_DELAY)
			values.next_stalk = GetTime() + values.current_delay
		end,
		update = function(manager, values)
			if #manager.shamblers ~= 0 then
				values.current_delay = math.random(TUNING.INVISIBLE_STALK_MIN_DELAY, TUNING.INVISIBLE_STALK_MAX_DELAY)
				values.next_stalk = GetTime() + values.current_delay
			end
			if values.next_stalk < GetTime() then
				values.current_delay = math.random(TUNING.INVISIBLE_STALK_MIN_DELAY, TUNING.INVISIBLE_STALK_MAX_DELAY)
				values.next_stalk = GetTime() + values.current_delay

				local center = GetPlayer():GetPosition()
				local angle = math.random()*360
				local distance = TUNING.INVISIBLE_STALK_SPAWN_DIST
				local result_offset = FindValidPositionByFan(angle*DEGREES, distance, 60, function(offset)
					local spawn_point = center + offset
					if (TheSim:GetLightAtPoint(spawn_point:Get()) > TUNING.DARK_CUTOFF) then
						return false
					end
					return true
				end)

				if result_offset then
					local soundent = SpawnPrefab("stalking_noise")
					soundent.Transform:SetPosition( (center + result_offset):Get() )
					soundent.StartMoving()
				end
			end

		end,
		cleanup = function(manager, values)
		end,
	},
    ["Helipad"] = {
        values = {
        	lengthaftergameover = 3,
        	stoptime = 0,
        	setstoptime = false,
        	generatortuttex = "Start the generator",
        	tutoriallength = 5,
        	tutorialstoptime = 0,
        },
        init = function(manager, values)

        	--jcheng: used to show face eating screen or not
        	manager.isfinaldeath = true

        	local templight = function()
		        local player = GetPlayer()
	            local x,y,z = player.Transform:GetWorldPosition()
	            local ents = TheSim:FindEntities(x,y,z, 200, {"beacon"})
	            print("num beacons: "..table.getn(ents))
	            for k, v in pairs(ents) do
                    v:PushEvent("onbeacontemplit")
	            end
	        end

        	local fulllight = function()
		        local player = GetPlayer()
	            local x,y,z = player.Transform:GetWorldPosition()
	            local ents = TheSim:FindEntities(x,y,z, 200, {"beacon"})
	            print("num beacons: "..table.getn(ents))
	            for k, v in pairs(ents) do
                    v:PushEvent("onbeaconlit")
	            end

	            --GetPlayer():PushEvent("spawn_shambler")
	        end

	        local breakalllights = function(player)
	            local x,y,z = player.Transform:GetWorldPosition()

	            -- Put out the fire immediately
	            local fires = TheSim:FindEntities(x,y,z, 300, {"firepit"})
                for i, f in pairs(fires) do
                    if f.components.burnable then
                    	if f.components.burnable:IsBurning() then
                        	f.components.burnable:Extinguish()
                        	f.SoundEmitter:PlaySound("scary_mod/stuff/blowout")
                        end
                    end
                end

                -- Then the generator
                local gens = TheSim:FindEntities(x,y,z, 200, {"generator"})
                for m, n in pairs(gens) do
                    if n.Light then
                        n.Light:SetIntensity(0)
                    end
                end
                player:PushEvent("killgensound")

                -- Put out the beacons quickly, but staggered
	            local beacons = TheSim:FindEntities(x,y,z, 200, {"beacon"})
	            print("num beacons: "..table.getn(beacons))
	            local delay = 1
	            for k, v in pairs(beacons) do
	            	if not v.broken then
	            		v:DoTaskInTime(delay*FRAMES*7, function(v)
	            			v:PushEvent("onbeaconbreak")
	            		end)
                    	delay = delay + 1
                    end
	            end
	        end

        	local breaklight = function()
		        local player = GetPlayer()
	            local x,y,z = player.Transform:GetWorldPosition()
	            local ents = TheSim:FindEntities(x,y,z, 200, {"beacon"})
	            print("num beacons: "..table.getn(ents))
	            for k, v in pairs(ents) do
	            	if not v.broken then
	            		v:PushEvent("onbeaconbreak")
                    end
	            end
	        end

        	GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.FOURTH_MUSIC_INCREASE)
        	local player = GetPlayer()

        	manager.inst:ListenForEvent("generatortutorial", function(inst)
        		if not manager.genpulled then
	 				player.HUD.tutorialtext:SetTutorialText(values.generatortuttex)
					player.HUD.tutorialtext:FadeIn()
					values.tutorialstoptime = GetTime() + values.tutoriallength
				end
        	end, GetPlayer())

            manager.inst:ListenForEvent("generator_pull", function(inst,data)
            	manager.genpulled = true
            	if data.num_generator_pulls == 1 then
            		player:DoTaskInTime(0.1, templight)

	            	player:DoTaskInTime(1.2, function()
	            		GetPlayer().components.talker:Say("Dammit, start already!", 2, false)
	            		--manager:StartStaticRing()
	            	end)

	            	player:DoTaskInTime(1.7, function()
	            		--player.SoundEmitter:PlaySound("scary_mod/stuff/screetch_scream")
	            		GetPlayer():PushEvent("change_breathing", {intensity = 2, duration=20})
	            		GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.FIFTH_MUSIC_INCREASE)
	            	end)

	            elseif data.num_generator_pulls == 2 then
	            	player.SoundEmitter:PlaySound("scary_mod/stuff/helicopter", "heli")

	            	player:DoTaskInTime(0.1, templight)

	            	player:DoTaskInTime(1.2, function()
	            		GetPlayer().components.talker:Say("Come on, come on!", 2, false)
	            	end)

	            else
	            	--DEATH
	            	player:DoTaskInTime(1.5, function()
	            		player.HUD.externalblockmap = true
	            		fulllight()
		            	player:DoTaskInTime(1.2, function()
		            		GetPlayer().components.talker:Say("All right!", 2, false)
		            		GetPlayer().components.scarymodmusic:SetBaseMusicLevel(TUNING.FIFTH_MUSIC_INCREASE + 0.05)
		            		GetPlayer():DoTaskInTime(0.5, function()
		            			GetPlayer():PushEvent("change_breathing", {intensity = 1, duration=20})
		            		end)

							player:DoTaskInTime(1, function()
								player.SoundEmitter:PlaySound("scary_mod/music/anticipate_7sec", "anticipate")
				            	TheMixer:SetLowPassFilter("set_sfx/sfx", 500, 5)

								player:DoTaskInTime(7, function()
				            		TUNING.DEFAULT_CAM_DISTANCE = 9
				            	end)

								player:DoTaskInTime(7, function(player)

					            	player.SoundEmitter:PlaySound("scary_mod/music/hit_light_piano", "breakscreech")
					            	player.SoundEmitter:KillSound("anticipate")
					            	player:PushEvent("change_default_breathing", {intensity = 3})
					            end)

				            	player:DoTaskInTime(8.5, function(player)

				            		--player.components.scarymodmusic:SetBaseMusicLevel(TUNING.FIFTH_MUSIC_INCREASE)
				            		
				            		breakalllights(player)
				            		--player.SoundEmitter:KillSound("breakscreech")
				            		--player.SoundEmitter:KillSound("breakscreech")

				            		-- Put out the flashlight last
					                player:DoTaskInTime(5.5*FRAMES*7, function()
					                	local flashlight_ent = GetPlayer().FlashlightEnt()
						            	if flashlight_ent then
							            	local flicker = flashlight_ent.components.flicker
							             	if flicker.ison and flicker.cantoggle then
							             		GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/flashlight_out")
							              		flicker:ToggleFlashlight()
											end
										end
									end)

					                player:ListenForEvent("flashlighttoggleon", function()
					                	--GRAHAM: add big screen
					                	if not manager.gameover then
						                	local flashlight_ent = GetPlayer().FlashlightEnt()
							            	if flashlight_ent then
						                		flashlight_ent.components.flicker.cantoggle = false
						                	end
						                	
						                	GetPlayer().HUD.batteryindicator:Hide()
										    local player = GetPlayer()
											local pt = Vector3(player.Transform:GetWorldPosition())
										    local theta = math.random() * 2 * PI
											local min_radius = 20
											local max_radius = 30
											local ground = GetWorld()
											local steps = 40
										    for i = 1, steps do
										    	local radius = math.random(min_radius, max_radius)
										    	local theta2 = theta + math.random()*(PI / steps)
										        local offset = Vector3(radius * math.cos( theta2 ), 0, -radius * math.sin( theta2 ))
										        local wander_point = pt + offset
										       
										        if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE then
													local shambler = SpawnPrefab("shambler")
													local scale = 1+math.random()/2
													shambler.Transform:SetScale(scale,scale,scale)
													shambler:AddTag("finale")
													shambler.Transform:SetPosition(wander_point:Get())
													shambler:DoTaskInTime(math.random()/2, function()
														shambler.components.shamblermodes:SetKind("killer")
														shambler.sg:GoToState("killer_taunt")
													end)
										        end
										        theta = theta - (2 * PI / steps)
										    end
										end
					                end)
				                end)

			            	end)

		            	end)
					end)

	            end
            end)
        end,
        update = function(manager, values)
        	if ((values.tutorialstoptime > 0 and GetTime() > values.tutorialstoptime) or manager.genpulled) and not manager.fadeoutgentut then
        		manager.fadeoutgentut = true
        		GetPlayer().HUD.tutorialtext:FadeOut()
        	end
        	if manager.gameover and not values.setstoptime then
        		values.stoptime = GetTime() + values.lengthaftergameover + 1*FRAMES
        		values.setstoptime = true
        	end
        	if values.setstoptime and GetTime() > values.stoptime then
        		manager:NextBeat()
        	end
        end,
        cleanup = function(manager, values)
        	if manager.shamblers[1] then
				manager:RemoveShambler(manager.shamblers[1])
			end
        end,
    },
    ["EndGame"] = {
		values = {
		},
		init = function(manager, values)
		end,
		update = function(manager, values)
		end,
		cleanup = function(manager, values)
		end,
	},
}

local events = {
	-- event logic not hooked up yet, so this does nothing
}

local beats = {

	{
		phases = {"Wakeup"},
		events = {},
	},
	{
		phases = {"Start"},
		events = {},
	},
	{
		phases = {"TeachToggle"},
		events = {},
	},
	{
		phases = {"TeachFires"},
		events = {},
	},
	{
		phases = {"FirstCamper", "TeachRoad"},
		events = {},
	},
    {
        phases = {"SecondCamper", "InvisibleStalking"},
        events = {},
    },
	{
		phases = {"NoteWatch1"}, --"InvisibleStalking"},
		events = {},
	},
    {
     	phases = {"StalkCamper", "InvisibleStalking"},
     	events = {},
    },
	{
		phases = {"Helipad", "InvisibleStalking"},
		events = {},
	},
	{
		phases = {"EndGame"},
		events = {},
	},
}


local lore = 
{
	{
		--use the flashlight
		type = "note",
		atlas = "images/hud/note_flashlight.xml",
		image = "note_flashlight.tex",
	},
	{
		--note to mom
		type = "note",
		atlas = "images/hud/note3.xml",
		image = "note3.tex",
	},
	{
		--eats the light, feeds in the dark
		type = "note",
		atlas = "images/hud/note5.xml",
		image = "note5.tex",
	},
	{
		--diary 1
		type = "note",
		atlas = "images/hud/note_Jan09.xml",
		image = "note_Jan09.tex",
	},
	{
		--diary 2
		type = "note",
		atlas = "images/hud/note_Jan12.xml",
		image = "note_Jan12.tex",
	},
	{
		--diary 3
		type = "note",
		atlas = "images/hud/note_Jan14.xml",
		image = "note_Jan14.tex",
	},
	{
		type = "speak",
		script = {
			{ "YOU SHOULD NOT SEE THIS", 2.5 },
		},
	},
}

local random_notes = 
{
	{
		--don't look at it
		type = "note",
		atlas = "images/hud/note1.xml",
		image = "note1.tex",
	},
	{
		--drawing of screecher
		type = "note",
		atlas = "images/hud/note4.xml",
		image = "note4.tex",
	},
	{
		type = "speak",
		script = {
			{ "This is someone's stuff.", 2.5 },
			{ [[Why did they leave it out here?]], 3 },
		},
	},
}

local debugger


local function CastToPosition(start, target, rad, tags)
	local offset = target - start
	local d = 0
	local max = offset:Length()
	local dir = offset:GetNormalized()
	while d < max do
		d = d + rad
		local checkpos = start + dir*d
		--print ("checking",d,center, "->", checkpos, "->", spawn_point )
		local ents = TheSim:FindEntities(checkpos.x, checkpos.y, checkpos.z, rad, {"visblocker"})
		--dumptable(ents,0,0)
		if #ents > 0 then
			--print("\t\t\tblocked")
			debugger:Line(start.x, start.z, checkpos.x, checkpos.z, 1, 0, 1, 1)
			return false
		end
	end
			--print("\t\t\topen")
	debugger:Line(start.x, start.z, target.x, target.z, 0, 1, 1, 1)
	return true
end

local ScaryModEncounterManager = Class(function(self, inst)
    self.inst = inst

	debugger = inst.entity:AddDebugRender()

	self.currentbeat = 0
	self.activephases = {}
	self:ChangeBeat(TUNING.STARTING_BEAT)

    self.area = nil
    self.inst:ListenForEvent("changearea", function(inst, area)
        self.area = area
    end)

    self.num_loot_found = 0
    self.total_notes_found = 0
	self.lore_found = 0
	self.random_notes_found = 0
    self.note_num_dismissed  = 0
    self.time_since_note = 0

    self.campers_encountered = 0

	-- a record of the shamblers in the world
	self.shamblers = {}

    self.min_shambler_aggro_level = 0
    self.next_aggro_increase_time = math.random(TUNING.MIN_TIME_BETWEEN_SHAMBLER_AGGRO_INCREASE, TUNING.MAX_TIME_BETWEEN_SHAMBLER_AGGRO_INCREASE)
    self.time_since_aggro_increase = 0

	self.want_shambler = false
    self.time_since_last_shambler = 0 --Track how long ago the player encountered a shambler
    self.time_between_shamblers = math.random(TUNING.MIN_TIME_BETWEEN_ADD_SHAMBLER, TUNING.MAX_TIME_BETWEEN_ADD_SHAMBLER)

    self.gametime = 0

    self.inst:StartUpdatingComponent(self)

    local player = self.inst
    player:ListenForEvent("hidenote", function()
		player.HUD.notetext:SetTutorialText("NOTES FOUND: "..tostring(self.total_notes_found).."/9")
		player.HUD.notetext:FadeIn()
		player:DoTaskInTime(3, function()
			player.HUD.notetext:FadeOut()
		end)
	end)

    player:ListenForEvent("hidemap", function()
		player.HUD.tutorialtext:SetTutorialText("Press [TAB] to use the map.")
		player.HUD.tutorialtext:FadeIn()
		player:ListenForEvent("openmap", function()
			player.HUD.tutorialtext.text:SetAlpha(0)
			player.HUD.tutorialtext:SetTutorialText("")
		end)
		player:AddTag("mapowner")
	end)

    player:ListenForEvent("shownote", function()
    	self.total_notes_found = self.total_notes_found + 1
	end)

    player:ListenForEvent("darknessdeath", function()
    	if self.isfinaldeath and not self.gameover then
    		self:DoFinaleDeath("darkness death")
    	elseif not self.isfinaldeath then
    		self:DoBeforeFinaleDeath("darkness death")
	    end
    end)
end)

function ScaryModEncounterManager:CheckShamblersForVisBlocking()
	if #self.shamblers > 0 then
		self.shambler_to_vis_check = self.shambler_to_vis_check and self.shambler_to_vis_check + 1 or 1
		if self.shambler_to_vis_check > #self.shamblers then
			self.shambler_to_vis_check = 1
		end

		local shambler = self.shamblers[self.shambler_to_vis_check]
		-- If this guy has light on him, we can't touch him. Move on.
		if TheSim:GetLightAtPoint(shambler.Transform:GetWorldPosition()) > 0 then
			return
		end

		-- If we are blocked (and not spotted so far), despawn to try again later.
		if not CastToPosition(GetPlayer():GetPosition(), shambler:GetPosition(), 5, {"visblocker"}) then
			print("shambler",shambler.shambler_id,"obstructed, removing")
			self:RemoveShambler(shambler)
		end
	end
end

function ScaryModEncounterManager:SawShambler(target)
	self.time_between_shamblers = math.random(TUNING.MIN_TIME_BETWEEN_ADD_SHAMBLER, TUNING.MAX_TIME_BETWEEN_ADD_SHAMBLER)
    self.time_since_last_shambler = 0

	self.want_shambler = false
	-- remove excess shamblers!
	-- make a copy coz we're modifying this list
	local shamblers = {}
	for i,shambler in ipairs(self.shamblers) do
		if shambler ~= target then
			table.insert(shamblers, shambler)
		end
	end
	for i,shambler in ipairs(shamblers) do
		self:RemoveShambler(shambler)
	end
	-- tick current phases
	for i,phase in ipairs(self.activephases) do
		if phases[phase].sawshambler then
			phases[phase].sawshambler(self, phases[phase].values)
		end
	end
end

function ScaryModEncounterManager:GetCurrentTutorialText()
	for i,phase in ipairs(self.activephases) do
		if phases[phase].values.tutorialtext then
			--print( phases[phase].values.tutorialtext )
			return phases[phase].values.tutorialtext
		end
	end

	return ""
end

function ScaryModEncounterManager:AvoidedShambler(shambler)
	print("avoided shambler",shambler.shambler_id)
	-- tick current phases
	for i,phase in ipairs(self.activephases) do
		if phases[phase].avoidedshambler then
			phases[phase].avoidedshambler(self, phases[phase].values)
		end
	end
end

function ScaryModEncounterManager:SufferedShambler(shambler)
	print("suffered shambler", shambler.shambler_id)
	-- tick current phases
	for i,phase in ipairs(self.activephases) do
		if phases[phase].sufferedshambler then
			phases[phase].sufferedshambler(self, phases[phase].values)
		end
	end
end

function ScaryModEncounterManager:GetLootDrop(pctfuel)
    --If fuel is less than 20%, player desperately needs battery
    if pctfuel <= 0.2 then
        return 0 -- A battery
    end

    self.num_loot_found = self.num_loot_found + 1
    if self.num_loot_found == 2 then
    	return 2 -- map found
    end

    --If there are more notes to give out, check how long it's been since the last one, then flip a coin
    if self.random_notes_found < #random_notes then
        if self.time_since_note > TUNING.MIN_TIME_BETWEEN_NOTES and math.random() >= 0.5 then
            self.time_since_note = 0
            return 1 -- A note (random bit of lore)
        end
    end 

    --Do some math to decide likelihood of awarding a non-desperation battery, otherwise: nothing
    local batterychance = math.random()
    batterychance = batterychance * (1.1-pctfuel)
    if batterychance >= 0.5 then
        return 0 -- A battery
    end

    return -1 -- Nothing in this container
end

function ScaryModEncounterManager:GetBatteryAmount(pctfuel)
    -- Weighted based on pct fuel left
    local direness = 1.1 - pctfuel
    local randfuelamt = math.random(TUNING.MIN_BATTERY_FUEL_AMOUNT, TUNING.MAX_BATTERY_FUEL_AMOUNT)
    print("Battery fuel on this pickup: " .. direness * randfuelamt)
    return (direness * randfuelamt)
end

function ScaryModEncounterManager:FoundLore(lore_num)
	local player = GetPlayer()

	self.lore_found = self.lore_found + 1
    self.time_since_note = 0

	local note_tbl = lore[lore_num]

	if note_tbl.type == "note" then
		player.HUD.note:DisplayImage(note_tbl.atlas, note_tbl.image, {imagetype="note", notenum=lore_num})

	elseif note_tbl.type == "speak" then
		local delay = 0
		for k, v in pairs(note_tbl.script) do
			player:DoTaskInTime(delay, function()
				player.components.talker:Say(v[1], v[2], false)
			end)
			delay = delay + v[2]
		end
	end
	
	--play lore found sound
	player:DoTaskInTime(0, function()
		self.inst.SoundEmitter:PlaySound("scary_mod/stuff/note_reveal")
	end)
end

function ScaryModEncounterManager:FoundRandomNote()
	local player = GetPlayer()

	self.random_notes_found = self.random_notes_found + 1

	local note_tbl = random_notes[self.random_notes_found]

	if note_tbl.type == "note" then
		player.HUD.note:DisplayImage(note_tbl.atlas, note_tbl.image, {imagetype="note"})
	elseif note_tbl.type == "speak" then
		local delay = 0
		for k, v in pairs(note_tbl.script) do
			player:DoTaskInTime(delay, function()
				player.components.talker:Say(v[1], v[2], false)
			end)
			delay = delay + v[2]
		end
	end
	
    --play lore found sound
    player:DoTaskInTime(0, function()
        self.inst.SoundEmitter:PlaySound("scary_mod/stuff/note_reveal")
    end)
end

function ScaryModEncounterManager:ChangeBeat(new_beat)
	print("changing beat to: "..tostring(new_beat))
	if self.currentbeat ~= new_beat then
		self.currentbeat = new_beat

		-- close old phases
		for i,phase in ipairs(self.activephases) do
			if not table.contains(beats[self.currentbeat].phases, phase) then
				phases[phase].cleanup(self, phases[phase].values)
				print("cleaning up phase: "..phase)
			end
		end

		-- activate new phases
		for i,phase in ipairs(beats[self.currentbeat].phases) do
			if not table.contains(self.activephases) then
				phases[phase].init(self, phases[phase].values)
				print("initializing phase: "..tostring(phase))
			end
		end

		-- phases are now synched, sync the lists
		self.activephases = beats[self.currentbeat].phases
	end
end

function ScaryModEncounterManager:NextBeat()
	self:ChangeBeat(self.currentbeat + 1)
end

function ScaryModEncounterManager:OnUpdate(dt)
	debugger:Flush()
    self.gametime = dt + self.gametime
    self.time_since_last_shambler = dt + self.time_since_last_shambler
    self.time_since_aggro_increase = dt + self.time_since_aggro_increase
    self.time_since_note = dt + self.time_since_note


	-- tick current phases
	for i,phase in ipairs(self.activephases) do
		if phases[phase].update then
			phases[phase].update(self, phases[phase].values)
		end
	end


	-- gjans: Disabling this so we can precisely control the aggro timing of shamblers
        --Increase the base aggro level of shamblers over time
		--[[
	if self.time_since_aggro_increase > self.next_aggro_increase_time then
		self.time_since_aggro_increase = 0 --reset the clock
		self.next_aggro_increase_time = math.random(TUNING.MIN_TIME_BETWEEN_SHAMBLER_AGGRO_INCREASE, TUNING.MAX_TIME_BETWEEN_SHAMBLER_AGGRO_INCREASE)
		self.min_shambler_aggro_level = TUNING.SHAMBLER_AGGRO_INCREASE_DELTA + self.min_shambler_aggro_level
	end
	self.inst:PushEvent("setminaggrolevel", {aggro=self.min_shambler_aggro_level})
	]]

	if self.want_shambler and #self.shamblers < 3 then
		print("We want some more shamblers!")

		self:SpawnShamblerNearby(self.want_shambler_kind)
	end
end

-- Lets the manager know when it's safe to spawn a shambler.
function ScaryModEncounterManager:SuggestShamblerLocation(position, offset, direction)
	if self.want_shambler then
		self:SpawnShambler(position, offset, direction, self.want_shambler_kind)
	end
end

-- Tries to successfully spawn a shambler for the player
function ScaryModEncounterManager:WantToSpawnShambler(kind)
	self.want_shambler = true
	self.want_shambler_kind = kind
end

-- Spawns a shambler in an empty region around the player
function ScaryModEncounterManager:SpawnShamblerNearby(kind)
	-- cover the sectors; one every third
	local front_left = false
	local front_right = false
	local rear = false
	local trash = {}

	local facing = GetPlayer().Transform:GetRotation()
	local facingvec = Vector3(math.cos(facing*DEGREES),0,math.sin(facing*DEGREES))
	local position = GetPlayer():GetPosition()
	local sidefacingvec = Vector3(-facingvec.z,0,facingvec.x)

	for i,shambler in ipairs(self.shamblers) do
		local offsetvec = shambler:GetPosition() - position
		local frontie = (facingvec:Dot(offsetvec) > 0)
		local leftie = (facingvec:Dot(offsetvec) > 0)
		
		if frontie and leftie then
			if front_left then
				table.insert(trash, shambler)
			else
				front_left = true
			end
		elseif frontie and not leftie then
			if front_right then
				table.insert(trash, shambler)
			else
				front_right = true
			end
		else
			if rear then
				table.insert(trash, shambler)
			else
				rear = true
			end
		end
	end
	for i,shambler in ipairs(trash) do
		self:RemoveShambler(shambler)
	end
	if front_left == false then
		local shambler = self:SpawnShambler(position, TUNING.SHAMBLER_SPAWN_DIST[kind], facing + 45, kind)
		--return shambler
	end
	if front_right == false then
		local shambler = self:SpawnShambler(position, TUNING.SHAMBLER_SPAWN_DIST[kind], facing - 45, kind)
		--return shambler
	end
	if rear == false then
		local shambler = self:SpawnShambler(position, TUNING.SHAMBLER_SPAWN_DIST[kind], facing + 180, kind)
		--return shambler
	end

end

-- Puts a shambler in the distance in front of the player
function ScaryModEncounterManager:SpawnShamblerInfront(kind)
	local pos = GetPlayer():GetPosition()
	local dist = TUNING.MAX_SHAMBLER_SPAWN_DIST
	--local dist = math.random(TUNING.MIN_SHAMBLER_SPAWN_DIST, TUNING.MAX_SHAMBLER_SPAWN_DIST)
	local angle = GetPlayer().Transform:GetRotation()
	return self:SpawnShambler(pos, dist, angle, kind)
end

local shambler_id = 0

function ScaryModEncounterManager:StartStaticRing()
	for k,v in pairs(shamblerdsp) do
		TheMixer:SetLowPassFilter(k, v, 2.0)
	end

	--print("play static ring")
	--GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/staticring","staticring")
end

function ScaryModEncounterManager:KillStaticRing()
	for k,v in pairs(shamblerdsp) do
		TheMixer:ClearLowPassFilter(k, 1.0)
	end            

	--print("kill static ring")
	--GetPlayer().SoundEmitter:KillSound("staticring")
end

-- Positions a new shambler in the world
function ScaryModEncounterManager:SpawnShambler(center, distance, angle, kind)

	local flashlight_ent = GetPlayer().FlashlightEnt()
	local ground = GetWorld()
	print("Adding a shambler...")
	local result_offset = FindValidPositionByFan(angle*DEGREES, distance, 60, function(offset)
		local spawn_point = center + offset
		
		local tile = ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z)
		if tile and (tile == GROUND.IMPASSABLE or tile == GROUND.CHECKER) then
			--print("\timpassable")
			return false
		end
		if (flashlight_ent and flashlight_ent.components.lightbeam:IsPointLit(spawn_point)) then
			--print("\tflash-lit")
			return false
		end
		if (TheSim:GetLightAtPoint(spawn_point:Get()) > TUNING.DARK_CUTOFF) then
			--print("\ttoo bright")
			return false
		end
		if not CastToPosition(center, spawn_point, 5, {"visblocker"}) then
			--print("\tsomething in the way!")
			return false
		end
		return true
	end)

	if result_offset then
		local shambler = SpawnPrefab("shambler")
		shambler.Transform:SetPosition((center+result_offset):Get())
		shambler.shambler_id = shambler_id
		shambler_id = shambler_id + 1
		shambler.components.shamblermodes:SetKind(kind)
		print("Added a shambler",shambler.shambler_id)
		table.insert(self.shamblers, shambler)

		return shambler
	end
	print("couldn't spawn this guy")
	return nil
end

function ScaryModEncounterManager:KillAllShamblers()
	print("removing all shamblers")
	for i,shambler in ipairs(self.shamblers) do
		shambler:Remove()
	end
	self.shamblers = {}
end

function ScaryModEncounterManager:RemoveShambler(shambler)
	local idx = -1
	for i,s in ipairs(self.shamblers) do
		if s == shambler then
			idx = i
			break
		end
	end
	if idx >= 0 then
		table.remove(self.shamblers, idx)
	end
	-- always remove this guy, even if we aren't managing him
	shambler:Remove()

	print("Shambler gone", shambler.shambler_id)

end

function ScaryModEncounterManager:DoFinaleDeath(reason)
	print("Player has died in the finale! Reason:",reason)
	self.gameover = true
	--self.inst.SoundEmitter:PlaySound("scary_mod/music/end")

	GetPlayer().sg:GoToState("idle")
	local flashlight_ent = GetPlayer().FlashlightEnt()
	if flashlight_ent then
	    flashlight_ent.components.flicker.cantoggle = false
	end
    GetPlayer():PushEvent("killallsounds")
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local fires = TheSim:FindEntities(x,y,z, 300, {"fx"})
    for i, f in pairs(fires) do
        if f.prefab == "campfirefire" then
        	f.SoundEmitter:KillSound("fire")
        end
    end
	GetPlayer().HUD.bloodover:KillOverlay()
	GetPlayer().HUD.batteryindicator:Hide()
	GetPlayer().components.characterbreathing:StopBreathing()
	GetPlayer():PushEvent("killgensound")
	GetPlayer().SoundEmitter:KillSound("heli")
	GetPlayer().SoundEmitter:KillAllSounds()
	GetPlayer().HUD:EndSequence()
	self.inst:DoTaskInTime(0.5, function()
		self.inst.SoundEmitter:PlaySound("scary_mod/music/musicbox")
	end)
end

function ScaryModEncounterManager:DoBeforeFinaleDeath(reason)
	print("Player has died! Reason:",reason)
    GetPlayer().components.health:Kill()
    GetPlayer():PushEvent("killallsounds")
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local fires = TheSim:FindEntities(x,y,z, 300, {"fx"})
    for i, f in pairs(fires) do
        if f.prefab == "campfirefire" then
        	f.SoundEmitter:KillSound("fire")
        end
    end
	GetPlayer().HUD.bloodover:KillOverlay()
	GetPlayer().HUD.batteryindicator:Hide()
	GetPlayer().components.characterbreathing:StopBreathing()
	GetPlayer().SoundEmitter:KillAllSounds()
	GetPlayer().HUD:Blackout()
	self.inst:DoTaskInTime(1, function()
		self.inst.SoundEmitter:PlaySound("scary_mod/music/musicbox")
	end)
end

function ScaryModEncounterManager:GetDebugString()
	local shamtime = self.time_between_shamblers - self.time_since_last_shambler
	return string.format("Beat: %d Next Shambler: %2.2f, Shamblers: %d, Campers: %d, Phases: %s", self.currentbeat, shamtime, #self.shamblers, self.campers_encountered, table.concat(self.activephases, ", "))
end

return ScaryModEncounterManager
