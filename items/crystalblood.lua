local calcDistanceInsts = function(i1, i2) return math.sqrt((i2.x - i1.x) ^ 2 + (i2.y - i1.y) ^ 2) end
local item = Item("Crystalized Blood")
item.pickupText = "Wile active, damaging nearby enemies deals 40% extra damage and heals you.\nWhen item deactivates, all extra damage dealt is applied to all nearby enemies."
item.sprite = Sprite.load("items/spr/crystalizedblood.png", 2, 12, 15)
local bloodcrystaleff = Sprite.load("items/spr/bloodcrystaleff", 1, 30, 69)
item.isUseItem = true
item.useCooldown = 10
item:setTier("use")
local dist = 60
local growstep = 2

local damagefactor = 1.4
local enddamagefactor = 1
local duration = 10
local circleDrawFunc = function()
	for _, v in ipairs(Object.find("P"):findAll()) do
    local pNN = v:getData()
    if pNN.crystalBloodTimer and pNN.crystalBloodSize > 0 then

      graphics.color(Color.RED)
  		graphics.circle(v.x, v.y, pNN.crystalBloodSize, true)
  		graphics.alpha(0.2)
  		graphics.circle(v.x, v.y, pNN.crystalBloodSize, false)
      for i = 0, 360, 45 do
        graphics.drawImage{
          image = bloodcrystaleff,
          x = v.x,
          y = v.y,
          angle = i + pNN.crystalBloodTimer,
          scale = pNN.crystalBloodSize / 60
        }
      end

    end
	end
end

item:addCallback("use", function(player, embryo)
  local factor
  if embryo then factor = 2 else factor = 1 end
  local pNN = player:getData()
  pNN.crystalBloodTimer = duration * 60 * factor
  pNN.crystalBloodGrowing = true
  pNN.crystalBloodSize = 0
  pNN.crystalBloodDamageTotal = 0
end)

registercallback("onPlayerStep", function(player)
  local pNN = player:getData()
    if pNN.crystalBloodTimer and pNN.crystalBloodTimer > 0 then
      pNN.crystalBloodTimer = math.approach(pNN.crystalBloodTimer, 0, -1)
    end
    if pNN.crystalBloodGrowing and pNN.crystalBloodSize < dist then
      pNN.crystalBloodSize = math.approach(pNN.crystalBloodSize, dist, growstep)
    elseif pNN.crystalBloodSize and pNN.crystalBloodSize > 0 and pNN.crystalBloodTimer <= 0 then
      if pNN.crystalBloodSize == dist then
        misc.fireExplosion(player.x, player.y, 1/19 * dist, 1/4 * dist, pNN.crystalBloodDamageTotal * enddamagefactor, "player")
      end
      pNN.crystalBloodGrowing = false
      pNN.crystalBloodSize = math.approach(pNN.crystalBloodSize, 0, -growstep)
    end
end)

registercallback("onStageEntry", function()
	graphics.bindDepth(-6, circleDrawFunc)
end)

registercallback("onHit", function(damager, victim, hitX, hitY)
  if isa(damager:getParent(), "PlayerInstance") then
    local pNN = damager:getParent():getData()

    if pNN.crystalBloodTimer and pNN.crystalBloodTimer > 0 then
      if calcDistanceInsts(damager:getParent(), victim) < dist + 5 then
        pNN.crystalBloodDamageTotal = pNN.crystalBloodDamageTotal + damager:get("damage") * (damagefactor - 1)
        damager:set("damage", damager:get("damage") * damagefactor):set("lifesteal", 1)
        damager:set("damage_fake", damager:get("damage") * damagefactor + math.random(-1, 1))
      end
    end
  end
end)

item:setLog{
	group = "use",
	description = "For "..duration.." seconds, &r&close combat is more effective&!&.\n On end, &b&damages all nearby enemies&!&.",
	story = "",
	destination = "",
	date = ""
}
