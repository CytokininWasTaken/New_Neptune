
------ magnet.lua
---- Adds a new playable character.

local magnet = Survivor.new("P0-L4R")

-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("guard_idle", "survivors/spr/spy-dr/idle", 1, 19, 24),
	walk = Sprite.load("guard_walk", "survivors/spr/spy-dr/walk", 6, 19, 24),

	jump = Sprite.load("polar_jump", "survivors/spr/polarity/jump", 1, 14, 19),
	climb = Sprite.load("polar_climb", "survivors/spr/polarity/climb", 2, 9, 16),
	death = Sprite.load("polar_death", "survivors/spr/polarity/death", 11, 22, 21),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("magnet_decoy", "survivors/spr/polarity/decoy", 1, 9, 18),
}


local sprShoot1 = Sprite.load("polar_shoot1", "survivors/spr/polarity/shoot1", 8, 30, 19)
-- The sprite used by the skill icons
local sprSkills = Sprite.load("magnet_skills", "survivors/spr/polarity/skills", 8, 0, 0)

-- Set the description of the character and the sprite used for skill icons
magnet:setLoadoutInfo(
[[THE &y&DR-1&!& UNIT IS HIGHLY ADAPTABLE, CAPABLE OF CHANGING BETWEEN 4 FIRING MODES:
&b&RIFLES&!& HANDLE SINGLE TARGETS WITH EASE.
&r&LASERS&!& ARE WEAK AGAINST SINGLE TARGETS BUT MELT GROUPS.
&g&ROCKETS&!& AUTOMATICALLY HOME IN ON TARGETS.
&or&FLAMES&!& CAN BE FIRED WHILE MOVING, BUT DON'T PIERCE WELL.]], sprSkills)

-- Set the character select skill descriptions
magnet:setLoadoutSkill(1, "PRIMARY FIRE",
[[FIRE FROM CURRENTLY POWERED BARRELS.
TO CHANGE FIRING MODE, REROUTE POWER WITH &y&BARREL SWAP&!&]])

magnet:setLoadoutSkill(2, "BARREL SWAP",
[[REROUTE POWER TO THE NEXT SET OF BARRELS
ORDER OF ROUTING IS &b&RIFLE&!&, &r&LASER&!&, &g&MISSILE&!&, &or&FLAME&!&.]])

magnet:setLoadoutSkill(3, "HOVER",
[[&b&LAUNCH FORWARD&!&, &y&SCORCHING ENEMIES&!& BENEATH AND BEHIND.
JUMP WHILE USING TO GAIN SOME HEIGHT!]])

magnet:setLoadoutSkill(4, "MUL-T MODE",
[[SURGE POWER TO ALL CANNONS,
&r&KNOCKING ENEMIES BACK&!& AND &r&FRYING THEM&!&.]])

-- The color of the character's skill names in the character select
magnet.loadoutColor = Color.fromRGB(92, 217, 255)
-- The character's sprite in the selection pod
magnet.loadoutSprite = Sprite.load("magnet_select", "survivors/spr/polarity/select", 14, -2, 0)
magnet.loadoutWide = true
-- The character's walk animation on the title screen when selected
magnet.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
magnet.endingQuote = "..and so it left, ready to return to duty."


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
