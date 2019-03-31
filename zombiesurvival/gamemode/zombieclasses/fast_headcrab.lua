CLASS.Name = "Fast Headcrab"
CLASS.TranslationName = "class_fast_headcrab"
CLASS.Description = "description_fast_headcrab"
CLASS.Help = "controls_fast_headcrab"

CLASS.Model = Model("models/headcrab.mdl")

CLASS.Wave = 1 / 3

CLASS.SWEP = "weapon_zs_fastheadcrab"

CLASS.Health = 35
CLASS.Speed = 260
CLASS.JumpPower = 100

CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

CLASS.Points = 3
CLASS.ZTraits = {
	["25hlth"] = {safename = "+25% Health", cost = 400},
	["lunge"] = {safename = "Lunge", cost = 125, desc = "Increases jump range"},
	["sbeak"] = {safename = "Sharp Beak", cost = 150, desc = "Increases damage by 3"},
}
CLASS.Hull = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.HullDuck = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.ViewOffset = Vector(0, 0, 10)
CLASS.ViewOffsetDucked = Vector(0, 0, 10)
CLASS.StepSize = 8
CLASS.CrouchedWalkSpeed = 1
CLASS.Mass = 24 -- from 16

CLASS.CantDuck = true

CLASS.IsHeadcrab = true

CLASS.PainSounds = {"NPC_FastHeadcrab.Pain"}
CLASS.DeathSounds = {"NPC_FastHeadcrab.Die"}

function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	return true
end

function CLASS:CalcMainActivity(pl, velocity)
	if pl:OnGround() then
		if velocity:Length2DSqr() > 1 then
			return ACT_RUN, -1
		end

		return 1, 1
	end

	if pl:WaterLevel() >= 3 then
		return 1, 6
	end

	return 1, 3
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)

	local seq = pl:GetSequence()
	if seq == 3 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end

		pl:SetPlaybackRate(1)

		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/fastheadcrab"

function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.m_ViewAngles and wep.IsPouncing and wep:IsPouncing() then
		local maxdiff = FrameTime() * 15
		local mindiff = -maxdiff
		local originalangles = wep.m_ViewAngles
		local viewangles = cmd:GetViewAngles()

		local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
		if diff > maxdiff or diff < mindiff then
			viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
		end

		wep.m_ViewAngles = viewangles

		cmd:SetViewAngles(viewangles)
	end
end
