collisTesterSprite = Sprite.load("spr/collis", 1, 0, 0)
blankbar = Sprite.load("spr/blankbar", 1, 1, 6)

particles = {
  SporeOld = ParticleType.find("SporeOld"),
}

enemies = ParentObject.find("enemies")
playerObj = Object.find("P")

nnColours = {
  tgYellow = Color.fromHex(0xEFEDA0),
  tgLime = Color.fromHex(0x8BCB45),
  tgGray = Color.fromHex(0x768398),
  tgGreen = Color.fromHex(0x9BB593),
}

--Custom Objectss

collisTesterObj = Object.new("Collision Tester")
collisTesterObj.sprite = collisTesterSprite

collisTesterObj:addCallback("draw", function(self)
  local selfTab = self:getData()
  if selfTab.parent and selfTab.parent:isValid() then
    self.alpha = 0
    self.x, self.y = selfTab.parent.x, selfTab.parent.y + 40
  else
    self:destroy()
  end
end)

--Puffball
puffball = Object.new("Puffball")
puffball.sprite = Sprite.load("survivors/spr/fungus/puffball", 1, 2, 2)

puffball:addCallback("step", function(self)
	local pbt = self:getData()

  if not pbt.set then
  	pbt.vspeed, pbt.vgrav = 1, 0.1
  	if pbt.parent then pbt.damage = pbt.parent:get("damage") end
    pbt.set = true
  end
	self.x = self.x + 3*self.xscale
	self.y = self.y - pbt.vspeed
	pbt.vspeed = pbt.vspeed - pbt.vgrav
	particles.SporeOld:burst("above", self.x, self.y, 3)
	local nearest = enemies:findNearest(self.x, self.y)
		if nearest and (self:collidesWith(nearest, self.x, self.y) and nearest:get("team") ~= pbt.parent:get("team") ) or self:collidesMap(self.x, self.y)  then
			pbt.parent:fireExplosion(self.x, self.y, 4/19, 4/4, 1)
			self:destroy()
		end
end)

--

-- Lightning Ball ( Projectile system?)
  lightningBall = Object.new("Ball of Lightning")
  lightningBall.sprite = Sprite.load("survivors/spr/guard/lightningball", 4, 16, 16)
  lightningBall.depth = 12

  electroBoom = Sprite.load("survivors/spr/guard/lightningball_explode", 6, 33, 34)

  lightningBall:addCallback("create", function(self)
    local selfTab = self:getData()
    selfTab.angle = math.rad(15)
    selfTab.velocity = 2.2
    selfTab.subImgCounter = 1
    selfTab.scale = 0
    selfTab.growSpeed, selfTab.animSpeed = 0.05, 0.2
    self.xscale, self.yscale = selfTab.scale, selfTab.scale
    self.subimage = selfTab.subImgCounter
    selfTab.shouldMove = true
    selfTab.parent = playerObj:findNearest(self.x, self.y)
    selfTab.collisTester = collisTesterObj:create(self.x, self.y)
    selfTab.collisTester:getData().parent = self
  end)

  lightningBall:addCallback("step", function(self)
    local selfTab = self:getData()
    if selfTab.shouldMove then
      self.x, self.y = self.x + math.cos(selfTab.angle) * selfTab.velocity, self.y + math.sin(selfTab.angle) * selfTab.velocity
    end
    if selfTab.subImgCounter > self.sprite.frames + 1 then
      selfTab.subImgCounter = 1
    else
      selfTab.subImgCounter = selfTab.subImgCounter + selfTab.animSpeed
    end
    selfTab.scale = math.min(selfTab.scale + selfTab.growSpeed, 1)
    self.xscale, self.yscale = selfTab.scale, selfTab.scale
    self.subimage = selfTab.subImgCounter
    if math.ceil(self.subimage) == 1 then
      selfTab.parent:fireExplosion(self.x, self.y, 50/19, 20/4, 1.5)
    end
    if self:collidesWith(playerObj:findNearest(self.x, self.y), self.x, self.y) then
      playerObj:findNearest(self.x, self.y):applyBuff(overcharged, 6 * 60)
    end
    if selfTab.collisTester:collidesMap(self.x, self.y) then
      selfTab.parent:fireExplosion(self.x, self.y, 50/19, 20/4, 5, electroBoom)
      self:destroy()
    end
  end)
--

--Spawnmanager

resurrected = {}
spawnmanager = Object.new("spawnmanager")

spawnmanager:addCallback("create", function(self)
	local selftab = self:getData()
	selftab.timer = 0
end)

spawnmanager:addCallback("draw", function(self)
	local selftab = self:getData()
	if selftab.sprite then
		graphics.drawImage{
			image = selftab.sprite,
			x = self.x,
			y = self.y,
			subimage = math.max(selftab.sprite.frames - selftab.timer, 1),
			xscale = self.xscale,
		}
		graphics.drawImage{
			image = selftab.sprite,
			x = self.x,
			y = self.y,
			subimage = math.max(selftab.sprite.frames - selftab.timer, 1),
			xscale = self.xscale,
			color = rezcol,
			alpha = rezop
		}
		selftab.timer = selftab.timer + 0.2
		if selftab.timer > selftab.sprite.frames then
			local spawned = selftab.obj:create(self.x, self.y)
			spawned:set("team", selftab.player:get("team"))
			spawned:applyBuff(fungalDecay, 29 / fungalDecaySpeed)
			table.insert(resurrected, spawned)
			self:destroy()
		end
	end
end)
--

--General useful functions

calcDistanceInsts = function(i1, i2) if (not i2) or (not i1) then return 0 else return math.sqrt((i2.x - i1.x) ^ 2 + (i2.y - i1.y) ^ 2) end end
calcDistance = function(x1, y1, x2, y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
findNearestTable = function(table, x, y, maxdist, exclude, excludeval, autoexclude)
  local distance = maxdist
  local nearest, keytodel

  for _, v in ipairs(table) do
    local excluded = false
    if exclude then
      for __, v2 in ipairs(exclude) do
        if v == v2 then excluded = true end
      end
    end
    if calcDistance(v.x, v.y, x, y) < distance and not excluded and not v[excludeval] then
      distance = calcDistance(v.x, v.y, x, y)
      nearest = v
      v[excludeval] = true
    end
  end
  return nearest
end
calcAngleInsts = function(i1, i2)
  local angle = math.deg(math.atan2(i1.y - i2.y, i2.x - i1.x))
	if angle < 0 then
	angle = angle + 360
	end
  return angle
end
calcAngle = function(x1, y1, x2, y2)
  local angle = math.deg(math.atan2(y1 - y2, x2 - x1))
	if angle < 0 then
	angle = angle + 360
	end
  return angle
end

predictAngleMovement = function(startX, startY, radian, velocity, velocityDecay, lineWidth)
  local dX, dY = startX, startY
  local player = playerObj:findNearest(startX, startY)
  local calcedGrav = 0
  local dotTable = {}
  lineWidth = lineWidth or 1
  for i = 1, velocity / velocityDecay do
    if velocity > 0 then
    dX, dY = dX + math.cos(radian) * velocity, dY - math.sin(radian) * velocity
    dY = dY + calcedGrav
    calcedGrav = calcedGrav + 0.26
    velocity = velocity - velocityDecay
    table.insert(dotTable, {x = dX, y = dY})
    if player:collidesMap(dX, dY - 7) then break end
    end
  end
  for i, v in ipairs(dotTable) do
    if i % 2 == 0 and i < #dotTable -1 then
      graphics.line(v.x, v.y, dotTable[math.min(i + 1, #dotTable)].x, dotTable[math.min(i + 1, #dotTable)].y, lineWidth)
    end
    if i == #dotTable then
      graphics.circle(v.x, v.y, 8, true)
      graphics.circle(v.x, v.y, 3, false)
    end
  end
end

--

--Custom Buffs

overcharged = Buff.new("NN_OverCharged")

overcharged.sprite = collisTesterSprite --Sprite.load("spr/buffs/overcharge", 1, 9, 7000)

local isOvercharged = {}

registercallback("onStageEntry", function()
  isOvercharged = {}
end)

overcharged:addCallback("start", function(self)
  isOvercharged[self.id] = self
end)

overcharged:addCallback("end", function(self)
  isOvercharged[self.id] = nil
end)

overcharged:addCallback("step", function(self)
  if self:getAlarm(2) > 1 then
    self:setAlarm(2, self:getAlarm(2) - 2)
  end
end)
--buff Drawing Stuff

local buffDrawFunc = function()
  for _, player in pairs(isOvercharged) do
    if player:hasBuff(overcharged) then
      graphics.drawImage{
        player.sprite,
        player.x - 1 * player.xscale, player.y,
        subimage = player.subimage,
        xscale = player.xscale,
        scale = 1.2 + math.random(20) / 100,
        color = Color.YELLOW,
      }
    end
  end
end



registercallback("onStageEntry", function()
  graphics.bindDepth(-7, buffDrawFunc)
end)

--


--

--Custom charge bars

customBars = {}
createCustomBar = function(name, initargs)
  customBars[name] = {sprite = blankbar, color = Color.WHITE, subimage = 1, width = 29, height = 4, xOffset = -14, yOffset = 20}
  if initargs and type(initargs) == "table" then
    for k, v in pairs(initargs) do
      customBars[name][k] = v
    end
  end
  customBars[name].draw = function(table, dx, dy, value, maxvalue)
    local t = table
    local fraction = value / maxvalue
    local cx, cy = dx + t.xOffset, dy + t.yOffset
    graphics.color(table.color)
    graphics.rectangle(cx, cy, cx + t.width * fraction, cy + t.height)

    graphics.drawImage{
      image = t.sprite,
      x     = cx,
      y     = cy,
    }
    return fraction * 100
  end

  return customBars[name]
end

--drawCustomBar =

--

registercallback("onHit", function(damager)

  if damager:get("NN_maxHit") and damager:get("hit_number") > damager:get("NN_maxHit") + 1 then
    damager:set("damage", 0)
  end
end)

--   [[Global Input Manager]]

local tableVals = function(table)
  local sum = ""
    for _, v in pairs(table) do
      sum = sum..tostring(v)
    end
  return sum
end

local inputManager = {}
local inputOld = {}

callback("onPlayerInit", function(p)
  for _, player in ipairs(playerObj:findAll()) do
    inputManager[player] = {0, 0, 0, 0}
    inputOld[player] = inputManager[player]

  end
end)

local sendInputsFunc = function(playerWhoSent, playerInQuestion, ...)
  local args = {...}
  if not isa(playerInQuestion, "PlayerInstance") then playerInQuestion = playerInQuestion:resolve() end
  if net.host then
    inputManager[playerInQuestion] = args
    sendInputs:sendAsHost(net.ALL, nil, playerInQuestion:getNetIdentity(), table.unpack(inputManager[playerInQuestion]))
  else
    inputManager[playerInQuestion] = args
  end
end

sendInputs = net.Packet("Input Manager", sendInputsFunc)

callback("onPlayerStep", function(player)
  if net.online and player == net.localPlayer then
    inputManager[player] = {player:control("ability1"), player:control("ability2"), player:control("ability3"), player:control("ability4")}

    if tableVals(inputManager[player]) ~= tableVals(inputOld[player]) then
      inputOld[player] = inputManager[player]
      if net.host then
        sendInputs:sendAsHost(net.ALL, nil, player:getNetIdentity(), table.unpack(inputManager[player]))
      else
        sendInputs:sendAsClient(player:getNetIdentity(), table.unpack(inputManager[player]))
      end
    end
  elseif not net.online then
    inputManager[player] = {player:control("ability1"), player:control("ability2"), player:control("ability3"), player:control("ability4")}
  end
end)

mpCtrl = function(player, skillNum)
  return inputManager[player][skillNum]
end

--   [[END OF GLOBAL INPUT MANAGER]]

-- CAMERA WOOO
  callback("onPlayerStep", function(player)
    print(player:get("outside_screen"))
    player:set("outside_screen", 0)
  end)

  callback("onCameraUpdate", function()

    local player = playerObj:findNearest(0, 0)
    if player and input.checkKeyboard("G") ~= 0 then
      camera.x, camera.y = player.x - camera.width / 2, player.y - camera.height / 2
      --[[camera.angle, player.yscale = 180, -1
      if player:control("left") > 0 then player:set("moveLeft", 0):set("moveRight", 1) end
      if player:control("right") > 0 then player:set("moveLeft", 1):set("moveRight", 0) end]]
    end
  end)

--

--
