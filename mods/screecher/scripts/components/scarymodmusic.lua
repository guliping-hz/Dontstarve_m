local ScaryModMusic = Class(function(self, inst)
    self.inst = inst

    self.gametime = 0
    self.enabled = true
    self.base_music_level = 0
    self.darkness_level = 0
   
    self.inst.SoundEmitter:PlaySound( "scary_mod/music/gamemusic", "scarymusic" )

    self.inst:ListenForEvent( "darknessmuschange", function(it, data)
        self.darkness_level = data.darknesslvl
        if self.darkness_level > self.base_music_level then --Make sure we don't go below the base level
            self.inst.SoundEmitter:SetParameter("scarymusic", "param00", self.darkness_level)
        else
            self.inst.SoundEmitter:SetParameter("scarymusic", "param00", self.base_music_level)
        end
    end, GetPlayer())
    
    self.inst:ListenForEvent( "daytime", function(it, data) 
    
            if self.enabled then --and data.day > 0 and not self.playing_danger then
                --self:StopPlayingBusy()
                self.inst.SoundEmitter:PlaySound( "dontstarve/music/music_dawn_stinger" )
            end
            
        end, GetWorld())

    self.inst:ListenForEvent( "nighttime", function(it, data) 
        end, GetWorld())      

    self.inst:StartUpdatingComponent(self)

end)

function ScaryModMusic:SetBaseMusicLevel(val)
    if val then
        self.base_music_level = val
        if self.darkness_level <= self.base_music_level then
            self.inst.SoundEmitter:SetParameter("scarymusic", "param00", self.base_music_level)
        end
    end
end


function ScaryModMusic:Enable()
    self.enabled = true
    self.inst.SoundEmitter:PlaySound( "scary_mod/music/gamemusic", "scarymusic" )
end


function ScaryModMusic:Disable()
    self.enabled = false
    self:StopPlayingScaryMusic()
end

function ScaryModMusic:OnUpdate(dt)
    self.gametime = self.gametime + dt
end

function ScaryModMusic:StopPlayingScaryMusic()
    self.inst.SoundEmitter:KillSound("scarymusic")
end

return ScaryModMusic