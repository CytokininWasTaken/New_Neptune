local survivor = Survivor.find("Baroness", "Starstorm")
local boarAnims = {
  idle_1 = Sprite.load("boaroness_idle1", "starstorm/idle", 1, 5, 9),
  idle_2 = Sprite.load("boaroness_idle2", "starstorm/idleBike", 1, 0, 10),
  jump_1 = Sprite.load("boaroness_jump1", "starstorm/jump", 1, 0, 0),
  jump_2 = Sprite.load("boaroness_jump2", "starstorm/jumpBike", 1, 0, 10),
  walk_1 = Sprite.load("boaroness_walk1", "starstorm/walk", 8, 0, 0),
  walk_2 = Sprite.load("boaroness_walk2", "starstorm/walkBike", 4, 0, 11),
  shoot1 = Sprite.load("boaroness_shoot1", "starstorm/shoot1", 3, 0, 0),
  shoot2_1 = Sprite.load("boaroness_shoot2a", "starstorm/shoot2a", 7, 0, 0),
  shoot2_2 = Sprite.load("boaroness_shoot2b", "starstorm/shoot2b", 7, 0, 0),
  shoot3_1 = Sprite.load("boaroness_shoot3a", "starstorm/shoot3a", 6, 0, 0),
  shoot3_2 = Sprite.load("boaroness_shoot3b", "starstorm/shoot3b", 6, 0, 0),
  shoot4_1 = Sprite.load("boaroness_shoot4a", "starstorm/shoot4a", 7, 0, 0),
  shoot4_2 = Sprite.load("boaroness_shoot4b", "starstorm/shoot4b", 7, 0, 0),
  climb = Sprite.load("boaroness_climb", "starstorm/climb", 2, 0, 0),
}


local Boar = SurvivorSkin.new(Survivor.find("Baroness"), "Boaroness", Sprite.load("starstorm/select", 23, 0, 0), boarAnims)
SurvivorSkin.setInfoStats(Boar, {{"Strength", 8}, {"Vitality", 7}, {"Toughness", 3}, {"Agility", 7}, {"Difficulty", 6}, {"Boar", 20}})
SurvivorSkin.setDescription(Boar, "The &y&Boaroness&!&, armed with an enchanted cane and a loyal boar, is a hybrid ranged/melee survivor with one notable improvement over its civilized counterpart: its mount *can* jump.")

callback("onSkinInit", function(player, skin)
  if skin == Boar then
    local vars = player:getModData("starstorm")
    vars._efcolor = Color.GREEN
    vars.enableJump = true
    vars.skin_skill1Override = true


  end
end)

survivor:addCallback("onSkill", function(player, skill, relevantFrame)
	local playerAc = player:getAccessor()
	if SurvivorSkin.getActive(player) == Boar then
		if skill == 1 then
			if relevantFrame == 1 and not player:getData().skin_onActiviy then

			elseif relevantFrame ~= 1 then
				player:getData().skin_onActiviy = nil
			end
		end

	end
end)
