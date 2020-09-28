local item = Item("Emergency Power Core")
item.pickupText = "Every 60 seconds, activate your use item upon falling below 25% hp."

item.sprite = Sprite.load("items/spr/emergency.png", 1, 12, 15)
item:setTier("uncommon")


item:addCallback("pickup", function(player)
  local pNN = player:getData()
  pNN.coreTimer = 0
end)

registercallback("onPlayerStep", function(player)
  local pNN = player:getData()
  if player:countItem(item) > 0 and player.useItem then
    if pNN.coreTimer and pNN.coreTimer > 0 then pNN.coreTimer = pNN.coreTimer - 1 end
      if player:get("hp") <= (player:get("maxhp_base") / 4) and not pNN.emergencycore and pNN.coreTimer == 0 then
        player:activateUseItem(true)
        pNN.emergencycore = true
        pNN.coreTimer = 60*60
      elseif player:get("hp") > (player:get("maxhp_base") / 4) and pNN.emergencycore then
        pNN.emergencycore = false
      end
  end
end)

-- Set the log for the item, just like the first example item
item:setLog{
	group = "uncommon",
	description = "Every 60 seconds, &b&activate your use item&!& upon falling &g&below 25% hp&!&.",
	story = "I know the clip might hurt your finger, but trust me, you'll want this.\nThe short explaination is that it monitors your well-being, and surges power to whatever it is loaded with when said well-being would be better reffered to as mal-being.\nThing is, you can load it with just about anything ;).",
	destination = "place,\nplace 2,\nNew Neptune",
	date = "idfk"
}
