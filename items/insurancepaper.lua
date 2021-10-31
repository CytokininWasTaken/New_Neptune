local item = Item("Danger Insurance Contract")
item.pickupText = "Narrowly dodging an attack gives you money."
item.sprite = Sprite.load("items/spr/insurancepaper.png", 1, 12, 15)
item:setTier("common")
local calcDistance = function(x1, y1, x2, y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
local p = Object.find("P")
local col = Color.fromHex(0x84D768)


registercallback("onFire", function(damager)
  if damager:get("team") == "enemy" and damager:get("target") then
    local attacker = damager:getParent()
    local targetpoi = Object.findInstance((damager:getParent():get("target")))
    local target = Object.findInstance(targetpoi:get("parent"))
    local damagerobj = damager:getObject()
    local widthX, widthY

    if target:countItem(item) > 0 then
      if damager:isExplosion() then
        widthX, widthY = 20 * damager.xscale, 5 * damager.yscale
      else
        widthX, widthY = damager:get("bullet_speed") * damager.xscale, 5 * damager.yscale
      end
      local trigger = true
      for _, v in ipairs(p:findAllRectangle(damager.x, damager.y, damager.x + widthX, damager.y + widthY)) do
        if v == target then
          trigger = false
        end
      end
      if trigger == true and math.abs(calcDistance(attacker.x, attacker.y, target.x, target.y)) > 10 and math.abs(calcDistance(damager.x + widthX/2, damager.y + widthY / 2, target.x, target.y)) < 30 then
        local heal = math.max(math.ceil((damager:get("damage_fake") * (0.5 + 0.1 * target:countItem(item) - 1)), 0))
        if heal > 0 then
          misc.damage(heal, target.x, target.y, false, col)
          target:set("hp", math.approach(target:get("hp"), target:get("maxhp_base"), heal))
        end
      end
    end
  end
end)

-- Set the log for the item, just like the first example item
item:setLog{
	group = "common",
	description = "&b&Narrowly dodging attacks &y&pays you&!&.",
	story = "Of course, Betsy, I'm sure we can work something out. But are you sure you need this?\nI mean, you haven't gotten so much as a rash in twenty years!",
	destination = "Saint Peter Retirement Home,\nOld New York,\nEarth",
	date = ""
}
