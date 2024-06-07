AddCSLuaFile()
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Half Life: Wars (Tutorial mode)"
ENT.Author = "Alcachofas13"
ENT.Information = "This is tutorial mode!"
ENT.Purpose = "Learn how to play this mini game based on the strategy game Stick War"
ENT.Category = "Half Life: Wars"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.MessageBig = 1
ENT.MessageMed = 2
ENT.MessageSmall = 3

local arena = net.ReadEntity()
------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------

local arena_length = 4000
local arena_width = 1800
local arena_height = 500

//bottom
local box1_min = Vector( -arena_width/2, -arena_length/2, -7 )
local box1_max = Vector( arena_width/2, arena_length/2, -0.2 )

//top
local box2_min = Vector( -arena_width/2, -arena_length/2, 0 )
local box2_max = Vector( arena_width/2, arena_length/2, 2 )

local box2_offset = Vector( 0, 0, arena_height )

//wall
local box3_min = Vector( -arena_width/2, -1, 0 )
local box3_max = Vector( arena_width/2, 0, arena_height )

local box3_offset = Vector( 0, -arena_length/2, 0 )


//small walls
local box4_min = Vector( -3, -arena_length/2, 0 )
local box4_max = Vector( 0, arena_length/2, arena_height )

local box4_offset = Vector( -arena_width/2, 0, 0 )

--local cam_offset = Vector( -1100, 0, 500 )
local cam_offset = Vector( -1000, 0,100 )

local cam_points = {
	Vector( -arena_width/2, arena_length/2, 0 ),
	Vector( -arena_width/2, -arena_length/2, 0 ),
	Vector( -arena_width/2, -arena_length/2, arena_height ),
	Vector( -arena_width/2, arena_length/2, arena_height ),
}

local spawnpoints = {
	[1] = Vector( -arena_width/3, 0, 15 ),
	[2] = Vector( arena_width/3, 0, 15 ),
}

function ENT:Use( activator )

	if self.Used then return end

if ( activator:IsPlayer() && activator:Alive() ) then 
	self.Used = true -- Determina sí se usa una vez o no
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local cam_pos, cam_ang = LocalToWorld( cam_offset, Angle( 0, 0, 0 ), pos, ang )

	activator:EmitSound( "garrysmod/ui_click.wav" )
	activator:EmitSound( "half_life_wars/round_start.wav" )
	activator:ScreenFade(SCREENFADE.OUT,Color(0,0,0),0.3,0.4)

	timer.Simple( 0.5, function()
		if IsValid( activator ) then
			activator:SetMoveType( MOVETYPE_NONE)
			activator:ScreenFade(SCREENFADE.IN,Color(0,0,0),0.3,0.4)
			activator:SetPos(cam_pos)
			activator:SetEyeAngles(cam_ang)
			self:Tutorial(activator)
		end
	end )

end
end

function ENT:Tutorial(ent)		
	--ent:EmitSound("half_life_wars/round_start.wav")
	local initial_cam_ang = ent:EyeAngles()
	local playerPos = ent:GetPos()
    ent:GodEnable()
    ent:AddFlags(FL_NOTARGET)
	ent:AddFlags(FL_NOTARGET)
	ent:SetMoveType( MOVETYPE_PUSH )
	ent:AllowFlashlight( false )
	ent:StripWeapons()
	ent:SetNoDraw(true)
	ent:Give("gmod_camera") -- es la unica forma que encontré para remover el HUD.
	local noArmas = false
	local move_speed = 20
	self:SetDTBool(0, true) -- Establece Draw() en false
	hook.Add( "PlayerNoClip", "No_Clip", function( ent )
		return false
	end )

	hook.Add("PlayerDeath", "TutorialDeathHook", function(victim) -- Sí el jugador llega a morir (probablemente utilice la consola para hacerlo), se destruye la estatua automáticamente
		--Si jugador muerto: Código para destruir la estatua :v
		return true
	end)

	hook.Add( "Think", "Ply_Move", function()
		if ( ent:KeyDown( IN_MOVERIGHT )) then
			local newPos = ent:GetPos() + ent:GetRight() * move_speed 
			ent:SetPos( newPos )

		elseif ( ent:KeyDown( IN_MOVELEFT ) ) then
			local newPos = ent:GetPos() - ent:GetRight() * move_speed 
			ent:SetPos( newPos )
		end
		ent:SetEyeAngles(initial_cam_ang)
	end )

    hook.Add("Think", "LimitPlayerMovement", function()
        local pos = ent:GetPos()
        local distance = (pos - playerPos):Length()

        if distance > 1800 then
            -- Mover al jugador de vuelta a una posición segura
            local dir = (pos - playerPos):GetNormal()
            ent:SetPos(playerPos + dir * 1800)
        end
	end)

	undo.Create( "Tutorial Mode Activated" )
	undo.SetPlayer( ent )
	undo.SetCustomUndoText( "The Tutorial Mode has been cancelled" )
	undo.AddFunction( function( tab, arena, pl, sl )
			ent:RemoveFlags(FL_NOTARGET)
			ent:GodDisable()
			ent:SetPos(self:GetPos())
			ent:AllowFlashlight( true )
			ent:SetMoveType( MOVETYPE_WALK )
			ent:SetNoDraw(false)
			hook.Remove("Think", "Ply_Move")
			hook.Remove("Think", "LimitPlayerMovement")
			hook.Remove("PlayerNoClip", "No_Clip")
			hook.Remove("PlayerDeath", "TutorialDeathHook")
			ent:StripWeapon("gmod_camera") -- quito la cámara para que el jugador vea de nuevo el HUD.
			if noArmas == false then --No me importa sí el jugador tenía removida estas armas o no.
				ent:Give("weapon_physgun")
				ent:Give("weapon_crowbar")
				ent:Give("weapon_physcannon")
				ent:Give("weapon_pistol")
				ent:Give("weapon_357")
				ent:Give("weapon_smg1")
				ent:Give("weapon_ar2")
				ent:Give("weapon_shotgun")
				ent:Give("weapon_crossbow")
				ent:Give("weapon_frag")
				ent:Give("weapon_rpg")
				ent:Give("gmod_camera")
				ent:Give("gmod_tool")
				noArmas = true
			end
			self:SetDTBool(0, false)
			self.Used = false -- Permite que el jugador pueda volver a utilizar la arena

			if arena and arena:IsValid() and pl and pl:IsValid() and sl then
				if arena:GetPlayer( sl ) == pl then
					arena:RemovePlayer( sl )
				end
			end
		end, self.Entity, ent, slot )
	undo.Finish()

end
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
		
		self:SetModel( "models/dav0r/camera.mdl" )
		self:DrawShadow( false )
		self.Used = false
		self:PhysicsInitMultiConvex( 
		{
			{ 
				Vector( box1_min.x, box1_min.y, box1_min.z ),
				Vector( box1_min.x, box1_min.y, box1_max.z ),
				Vector( box1_min.x, box1_max.y, box1_min.z ),
				Vector( box1_min.x, box1_max.y, box1_max.z ),
				Vector( box1_max.x, box1_min.y, box1_min.z ),
				Vector( box1_max.x, box1_min.y, box1_max.z ),
				Vector( box1_max.x, box1_max.y, box1_min.z ),
				Vector( box1_max.x, box1_max.y, box1_max.z ),
			},
			{ 
				Vector( box2_min.x, box2_min.y, box2_min.z ) + box2_offset,
				Vector( box2_min.x, box2_min.y, box2_max.z ) + box2_offset,
				Vector( box2_min.x, box2_max.y, box2_min.z ) + box2_offset,
				Vector( box2_min.x, box2_max.y, box2_max.z ) + box2_offset,
				Vector( box2_max.x, box2_min.y, box2_min.z ) + box2_offset,
				Vector( box2_max.x, box2_min.y, box2_max.z ) + box2_offset,
				Vector( box2_max.x, box2_max.y, box2_min.z ) + box2_offset,
				Vector( box2_max.x, box2_max.y, box2_max.z ) + box2_offset,
			},
			{ 
				Vector( box3_min.x, box3_min.y, box3_min.z ) + box3_offset,
				Vector( box3_min.x, box3_min.y, box3_max.z ) + box3_offset,
				Vector( box3_min.x, box3_max.y, box3_min.z ) + box3_offset,
				Vector( box3_min.x, box3_max.y, box3_max.z ) + box3_offset,
				Vector( box3_max.x, box3_min.y, box3_min.z ) + box3_offset,
				Vector( box3_max.x, box3_min.y, box3_max.z ) + box3_offset,
				Vector( box3_max.x, box3_max.y, box3_min.z ) + box3_offset,
				Vector( box3_max.x, box3_max.y, box3_max.z ) + box3_offset,
			},
			{ 
				Vector( box3_min.x, box3_min.y, box3_min.z ) - box3_offset,
				Vector( box3_min.x, box3_min.y, box3_max.z ) - box3_offset,
				Vector( box3_min.x, box3_max.y, box3_min.z ) - box3_offset,
				Vector( box3_min.x, box3_max.y, box3_max.z ) - box3_offset,
				Vector( box3_max.x, box3_min.y, box3_min.z ) - box3_offset,
				Vector( box3_max.x, box3_min.y, box3_max.z ) - box3_offset,
				Vector( box3_max.x, box3_max.y, box3_min.z ) - box3_offset,
				Vector( box3_max.x, box3_max.y, box3_max.z ) - box3_offset,
			},
			{ 
				Vector( box4_min.x, box4_min.y, box4_min.z ) + box4_offset,
				Vector( box4_min.x, box4_min.y, box4_max.z ) + box4_offset,
				Vector( box4_min.x, box4_max.y, box4_min.z ) + box4_offset,
				Vector( box4_min.x, box4_max.y, box4_max.z ) + box4_offset,
				Vector( box4_max.x, box4_min.y, box4_min.z ) + box4_offset,
				Vector( box4_max.x, box4_min.y, box4_max.z ) + box4_offset,
				Vector( box4_max.x, box3_max.y, box4_min.z ) + box4_offset,
				Vector( box4_max.x, box4_max.y, box4_max.z ) + box4_offset,
			},
			{ 
				Vector( box4_min.x, box4_min.y, box4_min.z ) - box4_offset,
				Vector( box4_min.x, box4_min.y, box4_max.z ) - box4_offset,
				Vector( box4_min.x, box4_max.y, box4_min.z ) - box4_offset,
				Vector( box4_min.x, box4_max.y, box4_max.z ) - box4_offset,
				Vector( box4_max.x, box4_min.y, box4_min.z ) - box4_offset,
				Vector( box4_max.x, box4_min.y, box4_max.z ) - box4_offset,
				Vector( box4_max.x, box3_max.y, box4_min.z ) - box4_offset,
				Vector( box4_max.x, box4_max.y, box4_max.z ) - box4_offset,
			},
			
			
		} )
		self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		self:SetSolid( SOLID_VPHYSICS  )
		self:SetMoveType( MOVETYPE_VPHYSICS  )

		self:EnableCustomCollisions( true )

		self:PhysWake()
		
		self:SetUseType( SIMPLE_USE )
		
		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion( false )
		end
		
		local ang = self:GetAngles()
		ang.p = 0
		
		self:SetDirVector( 1, ang:Forward() )
		
		ang:RotateAroundAxis( self:GetUp(), 180 )
		self:SetDirVector( 2, ang:Forward() )

		constraint.Weld( self, game.GetWorld(), 0, 0, 0, false, false ) --Evita que la arena se genere fuera del mundo
	end
	



	//prevents player from getting stuck inside the arena itself (or outside)
	function ENT:ConvertIntoSafePos( pos )
		
		local pos_loc = self:WorldToLocal( pos )
		
		pos_loc.x = math.Clamp( pos_loc.x, -176, 176 )
		pos_loc.y = 0
		pos_loc.z = 15
		
		local fixed_pos = self:LocalToWorld( pos_loc )
		
		return fixed_pos, pos_loc
		
	end
	
	function ENT:SetCharge( slot, am )
		slot = math.Clamp( slot + 4, 5, 6 )
		self:SetDTInt( slot, math.Clamp( am or 0, 0, 99 ) )
	end
	
	function ENT:SetDirVector( slot, vec )
		vec = vec:GetNormal()
		slot = math.Clamp( slot, 1, 2 )
		self:SetDTVector( slot, vec )
	end
	
	
 ----------------------------------------------------------------------------------------------------------------------------------------------
else
		

	
	function ENT:DrawArena()
		
		local pl = LocalPlayer()
		local ang = self:GetAngles()
		
		self.Alpha = self.Alpha or 0
		self.GoalAlpha = self.GoalAlpha or 0
		
		local dist = 20
		if pl.XRayTable and pl.XRayTable.xray_time and pl.XRayTable.xray_time > CurTime() and arena and arena == self then
			self.GoalAlpha = 230
		else
			self.GoalAlpha = 0
		end
		
		self.Alpha = math.Approach( self.Alpha, self.GoalAlpha, FrameTime() * 300 )
		
		if self.Alpha > 0 then
			
			cam.Start3D2D( self:GetPos() + vector_up - self:GetRight() * dist,ang, 1)//20
				surface.SetDrawColor( 10, 10, 10, self.Alpha )
				surface.DrawRect( - ScrW(), 0, ScrW()*2, ScrH() )
			cam.End3D2D()
			
			ang:RotateAroundAxis( self:GetForward(), 90 )
			
			cam.Start3D2D( self:LocalToWorld( self:OBBCenter() ) - self:GetRight() * ( dist + 2 ),ang, 1)//22
				surface.SetDrawColor( 10, 10, 10, self.Alpha )
				surface.DrawRect( - ScrW(), - ScrH() / 2, ScrW()*2, ScrH() )
			cam.End3D2D()

		
		end
		
	end
	
	local wireframe = Material( "models/wireframe" )
	local wire_col = Color( 255, 255, 255)
	
	function ENT:Draw()
		local INVISIBLEARENA = self:GetDTBool(0)
		if INVISIBLEARENA == false then
		local pl = LocalPlayer()
		
		self:SetRenderBounds( Vector( -400, -400, 0 ), Vector( 400, 400, 200 ) )

		local pos, ang = self:GetPos(), self:GetAngles()
		
		
		render.DrawWireframeBox( pos, ang, box1_min, box1_max, wire_col )
		render.DrawWireframeBox( pos, ang, box2_min + box2_offset, box2_max + box2_offset, wire_col )
		render.DrawWireframeBox( pos, ang, box3_min + box3_offset, box3_max + box3_offset, wire_col )
		render.DrawWireframeBox( pos, ang, box3_min - box3_offset, box3_max - box3_offset, wire_col )
		render.DrawWireframeBox( pos, ang, box4_min + box4_offset, box4_max + box4_offset, wire_col )
		render.DrawWireframeBox( pos, ang, box4_min - box4_offset, box4_max - box4_offset, wire_col )
		
		local pos = self:GetPos()
		local ang = self:GetAngles()
		

		local cam_pos, cam_ang = LocalToWorld( cam_offset, Angle( 0, 0, 0 ), pos, ang )

		self:SetRenderOrigin( cam_pos )
		self:SetRenderAngles( cam_ang )
		
		render.SetColorModulation( wire_col.r / 255, wire_col.g / 255, wire_col.b / 255 )
			render.ModelMaterialOverride( wireframe )
			self:DrawModel()
			render.ModelMaterialOverride( )
		render.SetColorModulation( 1, 1, 1 )
		
		self:SetRenderOrigin( )
		self:SetRenderAngles( )
		for i = 1, 4 do
			local vec = cam_points[ i ]
			if vec then
				local vec_pos, vec_ang = LocalToWorld( vec, Angle( 0, 0, 0 ), pos, ang )
				render.DrawLine( cam_pos, vec_pos, wire_col, false ) 
			end
		end
		
		local eyeang = EyeAngles()
		eyeang:RotateAroundAxis( eyeang:Right(), 90 )
		eyeang:RotateAroundAxis( eyeang:Up(), -90 )
		--Half life properties references (for some reason, gmod doesn't read the "actions" written with %%. So, I decided to implent this system)
		hlw_press_start = language.GetPhrase("hlw.press.to.start"):gsub("+use", string.upper(input.LookupBinding( "+use" )))
		hlw_press_exit = language.GetPhrase("hlw.press.to.exit"):gsub("+undo", string.upper(input.LookupBinding( "gmod_undo" )))

		cam.Start3D2D( self:GetPos() + vector_up * 60, eyeang, 0.3)
		draw.DrawText( hlw_press_start, "TargetIDSmall", 0, 0, color_white, TEXT_ALIGN_CENTER )
		draw.DrawText( hlw_press_exit, "TargetIDSmall", 0, 20, color_white, TEXT_ALIGN_CENTER )
		cam.End3D2D()
		end
	end
	

end