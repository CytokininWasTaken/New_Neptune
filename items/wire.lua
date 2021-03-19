local item = Item("Collaborative Power Line")
item.pickupText = "Do your part!\nDrag cable behind you that tethers itself to the first ally that touches it.\nActivates for N seconds upon killing an enemy."

item.sprite = Sprite.load("items/spr/wire", 1, 12, 15)

local particleElectric = ParticleType.new("particleElectric")
particleElectric:shape("spark")
particleElectric:size(0.25, 0.25, 0, 0)
particleElectric:life(5, 5)
particleElectric:color(Color.fromRGB(140, 185, 215), Color.WHITE)

item:setTier("uncommon")

local wireDots = 24
local followDistance = wireDots / 5
local tetherLength = 250
local sagfactor = 150
local lineColour = Color.fromHex(0x2F3949)
local gravityFactor = 1

for i = 0, 20 do

end


local correctDots = function(player)
  local pNN, pNNw = player:getData(), player:getData().wire
  if pNNw and #pNNw > pNN.wireMaxDots then
    for i = 1, #pNNw - pNN.wireMaxDots do
      pNNw[#pNNw] = nil
    end
  elseif pNNw and #pNNw < pNN.wireMaxDots then
    for i = 1, pNN.wireMaxDots - #pNNw do
      if #pNNw > 0 then xPos, yPos = pNNw[#pNNw].x, pNNw[#pNNw].y else xPos, yPos = player.x, player.y end
      pNNw[#pNNw + 1] = {num = #pNN.wire, x = xPos, y = yPos}
    end
  end
end

local distributeDots = function(player)
  local pNN, target = player:getData(), player:getData().wireTetherTarget
  local pX, pY, tX, tY = player.x, player.y, target.x, target.y
  pNN.tetheredDots = {}
  local dX, dY = pX - tX, pY - tY
  local dist = math.ceil(calcDistance(pX,pY,tX,tY) / 10)
  for i = 0, dist do
    pNN.tetheredDots[i] = {x = pX + (dX * (i / dist)) * -1, y = ((pY + (dY * (i / dist)) * -1)) + (math.sin((i / dist) * math.pi) * (math.abs(math.ceil(calcDistance(pX,pY,tX,tY))) /10))}

  end
end

local collisTester = Object.new("NN_collisTester")

local tetherLine = function(player, target)
  local pNNw, pNN = player:getData().wire, player:getData()
  pNN.wireTetherTarget, pNN.wireTethered, pNN.dotAmountBackup = target, true, pNN.wireMaxDots
end

local untetherLine = function(player)
  local pNNw, pNN = player:getData().wire, player:getData()
  pNN.wireTetherTarget, pNN.wireTethered = nil, false

  pNN.wireMaxDots = pNN.dotAmountBackup
  correctDots(player)
end

local drawDots = function()
  for k, player in ipairs(Object.find("P"):findAll()) do
    local pNN, pNNw, pNNc = player:getData(), player:getData().wire, player:getData().collisTester
    if player:countItem(item) > 0 then
        if isa(pNNw, "table") then
          for k, v in ipairs(pNNw) do
            graphics.color(lineColour)
            --if not pNNc:collidesMap(v.x, v.y - .5) then graphics.color(Color.GREEN) else graphics.color(Color.RED) end

            if k < #pNNw then
              graphics.line(v.x, v.y, pNNw[k + 1].x, pNNw[k + 1].y, 3)
            end

          end
        end
      if pNN.wireTethered then

        graphics.color(lineColour)
        for k, v in ipairs(pNN.tetheredDots) do
          if k < #pNN.tetheredDots then
          graphics.line(v.x, v.y, pNN.tetheredDots[k + 1].x, pNN.tetheredDots[k + 1].y, 3)
          graphics.line(player.x, player.y, pNN.tetheredDots[1].x, pNN.tetheredDots[1].y, 3)
          end
        end
      end
    end

    end
end

local pickupcode = function(player)
  local pNN = player:getData()
  if not pNN.wire then
    pNN.wire = {}
  end
  pNN.collisTester = collisTester:create(player.x, player.y - 90)
  pNN.collisTester.sprite = collisTesterSprite
  pNN.wireMaxDots = wireDots
  correctDots(player)
end

registercallback("onStageEntry", function()

  local depth
  if Stage.getCurrentStage().displayName == "Dried Lake" then depth = 12 else depth = -5 end
    graphics.bindDepth(depth, drawDots)

    for k, player in ipairs(Object.find("P"):findAll()) do
      if misc.director:get("stages_passed") > 0 then
        pickupcode(player)
      end
    end
end)

registercallback("onPlayerStep", function(player)

  if input.checkKeyboard("B") == input.PRESSED then
    item:create(player.x, player.y)
  end

  local pNNw, pNNc, pNN = player:getData().wire, player:getData().collisTester, player:getData()
  if player:countItem(item) > 0 and pNNw then

    if net.online then
      for k, playerT in ipairs(Object.find("P"):findAll()) do
        if calcDistance(playerT.x, playerT.y, pNNw[#pNNw].x, pNNw[#pNNw].y) <= 20 and playerT ~= player then
          tetherLine(player, playerT)
        end
      end
    end

      if pNN.wireActive and pNN.wireActive > 0 then
        pNN.wireActive = pNN.wireActive - 1
        if not pNN.wireTimer then pNN.wireTimer = 0 elseif pNN.wireTimer > pNN.wireMaxDots * 2 - 2 then pNN.wireTimer = 0 else pNN.wireTimer = pNN.wireTimer + 1 end
            for i = 1, pNN.wireMaxDots, 20 do
              if pNNw[pNN.wireTimer + 2 - i] then
                particleElectric:burst("above", pNNw[pNN.wireTimer + 2 - i].x, pNNw[pNN.wireTimer + 2 - i].y, 1)

                local electrix = misc.fireExplosion(pNNw[pNN.wireTimer + 2 - i].x, pNNw[pNN.wireTimer + 2 - i].y, 1/19, 1/2, (player:get("damage") * 0.5) + (player:get("damage") * 0.3) * (player:countItem(item) - 1) , "player")
                electrix:set("isWireDamager", 1)
              end
          end
        end


          for k, v in ipairs(pNNw) do

            if k == 1 then
              v.x, v.y = player.x, player.y + 3
            else

              local distance = calcDistance(v.x, v.y, pNNw[v.num].x, pNNw[v.num].y)

              if distance > followDistance then
                excess, excessX, excessY = distance - followDistance, v.x - pNNw[v.num].x, v.y - pNNw[v.num].y

                  v.x = v.x - excessX * .35
                  v.y = v.y - excessY * .35

              end


              if Object.find("Water"):findNearest(v.x, v.y) and Object.find("Water"):findNearest(v.x, v.y).y < v.y then gravityFactor = -.5 else gravityFactor = 1 end
              if k > 2 then
                if not pNNc:collidesMap(v.x, v.y + 1) then  v.y = v.y + 2.5 * gravityFactor elseif not pNNc:collidesMap(v.x, v.y) then v.y = v.y + .5 * gravityFactor end
              end
            end
          end
        if pNN.wireTethered then
            pNN.wireMaxDots = ((tetherLength + 50) - calcDistance(player.x, player.y, pNN.wireTetherTarget.x, pNN.wireTetherTarget.y)) / 15
            correctDots(player)
            distributeDots(player)

            if calcDistance(player.x, player.y, pNN.wireTetherTarget.x, pNN.wireTetherTarget.y) > tetherLength or not pNN.wireTetherTarget:isValid() then
              untetherLine(player)
            end

        end
  end
end)

item:addCallback("pickup", function(player)
  pickupcode(player)
end)

registercallback("onNPCDeathProc", function(dead, player)
  if player:countItem(item) > 0 then
    local pNN = player:getData()
    pNN.wireActive = (5 * 60) + (2 * 60) * (player:countItem(item) - 1)
  end
end)

item:setLog{
	group = "uncommon",
	description = "Extends a power line behind yourself that tethers to allies. &b&Goes live upon killing an enemy.",
	story = "What's more effective than hiring an electrician to lay power lines down the mines?\nEmploying your miners, of course, through a mixture of bribes and threats.\nJust a thought, in case you feel like saving cash when the time comes.\n\n--Stu Ruther",
	destination = "ERR: DATA MISSING",
	date = "__/__/___",
  priority = "&b&Standard/Electrical"
}
