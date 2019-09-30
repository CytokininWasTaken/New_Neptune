local item = Item("Umbraic Essence")
local umbraSprite = Sprite.load("items/spr/umbrasprite", 8, (68 / 3), 2 * (56 / 3) + 4)
item.pickupText = "Summons an umbra of Providence to attack upon using your third skill."
item.sprite = Sprite.load("items/spr/umbraic.png", 1, 12, 15)
item:setTier("rare")
local alphafactor = 0


local drawUmbra = function()

  for _, player in ipairs(Object.find("P"):findAll()) do
    local pNN = player:getData()

    if player:countItem(item) > 0 and pNN.umbra.draw then
      if pNN.umbra.subimage >= 6 then alphafactor = 0.07 * pNN.umbra.subimage else alphafactor = 0 end
      graphics.drawImage{
        image = umbraSprite,
        x = player.x,
        y = player.y,
        subimage = pNN.umbra.subimage or 1,
        color = Color.BLACK,
        xscale = player.xscale,
        alpha = 0.7 - alphafactor,
      }

    end
  end
end

local umbraAttack = function(player)
  local pNN = player:getData()
  player:fireExplosion(player.x + (19 * player.xscale), player.y, 1.5, 1, 3.5)
  pNN.umbra.subimage = pNN.umbra.subimage + 1
end

registercallback("onStageEntry", function()
  for _, player in ipairs(Object.find("P"):findAll()) do
    local pNN = player:getData()
    pNN.umbra = {}
    pNN.umbra.draw = false
    pNN.umbra.subimage = 0
  end

  graphics.bindDepth(-7, drawUmbra)
end)

registercallback("onPlayerStep", function(stepplayer)
  for _, player in ipairs(Object.find("P"):findAll()) do
    local pNN = player:getData()
    if player:countItem(item) > 0 then
      if player:get("c_skill") == 1 and player:getAlarm(4) == -1 then
        if pNN.umbra.subimage == 0 then
          pNN.umbra.subimage, pNN.umbra.draw = 1, true
        end
      end
      if stepplayer == player then
        if pNN.umbra.subimage >= 8 then pNN.umbra.subimage, pNN.umbra.draw = 0, false elseif pNN.umbra.subimage == 4 then umbraAttack(player) elseif pNN.umbra.subimage > 0 then pNN.umbra.subimage = pNN.umbra.subimage + 0.25 end
      end
    end
  end
end)

item:setLog{
	group = "rare",
	description = "Summons an &r&umbra of Providence&!& to attack upon &b&using your third skill&!&.",
	story = "A bubbling void. Moving, yet still. The more I move the more It moves. Following me. Mimicking me.    Mimicking me.\nHow can I use this?    How can I use this?",
	destination = "HOME",
	date = ""
}
