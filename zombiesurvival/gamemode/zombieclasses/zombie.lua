CLASS.Name = "Zombie"
CLASS.TranslationName = "class_zombie"
CLASS.Description = "description_zombie"
CLASS.Help = "controls_zombie"

CLASS.Wave = 0
CLASS.Unlocked = true
CLASS.IsDefault = true
CLASS.Order = 0

CLASS.Health = 450
CLASS.Speed = 140
CLASS.Revives = false 

CLASS.CanTaunt = true

CLASS.Points = 6

CLASS.SWEP = "weapon_zs_zombie"

CLASS.Model = Model("models/player/zombie_classic.mdl")
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

if SERVER then
    function CLASS:OnSpawned(pl)
        if pl:IsBot() then
            if pl:GetZombieClassTable().Name == "Zombie" then
                pl:SetBodygroup( 1, 1 )
            end
        end
    end

    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
        if pl:IsBot() then
            if pl:GetZombieClassTable().Name == "Zombie" then
                pl:SetBodygroup( 1, 0 )
            end
        end
    end
end

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


