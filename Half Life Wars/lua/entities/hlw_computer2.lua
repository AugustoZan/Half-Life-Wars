AddCSLuaFile()
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Resistance Computer 2"
ENT.Author = "Alcachofas13"
ENT.Information = "The resistance computers"
ENT.Purpose = "The path for citizens"
ENT.Category = "Half Life: Wars"

ENT.Spawnable = true
ENT.AdminOnly = false

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
    self.Dead = false
    -- Set up the NPC's physics
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end
end
function ENT:Draw()
    self:DrawModel()
end
function ENT:Think()

    local currentAngles = self:GetAngles()
    if currentAngles ~= self.Posicion  then
        self:SetAngles(self.Posicion) -- Establecer el ángulo del NPC a la variable test
    end
end
