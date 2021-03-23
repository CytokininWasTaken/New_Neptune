
local glitchSpot = Object.new("AAA_glitch")

glitchSpot:addCallback("create", function(self)
  local selfTab = self:getData()
  selfTab.surfaces = {}
  for iY = 1, 8 do
    for iX = 1, 8 do
      table.insert(selfTab.surfaces, {xNum = iX, yNum = iY, surf = Surface.new(8, 8)})
    end
  end
end)

glitchSpot:addCallback("draw", function(self)
  local selfTab = self:getData()
  graphics.color(Color.WHITE)
  --graphics.rectangle(self.x - 17, self.y - 17, self.x + 16, self.y + 16, true)

  local xR, yR = 0, 0
  local drawX, drawY = self.x - 32, self.y - 32
  for _, v in ipairs(selfTab.surfaces) do
    graphics.setTarget(v.surf)

      local nearPlayer = playerObj:findNearest(self.x, self.y)
      if nearPlayer then
        graphics.drawImage{
          image = nearPlayer.sprite,
          subimage = nearPlayer.subimage,
          x = xR,
          y = yR,
        }
      end

    graphics.resetTarget()

    v.surf:draw(drawX + 16*xR, drawY + 16*yR)
    xR = xR + 1
    if xR > 7 then
      yR, xR = yR + 1, 0
    end
    v.surf:clear()
  end

end)

local deltaMult = 0.3
callback("onCameraUpdate", function()
  for k, self in ipairs(glitchSpot:findAll()) do
    local nearPlayer = playerObj:findNearest(self.x, self.y)
    local dist = calcDistanceInsts(self, nearPlayer)
    --camera.angle = 0 + (180 - math.min(dist, 180)
    --camera.angle = 0 + math.random(-((180 - math.min(dist, 180))/500), ((180 - math.min(dist, 180))/500))
  end
end)

---------------------------------------------
---------GLITCH---------------ITEMS----------
---------------------------------------------

local surfacesMade = 0

local function getSpriteFrame(sprite, frame)
  local tSurface = Surface.new(sprite.width, sprite.height)
  surfacesMade = surfacesMade + 1
  tSurface:clear()
  graphics.setTarget(tSurface)
  graphics.drawImage{image = sprite,
    x = sprite.xorigin, y = sprite.yorigin, subimage = frame}
  local madeSprite = tSurface:createSprite(sprite.xorigin, sprite.yorigin)
  graphics.resetTarget()
  tSurface:free()
  return madeSprite:finalise(sprite.id.."_split_"..frame)
end

local corruptingChars = {"_", "-", "/", [[\]], "<", ">", "%", "#", "@", "!", "*"}
local function corruptString(string, chance)
  local newString = ""

  for i = 1, #string do
    local c = string:sub(i,i)
    if math.chance(chance) then
      newString = newString..table.random(corruptingChars)
    else
      newString = newString..c
    end
  end
  return newString
end

local glitchHandler = {
  allItems = {},
  settings = {hSplit = 3, vSplit = 6, framesToAdd = 7, animateSpeed = 0.1, glitchPrefix = "Entropic "},
  allGlitchSprites = {},
}

function glitchHandler.splitSprite(rawSprite)
  local smallSurface = Surface.new(rawSprite.width, rawSprite.height)
  surfacesMade = surfacesMade + 1
  smallSurface:clear()
  graphics.setTarget(smallSurface)
  rawSprite:draw(rawSprite.xorigin, rawSprite.yorigin)
  local sprite = smallSurface:createSprite(0,0)
  graphics.resetTarget()
  smallSurface:free()
  local origin = {x = rawSprite.xorigin, y = rawSprite.yorigin}

  local width, height = sprite.width, sprite.height
  local xAdded, yAdded = 0, 0
  while width % glitchHandler.settings.hSplit ~= 0 do
    width = width + 1
    xAdded = xAdded + 1
  end
  while height % glitchHandler.settings.vSplit ~= 0 do
    height = height + 1
    yAdded = yAdded + 1
  end
  --print(sprite.width, sprite.height, width, height)
  local partWidth, partHeight = width/glitchHandler.settings.hSplit, height/glitchHandler.settings.vSplit

  spriteParts = {}
  local tSurface = Surface.new(partWidth, partHeight)
  surfacesMade = surfacesMade + 1
  for vIter = 1, glitchHandler.settings.vSplit do
    for hIter = 1, glitchHandler.settings.hSplit do
      tSurface:clear()
      graphics.setTarget(tSurface)
      local hExtra, vExtra = 0,0
      if hIter == glitchHandler.settings.hSplit then hExtra = xAdded end
      if vIter == glitchHandler.settings.vSplit then vExtra = yAdded end
      graphics.drawImage{
        x = 0, y = 0,
        image = sprite,
        region = {
          math.floor((hIter - 1) * partWidth),
          math.floor((vIter - 1) * partHeight),
          math.floor(hIter * partWidth) - math.floor((hIter - 1) * partWidth) - hExtra,
          math.floor(vIter * partHeight) - math.floor((vIter - 1) * partHeight) - vExtra,
        },
      }
      graphics.resetChannels()
      table.insert(spriteParts, tSurface:createSprite(0,0))
      graphics.resetTarget()
    end
  end
  tSurface:free()
  sprite:delete()
  return spriteParts, origin
end

function glitchHandler.glitchFrame(parts, origin, surface, whiteFrame,madeSprite)
  surface:clear()
  graphics.setTarget(surface)
  --
  horizontalOffset, verticalOffset = 0, 0
  lineOffsets = {
    [math.random(0,glitchHandler.settings.vSplit)] = {offset = math.random(-10, 10)},
    [math.random(0,glitchHandler.settings.vSplit)] = {offset = math.random(-10, 10)},
  }
  for i2, sprite in ipairs(parts) do
    if horizontalOffset > glitchHandler.settings.hSplit-1 then horizontalOffset, verticalOffset = 0, verticalOffset + 1 end
    local extraHorizontal = 0
    if whiteFrame == i and math.chance(50) then
      --graphics.setBlendMode("additive")
      for i = 1,2 do
        graphics.drawImage{
          image = sprite,
          x = 10 + horizontalOffset*sprite.width + extraHorizontal + math.random(-2,2),
          y = 10 + verticalOffset*sprite.height + math.random(-2,2),
          color = Color.fromRGB(math.random(255),math.random(255),math.random(255))
        }
      end
    elseif lineOffsets[verticalOffset] then
      col = lineOffsets[verticalOffset].colours
      graphics.setChannels(math.chance(50), math.chance(50), math.chance(50), true)
      extraHorizontal = lineOffsets[verticalOffset].offset
    end
    graphics.drawImage{
      image = sprite,
      x = 10 + horizontalOffset*sprite.width + extraHorizontal,
      y = 10 + verticalOffset*sprite.height,
    }
    graphics.resetChannels()
    horizontalOffset = horizontalOffset + 1
  end
  if madeSprite then madeSprite:addFrame(surface) end

  graphics.resetTarget()
  return surface:createSprite(origin.x+10,origin.y+10)
end

function glitchHandler.animateSprite(parts, origin, framesToAdd)
  local separatedTableA = {}
  local width, height = parts[1].width * (glitchHandler.settings.hSplit), parts[1].height * (glitchHandler.settings.vSplit)
  local assemble = Surface.new(width+20, height+20)
  surfacesMade = surfacesMade + 1
  assemble:clear()
  graphics.setTarget(assemble)
  ---
  local horizontalOffset, verticalOffset = 0, 0
  for i, sprite in ipairs(parts) do
    if horizontalOffset > glitchHandler.settings.hSplit-1 then horizontalOffset, verticalOffset = 0, verticalOffset + 1 end
    sprite:draw(10 + horizontalOffset*sprite.width, 10 + verticalOffset*sprite.height)
    horizontalOffset = horizontalOffset + 1
  end
  ---
  local madeSprite = assemble:createSprite(origin.x+10,origin.y+10)

  table.insert(separatedTableA,assemble:createSprite(origin.x+10,origin.y+10))
  graphics.resetTarget()
  assemble:free()
  local whiteFrame = math.random(1, glitchHandler.settings.framesToAdd)
  local tSurface = Surface.new(width+20, height+20)
  surfacesMade = surfacesMade + 1

  for i = 1, glitchHandler.settings.framesToAdd do
    table.insert(separatedTableA, glitchHandler.glitchFrame(parts,origin,tSurface,whiteFrame,madeSprite))
  end

  tSurface:free()

  local separatedTableB = {}
  for i, sprite in ipairs(separatedTableA) do
    local done = sprite:finalise("NN_Glitch_"..(#glitchHandler.allGlitchSprites-1).."_"..i)
    table.insert(separatedTableB, done)
  end

  local doneSprite = madeSprite:finalise("NN_Glitch_"..#glitchHandler.allGlitchSprites)
  table.insert(glitchHandler.allGlitchSprites, doneSprite)
  return doneSprite, separatedTableB
end


function glitchHandler.makeItem(item)
  local foundItem = Item.find(glitchHandler.settings.glitchPrefix..item.displayName)
  if not foundItem then
    local madeItem = Item.new(glitchHandler.settings.glitchPrefix..item.displayName)
    madeItem.sprite, individualSpriteTable = glitchHandler.animateSprite(glitchHandler.splitSprite(item.sprite))

    madeItem.isUseItem = item.isUseItem
    madeItem.color = Color.fromHex(0x99F4D2)
    madeItem.pickupText = corruptString(item.pickupText, 33)
    madeItem.displayName = corruptString(glitchHandler.settings.glitchPrefix..item.displayName, 25)
    local obj = madeItem:getObject()
    obj:addCallback("step", function(self)
      local data = self:getData()
      data.subimage = (data.subimage or 0) + glitchHandler.settings.animateSpeed
      self.subimage = data.subimage
    end)

    glitchHandler.allItems[#glitchHandler.allItems+1] = {
      item = madeItem,
      baseItem = item,
      sprites = individualSpriteTable,
      trueDescription = item.pickupText,
      trueName = glitchHandler.settings.glitchPrefix..item.displayName,
    }

    foundItem = madeItem
  end

  return foundItem
end

function glitchHandler.updateItemCounts(player)

end

function glitchHandler.glitchAnimatedImage(image)
  local separatedImages = {}
  local xOrigin, yOrigin = image.xorigin, image.yorigin
  local tSurface = Surface.new(image.width,image.height)
  for i = 1, image.frames do
    tSurface:clear()
    graphics.setTarget(tSurface)

    graphics.drawImage{
      image = image,
      x = xOrigin, y = yOrigin,
      subimage = i,
    }

    table.insert(separatedImages, tSurface:createSprite(xOrigin,yOrigin))
    graphics.resetTarget()
    tSurface:clear()
  end
  local newSprite
  for k, sprite in ipairs(separatedImages) do
    graphics.setTarget(tSurface)
    tSurface:clear()


    if not newSprite then newSprite = "" end
  end
end

glitchHandler.glitchBurstParticle = ParticleType.new("glitchBurstParticle")
local t = glitchHandler.glitchBurstParticle
t:shape("disc")
t:direction(0,60,5,1)
t:speed(0,0,0,0)
t:size(0.12, 0.12, 0, 0)

function glitchHandler.corruptItem(instance)
  if isa(instance, "ItemInstance") then
    local baseItem = instance:getItem()
    local newItem = glitchHandler.makeItem(baseItem)
    local x, y = instance.x, instance.y
    local acc = instance:getAccessor()
    local owner, yy, pGravity, pVspeed = acc.owner, acc.yy, acc.pGravity, acc.pVspeed
    instance:destroy()

    local newInstance = newItem:create(x, y)
    newInstance.depth = 10
  end
end




callback("onPlayerStep", function(player)
  local data = player:getData()
  data.glitchHandlerFrame = (data.glitchHandlerFrame or 0) + glitchHandler.settings.animateSpeed
  if data.glitchHandlerFrame > glitchHandler.settings.framesToAdd+1 then data.glitchHandlerFrame = 1 end
  for _, itemData in ipairs(glitchHandler.allItems) do
    if player:countItem(itemData.item) > 0 then
      player:setItemSprite(itemData.item, itemData.sprites[math.floor(data.glitchHandlerFrame)])
      if math.chance(20) then
        player:setItemText(itemData.item, corruptString(itemData.trueDescription,33))
      end
    end
  end
  if input.checkKeyboard("Q") == input.PRESSED then
    for _, obj in ipairs(Object.findAll("vanilla")) do
      for _, instance in ipairs(obj:findAll()) do
        glitchHandler.corruptItem(instance)
      end
    end
  end
  if input.checkKeyboard("W") == input.HELD then
    player.sprite = glitchAnimatedImage(player.sprite)
  end
end)

--local allItems = Item.findAll()
--for _, item in ipairs(allItems) do
--  glitchHandler.makeItem(item)
--  print("Made item: "..item.displayName)
--end
--print("surfaces made: "..surfacesMade..", equaling "..surfacesMade/#allItems.." per item for "..#allItems.." items.")





--[[iter = 1
start = false
local allItems = {}
callback("onPlayerStep", function(player)
  if input.checkKeyboard("Q") == input.PRESSED then start = true end
  if start then
    if iter < (#allItems) or #allItems == 0 then
      iter = iter + 1

      if #allItems == 0 then allItems = Item.findAll() end
      glitchHandler.makeItem(allItems[iter])
      print("Made item: "..allItems[iter].displayName)
    end
    if input.checkKeyboard("V") == input.PRESSED then
      table.random(glitchHandler.allItems).item:create(player.x,player.y)
    end
  end
end)]]
