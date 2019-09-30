local item = Item("Cursed Scepter")
item.pickupText = "Doubles your cooldowns.\nAllows using skills on cooldown, for the price of health."

damagefactor = 0.025

item.sprite = Sprite.load("items/spr/cursedscepter", 1, 14, 13)
item:setTier("rare")
local numtoskill = {"z", "x", "c", "v"}
local recharging = {}

registercallback("onPlayerStep", function(player)
  if player:countItem(item) > 0 then
    local alarmtab = {-1, player:getAlarm(3), player:getAlarm(4), player:getAlarm(5)}
    for k, v in pairs(alarmtab) do
      if v > -1 and recharging[k] ~= true then
        recharging[k] = true
        v = v * 2
        player:setAlarm(k + 1, v)
      elseif v <= 0 and recharging[k] == true then
        recharging[k] = false
      end
    end

    for i = 2, 4 do
      if player:control("ability"..i) == input.PRESSED and player:getAlarm(i + 1) > 0 and player:get("activity_type") == 0 then
        local damagevar = player:getAlarm(i + 1) * damagefactor * (player:get("maxhp_base") / 100)
        player:set("hp", player:get("hp") - damagevar)
        misc.damage(damagevar, player.x - 10 + math.random(10), player.y - 10, false, Color.RED)
        player:setAlarm(i + 1, -1)
        recharging[i] = false
      end
    end
  end
end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "rare",
	description = "&r&Doubles your cooldowns&!&, but &b&abilities can be used on cooldown using health&!&.",
	story = "...They called me crazy, they called me immoral. A monster. All they'll do now is beg for mercy.\nElectrical power from the nerve signals caused by pain. Who's going to stop me when their suffering only fuels me?\nThe pain you've imagined when reading this has only empowered me more.",
	destination = "",
	date = ""
}
