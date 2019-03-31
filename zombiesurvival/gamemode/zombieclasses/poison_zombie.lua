CLASS.Name = "Poison Zombie"
CLASS.TranslationName = "class_poison_zombie"
CLASS.Description = "description_poison_zombie"
CLASS.Help = "controls_poison_zombie"

CLASS.Model = Model("models/Zombie/Poison.mdl")

CLASS.Wave = 2 / 3

CLASS.Health = 1800
CLASS.Speed = 200
CLASS.SWEP = "weapon_zs_poisonzombie"

CLASS.Mass = DEFAULT_MASS * 1.5



CLASS.Points = 6

CLASS.PainSounds = {"NPC_PoisonZombie.Pain"}
CLASS.DeathSounds = {"NPC_PoisonZombie.Die"}
CLASS.VoicePitch = 0.6

CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end

	return ACT_WALK, -1
end


local mathrandom = math.random
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and mathrandom(3) < 3 then
		pl:EmitSound("NPC_PoisonZombie.FootstepRight")
	else
		pl:EmitSound("NPC_PoisonZombie.FootstepLeft")
	end

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 365 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 300
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 450
	end

	return 150
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)
end

if SERVER then
	function CLASS:OnSpawned(pl)
		if pl:IsBot() then
			pl:SetBodygroup( 1, 1 )
		end
	end
	
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		if pl:IsBot() then
			pl:SetBodygroup( 1, 0 )
		end
	end
end


if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/poisonzombie"
