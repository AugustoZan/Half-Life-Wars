AddCSLuaFile()
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Combine Computer"
ENT.Author = "Alcachofas13"
ENT.Information = "The combine computers"
ENT.Purpose = "The path for stalkers"
ENT.Category = "Half Life: Wars"

ENT.Spawnable = true
ENT.AdminOnly = false

if SERVER then
    function ENT:SpawnFunction( pl, tr, classname )

        if ( !tr.Hit ) then return end
    
        local SpawnPos = tr.HitPos
        local SpawnAng = pl:EyeAngles()
        SpawnAng.p = 0
        
        SpawnAng = SpawnAng:Forward():Angle()
    
        local ent = ents.Create( classname )
        ent:SetPos( tr.HitPos )
        ent:SetAngles( SpawnAng )
        ent:Spawn()
        ent:Activate()
    
        return ent
    
    end
    
    function ENT:Initialize()
        self.Posicion = self:GetAngles()
        self:SetAngles(self:GetAngles())
        self:SetModel("models/props_junk/garbage_carboard002a.mdl")
        self:DrawShadow( false )
        -- Set up the NPC's physics
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:DropToFloor()
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetNoDraw(true)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:EnableMotion(false)
        end
        self.prop = ents.Create( "prop_physics" )
        self.prop:SetModel("models/props_combine/combine_interface001.mdl")
        self.prop:SetPos(self:GetPos() + self:GetRight() * -2 + self:GetForward() * 37 + self:GetUp() * 5)
        self.prop:SetAngles(Angle(0, self:EyeAngles().y - 180, 0))
        self.prop:PhysicsInit(SOLID_VPHYSICS)
        self.prop:SetMoveType(MOVETYPE_VPHYSICS)
        self.prop:SetSolid(SOLID_VPHYSICS)
        self.prop:Spawn()
        self.prop:GetPhysicsObject():EnableMotion(false)
        self.prop:DropToFloor()
        self.prop:SetCollisionGroup(COLLISION_GROUP_NONE)
        if IsValid(self.prop) and IsValid(self) then self.prop:DeleteOnRemove(self) end
        self:DeleteOnRemove(self.prop)
    end
end
