local item = Item("Suction Boots")
item.pickupText = "Lets you walk up walls."

item.sprite = Sprite.load("items/spr/suctionboots.png", 1, 12, 15)
item:setTier("uncommon")

registercallback("onPlayerInit", function(player)
  local pNN = player:getData()
  pNN.suction = {}
  pNN.suction.draw = false
end)

local timer = 0

registercallback("onPlayerStep", function(player)

  local pNN = player:getData()
  if not pNN.suction.sprite then
    pNN.suction.sprite = player:getAnimation("walk")
  end

  if player:countItem(item) > 0 then
    local checkstr
    if player:collidesMap(player.x + 1 * player.xscale, player.y) and player:get("activity") == 0 then
      player.x = player.x - 1 * player.xscale
      if player.xscale == -1 then checkstr = "left" else checkstr = "right" end
      if player:control(checkstr) == 2 then
        player.alpha = 0
        pNN.suction.draw = true
        player:set("pVspeed", -math.clamp((1.5 + (0.2 * (player:countItem(item) - 1))), 0, 15))
      else
        if player:get("pVspeed") < 0 then player:set("pVspeed", 0) end
      end
    else
      if player.alpha == 0 and pNN.suction.draw == true then player.alpha = 1 end
      pNN.suction.draw = false
      player.angle = 0


    end
  end
end)



registercallback("onPlayerDraw", function(player)
  local pNN = player:getData()
  if player:countItem(item) > 0 then
    if pNN.suction and pNN.suction.draw and pNN.suction.sprite then
      if timer < pNN.suction.sprite.frames then timer = timer + 0.3 else timer = 0 end

      graphics.drawImage{
        image = pNN.suction.sprite,
        x = player.x,
        y = player.y,
        xscale = player.xscale,
        angle = 90 * player.xscale,
        subimage = 1 + timer,
        }

    end
  end
end)

-- Set the log for the item, just like the first example item
item:setLog{
	group = "uncommon",
	description = "Allows walking up flat walls.",
	story = [[Look out your office window, mate. And don't give me that "It's on the fifty-fifth floor!" shit, just do it, alright?
I want to show you something.]],
	destination = "Starworks Office Building,\nSW Corpo District,\nLilia 46P1",
	date = ""
}
