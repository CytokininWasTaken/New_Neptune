local item = Item("Black Thread Spool")
item.pickupText = "Upon killing an enemy, there is a 10% chance that the enemy closest to it instantly dies."

item.sprite = Sprite.load("items/spr/spool.png", 1, 12, 15)
item:setTier("rare")

local deathtimer = Buff.new("deathtimer")
deathtimer.sprite = Sprite.load("items/spr/threadanimation.png", 10, 5, 5)
deathtimer.subimage = 1
deathtimer.frameSpeed = 0.15

deathtimer:addCallback("end", function(self)
  self:kill()
end)


local calcDistanceInsts = function(i1, i2) return math.sqrt((i2.x - i1.x) ^ 2 + (i2.y - i1.y) ^ 2) end
local enemies = ParentObject.find("enemies")
local findNearestOther = function(self)
  local dist, chosen = 999999, nil
  for _, v in ipairs(enemies:findAll()) do
    if v ~= self and calcDistanceInsts(self, v) < dist then
      dist, chosen = calcDistanceInsts(self, v), v
    end
  end
  return chosen
end


registercallback("onNPCDeathProc", function(npc, player)
  if (not npc:getData().noDeathProc) and math.chance(player:countItem(item) * 10) then
    local newTarget = findNearestOther(npc)
      if newTarget and newTarget:isValid() then
        print(npc, newTarget)
        newTarget:getData().noDeathProc = true
        newTarget:applyBuff(deathtimer, 60 * 0.8)
      end
  end
end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "",
	story = "",
	destination = "",
	date = ""
}
