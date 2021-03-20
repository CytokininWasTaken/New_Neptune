
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
local function getSpriteFrame(sprite, frame)
  local tSurface = Surface.new(sprite.width, sprite.height)
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

local glitchItem = {
  allItems = {},
  settings = {hSplit = 1, vSplit = 1, framesToAdd = 7, animateSpeed = 0.1, glitchPrefix = "Entropic "},
  allGlitchSprites = {},
}

function glitchItem.splitSprite(rawSprite)
  local smallSurface = Surface.new(rawSprite.width, rawSprite.height)
  graphics.setTarget(smallSurface)
  rawSprite:draw(rawSprite.xorigin, rawSprite.yorigin)
  local sprite = smallSurface:createSprite(0,0)
  graphics.resetTarget()
  smallSurface:free()
  local origin = {x = rawSprite.xorigin, y = rawSprite.yorigin}

  local width, height = sprite.width, sprite.height
  local xAdded, yAdded = 0, 0
  while width % glitchItem.settings.hSplit ~= 0 do
    width = width + 1
    xAdded = xAdded + 1
  end
  while height % glitchItem.settings.vSplit ~= 0 do
    height = height + 1
    yAdded = yAdded + 1
  end
  --print(sprite.width, sprite.height, width, height)
  local partWidth, partHeight = width/glitchItem.settings.hSplit, height/glitchItem.settings.vSplit

  spriteParts = {}
  for vIter = 1, glitchItem.settings.vSplit do
    for hIter = 1, glitchItem.settings.hSplit do
      local tSurface = Surface.new(partWidth, partHeight)
      graphics.setTarget(tSurface)
      local hExtra, vExtra = 0,0
      if hIter == glitchItem.settings.hSplit then hExtra = xAdded end
      if vIter == glitchItem.settings.vSplit then vExtra = yAdded end
      graphics.drawImage{
        x = 0, y = 0,
        image = sprite,
        --region = {
        --  math.floor((hIter - 1) * partWidth),
        --  math.floor((vIter - 1) * partHeight),
        --  math.floor(hIter * partWidth) - math.floor((hIter - 1) * partWidth) - hExtra,
        --  math.floor(vIter * partHeight) - math.floor((vIter - 1) * partHeight) - vExtra,
        --},
      }
      --graphics.resetChannels()
      table.insert(spriteParts, tSurface:createSprite(0,0))
      graphics.resetTarget()
      tSurface:free()
    end
  end
  sprite:delete()
  return spriteParts, origin
end

function glitchItem.reassemble(spriteParts, origin)
  local hSplit, vSplit = glitchItem.settings.hSplit, glitchItem.settings.vSplit
  local newSurface = Surface.new(spriteParts[1].width*hSplit,spriteParts[2].height*vSplit)
  graphics.setTarget(newSurface)
  local vLine = 0
  local hLine = 0
  for i, part in ipairs(spriteParts) do
    part:draw(0 + hLine*part.width, 0 + vLine*part.height)
    if hLine < hSplit then hLine = hLine + 1 else hLine, vLine = 0, vLine + 1 end
  end
  local madeSprite = newSurface:createSprite(0,0)
  graphics.resetTarget()
  newSurface:free()
  return madeSprite
end

function glitchItem.animateSprite(parts, origin)
  local width, height = parts[1].width * (glitchItem.settings.hSplit), parts[1].height * (glitchItem.settings.vSplit)
  local assemble = Surface.new(width+20, height+20)
  graphics.setTarget(assemble)
  ---
  local horizontalOffset, verticalOffset = 0, 0
  for i, sprite in ipairs(parts) do
    if horizontalOffset > glitchItem.settings.hSplit-1 then horizontalOffset, verticalOffset = 0, verticalOffset + 1 end
    sprite:draw(10 + horizontalOffset*sprite.width, 10 + verticalOffset*sprite.height)
    horizontalOffset = horizontalOffset + 1
  end
  ---
  local madeSprite = assemble:createSprite(origin.x+10,origin.y+10)
  graphics.resetTarget()
  assemble:free()
  local whiteFrame = math.random(1, glitchItem.settings.framesToAdd)
  for i = 1, glitchItem.settings.framesToAdd do
    tSurface = Surface.new(width+20, height+20)
    graphics.setTarget(tSurface)
    --
    horizontalOffset, verticalOffset = 0, 0
    lineOffsets = {
      [math.random(0,glitchItem.settings.vSplit)] = {offset = math.random(-10, 10)},
      [math.random(0,glitchItem.settings.vSplit)] = {offset = math.random(-10, 10)},
    }
    for i2, sprite in ipairs(parts) do
      if horizontalOffset > glitchItem.settings.hSplit-1 then horizontalOffset, verticalOffset = 0, verticalOffset + 1 end
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
    madeSprite:addFrame(tSurface)
    graphics.resetTarget()
    --graphics.setBlendMode("normal")
    tSurface:free()
  end

  doneSprite = madeSprite:finalise("NN_Glitch_"..#glitchItem.allGlitchSprites)
  table.insert(glitchItem.allGlitchSprites, doneSprite)
  return doneSprite
end


function glitchItem.make(item)
  local madeItem = Item.new(glitchItem.settings.glitchPrefix..item.displayName)
  madeItem.sprite = glitchItem.animateSprite(glitchItem.splitSprite(item.sprite))

  madeItem.color = Color.fromHex(0x99F4D2)
  madeItem.pickupText = corruptString(item.pickupText, 33)
  madeItem.displayName = corruptString(glitchItem.settings.glitchPrefix..item.displayName, 25)
  local obj = madeItem:getObject()

  obj:addCallback("step", function(self)
    local data = self:getData()
    data.subimage = (data.subimage or 0) + glitchItem.settings.animateSpeed
    self.subimage = data.subimage
  end)

  individualSpriteTable = {}
  for i = 1, madeItem.sprite.frames do
    individualSpriteTable[i] = getSpriteFrame(madeItem.sprite, i)
  end
  glitchItem.allItems[#glitchItem.allItems+1] = {item = madeItem, baseItem = item, sprites = individualSpriteTable, trueDescription = item.pickupText, trueName = glitchItem.settings.glitchPrefix..item.displayName}
end

function glitchItem.updateCounts(player)

end

callback("onPlayerStep", function(player)
  local data = player:getData()
  data.glitchItemFrame = (data.glitchItemFrame or 0) + glitchItem.settings.animateSpeed
  if data.glitchItemFrame > glitchItem.settings.framesToAdd+1 then data.glitchItemFrame = 1 end
  for _, itemData in ipairs(glitchItem.allItems) do
    if player:countItem(itemData.item) > 0 then
      player:setItemSprite(itemData.item, itemData.sprites[math.floor(data.glitchItemFrame)])
      if math.chance(20) then
        player:setItemText(itemData.item, corruptString(itemData.trueDescription,33))
      end
    end
  end

end)

callback("onPlayerDraw",function(player,x,y)
  local itemtotest = "Life Savings"
  --glitchItem.reassemble(glitchItem.splitSprite(Item.find(itemtotest).sprite)):draw(x, y - 20)
end)

iter = 1
local allItems = {}
callback("onPlayerStep", function(player)
  if iter < (#allItems) or #allItems == 0 then
    iter = iter + 1

    if #allItems == 0 then allItems = Item.findAll() end
    glitchItem.make(allItems[iter])
    print("Made item: "..allItems[iter].displayName)
  end
  if input.checkKeyboard("V") == input.PRESSED then
    table.random(glitchItem.allItems).item:create(player.x,player.y)
  end
end)
