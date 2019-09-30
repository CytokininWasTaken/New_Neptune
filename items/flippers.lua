local item = Item("Waterlogged Rocket-Flippers")
item.pickupText = "Gain the ability to swim!\nUse to empty the flippers, creating water at your position."

item.sprite = Sprite.load("items/spr/flippers.png", 2, 15, 15)
item.isUseItem = true
item.useCooldown = 40
item:setTier("use")

local waterSink = function(target, height, player)
  target.y = target.y + 5
  if target.y > player.y + 400 then
    target:destroy()
  end
end

local waterGrow = function(target, height, player)
  if not target or not target:isValid() then return end
  if target:get("done") ~= 1 then
    if target.y > height then
      target.y = target.y - 5
    end
    if target.y <= height then
      target:set("done", 1)
    end
  end

  if target:get("done") == 1 and target:get("donedone") ~= 1 then
    if target:get("age") == nil then
      target:set("age", 0)
    elseif target:get("age") < 600 then
      target:set("age", target:get("age") + 1)
    elseif target:get("age") >= 300 then
      target:set("donedone", 1)
    end
  end

  if target:get("donedone") == 1 then
    waterSink(target, height, player)
  end
end

local swimEff = function(player, type, factor)
  player:set("pVspeed", -5 * factor):set("swimCD", 20)
  for i = 1, 5 do
    ParticleType.find("Bubble", "vanilla"):burst("above", player.x + 1 * math.random(i, i*2), player.y + 1 * math.random(i*2), 10)
    player:set("lastswim", type)
  end
end

item:addCallback("use", function(player, embryo)
  if SpawnedWaterInst and SpawnedWaterInst:isValid() then
    SpawnedWaterInst:destroy()
  end

  local times = 1

  if embryo then
    times = times + 1
  end

  SpawnedWaterInst = Object.find("Water"):create(player.x, player.y + 400)
  SpawnedWaterTarget = player.y

  if embryo then
    SpawnedWaterTarget = player.y - 100
  end
end)

registercallback("onPlayerStep", function(player)
  if player.useItem == item then
    if SpawnedWaterInst and SpawnedWaterInst:isValid() then
        waterGrow(SpawnedWaterInst, SpawnedWaterTarget, player)
      end

    if player:get("swimCD") and player:get("swimCD") > 0 then
      player:set("swimCD", player:get("swimCD") - 1)
    elseif player:get("swimCD") == nil then
        player:set("swimCD", 0)
    end

      local waterInst = Object.find("Water"):findNearest(player.x, player.y)

      if waterInst and waterInst:isValid() and player.y >= waterInst.y and input.checkControl("jump", player) == input.HELD and player:get("swimCD") <= 0 then
        swimEff(player, "Water", 1)

      elseif Object.find("Waterfall"):findNearest(player.x, player.y) and player.x >= Object.find("Waterfall"):findNearest(player.x, player.y).x and player.x <= Object.find("Waterfall"):findNearest(player.x, player.y).x + 18 and input.checkControl("jump", player) == input.HELD and player:get("swimCD") <= 0 then
        swimEff(player, "Waterfall", 0.8)
      end
      if waterInst and player:get("lastswim") == "Water" and waterInst:isValid() and player.y < waterInst.y and player:get("swimCD") > 0 then
        player:set("pVspeed", -5):set("swimCD", 0)
    end
  end
end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "Gives the passive ability to swim.\nUse to dump the water from the flippers, creating swimmable water.",
	story = "Okay, these are really confusing. Somehow, they're filled with an infinite amount of water, or at least a seemingly infinite amount?\nI thought, however, that if anyone could make use out of these, it's you.",
	destination = "Prima Crater Hydroelectronics,\nKalmar II,\nNew Neptune",
	date = "1/27/2002"
}
