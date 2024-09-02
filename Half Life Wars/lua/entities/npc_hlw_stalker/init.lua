AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end

local SpawnPos = tr.HitPose + tr.HitNormal * 6
self.Spawn_angles = ply:GetAngles()
self.Spawn_angles.pitch = 0
self.Spawn_angles.roll = 0
self.Spawn_angles.yaw = self.Spawn_angles.yaw + 180

local ent = ents.Create( "npc_hlw_stalker" )
ent:SetKeyValue( "disableshadows", "1" )
ent:SetPos( SpawnPos )
ent:SetAngles( self.Spawn_angles )
ent:HasSpawnFlags( 1048576, 16384 )
ent:Spawn()
ent:Activate()

return ent
end

function ENT:Initialize()
	self:SetModel("models/props_lab/huladoll.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetName(self.PrintName)
	self:SetOwner(self.Owner)
	self:DropToFloor()

	self.npc = ents.Create( "npc_stalker" )
	self.npc:SetPos(self:GetPos())
	self.npc:SetAngles(self:GetAngles())
	

	self.npc:SetSpawnEffect(false)
	self.npc:Spawn()
	self.npc:Activate()
	self:SetParent(self.npc)
	self.npc:SetHealth(40)
	self.npc:SetMaxHealth(40)
	self.npc:SetBloodColor(0)
	self.npc:CapabilitiesAdd(CAP_FRIENDLY_DMG_IMMUNE)
	self.npc:CapabilitiesRemove(CAP_INNATE_RANGE_ATTACK1)
	self.npc:CapabilitiesRemove(CAP_INNATE_RANGE_ATTACK2)
	if IsValid(self.npc) and IsValid(self) then self.npc:DeleteOnRemove(self) end
	self:DeleteOnRemove(self.npc)

	if( IsValid(self.npc))then

		local min,max = self.npc:GetCollisionBounds()
		local hull = self.npc:GetHullType()
		self.npc:SetSolid(SOLID_BBOX)
		self.npc:SetPos(self.npc:GetPos()+self.npc:GetUp()*16)
		self.npc:SetHullType(hull)
		self.npc:SetHullSizeNormal()
		self.npc:SetCollisionBounds(min,max)
		self.npc:DropToFloor()
		self.npc:SetModelScale(1)
		self.npc.animateChange = true
		local model = self.npc:GetModel()
			
	end

	self.npc.celebrateTimer = nil
	self.npc.celebrate = false
	self.npc.hasStation = false
end

function ENT:Cargar(npc)
    if IsValid(self) and IsValid(npc) then
		npc:CapabilitiesRemove(CAP_MOVE_GROUND)
        npc:SetNPCState(NPC_STATE_SCRIPT)
        npc:SetSchedule(SCHED_WAIT_FOR_SCRIPT)
        
		if	npc.animateChange or (npc.animateChange == false and npc.celebrate) then
			npc:ResetSequence("console_work_looping")
            npc:SetSequence("console_work_looping")
			npc.celebrate = false
        end



    end
end

function ENT:Think()
    if IsValid(self) and IsValid(self.npc) then
        local npc = self.npc
        local enemy = self.npc:GetEnemy()
        local anim = self.npc:GetSequenceName(self.npc:GetSequence())
        local act = self.npc:GetActivity()
        if 1 + 1 == 2 then
			-- Buscar la entidad 'hlw_station' en un radio de 1000 metros
			local computers = ents.FindInSphere(self:GetPos(), 3000)
			for _, computer in pairs(computers) do
				if computer:GetClass() == "hlw_station"  then
					-- Verificar si hay un 'npc_stalker' cerca de la computadora
					local stalkers = ents.FindInSphere(computer:GetPos(), 1)
					local hasStalker = false
					for _, stalker in pairs(stalkers) do
						if stalker:GetClass() == "npc_stalker" and stalker ~= self.npc then
							hasStalker = true
							break
						end
					end
					
					-- Si no hay un 'npc_stalker' cerca, dirigirse hacia la computadora
					if not hasStalker then
						self.npc:SetLastPosition(computer:GetPos())
						self.npc:SetSchedule(SCHED_FORCED_GO)
						
						if (self.npc:GetPos():Distance(computer:GetPos()) < 1) then
							self.npc:SetAngles(computer:GetAngles())
							self:Cargar(npc)
							self:IniciarCelebracion(npc)
							self.npc.hasStation = true
						end
						if self.npc.hasStation then
							self:Cargar(npc)
							
						end
						break
					end
				end
			end
		end
        
    end
end

function ENT:IniciarCelebracion(npc)
    if IsValid(self) and IsValid(npc) then
        timer.Simple(10, function()
            if IsValid(self) and IsValid(npc) then
                self:Celebrar(npc)
                self:IniciarCelebracion(npc)
            end
        end)
    end
end

function ENT:Celebrar(npc)
    if IsValid(self) and IsValid(npc) and npc.animateChange  then
        
        npc:SetNPCState(NPC_STATE_SCRIPT)
        npc:SetSchedule(SCHED_SLEEP)

        npc.animateChange = false

		timer.Simple(1.5, function()
            if IsValid(self) and IsValid(npc) then
				npc.celebrate = true
				
            end
        end)
		timer.Simple(11, function()
            if IsValid(self) and IsValid(npc) then
				npc.animateChange = true
            end
        end)
		
		npc:ResetSequence("console_surprised_startup")
		npc:EmitSound("npc/stalker/go_alert2.wav")
		
		local sonidos = {
			"items/ammo_pickup.wav",
			"items/battery_pickup.wav",
			"items/medshot4.wav",
			"items/suitchargeok1.wav"
		}
		local sonidoAleatorio = sonidos[math.random(1, #sonidos)]
		self:EmitSound(sonidoAleatorio)
    end
end

function ENT:OnRemove()
	if IsValid(self.npc) then
	self.npc:Remove()
	end
end
