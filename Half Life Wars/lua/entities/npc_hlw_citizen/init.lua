AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end

local SpawnPos = tr.HitPose + tr.HitNormal * 6
self.Spawn_angles = ply:GetAngles()
self.Spawn_angles.pitch = 0
self.Spawn_angles.roll = 0
self.Spawn_angles.yaw = self.Spawn_angles.yaw + 180

local ent = ents.Create( "npc_hlw_citizen" )
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

	self.npc = ents.Create( "npc_citizen" )
	self.npc:SetPos(self:GetPos())
	self.npc:SetAngles(self:GetAngles())
	

	self.npc:SetSpawnEffect(false)
	self.npc:Spawn()
	self.npc:Activate()
	self:SetParent(self.npc)
	self.npc:SetKeyValue( "spawnflags", bit.bor("1048576", "512", "8192", "16384", "512"))
	self.npc:SetHealth(40)
	self.npc:SetMaxHealth(40)
	self.npc:SetBloodColor(0)
	self.npc:CapabilitiesAdd(CAP_FRIENDLY_DMG_IMMUNE)
	self.npc:CapabilitiesAdd(CAP_DUCK)
	self.npc:CapabilitiesRemove(CAP_SQUAD)
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
        
	-- Establecer la animación correspondiente
	if model == "models/humans/group01/male_01.mdl" or 
	   model == "models/humans/group01/male_02.mdl" or 
	   model == "models/humans/group01/male_03.mdl" or 
	   model == "models/humans/group01/male_04.mdl" or 
	   model == "models/humans/group01/male_05.mdl" or 
	   model == "models/humans/group01/male_06.mdl" or 
	   model == "models/humans/group01/male_07.mdl" or 
	   model == "models/humans/group01/male_08.mdl" or 
	   model == "models/humans/group01/male_09.mdl" then
		self.npc.isWoman = false
		
	elseif model == "models/humans/group01/female_01.mdl" or 
		   model == "models/humans/group01/female_02.mdl" or 
		   model == "models/humans/group01/female_03.mdl" or 
		   model == "models/humans/group01/female_04.mdl" or 
		   model == "models/humans/group01/female_05.mdl" or 
		   model == "models/humans/group01/female_06.mdl" or 
		   model == "models/humans/group01/female_07.mdl" then
		
		self.npc.isWoman = true
	end
	end
	-- Verificar el modelo del NPC
	self.npc.celebrateTimer = nil
	self.npc.celebrate = false
	self.npc.hasComputer = false
	self.npc.hasComputer2 = false
end

function ENT:Cargar(npc)
    if IsValid(self) and IsValid(npc) then
		npc.hasComputer = true
		npc:CapabilitiesRemove(CAP_MOVE_GROUND)
        npc:SetNPCState(NPC_STATE_SCRIPT)
        npc:SetSchedule(SCHED_WAIT_FOR_SCRIPT)
        npc:Fire("RemoveFromPlayerSquad")
        
        if (npc.isWoman and npc.animateChange) or (npc.isWoman and npc.animateChange == false and npc.celebrate) then
            npc:SetSequence("canals_arlene_tinker")
			npc.celebrate = false
		elseif	npc.animateChange or (npc.animateChange == false and npc.celebrate) then
            npc:SetSequence("d1_town05_Leon_Lean_Table_Idle")
			npc.celebrate = false
        end



    end
end

function ENT:Observar(npc)
    if IsValid(self) and IsValid(npc) then
		npc.hasComputer2 = true
		npc:CapabilitiesRemove(CAP_MOVE_GROUND)
        npc:SetNPCState(NPC_STATE_SCRIPT)
        npc:SetSchedule(SCHED_SLEEP)
        npc:Fire("RemoveFromPlayerSquad")
        
        if (npc.isWoman and npc.animateChange) or (npc.isWoman and npc.animateChange == false and npc.celebrate) then
            npc:SetSequence("LineIdle03")
			npc.celebrate = false
		elseif	npc.animateChange or (npc.animateChange == false and npc.celebrate) then
            npc:SetSequence("LineIdle02")
			npc.celebrate = false
        end



    end
end
local citizenForward = false
local computadora = nil
function ENT:Piensa(computer)
    --if computer == nil then return end
    if IsValid(self) and IsValid(self.npc) then
		computadora = computer
        local npc = self.npc
        
        -- Create a table with a single element, the computer parameter
        local computers = {computer}
        for _, computer in pairs(computers) do
            -- Verificar si hay un 'npc_citizen' cerca de la computadora
            local citizens = ents.FindInSphere(computer:GetPos(), 1)
            local hasCitizen = false
            for _, citizen in pairs(citizens) do
                if citizen:GetClass() == "npc_citizen" and citizen ~= self.npc then
                    hasCitizen = true
                    break
                end
            end
            
            -- Si no hay un 'npc_citizen' cerca, dirigirse hacia la computadora
            if not hasCitizen then
				citizenForward = true
            end
        end
        
        if self.npc.hasComputer then
            self:Cargar(npc)
        end
        if self.npc.hasComputer2 then
            self:Observar(npc)
        end
    end
end
function ENT:Think()
if !self:IsValid() then return end
  if citizenForward and self:IsValid() then

		self.npc:SetLastPosition(computadora:GetPos())
		self.npc:SetSchedule(SCHED_FORCED_GO)
		
		if (self.npc:GetPos():Distance(computadora:GetPos()) < 1) then
			self.npc:SetAngles(computadora:GetAngles())
			
			-- Evaluar qué función ejecutar según la entidad encontrada
			if computadora:GetClass() == "hlw_computer" then
				self:Cargar(self.npc)
				self:IniciarCelebracion(self.npc)
				
			elseif computadora:GetClass() == "hlw_computer2" then
				self:Observar(self.npc)
				self:IniciarCelebracion(self.npc)
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
        npc:SetSequence("cheer1")
        if npc.isWoman then
			local celebrateFemale = {
			"vo/coast/odessa/female01/nlo_cheer02.wav",
			"vo/coast/odessa/female01/nlo_cheer01.wav"
			}
			local celebrateFemaleSounds = celebrateFemale[math.random(1, #celebrateFemale)]
            npc:EmitSound(celebrateFemaleSounds)
        else
            npc:EmitSound("vo/coast/odessa/male01/nlo_cheer02.wav")
        end
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
