local item = Item("Chronal accelerator")
local s = {
  rewindLength = 9,
  stepRate = 3,
  itemCooldown = 60,

  doHealth = true,
  useTrueHealth = false,

  doCooldowns = false,
  useTrueCooldowns = false,
}

local rewindTime = s.rewindLength * (60 / s.stepRate)
local timer = 0

--



item:addCallback("use", function(player, embryo)
  local pNNa = player:getData().accelerator
  pNNa.timeLeft = rewindTime

end)

registercallback("onPlayerStep", function(player)
  if player.useItem == item then
    if not timer then local timer = 0 elseif timer > s.stepRate - 2 then timer = 0 else timer = timer + 1 end

    local pNNas, pNNa = player:getData().accelerator.steps, player:getData().accelerator


    if pNNa.timeLeft and pNNa.timeLeft == 0 and timer == s.stepRate - 1 then
     table.insert(pNNas, {x = player.x, y = player.y, sprite = player.sprite, subimage = player.subimage, health = player:get("hp"), shield = player:get("shield"), cooldowns = {[2] = player:getAlarm(2), [3] = player:getAlarm(3), [4] = player:getAlarm(4), [5] = player:getAlarm(5)}})
     player.alpha = 1
   end

     if pNNa.timeLeft and pNNa.timeLeft > 0 then
       player.alpha = 0
       local diff = rewindTime - pNNa.timeLeft
       local index = pNNas[#pNNas - diff]
          if index then
             player.x, player.y = index.x, index.y

             if s.doHealth and s.useTrueHealth then
               player:set("hp", index.health):set("shield", index.shield)
             elseif s.doHealth and not s.useTrueHealth then
               if index.health > player:get("hp") then
                 player:set("hp", index.health):set("shield", index.shield)

              end
             end

             if s.doCooldowns and s.useTrueCooldowns then
              for i = 2, 6 do
                if index.cooldowns[i] then

                  player:setAlarm(i, index.cooldowns[i])

                end
              end
            elseif s.doCooldowns and not s.useTrueCooldowns then
              for i = 2, 6 do
                if index.cooldowns[i] then
                  if player:getAlarm(i) > index.cooldowns[i] then
                    player:setAlarm(i, index.cooldowns[i])
                  end
                end
              end
            end

            if pNNa.timeLeft > 1 then
              pNNa.timeLeft = pNNa.timeLeft - 1
            elseif pNNa.timeLeft == 1 then
              pNNa.timeLeft = 0
              pNNa.steps = {}
            end
          else
            pNNa.timeLeft, pNNa.steps = 0, {}
          end
     end

   end
end)

registercallback("onPlayerDraw", function(player)
   if player.useItem == item then
   local pNNas, pNNa = player:getData().accelerator.steps, player:getData().accelerator
     if pNNas then
       if pNNa.timeLeft and pNNa.timeLeft > 0 then
         local diff = rewindTime - pNNa.timeLeft
         for i = - 2, 2 do
           local v = pNNas[(#pNNas - diff) + i]
           if v then
             graphics.drawImage{
               image = v.sprite,
               x = v.x,
               y = v.y,
               subimage = v.subimage,
               alpha = 1 - math.abs(i) / 5,
             }
          end
         end
       end
     end
   end
end)

registercallback("onStageEntry", function()
  for _, player in ipairs(Object.find("P"):findAll()) do
    local pNN = player:getData()
    pNN.accelerator = {}
    pNN.accelerator.steps = {}
    pNN.accelerator.timeLeft = 0
  end
end)


item.sprite = Sprite.load("items/spr/accelerator.png", 2, 15, 15)
item.isUseItem = true
item.useCooldown = s.itemCooldown
item:setTier("use")

item.pickupText = "Activate to rewind your position in time by "..tostring(s.rewindLength).." seconds."

item:setLog{
	group = "end",
	description = "Activate to rewind your position in time by &b&"..tostring(s.rewindLength).." seconds&!&.",
	story = "Figuring out how to grab this thing was a hassle. \nEach time I touched it, I got sent back to the mouth of the cave, seemingly dislodged from my path in time.\nIt even healed the wounds I attained each time I tried to claim it, so I stand by the price you called 'outrageous'.",
	destination = "Reinhold Manor,\nWarden's Well\nNew Neptune",
	date = "__/__/___",
  priority = "&r&High priority - armed escort."
}
