AddCSLuaFile()
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Resistance Computer"
ENT.Author = "Alcachofas13"
ENT.Information = "The resistance computers"
ENT.Purpose = "The path for citizens"
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
        self:SetAngles(self:GetAngles())
        self:SetModel("models/props_junk/garbage_carboard002a.mdl")
        self:DrawShadow( false )
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
        self.prop:SetModel("models/props_lab/workspace004.mdl")
        self.prop:SetPos(self:GetPos() + self:GetRight() * -15 + self:GetForward() * 35 + self:GetUp() * 5)
        self.prop:SetAngles(Angle(0, self:EyeAngles().y - 90, 0))
        self.prop:PhysicsInit(SOLID_VPHYSICS)
        self.prop:SetMoveType(MOVETYPE_VPHYSICS)
        self.prop:SetSolid(SOLID_VPHYSICS)
        self.prop:Spawn()
        self.prop:GetPhysicsObject():EnableMotion(false)
        self.prop:DropToFloor()
        self.prop:SetCollisionGroup(COLLISION_GROUP_NONE)
        if IsValid(self.prop) and IsValid(self) then self.prop:DeleteOnRemove(self) end
        self:DeleteOnRemove(self.prop)

        self.computer2 = ents.Create( "hlw_computer2" )
        self.computer2:SetPos(self:GetPos() + self:GetRight() * 50 + self:GetForward() * -0.5 + self:GetUp() *2)
        self.computer2:SetAngles(self:GetAngles())
        self.computer2:PhysicsInit(SOLID_NONE)
        self.computer2:SetMoveType(MOVETYPE_NONE)
        self.computer2:SetSolid(SOLID_NONE)
        self.computer2:Spawn()
        self.computer2:SetNoDraw(true)
        if IsValid(self.computer2) and IsValid(self) then self.computer2:DeleteOnRemove(self) end
        self:DeleteOnRemove(self.computer2)
        
    end
end