AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.Category = "HLW Entities"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self:SetAngles(self:GetAngles())
    self:SetModel("models/props_combine/CombineThumper002.mdl")
    --self:SetModelScale(2)
    --elf:ManipulateBoneScale( 0.5, self:GetPos() )
    self:DrawShadow( false )
    self.Dead = false
    -- Set up the NPC's physics
    self:SetNPCClass(CLASS_COMBINE)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:CapabilitiesRemove(CAP_MOVE_GROUND)
    self:SetMaxHealth(10)
    self:SetHealth(10)
    self:SetCollisionBounds(Vector(0, 0, 0), Vector(0, 0, 0))
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end
end
function ENT:Draw()
    self:DrawModel()
    self:DrawCollisionBounds()
end
function createSmoke(ent)
    local sfx = EffectData()
    sfx:SetOrigin(ent:GetPos())
    util.Effect("effect_humo",sfx)
    util.ScreenShake( ent:GetPos(), 32, 210, 1, 1024 )
end
function ENT:OnTakeDamage(dmg)
    -- Apply damage to the NPC
    if(dmg:IsDamageType(DMG_BLAST + DMG_DISSOLVE)) then

        return false;
        
    end
    if self:IsValid() and self:Health() > 0 then
        self:SetHealth(self:Health() - dmg:GetDamage())
    end

    if self:Health() <= 0 and not self.Dead and self:IsValid() then
        self:SetHealth(0)
        self:SetNPCClass(CLASS_NONE)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        self.Dead = true
        local entIndex = self:EntIndex() -- Get the entity's unique ID
        local sinkSpeed = 40
        local sinkTimer = 0
        local opacity = 255
        self:EmitSound("ambient/machines/wall_crash1.wav")
        self:SetRenderMode(RENDERMODE_TRANSALPHA)
        createSmoke(self)
        timer.Create("hlw_statue_sink_".. entIndex, 0.01, 400, function()
            if self:IsValid() then
                self:SetPos(self:GetPos() - Vector(0, 0, sinkSpeed * 0.005))
                sinkTimer = sinkTimer + 1
                if sinkTimer >= 300 then
                    opacity = opacity - 3
                    if opacity > -1 then
                        self:SetColor(Color(255, 255, 255, opacity))
                    end
    
                end
                if sinkTimer >= 400 then
                    self:Remove()
                end
                if sinkTimer % 10 == 0 then
                    
                end
            end

        end)
    end
end

function ENT:OnRemove()
    if self and self:IsValid() then
        self:Remove()
    end
end