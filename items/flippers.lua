local item = Item("Waterlogged Rocket-Flippers")
item.pickupText = "Gain the ability to swim!\nUse to empty the flippers, creating water at your position."

item.sprite = Sprite.load("items/spr/flippers.png", 2, 15, 15)
item.isUseItem = true
item.useCooldown = 30
item:setTier("use")

local res = {
  waterObj = Object.find("Water"),
  waterfallObj = Object.find("Waterfall"),
  waterInstances = {},
  waterSpeed = 30,
  waterAge = 7*60,

}

callback("onStep",function()
  for i, waterInst in ipairs(res.waterInstances) do
    local data = waterInst:getData()
    print(waterInst,waterInst.x,waterInst.y,data.mode)
    if data.mode == 1 then
      waterInst.y = math.max(waterInst.y - res.waterSpeed,data.riseHeight)
      if waterInst.y == data.riseHeight then data.mode = 2 end
    elseif data.mode == 2 then
      data.age = (data.age or 0) + 1
      if data.age >= res.waterAge then data.mode = 3 end
    elseif data.mode == 3 then
      waterInst.y = waterInst.y + res.waterSpeed * 3
      if waterInst.y > 4000 then
        table.remove(res.waterInstances,i)
        waterInst:destroy()
      end
    end
  end


end)

callback("onPlayerStep", function(player)
  player.useItem = Item.find("Waterlogged Rocket-Flippers")
  local data = player:getData()


  for _, w in ipairs(res.waterObj:findAll()) do
    if player.y >= w.y then data.inWater = true end
  end
  for _, w in ipairs(res.waterfallObj:findAll()) do
    local width = w:get("width_b")
    if width == 10 then width = 1 end
    if player.x >= w.x and player.y >= w.y and player.x <= w.x + 20 + 10*width and player.y <= w.y+15+w:get("height_b") then data.inWater = true end
  end

  if player.useItem == item or data.canSwim then
    if data.swimCD == 0 and data.inWater then
      if player:control("jump") == input.HELD then
        player:set("pVspeed",-5)
        data.swimCD = 20
        for i = 1,5 do
          particles.bubble:burst("above", player.x + math.random(-(i*2),(i*2)), player.y + math.random(-(i*2),(i*2)), 10)
        end
      end
    else
      data.swimCD = math.max((data.swimCD or 0)-1,0)
    end
  end
  data.inWater = false
end)

--
--pvspeed -5
item:addCallback("use", function(player, embryo)
  local waterInst = res.waterObj:create(player.x,player.y + 1000)
  local data = waterInst:getData()
  table.insert(res.waterInstances,waterInst)
  data.riseHeight,data.mode = player.y - 20, 1
  if embryo then data.riseHeight = data.riseHeight - 100 end
end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "Gives the &b&passive ability to swim&!&. Use to &b&dump swimmable water&!& from the flippers.",
	story = "",
	destination = "Prima Crater Hydroelectronics,\nKalmar II,\nNew Neptune",
	date = "1/27/2002"
}
