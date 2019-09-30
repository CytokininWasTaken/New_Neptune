shockWaveObj = Object.new("shockWaveObj")
local shockwave = Sprite.load("shock", "survivors/spr/harpy/shockwave", 9, 12, 6)
local suspendEF = Sprite.load("suspendEF", "survivors/spr/harpy/suspendEF", 1, 18, 18)

local suspendTime = 1.5

------ harpy.lua
---- Adds a new playable character.
local currVars = 1
local maxVars = 3


local harpy = Survivor.new("The Harpy")

-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("harpy_idle", "survivors/spr/harpy/idle", 1, 3, 10),
	walk = Sprite.load("harpy_walk", "survivors/spr/harpy/walk", 10, 4, 10),
	jump = Sprite.load("harpy_jump", "survivors/spr/harpy/jump", 1, 5, 11),
	climb = Sprite.load("harpy_climb", "survivors/spr/harpy/climb", 2, 4, 7),
	death = Sprite.load("harpy_death", "survivors/spr/harpy/death", 8, 48, 13),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("harpy_decoy", "survivors/spr/harpy/decoy", 1, 9, 18),
}
-- Attack sprites are loaded separately as we'll be using them in our code
local zSprites = {
	[0] = Sprite.load("harpy_shoot1a", "survivors/spr/harpy/shoot1", 9, 4, 14),
	[1] = Sprite.load("harpy_shoot1b", "survivors/spr/harpy/shoot1-2", 9, 4, 14),
	[2] = Sprite.load("harpy_shoot1c", "survivors/spr/harpy/shoot1-3", 9, 4, 14),
}
local sprShoot3 = Sprite.load("harpy_shoot3", "survivors/spr/harpy/shoot3", 6, 14, 16)


local harpyAttS = {
	[0] = function(player, rF)
		print("1")
		if rF == 1 then

		end
	end,
	[1] = function(player, rF)
		print("2")
	end,
	[2] = function(player, rF)
		print("3")
	end,
}
-- The sprite used by the skill icons
local sprSkills = Sprite.load("harpy_skills", "survivors/spr/harpy/skills", 5, 0, 0)

-- Get the sounds we'll be using
local sndClayShoot1 = Sound.find("ClayShoot1", "vanilla")
local sndBullet2 = Sound.find("Bullet2", "vanilla")
local sndBoss1Shoot1 = Sound.find("Boss1Shoot1", "vanilla")
local sndGuardDeath = Sound.find("GuardDeath", "vanilla")



-- Set the description of the character and the sprite used for skill icons
harpy:setLoadoutInfo(
[[e]], sprSkills)

-- Set the character select skill descriptions
harpy:setLoadoutSkill(1, "Wing Attack",
[[Perform a 3 hit combo with consecutive uses, ending in an upwards sweep that knocks you and the target into the air..]])

harpy:setLoadoutSkill(2, "Talon Grasp",
[[Lunge forward, grabbing the first enemy hit and then fly diagonally into the air.
Use while holding an enemy to throw the enemy to the ground. Enemy is released upon touching the ground.]])

harpy:setLoadoutSkill(3, "Soar",
[[Fly upwards, creating a shockwave that knocks nearby enemies upwards.
Enemies hit get suspended in the air for N seconds.]])

harpy:setLoadoutSkill(4, "Aerial Superiority",
[[Suspend all currently-in-air enemies, then dash to the closest one that has not been hit by the ability.
If more not-yet-hit targets remain, cooldown is reset.]])

-- The color of the character's skill names in the character select
harpy.loadoutColor = Color(0xA23EE0)

-- The character's sprite in the selection pod
harpy.loadoutSprite = Sprite.load("harpy_select", "survivors/spr/harpy/select", 4, 2, 0)

-- The character's walk animation on the title screen when selected
harpy.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
harpy.endingQuote = "..and so it left, still not knowing how it got here to begin with."

-- Called when the player is created
harpy:addCallback("init", function(player)
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(120, 14, 0.01)
	-- Set the player's skill icons

	local pT = player:getData()

	pT.timeSinceZ, pT.zVal, pT.zTresh, pT.player, pT.enemies, pT.xShockEns, pT.xToler, pT.suspendEnemiesTab = 0, 0, 10, player, ParentObject.find("classicEnemies"), {}, 20, {}
	player:setSkill(1,
		"Stab",
		"Stab for 90% damage hitting up to 5 enemies.",
		sprSkills, 1,
		20
	)
	player:setSkill(2,
		"Raspberry Bullet",
		"Fire a projectile from your rod for 60% damage.\nPierces enemies and causes bleeding for 4x60% damage over time.",
		sprSkills, 2,
		6 * 60
	)
	player:setSkill(3,
		"Roll",
		"Roll forward a small distance.\nYou cannot be hit while rolling.",
		sprSkills, 3,
		4.5 * 60
	)
	player:setSkill(4,
		"Spikes of Death",
		"Form spikes in front of yourself dealing up to 3x240% damage.",
		sprSkills, 4,
		7 * 60
	)
end)

local createShockwave = function(x, y, player, damage)
	damage = damage or 2
	shockwaveInst = shockWaveObj:create(x, y)
	shockDamage = player:fireExplosion(shockwaveInst.x, shockwaveInst.y - 4, 78/19, 0.25, damage)
	shockDamage:set("knockup", 10):set("unID", "shockDamage"):set("stun", suspendTime / 1.5)
end

local suspend = function(self, duration)
	if not self:get("durationLeft")	then self:set("durationLeft", duration) end

	if self:get("durationLeft") > 0 then
		self:set("pVspeed", -0.28):set("durationLeft", self:get("durationLeft") - 1)
	end
	print(self:get("durationLeft"))
	return self:get("durationLeft")
end

-- Called when the player levels up
harpy:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
harpy:addCallback("scepter", function(player)
	player:setSkill(4,
		"Spikes of Super Death",
		"Form spikes in both directions dealing up to 2x3x240% damage.",
		sprSkills, 5,
		7 * 60
	)
end)

registercallback("onPlayerStep", function(player)
	print("Harpy Code")
	local pT = player:getData()
	if pT.timeSinceZ < pT.zTresh * 2 then
		pT.timeSinceZ = pT.timeSinceZ + 1
	end

	for k, v in ipairs(pT.xShockEns) do
		if v:isValid() and v:get("free") == 0 and v:get("isShockwave") == 1 then
			createShockwave(v.x, v.y, pT.player, 1)
			v:set("isShockwave", 0)
			pT.xShockEns[k] = nil
		end
	end

	if input.checkKeyboard("G") == input.PRESSED then
		pT.player.x, pT.player.y = input.getMousePos()
	end

	for k, v in ipairs(pT.suspendEnemiesTab) do
		if v:isValid() and v:get("pVspeed") < 3 and v:get("pVspeed") > -1 then
			if suspend(v, (suspendTime * 60)) == 0 then
			end
		end
	end
end)

-- Called when the player tries to use a skill
harpy:addCallback("useSkill", function(player, skill)
	local pT = player:getData()
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
		-- Set the player's state

		if skill == 1 then

			if pT.timeSinceZ >= pT.zTresh or pT.zVal > 2 then
				pT.zVal, pT.timeSinceZ = 0, 0
			end

			if pT.timeSinceZ <= pT.zTresh then
				player:survivorActivityState(1, zSprites[pT.zVal], 0.30, true, true)
				pT.timeSinceZ = 0
			end

		elseif skill == 2 then
			-- X skill

		if pT.xTarget and pT.xTarget.id:isValid() and pT.xTargetQ == true then
			player:survivorActivityState(2.1, zSprites[1], 0.40, true, true)
		else
			player:survivorActivityState(2, sprShoot3, 0.25, true, true)
		end

		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprShoot3, 0.20, false, false)
		elseif skill == 4 then
			-- V skill
			player:survivorActivityState(4, sprShoot1c, 0.25, true, true)
		end

		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

-- Called each frame the player is in a skill state
harpy:addCallback("onSkill", function(player, skill, relevantFrame)
	local pT = player:getData()
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0


	if skill == 1 then

		if relevantFrame >= 8 then
			pT.zVal, pT.timeSinceZ = pT.zVal + 1, 0
		end

		if relevantFrame == 1 then
			harpyAttS[pT.zVal](player, relevantFrame)
		end
	elseif skill == 2 then
		if not pT.xTarget then
			player:set("pHspeed", 10 * player.xscale):set("pVspeed", -0.28)
		end
		for i = 1, pT.xToler do
			if pT.enemies:findNearest(pT.player.x, pT.player.y) and pT.player:collidesWith(pT.enemies:findNearest(pT.player.x, pT.player.y), pT.player.x, pT.player.y + i) and not pT.xTarget then
					enemyGrab(pT.player, pT.enemies:findNearest(pT.player.x, pT.player.y + i))
					pT.player:set("activity", 0)
					print("what Tha fackK!", pT.xTargetQ)
					pT.player:survivorActivityState(2, sprShoot3, 0.20, true, true)
					pT.player:set("pVspeed", -12):set("pHspeed", 5 * pT.player.xscale)
			end
		end
	elseif skill == 2.1 then
		enemyRelease(pT.player, true)
		print("enemyRelease called manually", os.time())
	elseif skill == 3 then

    if relevantFrame == 3 then
			if pT.player:get("pVspeed") == 0 then
				createShockwave(player.x, player.y, player, 1)
			end
      pT.player:set("pVspeed", -10)

    end

	elseif skill == 4 then

	end
end)

registercallback("onPlayerHUDDraw", function(player)
	local pT = player:getData()
	testingVars = {
        [1] = "zTresh: " ..tostring(pT.zTresh),
        [2] = "timeSinceZ: " ..tostring(pT.timeSinceZ),
        [3] = "zVal: " ..tostring(pT.zVal),
      }

      table.insert(testingVars, " ")

			for k, v in pairs(pT) do
				table.insert(testingVars, "" ..tostring(k).. ":" ..tostring(v))
			end
			 	table.insert(testingVars, " ")
				if pT.xTarget ~= nil then
					for k, v in pairs(pT.xTarget) do
						table.insert(testingVars, "" ..tostring(k).. ":" ..tostring(v))
					end
				end

      for k, v in pairs(testingVars) do
        if currVars == nil or k > currVars then
          currVars = k
        end

        if k > maxVars then
          maxVars = k + 1
        end

      end

      local maxX, maxY = graphics.getHUDResolution()
      graphics.color(Color.GREEN)
      graphics.alpha(0.3)
      graphics.rectangle(maxX, maxY, maxX -250, maxY - (10 * maxVars))
      graphics.color(Color.DARK_GREEN)
      graphics.alpha(0.8)
      graphics.line(maxX - 250, maxY - (10 * maxVars), maxX, maxY - (10 * maxVars), 2)
      graphics.line(maxX - 250, maxY - (10 * maxVars), maxX - 250, maxY, 2)

      for k, v in pairs(testingVars) do

      graphics.color(Color.BLACK)
      graphics.alpha(1)
      graphics.print(testingVars[k], maxX - 240, maxY - ((10 * maxVars) - 3) + 10 * (k - 1))
      end
end)

registercallback("onPlayerDraw", function(player)
	local pT = player:getData()

	for k, v in ipairs(pT.suspendEnemiesTab) do
		if v:isValid() and v:get("durationLeft") and v:get("durationLeft") > 0 then
			graphics.drawImage{
				image = suspendEF,
				x = v.x,
				y = v.y,
				opacity = v:get("durationLeft") / 10
				}
			end
	end
end)

registercallback("onHit", function(self, hit, hX, hY)
	if self:get("unID") == "shockDamage" then
		local pT = self:getParent():getData()
		hit:set("durationLeft", nil)
		table.insert(pT.suspendEnemiesTab, hit)

	end
end)

shockWaveObj:addCallback("create", function(self)
	self:set("age", 0)
end)

shockWaveObj:addCallback("draw", function(self)
	self:set("subImage", self:get("age") / 6)
	for i = 1, 2 do
		graphics.drawImage{
	    image = shockwave,
	    x = self.x + (self:get("subImage") * 11) * ((i*2)-3),
	    y = self.y,
			xscale = ((i*2)-3),
			subimage = self:get("subImage"),
		}
	end

	self:set("age", self:get("age") + 1)
	if self:get("age") > 7 * 6 then
		self:destroy()
	end
end)
