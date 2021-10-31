local item = Item("Cursed Phylactery")
item.pickupText = "Allows using skills on cooldown, for the price of health."
damagefactor = 0.025
item.sprite = Sprite.load("items/spr/cursedscepter", 1, 14, 13)
item:setTier("rare")

registercallback("onPlayerStep", function(player)
  if player:countItem(item) > 0 then
    for i = 2, 4 do
      if player:control("ability"..i) == input.PRESSED and player:getAlarm(i + 1) > 0 and player:get("activity_type") == 0 then
        local damagevar = player:getAlarm(i + 1) * damagefactor * (player:get("maxhp_base") / 100)
        player:set("hp", player:get("hp") - damagevar)
        misc.damage(damagevar, player.x - 10 + math.random(10), player.y - 10, false, Color.RED)
        player:setAlarm(i + 1, -1)
      end
    end
  end
end)

item:setLog{
	group = "rare",
	description = "&b&Your abilities can be used on cooldown at the cost of health&!&.",
	story = "...They called me crazy, they called me immoral. A monster. All they'll do now is beg for mercy.\nElectrical power from the nerve signals caused by pain. Who's going to stop me when their suffering only fuels me?\nThe pain you've imagined when reading this has only empowered me more.",
	destination = "",
	date = ""
}
