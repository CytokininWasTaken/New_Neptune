print("Fungus has been loaded")
------ fungus.lua
---- Adds a new playable character.
local fungus = Survivor.new("Myco")
local body = Object.find("body")

local rezcol, rezop = Color.fromHex(0x785628), 0.4
local mushcol = Color.fromHex(0x1AC48B)
local charge = 0
local fungusChargeBar = createCustomBar("Fungus Charge Bar", {sprite = Sprite.load("survivors/spr/fungus/fungalbar", 1, 3, 6), color = mushcol })

local corpses = {}
body:addCallback("destroy", function(self)
	table.insert(corpses, {spr = self.sprite, x = self.x, y = self.y, xs = self.xscale, alpha = 0, obj = Object.fromID(self:get("parent"))})
end)

local drawCorpses = function()
	local time = misc.hud:get("second")
	for _, v in ipairs(corpses) do
		if v then
			graphics.drawImage{image = v.spr, x = v.x, y = v.y, subimage = v.spr.frames, xscale = v.xs, alpha = v.alpha / 2000}
			v.alpha = v.alpha + 1
			if v.alpha > 5*60*60 then
				corpses[_] = nil
			end
		end
	end
end

local rezTargets = function(tab, player)
	for _, v in ipairs(tab) do
		local spawnman = spawnmanager:create(v.x, v.y)
		local spawnmantab = spawnman:getData()
		spawnmantab.sprite, spawnmantab.player, spawnmantab.obj, spawnman.xscale = v.spr, player, v.obj, v.xs

	end
end

registercallback("onDraw", function()
	for _, v in ipairs(resurrected) do
		if v and v:isValid() then
			graphics.drawImage{
				image = v.sprite,
				x = v.x,
				y = v.y,
				subimage = v.subimage,
				xscale = v.xscale,
				yscale = v.yscale,
				color = rezcol,
				alpha = rezop,
			}
		end
	end
end)

registercallback("onStageEntry", function() graphics.bindDepth(-7, drawCorpses) end)

-- Load all of our sprites into a table
local sprites = {
	idle     = Sprite.load("fungus_idle",	 		"survivors/spr/fungus/idle", 1, 3, 8),
	walk     = Sprite.load("fungus_walk", 		"survivors/spr/fungus/walk", 6, 4, 8),
	jump     = Sprite.load("fungus_jump", 		"survivors/spr/fungus/jump", 1, 4, 9),
	climb    = Sprite.load("fungus_climb", 		"survivors/spr/fungus/climb", 2, 4, 7),
	death    = Sprite.load("fungus_death", 		"survivors/spr/fungus/death", 8, 48, 13),
	decoy    = Sprite.load("fungus_decoy", 		"survivors/spr/fungus/decoy", 1, 9, 18),

  shoot1_1 = Sprite.load("fungus_shoot1_1", "survivors/spr/fungus/shoot1_1", 6, 4, 8),
  shoot1_2 = Sprite.load("fungus_shoot1_2", "survivors/spr/fungus/shoot1_2", 6, 4, 8),
  shoot2_1 = Sprite.load("fungus_shoot2_1", 	"survivors/spr/fungus/shoot2_1", 6, 4, 8),
	shoot2_2 = Sprite.load("fungus_shoot2_2", 	"survivors/spr/fungus/shoot2_2", 4, 4, 8),
  shoot3_1 = Sprite.load("fungus_shoot3",		"survivors/spr/fungus/shoot3_1", 12, 6, 8),
  shoot4_1 = Sprite.load("fungus_shoot4",		"survivors/spr/fungus/shoot4", 15, 4, 19),
}
-- Attack sprites are loaded separately as we'll be using them in our code

-- The hit sprite used by our X skill
local sprSparksfungus = Sprite.load("fungus_sparks1", "survivors/spr/fungus/bullet", 4, 10, 8)
-- The spikes creates by our V skill
local sprfungusSpike = Sprite.load("fungus_spike", "survivors/spr/fungus/spike", 5, 12, 32)
local sprSparksSpike = Sprite.load("fungus_sparks2", "survivors/spr/fungus/hitspike", 4, 8, 9)
-- The sprite used by the skill icons
local sprSkills = Sprite.load("fungus_skills", "survivors/spr/fungus/skills", 5, 0, 0)

-- Get the sounds we'll be using
local sndClayShoot1 = Sound.find("ClayShoot1", "vanilla")
local sndBullet2 = Sound.find("Bullet2", "vanilla")
local sndBoss1Shoot1 = Sound.find("Boss1Shoot1", "vanilla")
local sndGuardDeath = Sound.find("GuardDeath", "vanilla")

local torez = {}
local variables = {
  x_duration = 8,
  c_duration = 10,
}

-- Set the description of the character and the sprite used for skill icons
fungus:setLoadoutInfo(
[[Myco is a tactical survivor that is able to mutate themself to fit more niche scenarios.
Volatile Lycoperdon is powerful against large groups thanks to its explosive nature.
__willing Subjects lets Myco revive up to two enemies to act as protection.
Gone with the Wind has a long cooldown, but automatically activates upon reaching low health.]], sprSkills)

-- Set the character select skill descriptions
fungus:setLoadoutSkill(1, "Volatile Lycoperdon",
[[Throw an &r&exploding puffball&!& that &y&damages and poisons&!& enemies.]])

fungus:setLoadoutSkill(2, "__willing Subjects",
[[&r&Seed a fungus&!& in two nearby corpses, &b&reviving them&!&.
After ]]..variables.x_duration..[[ seconds, the fungus returns to Myco.]])

fungus:setLoadoutSkill(3, "Gone with the wind",
[[&r&Release and control&!& a cloud of spores, then wither away.
After ]]..variables.c_duration..[[ seconds, the spores fall and &g&regrow into Myco&!&.]])

fungus:setLoadoutSkill(4, "Mutative Foraging",
[[Replaces abilities Z and X with different fungi that &b&mutate Myco&!&.
Z makes Myco larger and grants &r&powerful melee attacks&!&.
X camouflages Myco and allows for &r&long-range combat&!&.]])

-- The color of the character's skill names in the character select
fungus.loadoutColor = Color(0x255C60)

-- The character's sprite in the selection pod
fungus.loadoutSprite = Sprite.load("fungus_select", "survivors/spr/fungus/select", 4, 2, 0)

-- The character's walk animation on the title screen when selected
fungus.titleSprite = Sprite.load("why", "survivors/spr/fungus/mistake", 4, 0, 8)

-- Quote displayed when the game is beat as the character
fungus.endingQuote = "..and so it left, still not knowing how it got here to begin with."

-- Called when the player is created
fungus:addCallback("init", function(player)
	local pNN = player:getData()
	pNN.fungus = {}
	pNN.fungus.isFungus = true
	pNN.fungus.drawChargeCounter = 0

	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(999120, 99914, 9990.01)
	-- Set the player's skill icons
	player:setSkill(1,
		"Volatile Lycoperdon",
		"Throw an exploding puffball that damages and poisons enemies.",
		sprSkills, 1,
		0
	)
	player:setSkill(2,
		"__willing Subjects",
		"Seed a fungus in two nearby corpses, reviving them.\nAfter "..variables.x_duration.." seconds, the fungus returns to Myco..",
		sprSkills, 2,
		1 * 60
	)
	player:setSkill(3,
		"Gone with the wind",
		"Release and control a cloud of spores, then wither away.\nAfter "..variables.c_duration.." seconds, the spores fall and regrow into Myco.",
		sprSkills, 3,
		4.5 * 60
	)
	player:setSkill(4,
		"Mutative Foraging",
		"Replaces abilities Z and X with different fungi that mutate Myco.\nZ promotes melee, while X promotes ranged combat.",
		sprSkills, 4,
		7 * 60
	)
end)


-- Called when the player levels up
fungus:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
fungus:addCallback("scepter", function(player)
	player:setSkill(4,
		"Spikes of Super Death",
		"Form spikes in both directions dealing up to 2x3x240% damage.",
		sprSkills, 5,
		7 * 60
	)
end)

-- Called when the player tries to use a skill
fungus:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 and charge == 0 then
		-- Set the player's state

		if skill == 1 then
			-- Z skill
			player:survivorActivityState(1, table.random{sprites.shoot1_1, sprites.shoot1_2}, 0.2, true, true)
		--[[elseif skill == 2 then
			-- X skill
			player:survivorActivityState(2, sprites.shoot2_1, 0.2, true, true)]]
		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprites.shoot3_1, 0.2, false, false)
		elseif skill == 4 then
			-- V skill
			player:survivorActivityState(4, sprites.shoot4_1, 0.25, true, true)
		end

		-- Put the skill on cooldown
		if skill ~= 2 then
			player:activateSkillCooldown(skill)
		end
	end
end)

registercallback("onPlayerDraw", function(player)
	local pNN = player:getData()

	if charge > 0 and not mpCtrl(player, 2) == input.HELD then player.alpha, charge, pNN.fungus.drawChargeCounter = 1, 0, 0 end
	if pNN.fungus and pNN.fungus.isFungus and player:get("activity") == 0 and player:getAlarm(3) == -1 then
		if mpCtrl(player, 2) == input.HELD and charge < 100 then
			charge = fungusChargeBar:draw(player.x, player.y, pNN.fungus.drawChargeCounter, 200)
			pNN.fungus.drawChargeCounter = pNN.fungus.drawChargeCounter + 1
			player.alpha = 0
			graphics.drawImage{
				image = sprites.shoot2_1,
				x = player.x,
				y = player.y,
				subimage = math.min(pNN.fungus.drawChargeCounter / 4, 6),
				xscale = player.xscale,
				yscale = player.yscale,
			}
			if charge == 33 then

			elseif charge == 66 then

			end

			player:set("activity_type", 3):set("pHspeed", 0)
		elseif (mpCtrl(player, 2) == input.RELEASED or charge >= 100) or (mpCtrl(player, 2) ~= input.HELD and charge > 0) then
			charge = 0
			pNN.fungus.drawChargeCounter = 0
			player.alpha = 1
			graphics.drawImage{
				image = sprites.shoot2_1,
				x = player.x,
				y = player.y,
				subimage = 6,
				xscale = player.xscale,
				yscale = player.yscale
			}


			player:survivorActivityState(2, sprites.shoot2_2, 0.2, true, true)
			player:activateSkillCooldown(2)
		end
	end

end)

-- Called each frame the player is in a skill state
fungus:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0


	if skill == 1 then
		-- Z skill: stab

		if relevantFrame == 4 then
			-- Code is ran when the 4th frame of the animation starts

			-- The "survivorFireHeavenCracker" method handles the effects of the item Heaven Cracker
			-- If the effect is triggered, it returns the fired bullet, otherwise it returns nil
			if player:survivorFireHeavenCracker(0.9) == nil then
				-- The player's "sp" variable is the attack multiplier given by Shattered Mirror
				for i = 0, player:get("sp") do
					local pb = puffball:create(player.x, player.y)
					pb.xscale = player.xscale
					local pbt = pb:getData()
					pbt.parent = player
				end
			end

			-- Plays the clay man stab sound effect
			sndClayShoot1:play(0.8 + math.random() * 0.2)
		end


	elseif skill == 2 then


		if relevantFrame == 1 then
			torez = {}
			for i = -20, 20, 40 do
				table.insert(torez, findNearestTable(corpses, player.x + i, player.y, 150, torez, "exhausted"))
			end

		elseif relevantFrame == 3 then
			player:set("pVspeed", player:get("pVspeed") -2)
			rezTargets(torez, player)
		end


	elseif skill == 3 then
		-- C skill: roll

		if relevantFrame == 8 then
			-- Ran on the last frame of the animation

			-- Reset the player's invincibility
			if player:get("invincible") <= 5 then
				player:set("invincible", 0)
			end
		else
			-- Ran all other frames of the animation

			-- Make the player invincible
			-- Only set the invincibility when below a certain value to make sure we don't override other invincibility effects
			if player:get("invincible") < 5 then
				player:set("invincible", 5)
			end

			-- Set the player's horizontal speed
		end



	elseif skill == 4 then
		-- V skill: fungus spikes
		if relevantFrame == 6 or relevantFrame == 10 or relevantFrame == 14 then
			for i = 0, player:get("sp") do
				-- Calculate the offset from the player
				local pos = ((relevantFrame - 2) / 4) * 48 + i * 12

				-- Create the spike
				player:fireExplosion(player.x + player.xscale * pos, player.y, 2, 4, 2.4, sprfungusSpike, sprSparksSpike)

				-- If we have ancient scepter, create a spike behind the player too
				if player:get("scepter") > 0 then
					player:fireExplosion(player.x + -player.xscale * pos, player.y, 2, 4, 2.4, sprfungusSpike, sprSparksSpike)
					-- Layer sound effects when scepter is active
					sndGuardDeath:play(1.2 + math.random() * 0.3, 0.6)
				end

				-- Play a sound effect
				sndBoss1Shoot1:play(1.2 + math.random() * 0.3)
			end
		end
	end
end)
