local survivorName = "Temple Guard"

print("The Temple Guard has been loaded")
local guard = Survivor.new(survivorName)
local sprites = {
	idle     = Sprite.load("guard_idle",	 	"survivors/spr/guard/idle", 1, 3, 8),
	walk     = Sprite.load("guard_walk", 		"survivors/spr/guard/walk", 8, 9, 8),
	jump     = Sprite.load("guard_jump", 		"survivors/spr/guard/jump", 2, 4, 9),
	climb    = Sprite.load("guard_climb", 		"survivors/spr/guard/climb", 2, 5, 7),
	death    = Sprite.load("guard_death", 		"survivors/spr/guard/death", 7, 48, 13),
	decoy    = Sprite.load("guard_decoy", 		"survivors/spr/guard/decoy", 1, 9, 18),

  shoot1 = Sprite.load("guard_shoot1", "survivors/spr/guard/shoot1", 9, 11, 9),
  skills = Sprite.load("guard_skills", "survivors/spr/guard/skills", 5, 0, 0),

  --drone sprites
  drmain = Sprite.load("guard_drone", "survivors/spr/guard/drone", 2, 10, 6),
  drshoot1 = Sprite.load("guard_droneshoot1", "survivors/spr/guard/drone_shoot1", 9, 10, 6),
	drshoot2 = Sprite.load("guard_droneshoot2", "survivors/spr/guard/drone_shoot2", 6, 14, 11),
  drturn = Sprite.load("guard_droneturn", "survivors/spr/guard/drone_turn", 7, 8, 5)
}
local yBob = 0
local flV = 10
local flVDecay = 0.1
local elephantMaxHit = 4
local droneDeltaMult = 0.3
local subImgCounter = 1
local droneRelevantFrame = 1
local lastDRelevantFrame = 0
local btbduration = 10
local droneName = "FRUT.bat"
local electric

local efHit = Sprite.find("Sparks4", "vanilla")

guard:setLoadoutInfo(
[[The &y&]]..survivorName..[[ wields an &y&Elephant Gun&!&, an incredibly powerful rifle that pierces enemies,
and efficient use of &g&]]..droneName..[[&!& is crucial to offset its low fire rate.
]], sprites.skills)

guard:setLoadoutSkill(1, "Elephant Gun",
[[Fire your rifle for &5&250% damage&!&, hitting up to ]]..elephantMaxHit..[[ enemies.]])

guard:setLoadoutSkill(2, "DISCHARGE()",
[[&g&]]..droneName..[[&!& releases a ball of electricity that &r&explodes&!& for &y&500% damage&!&
Getting hit by the ball &b&overcharges you&!& for &y&6 seconds&!&]])

guard:setLoadoutSkill(3, "",
[[Hold to lock &g&]]..droneName..[[&!& in place, release to &b&fling yourself in its directon&!&.]])

guard:setLoadoutSkill(4, "Back-to:BACK()",
[[For ]]..btbduration..[[ seconds, &g&]]..droneName..[[&!& mimicks your attacks in the opposite direction.]])

-- The color of the character's skill names in the character select
guard.loadoutColor = nnColours.tgGreen

-- The character's sprite in the selection pod
guard.loadoutSprite = Sprite.load("guard_select", "survivors/spr/guard/select", 12, 2, 0)

-- The character's walk animation on the title screen when selected
guard.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
guard.endingQuote = "..and so it left, eager to rebuild its home."

-- Called when the player is created
guard:addCallback("init", function(player)
	local pNN = player:getData()
  pNN.tG = {}


	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(120, 14, 0.01)
	-- Set the player's skill icons
	player:setSkill(1,
		"Elephant Gun",
		"Fire your rifle for 250% damage, hitting up to "..elephantMaxHit.." enemies.",
		sprites.skills, 1,
		1 * 60
	)
	player:setSkill(2,
		"DISCHARGE()",
		"ew gross",
		sprites.skills, 2,
		7 * 60
	)
	player:setSkill(3,
		"Lifeline",
		"Hold to lock "..droneName.." in place, release to &b&fling yourself&!& in its directon.",
		sprites.skills, 3,
		7 * 60
	)
	player:setSkill(4,
		"Back-to:BACK()",
		"For "..btbduration.." seconds, "..droneName.."mimicks your attacks in the opposite direction.",
		sprites.skills, 4,
		30 * 60
	)
end)


-- Called when the player levels up
guard:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
guard:addCallback("scepter", function(player)
	player:setSkill(4,
		"",
		"",
		sprites.skills, 5,
		7 * 60
	)
end)

local guardDrone = Object.new("Temple Guardian's Drone")
guardDrone:addCallback("create", function(self)
  local selfTab = self:getData()
  if not selfTab.drone then selfTab.drone = Object.find("SniperDrone"):create(self.x, self.y) end
  --if not selfTab.parent then selfTab.parent = Object.find("P"):findNearest(self.x, self.y) end
  selfTab.drone.visible = false
end)

local getRelevantFrame = function(droneRelevantFrame)
	if math.floor(droneRelevantFrame) ~= lastDRelevantFrame then
		lastDRelevantFrame = math.floor(droneRelevantFrame)
		return math.floor(droneRelevantFrame)
	else
		return 0
	end
end

guardDrone:addCallback("draw", function(self)
  local selfTab = self:getData()
  self.x, self.y = selfTab.drone.x, selfTab.drone.y
  if yBob > 4 then yBob = -yBob end
  yBob = yBob + 0.06

  local drawSprite = sprites.drmain
  local droneXscale = selfTab.drone.xscale

  local drawX, drawY = self.x, self.y

	if selfTab.btb and selfTab.btb > 0 then
		local dX, dY = selfTab.drone.x - selfTab.parent.x - 10 * -selfTab.parent.xscale, selfTab.drone.y - selfTab.parent.y - 4

		selfTab.drone.x, selfTab.drone.y =  selfTab.drone.x - dX * droneDeltaMult, selfTab.drone.y - dY * droneDeltaMult
		droneXscale = selfTab.parent.xscale * -1
		drawX, drawY = self.x, self.y
		drawY = drawY + 2 - math.abs(math.floor(yBob))
		selfTab.btb = selfTab.btb - 1
	end

	if selfTab.btbShoot then
		drawSprite = sprites.drshoot1
		local relevantFrame = getRelevantFrame(subImgCounter)
		if relevantFrame == 5 then
			local droneBullet = selfTab.parent:fireBullet(self.x, self.y, 90 * (-droneXscale + 1), 300, 2.5, efHit, DAMAGER_BULLET_PIERCE):set("NN_maxHit", elephantMaxHit)
			if selfTab.parent:get("scepter") > 0 then
				droneBullet:set("stun", 1):set("knockback", 1)
			end
		elseif relevantFrame == 10 then
			selfTab.btbShoot = false
		end
	elseif selfTab.xShoot then
		self.x, self.y = selfTab.xLock[1], selfTab.xLock[2]
		drawX, drawY = self.x, self.y
		selfTab.drone.x, selfTab.drone.y = drawX, drawY
		local relevantFrame = getRelevantFrame(subImgCounter)
		drawSprite = sprites.drshoot2
		if relevantFrame == 1 then
			electric = lightningBall:create(drawX + 5 * droneXscale, drawY)
			local eT = electric:getData()
			eT.velocity = 0
			eT.angle = math.rad(15 + 75 * (-droneXscale + 1))
			if selfTab.btb and selfTab.btb > 0 then
				eT.angle = math.rad(0 + 90 * (-droneXscale + 1))
			end
		elseif relevantFrame == 5 and electric and electric:isValid() then
			electric:getData().velocity = 2.2
		elseif relevantFrame == 6 then
			selfTab.xShoot = false
			selfTab.xLock = nil
		end

	elseif selfTab.lockPos then drawX, drawY, droneXscale = table.unpack(selfTab.lockPos) drawY = drawY + 2 - math.abs(math.floor(yBob)) selfTab.drone.x, selfTab.drone.y = drawX, drawY
    graphics.color(nnColours.tgGray)
    graphics.line(drawX, drawY, selfTab.parent.x, selfTab.parent.y, 2)
	elseif string.find(tostring(selfTab.drone.sprite), "Turn") and not (selfTab.btb and selfTab.btb > 0) then
		drawSprite = sprites.drturn
	end

	if drawSprite == sprites.drshoot1 or drawSprite == sprites.drshoot2 then
		if subImgCounter < drawSprite.frames + 1 then subImgCounter = subImgCounter + 0.2 else subImgCounter = 1 end
	elseif drawSprite == sprites.drturn then
		subImgCounter = selfTab.drone.subimage
	else
		if subImgCounter < drawSprite.frames + 1 then subImgCounter = subImgCounter + 0.07 else subImgCounter = 1 end
	end

  graphics.drawImage{
    image = drawSprite,
    x = drawX,
    y = drawY,
    subimage = subImgCounter,
    xscale = droneXscale,
		}
  --graphics.print(selfTab.drone:get("state").."\n"..tostring(selfTab.drone.sprite).."\n"..selfTab.drone.xscale.."  "..selfTab.drone.subimage, self.x, self.y - 40)
end)


callback("onPlayerStep", function(player)

end)

callback("onStageEntry", function()
  for i, player in ipairs(playerObj:findAll()) do
    if player:getSurvivor().displayName == survivorName then
      local pNN = player:getData()
      pNN.tG.mDrone = guardDrone:create(player.x, player.y)
			pNN.tG.mDrone:getData().parent = player
      pNN.tG.mDrone:getData().drone:set("master", player.id)

    end
  end
end)

-- Called when the player tries to use a skill
guard:addCallback("useSkill", function(player, skill)
  local pNN = player:getData()
  local mDroneTab = pNN.tG.mDrone:getData() --"fake" drone's table
  local childDroneTab = mDroneTab.drone:getData() --"real" drone's table

	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
		-- Set the player's state

		if skill == 1 then
			-- Z skill
			player:survivorActivityState(1, sprites.shoot1, 0.18, true, true)
		elseif skill == 2 then
			-- X skill
			if not mDroneTab.lockPos then
				mDroneTab.xShoot = true
				mDroneTab.xLock = {pNN.tG.mDrone.x, pNN.tG.mDrone.y}
				subImgCounter = 1
			end
			print("drone X shoot")
		elseif skill == 4 then
			-- V skill
			--player:survivorActivityState(4, sprites.shoot1, 0.25, true, true)
			if not mDroneTab.lockPos then
				mDroneTab.btb = 10 * 60
			end
		end

		-- Put the skill on cooldown
    if skill ~= 3 and not mDroneTab.lockPos then
			player:activateSkillCooldown(skill)
    end
	end
end)

callback("onDraw", function()
  for _, player in ipairs(playerObj:findAll()) do
    local pNN = player:getData()
    if pNN.tG then

      local mDroneTab = pNN.tG.mDrone:getData()
			if player:getAlarm(4) == -1 and player:get("activity") == 0 then
	      if mpCtrl(player, 3) == input.HELD then
	        if not mDroneTab.lockPos then mDroneTab.lockPos = {pNN.tG.mDrone.x, pNN.tG.mDrone.y, mDroneTab.drone.xscale} end

	        graphics.color(nnColours.tgLime)
	        graphics.alpha(0.5)
	        predictAngleMovement(player.x, player.y, math.rad(calcAngle(player.x, player.y, mDroneTab.lockPos[1], mDroneTab.lockPos[2])), flV, flVDecay, 3)

	      elseif mpCtrl(player, 3) == input.RELEASED and player:getAlarm(4) == -1 then
	        player:survivorActivityState(3, sprites.jump, 0.25, true, true)
	      end
			end

      if pNN.tG.flV and pNN.tG.flV > 0 then
        if not player:collidesMap(player.x + math.cos(pNN.tG.flA) * pNN.tG.flV, player.y - math.sin(pNN.tG.flA) * pNN.tG.flV) and player:get("activity") ~= 30 and (player:get("free") == 1 or pNN.tG.flV == flV) then
          player:set("moveUpHold", 0):set("invincible", 2)
          player.x, player.y = player.x + math.cos(pNN.tG.flA) * pNN.tG.flV, player.y - math.sin(pNN.tG.flA) * pNN.tG.flV
          pNN.tG.flV = pNN.tG.flV - flVDecay
        else pNN.tG.flV = 0 player:set("pVspeed", 0)
					if player:hasBuff(overcharged) then
						player:fireExplosion(player.x, player.y, 50/19, 20/4, 5, electroBoom)
					end
					misc.shakeScreen(2)
				end
      end
		end
  end
end)

-- Called each frame the player is in a skill state
guard:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0
  local pNN = player:getData()
  local mDroneTab = pNN.tG.mDrone:getData()

	if skill == 1 then
    if relevantFrame == 5 then
      if not player:survivorFireHeavenCracker(1.5) then
        player:fireBullet(player.x, player.y, player:getFacingDirection(), 600,
				 2.5, efHit, DAMAGER_BULLET_PIERCE):set("NN_maxHit", elephantMaxHit)
      end
			if mDroneTab.btb and mDroneTab.btb > 0 then
				mDroneTab.btbShoot = true
				subImgCounter = 0
			end
      if not player:collidesMap(player.x - 5 * player.xscale, player.y) then
        if player:get("free") == 0 then
          player.x = player.x - 5 * player.xscale
        else
          player:set("pHspeed", -3 * player.xscale)
        end
      end
    end
	elseif skill == 2 then

	elseif skill == 3 then
    print(relevantFrame)
    if relevantFrame == 1 then
      pNN.tG.flV = flV
      pNN.tG.flA = math.rad(calcAngle(player.x, player.y, mDroneTab.lockPos[1], mDroneTab.lockPos[2]))
      mDroneTab.lockPos = nil
      player:set("pVspeed", -0.3)
      player:activateSkillCooldown(3)
    end
	elseif skill == 4 then

	end
end)
