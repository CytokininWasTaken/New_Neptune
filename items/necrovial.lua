local item = Item("Necromaniac's Vial")
item.pickupText = "Enter a death trance for 5 seconds. Dying during the effect heals you fully and deals massive damage to nearby enemies.\nFailing to die kills you."

item.sprite = Sprite.load("items/spr/necrovial", 2, 12, 15)
local wings = Sprite.load("items/spr/vialrevive", 19, 55, 43)
item.isUseItem = true
item.useCooldown = 15
item:setTier("use")
local necromaniacwings = Object.new("necrowing")
local duration = 5 * 60

necromaniacwings:addCallback("create", function(self)
  local wingTab = self:getData()
  wingTab.timer = 1
end)

necromaniacwings:addCallback("draw", function(self)
  local wingTab = self:getData()
  wingTab.timer = wingTab.timer + 0.15
  self.x, self.y = wingTab.target.x, wingTab.target.y
  graphics.drawImage{
    image = wings,
    subimage = wingTab.timer,
    x = self.x,
    y = self.y
  }
  if wingTab.timer > 19 then
    self:destroy()
  end
end)

item:addCallback("use", function(player, embryo)
  local factor
  if embryo then factor = 2 else factor = 1 end
  local pNN = player:getData()
  pNN.deathTranceTimer = duration * factor
end)

registercallback("onPlayerStep", function(player)
  local pNN = player:getData()
  if pNN.deathTranceTimer and pNN.deathTranceTimer > 1 then
    pNN.deathTranceTimer = pNN.deathTranceTimer - 1
  end
  if pNN.deathTranceTimer and pNN.deathTranceTimer == 1 then
    if player:get("hp") > 0 then
      pNN.deathTranceTimer = 0
      player:kill()
    end
  end
  if input.checkKeyboard("N") == 3 then
    necromaniacwings:create(player.x, player.y):getData().target = player
  end
end)

registercallback("onHit", function(damager, victim)
  if isa(victim, "PlayerInstance") then
    local dam = damager:get("damage")
    local damagereduction = victim:get("armor")/(victim:get("armor")+100)
    if victim:getData().deathTranceTimer and victim:getData().deathTranceTimer > 1 then
      if victim:get("hp") <= dam - (dam * damagereduction) then
        damager:set("damage", 0)
        necromaniacwings:create(victim.x, victim.y):getData().target = victim
        victim:set("hp", victim:get("maxhp_base"))
        victim:getData().deathTranceTimer = 0
        victim:fireExplosion(victim.x, victim.y, 2, 2, 10):set("knockback", 5)
      end
    end
  end
end)

-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "For &y&5 seconds&!&, dying &g&revives you&!& and &r&damages nearby enemies&!&. &b&Failing to die kills you&!&.",
	story = "",
	destination = "",
	date = ""
}
