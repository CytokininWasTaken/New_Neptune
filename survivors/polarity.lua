
------ magnet.lua
---- Adds a new playable character.

local magnet = Survivor.new("P0-L4R")



-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("polar_idle", "survivors/spr/polarity/idle", 1, 14, 19),
	walk = Sprite.load("polar_walk", "survivors/spr/polarity/walk", 8, 14, 19),
	jump = Sprite.load("polar_jump", "survivors/spr/polarity/jump", 1, 14, 19),
	climb = Sprite.load("polar_climb", "survivors/spr/polarity/climb", 2, 9, 16),
	death = Sprite.load("polar_death", "survivors/spr/polarity/death", 11, 22, 21),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("magnet_decoy", "survivors/spr/polarity/decoy", 1, 9, 18),
}


local sprShoot1 = Sprite.load("polar_shoot1", "survivors/spr/polarity/shoot1", 6, 13, 19)
-- The sprite used by the skill icons
local sprSkills = Sprite.load("magnet_skills", "survivors/spr/polarity/skills", 8, 0, 0)

-- Set the description of the character and the sprite used for skill icons
magnet:setLoadoutInfo(
[[]], sprSkills)

-- Set the character select skill descriptions
magnet:setLoadoutSkill(1, "",
[[]])

magnet:setLoadoutSkill(2, "",
[[]])

magnet:setLoadoutSkill(3, "",
[[]])

magnet:setLoadoutSkill(4, "",
[[]])

-- The color of the character's skill names in the character select
magnet.loadoutColor = Color.fromRGB(92, 217, 255)
-- The character's sprite in the selection pod
magnet.loadoutSprite = Sprite.load("magnet_select", "survivors/spr/polarity/select", 14, -2, 0)
magnet.loadoutWide = true
-- The character's walk animation on the title screen when selected
magnet.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
magnet.endingQuote = "..and as it left, every compass on the planet snapped back into position."


-- The sprite displayed on the multiplayer select menu
magnet.idleSprite = sprites.idle



-- Called when the player is created
magnet:addCallback("init", function(player)
  local pT = player:getData()
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(100, 11, 0.01)
	-- Set the player's skill icons
	player:setSkill(1,
		"PRIMARY FIRE - RIFLE",
		"FIRE CANNONSIDE RIFLES, MAY CAUSE SERIOUS INJURY TO THOSE AT THE END OF BARRELS.",
		sprSkills, 1,
		0
	)
	player:setSkill(2,
		"BARREL SWAP",
		"REROUTE POWER TO THE NEXT SET OF BARRELS.\nORDER OF ROUTING IS RIFLE, LASER, MISSILE, FLAME.",
		sprSkills, 2,
		20
	)
	player:setSkill(3,
		"HOVER",
		"LAUNCH FORWARD, SCORCHING ENEMIES BENEATH AND BEHIND. JUMP WHILE USING TO GET SOME HEIGHT!",
		sprSkills, 3,
		4.5 * 60
	)
	player:setSkill(4,
		"peepee",
		"weee.",
		sprSkills, 4,
		7 * 60
	)
	pT.mode = 1
  pT.self = player
end)

-- Called when the player levels up
magnet:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
magnet:addCallback("scepter", function(player)
	player:setSkill(4,
		"4-TRESS MODE",
		"SURGE POWER TO ALL CANNONS FOR &r&IMMEDIATE EVISCERATION&!&.",
		sprSkills, 8,
		7 * 60
	)
end)


local magnets = {}

local function insertMagnet(toInsert)
	for i = 1, #magnets + 1 do
		if not magnets[i] then
			magnets[i] = toInsert

		end
	end
end

local magnetObj = Object.new("Magnet Orb")
magnetObj:addCallback("create", function(self)
	insertMagnet(self)
end)

local function magnetFunc()
	for i, mag in ipairs(magnets) do
		local magData = mag:getData()
		graphics.circle(mag.x, mag.y, magData.size or 120, true)
	end
end

callback("onDraw", magnetFunc)

armDots = {
  num = 15,
  dist = 3,
  mult = 0.5,
  grav = 1.8,
}

local arms = {
  r = {

  },

  l = {

  },
}

local function createDots(player)
  arms.r, arms.l = {}, {}
  for k, _ in pairs(arms) do
    for i = 1, armDots.num do
      table.insert(arms[k], {x = player.x, y = player.y, id = i0})
    end
  end
end

local magnetSprite = Sprite.load("polar_magnet", "survivors/spr/polarity/hands", 2, 4, 8)

local hand = Object.new("polarHand")
hand.sprite = magnetSprite

hand:addCallback("step", function(self)
	data = self:getData()
	self.subimage = data.subimage
	self.angle = data.angle
	self.xscale = data.xscale
end)

local ropeObject = Object.new("physicsRope")
ropeObject.sprite = collisTesterSprite
local rope = {}
rope.ropes = {}
rope.new = function(name, segmentCount, pullStrength, pullMaxDistance, gravity, thickness, colour, endPiece, debug)
	rope.ropes[name] = {segmentCount = segmentCount, pullStrength = pullStrength, pullMaxDistance = pullMaxDistance, gravity = gravity, thickness = thickness, colour = colour, endPiece = endPiece, debug = debug}
	return rope.ropes[name]
end
rope.create = function(name, x, y)
	r = rope.ropes
	if r[name] then
		local ropeInst = ropeObject:create(x, y)
		local ropeData = ropeInst:getData()
		if not data.attachmentPoint then data.attachmentPoint = {x=x,y=y} end
		ropeData.info = r[name]
		ropeData.points = {}
		for i = 1, r[name].segmentCount do
			table.insert(ropeData.points, {x, y})
		end
		return ropeInst
	end
end
ropeObject:addCallback("step", function(self)
	data = self:getData()
	self.x, self.y = data.attachmentPoint.player.x + data.attachmentPoint.xOffset, data.attachmentPoint.player.y  + data.attachmentPoint.yOffset
	for i, dot in ipairs(data.points) do
		if i == 1 then
			data.points[i][1], data.points[i][2] = self.x, self.y
		elseif i <= #data.points then
			deltaX, deltaY = data.points[i-1][1] - data.points[i][1], data.points[i-1][2] - data.points[i][2]
			dist = calcDistanceInsts({x=data.points[i][1],y=data.points[i][2]},{x=data.points[i-1][1],y=data.points[i-1][2]})
			if dist > data.info.pullMaxDistance then
				data.points[i][1] = (data.points[i][1] + deltaX * data.info.pullStrength)
				data.points[i][2] = (data.points[i][2] + deltaY * data.info.pullStrength)
			end
			local player = data.attachmentPoint.player
			if not self:collidesMap(dot[1], dot[2] + 1) or (player:get("activity") == 30 and player:collidesMap(player.x, player.y) and calcDistanceInsts({x=dot[1],y=dot[2]}, player) < 10) then
				data.points[i][2] = data.points[i][2] + data.info.gravity
			end
		end
	end
end)

rope.new("frontArm", 15, 0.5, 2, 1.8, 2, Color.fromHex(0x5e838f), magnetSprite, false)
rope.new("backArm", 15, 0.5, 2, 1.8, 2, Color.fromHex(0x5e838f), magnetSprite, false)


callback("onPlayerStep", function(player)
	data = player:getData()
	if input.checkKeyboard("E") == input.PRESSED then
		data.testingRope = rope.create("TestRope", player.x, player.y)
	end
	if data.testingRope and data.testingRope:isValid() then
		data.testingRope:getData().attachmentPoint = {player = player, xOffset = 0, yOffset = 0}
	end
end)


ropeObject:addCallback("draw", function(self)
	data = self:getData()
	for i, dot in ipairs(data.points) do
		posx, posy = math.floor(dot[1]), math.floor(dot[2])
		graphics.color(data.info.colour)
		if data.info.debug then
			graphics.print(i, posx, posy - 20 -(10*i))
			graphics.alpha(0.3)
			graphics.line(posx, posy, posx, posy- 15 -(10*i))
			graphics.alpha(1)
		end
		if i > 1 then
			graphics.line(posx, posy, math.floor(data.points[i-1][1]), math.floor(data.points[i-1][2]), data.info.thickness)
		end
		if i == #data.points then
			if data.info.endPiece then
				graphics.drawImage{
					image = data.info.endPiece,
					x = posx, y = posy-1,
					angle = calcAngleInsts({x=dot[1],y=dot[2]}, {x=data.points[i-3][1],y=data.points[i-3][2]}) + 90,
					subimage = 1,
				}
			end
		end
	end
end)

local bbbX, bbbY
local function dotStep(tab, aX, aY, player, colour, magnetcol)
  for k, v in ipairs(tab) do
		graphics.color(colour)
    if k == 1 then
      v.x, v.y = aX, aY
    else
      local deltaX, deltaY = v.x - tab[k - 1].x, v.y - tab[k - 1].y
      if calcDistanceInsts(v, tab[k-1]) > armDots.dist then
        v.x, v.y = v.x - deltaX * armDots.mult, v.y - deltaY * armDots.mult
      end
      if not player:getData().collis:collidesMap(v.x, v.y) then v.y = v.y + armDots.grav end
			graphics.line(v.x, v.y -2, tab[k-1].x, tab[k-1].y -2, 2)

			if k == #tab then
				graphics.drawImage{
					image = magnetSprite,
					x = v.x-.5, y = (v.y-.5) - 2,
					angle = calcAngleInsts(v, tab[k-4]) + 90,
					subimage = magnetcol,
				}
				bbbX, bbbY = v.x-.5, (v.y-.5) - 2
			end
    end

    --graphics.circle(v.x, v.y, 1)
  end
end


callback("onCameraUpdate", function()
	local w,h = graphics.getGameResolution()
	--camera.x, camera.y = (bbbX or 0) -w/2, (bbbY or 0) -h/2
end)

callback("onStageEntry", function()
	for k, v in ipairs(misc.players) do
		if v:getSurvivor() == magnet then
		   createDots(v)
			 v:getData().collis = collisTesterObj:create(v.x, v.y)
			 v:getData().collis:getData().parent = v
		end
	end
end)

callback("onPlayerDraw", function(player, x, y)
	if player:get("activity") ~= 30 then
		dotStep(arms.r, x -4*player.xscale, y - 4, player, Color.fromHex(0x5e838f), 1)
	else
		for k, v in ipairs{{"r", -3}, {"l", 3}} do
			dotStep(arms[v[1]], x + v[2]*player.xscale, y - 4, player, Color.fromHex(0x5e838f), 1)
		end
	end
end)

callback("onPlayerDrawBelow", function(player, x, y)
	if player:get("activity") ~= 30 then
  	dotStep(arms.l, x +2*player.xscale, y - 4, player, Color.fromHex(0x455a61), 2)
	end
end)

-- Called when the player tries to use a skill
magnet:addCallback("useSkill", function(player, skill)
  local pT = player:getData()
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
		-- Set the player's state

		if skill == 1 then
      player:survivorActivityState(1, sprShoot1, 0.2, true, true)

		elseif skill == 2 then
      player:survivorActivityState(2, sprShoot1, 0.2, true, true)

		elseif skill == 3 then
			player:survivorActivityState(3, sprShoot1, 0.2, false, false)

		elseif skill == 4 then
			player:survivorActivityState(4, sprShoot1, 0.2, true, true)

		end

		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

-- Called each frame the player is in a skill state
magnet:addCallback("onSkill", function(player, skill, relevantFrame)
  local pT = player:getData()

	if skill == 1 then

	elseif skill == 3 then

	elseif skill == 4 then

	end
end)
