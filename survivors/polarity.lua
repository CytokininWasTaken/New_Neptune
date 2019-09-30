local calcDistanceInsts = function(i1, i2) return math.sqrt((i2.x - i1.x) ^ 2 + (i2.y - i1.y) ^ 2) end
local magspeed = 4

local collisSprite = Sprite.load("polaritycollis","spr/collis.png", 1, 0, 0)

local enemyObjs = ParentObject.find("enemies")
local maxAccel = 20
local magstrengths = {[0] = 55, [1] = 85}
local magnets = {}

local polarity = Survivor.new("Polarity")

local negCheck = function(val) if val < 0 then return -1 else return -1 end end

local moveEnforce = function(target, oX, nX, oY, nY)
  for i = oX, nX, negCheck(nX - oX) do
    if not target:collidesMap(i, target.y) then
      target.x = i
    end
  end
  for i = oY, nY, negCheck(oY - nY) do
    if not target:collidesMap(i, target.y) then
      target.y = i
    end
  end
end

local overlayColours = {
  pos = Color.BLUE,
  neg = Color.RED
}

misc.setRunSeed(2314)
-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("polarity_idle", "survivors/spr/polarity/idle", 1, 3, 7),
	walk = Sprite.load("polarity_walk", "survivors/spr/polarity/walk", 8, 4, 7),
	jump = Sprite.load("polarity_jump", "survivors/spr/polarity/jump", 1, 5, 11),
	climb = Sprite.load("polarity_climb", "survivors/spr/polarity/climb", 2, 4, 7),
	death = Sprite.load("polarity_death", "survivors/spr/polarity/death", 5, 48, 13),
	decoy = Sprite.load("polarity_decoy", "survivors/spr/polarity/decoy", 1, 9, 18),
}

local overlays = {
  polarity_idle = Sprite.load("polarity_idleO", "survivors/spr/polarity/idleO", 1, 3, 7),
  polarity_walk = Sprite.load("polarity_walkO", "survivors/spr/polarity/walkO", 8, 4, 7),
  polarity_jump = Sprite.load("polarity_jumpO", "survivors/spr/polarity/jumpO", 1, 5, 11),
  polarity_climb = Sprite.load("polarity_climbO", "survivors/spr/polarity/climbO", 2, 4, 7),
  polarity_death = Sprite.load("polarity_deathO", "survivors/spr/polarity/deathO", 5, 48, 13),
  polarity_shoot1 = Sprite.load("polarity_shoot1O", "survivors/spr/polarity/shoot1O", 5, 7, 13),
  polarity_shoot2 = Sprite.load("polarity_shoot2O", "survivors/spr/polarity/shoot2O", 6, 6, 8),
}
-- Attack sprites are loaded separately as we'll be using them in our code --ok i dont care

local polarityCalc = function(p1, p2) if p1:get("polarity") == p2:get("polarity") then return -1 else return 1 end end

local applyForce = function(target, origin)

  local tdeltaX, tdeltaY, odeltaX, odeltaY = (target.x - origin.x), (target.y - origin.y), (origin.x - target.x), (origin.y - target.y)
  if tdeltaX ~= 0 then tdeltaX = 1/tdeltaX end if tdeltaY ~= 0 then tdeltaY = 1/tdeltaY end
  if (not target:get("still")) then
    newX, newY = target.x - (tdeltaX * maxAccel) * polarityCalc(target, origin), target.y - (tdeltaY * maxAccel) * polarityCalc(target, origin)
    moveEnforce(target, target.x, newX, target.y, newY)
    --target.x, target.y = target.x - maxAccel * math.min(tdeltaX - magstrengths[1], 0) / magstrengths[1], target.y - maxAccel * math.min(tdeltaY - magstrengths[1], 0) / magstrengths[1]
    --print(target.x - maxAccel * math.min(magstrengths[1] - tdeltaX, 0) / magstrengths[1], target.y - maxAccel * math.min(magstrengths[1] - tdeltaY, 0) / magstrengths[1])
  end
end

local magnetCalcs = function()
  for _, v in ipairs(magnets) do
    for _,v2 in ipairs(magnets) do
      if v ~= v2 then
        local deltaX, deltaY = (v.owner.x - v2.owner.x), (v.owner.y - v2.owner.y)
        graphics.line(v.owner.x, v.owner.y, v.owner.x + deltaX / 2, v.owner.y + deltaY)
        if calcDistanceInsts(v.owner, v2.owner) < magstrengths[1] then
          applyForce(v.owner, v2.owner)
        end
        graphics.print(calcDistanceInsts(v.owner, v2.owner), v.owner.x, v.owner.y + 40)
      end
    end
  end
end





registercallback("onStep", function()
  for k, v in ipairs(magnets) do
    if v.timemade and math.abs(v.timeMade - os.time()) > 15 * 20 then
      magnets[k] = nil
    end

  end
end)

registercallback("onDraw", magnetCalcs)

local drawStuff = function()
  for _, v in ipairs(magnets) do
    graphics.color(overlayColours[v.owner:get("polarity")])
    for i = 0, 1 do
      graphics.alpha(0.5 - (0.35 * i))
      graphics.circle(v.owner.x, v.owner.y, magstrengths[i] * v.rangefac, true)
    end
  end
end

registercallback("onStageEntry", function()
  graphics.bindDepth(13, drawStuff)
end)

local sprShoot1 = Sprite.load("polarity_shoot1", "survivors/spr/polarity/shoot1", 5, 7, 13)
local sprShoot2 = Sprite.load("polarity_shoot2", "survivors/spr/polarity/shoot2", 6, 6, 8)

local magnetProj = Object.new("Magnet Ball")


magnetProj:addCallback("create", function(self)
  magnets[#magnets + 1] = {owner = self, rangefac = 0.5, timeMade = os.time()}
  self.sprite = collisSprite
end)

magnetProj:addCallback("step", function(self)
  local index
  local closestEnemy = enemyObjs:findNearest(self.x, self.y)
  for k, v in ipairs(magnets) do
    if v.owner == self then
      index = k
    end
  end
  if closestEnemy and self:collidesWith(closestEnemy, self.x, self.y) and magnets[index] then
    magnets[index].owner = closestEnemy
    closestEnemy:set("polarity", self:get("polarity"))
    self:destroy()

  elseif not self:collidesMap(self.x, self.y) then
      self.x = self.x + magspeed * self.xscale
      magnets[index].still = true
      magnets[index].owner:set("still", 1)

  else

  end
end)

magnetProj:addCallback("draw", function(self)
  graphics.color(Color.GREY)
  graphics.circle(self.x, self.y, 2)
end)


-- The sprite used by the skill icons
local sprSkills = Sprite.load("polarity_skills", "survivors/spr/polarity/skills", 6, 0, 0)

-- Get the sounds we'll be using
local sndClayShoot1 = Sound.find("ClayShoot1", "vanilla")
local sndBullet2 = Sound.find("Bullet2", "vanilla")
local sndBoss1Shoot1 = Sound.find("Boss1Shoot1", "vanilla")
local sndGuardDeath = Sound.find("GuardDeath", "vanilla")



-- Set the description of the character and the sprite used for skill icons
polarity:setLoadoutInfo(
[[]], sprSkills)

-- Set the character select skill descriptions
polarity:setLoadoutSkill(1, "Slap",
[[]])

polarity:setLoadoutSkill(2, "Magnet Launch",
[[]])

polarity:setLoadoutSkill(3, "Polarity Switch",
[[]])

polarity:setLoadoutSkill(4, "Electromagnetical Surge",
[[]])

-- The color of the character's skill names in the character select
polarity.loadoutColor = Color(0xA23EE0)

-- The character's sprite in the selection pod
polarity.loadoutSprite = Sprite.load("polarity_select", "survivors/spr/polarity/select", 4, 2, 0)

-- The character's walk animation on the title screen when selected
polarity.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
polarity.endingQuote = "..."

-- Called when the player is created
polarity:addCallback("init", function(player)
  local pNN = player:getData()
  pNN.polarity = {}
  table.insert(magnets, {owner = player, rangefac = 1, still = true})
  player:set("polarity", "neg")
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(120, 14, 0.01)
	-- Set the player's skill icons
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
		20
	)
	player:setSkill(3,
		"Roll",
		"Roll forward a small distance.\nYou cannot be hit while rolling.",
		sprSkills, 3,
		15
	)
	player:setSkill(4,
		"Spikes of Death",
		"Form spikes in front of yourself dealing up to 3x240% damage.",
		sprSkills, 4,
		20
	)
end)

-- Called when the player levels up
polarity:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
polarity:addCallback("scepter", function(player)
	player:setSkill(4,
		"Spikes of Super Death",
		"Form spikes in both directions dealing up to 2x3x240% damage.",
		sprSkills, 5,
		7 * 60
	)
end)

registercallback("onPlayerDraw", function(player)
  local pNN = player:getData()
  --print(player.sprite:getName())
  graphics.drawImage{
    image = overlays[player.sprite:getName()],
    x = player.x,
    y = player.y,
    subimage = player.subimage,
    xscale = player.xscale,
    yscale = player.yscale,
    color = overlayColours[player:get("polarity")],
  }
end)



-- Called when the player tries to use a skill
polarity:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
  local pNN = player:getData()

  if skill == 3 then
    if player:get("polarity") then if player:get("polarity") == "pos" then player:set("polarity", "neg") else player:set("polarity", "pos") end end
    player:activateSkillCooldown(skill)
  end

	if player:get("activity") == 0 then
		-- Set the player's state

		if skill == 1 then
      player:survivorActivityState(1, sprShoot1, 0.15, false, false)
		elseif skill == 2 then
			-- X skill
      player:survivorActivityState(2, sprShoot2, 0.15, false, false)
		elseif skill == 3 then
			-- C skill
			--player:survivorActivityState(3, sprShoot3, 0.20, false, false)
		elseif skill == 4 then
			-- V skill
			--player:survivorActivityState(4, sprShoot1c, 0.25, true, true)
		end

		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

-- Called each frame the player is in a skill state
polarity:addCallback("onSkill", function(player, skill, relevantFrame)
  local pNN = player:getData()
	if skill == 1 then

	elseif skill == 2 then
    if relevantFrame == 5 then
      local magnetInst = magnetProj:create(player.x, player.y)
      magnetInst.xscale = player.xscale
      magnetInst:set("polarity", player:get("polarity")):set("owner", player.id)
    end
	elseif skill == 3 then

	elseif skill == 4 then

	end
end)

registercallback("onPlayerHUDDraw", function(player)

end)

registercallback("onPlayerDraw", function(player)

end)

registercallback("onHit", function(self, hit, hX, hY)

end)
