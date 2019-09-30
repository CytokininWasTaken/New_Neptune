local calcDistanceSpots = function(x1, y1, x2, y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
local calcDistanceInsts = function(i1, i2) return math.sqrt((i2.x - i1.x) ^ 2 + (i2.x - i1.x) ^ 2) end

local prey = Artifact.new("Prey")
prey.unlocked = true

prey.loadoutSprite = Sprite.load("artifacts/spr/prey.png", 2, 18, 18)
prey.loadoutText = "Something is attracted to you gaining power."

local prov = Object.find("Boss2Clone")

local createHunter = function(player)
    local pNN = player:getData()
pNN.preyArtifact.hunter = prov:create(player.x, player.y):set("targetPlayer", player.id)
end

registercallback("onPlayerInit", function(player)
  if prey.active then
    local pNN = player:getData()
    pNN.preyArtifact = {}
    player:set("level", 4)
  end
end)

registercallback("onPlayerLevelUp", function(player)
  if prey.active then
    if player:get("level") % 5 == 0 then
      createHunter(player)
    end
  end
end)

registercallback("onPlayerStep", function(player)
  if prey.active then
    local pNN = player:getData()
    local hunter = pNN.preyArtifact.hunter

    if hunter and hunter:isValid() then
      if calcDistanceInsts(hunter, Object.findInstance(hunter:get("targetPlayer"))) > 50 then
        if hunter:get("state") == "attack1" then
        hunter.x, hunter.y = player.x + 15 * player.xscale, player.y
        end
      end
    end
    if input.checkKeyboard("H") == input.PRESSED then
      createHunter(player)
    end
  end
end)

registercallback("onPlayerDraw", function(player)
  if prey.active then
    local pNN = player:getData()
    local hunter = pNN.preyArtifact.hunter
    if hunter and hunter:isValid() then
      graphics.print(hunter:get("state"), hunter.x, hunter.y - 20)
    end
  end
end)
