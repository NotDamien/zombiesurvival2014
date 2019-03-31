CLASS.Name = "Fresh Dead"
CLASS.TranslationName = "class_fresh_dead"
CLASS.Description = ""
CLASS.Help = ""

CLASS.Wave = 0
CLASS.Unlocked = true
CLASS.Hidden = true

CLASS.Health = 200
CLASS.Speed = 190

CLASS.Points = 5

CLASS.CanTaunt = true

CLASS.UsePreviousModel = true

CLASS.SWEP = "weapon_zs_freshdead"

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

CLASS.CanFeignDeath = true

local math_min = math.min
local math_Clamp = math.Clamp
local IN_SPEED = IN_SPEED
local ACT_HL2MP_SWIM_PISTOL = ACT_HL2MP_SWIM_PISTOL
local ACT_HL2MP_IDLE_CROUCH_FIST = ACT_HL2MP_IDLE_CROUCH_FIST
local ACT_HL2MP_IDLE_KNIFE = ACT_HL2MP_IDLE_KNIFE
local ACT_HL2MP_WALK_CROUCH_KNIFE = ACT_HL2MP_WALK_CROUCH_KNIFE
local ACT_HL2MP_WALK_KNIFE = ACT_HL2MP_WALK_KNIFE
local ACT_HL2MP_RUN_KNIFE = ACT_HL2MP_RUN_KNIFE
local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY
local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD
local ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL = ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL
local ACT_GMOD_GESTURE_TAUNT_ZOMBIE = ACT_GMOD_GESTURE_TAUNT_ZOMBIE
local ACT_INVALID = ACT_INVALID

function CLASS:Move(pl, move)
	if pl:KeyDown(IN_SPEED) then
		move:SetMaxSpeed(40)
		move:SetMaxClientSpeed(40)
	end
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end

	if pl:WaterLevel() >= 3 then
		return ACT_HL2MP_SWIM_PISTOL, -1
	end

	local len = velocity:Length2DSqr()
	if len <= 1 then
		if pl:Crouching() and pl:OnGround() then
			return ACT_HL2MP_IDLE_CROUCH_FIST, -1
		end

		return ACT_HL2MP_IDLE_KNIFE, -1
	end

	if pl:Crouching() and pl:OnGround() then
		return ACT_HL2MP_WALK_CROUCH_KNIFE, -1
	end

	if len < 2800 then
		return ACT_HL2MP_WALK_KNIFE, -1
	end

	return ACT_HL2MP_RUN_KNIFE, -1
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed, 3))
	else
		pl:SetPlaybackRate(1)
	end

	return true
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

--[[function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	-- The Wraith model doesn't have hitboxes.
	return true
end]]

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

function CLASS:GetAlpha(pl)
	local wep = pl:GetActiveWeapon()
	if not wep.IsAttacking then wep = NULL end

	if wep:IsValid() and wep:IsAttacking() then
		return 0.7
	end

	local eyepos = EyePos()
	local nearest = pl:WorldSpaceCenter()
	local norm = nearest - eyepos
	norm:Normalize()
	local dot = EyeVector():Dot(norm)

	local vis = (dot * 0.4 + pl:GetVelocity():Length() / self.Speed / 2 - eyepos:Distance(nearest) / 400) * dot

	return math_Clamp(vis, MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD and 0.137 or 0, 0.7)
end



if not CLIENT then return end

if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/zombie"
end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/ghoul"
CLASS.IconColor = Color(20, 20, 250)

local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

local colGlow = Color(255, 0, 0)
local matSkin = Material("Models/humans/corpse/corpse1.vtf")
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end

