require("globals")
--require("spritecollistest")
--require("saverun")

if not modloader.checkFlag("NN_NoItems") then
  require("items.items")
end

if not modloader.checkFlag("NN_NoSurvivors") then
  require("survivors.survivors")
end

if not modloader.checkFlag("NN_NoArtifacts") then
  require("artifacts.artifacts")
end

if not modloader.checkFlag("NN_NoMisc") then
  require("misc.misc")
end

if not modloader.checkFlag("NN_NoEnemies") then
  require("enemies.enemies")
end

if not modloader.checkFlag("NN_NoGlitch") then
  require("glitch")
end

if not modloader.checkFlag("NN_NoHub") then
	require("hub")
end

if not modloader.checkFlag("NN_NoTitle") then
  local sprTitle = Sprite.load("spr/NN_title", 1, 205, 44)
	local sprTitleV = Sprite.find("sprTitle", "vanilla")
	sprTitleV:replace(sprTitle)
end

local function inputListener()
  local str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
  local inp
  for i = 1, #str do
    local c = str:sub(i,i)
    if input.checkKeyboard(c) == input.PRESSED then
      inp = c
    end
  end

  return inp
end

local function stringtonum(str)
  local newstring = ""
  for i = 1, #str do
    local c = str:sub(i,i)
    if tonumber(c) then
      newstring = newstring..c
    else
      newstring = newstring..string.byte(c)
    end
  end

  return newstring or "0"
end

local currentseed = ""..math.random(9999999)
local lastseed = currentseed
local defaultseed = currentseed
local seedMenuSelected = 0
local seedMenuInit = 0
--local seedmenu = Sprite.load("spr/seedmenu", 1, 0, 0)
--local seedmenuhigh = Sprite.load("spr/seedmenuhigh", 1, 2, 2)
-- || NUDGE || --

nudge={h=0,v=0,l=0,s=0}do local n,c,p={h={4,6},v={2,8},l={1,9},s={3,7}},input.checkKeyboard,function(k)print("Nudge "..string.upper(k)..": "..nudge[k])end registercallback("globalStep",function()local i=c("control")==2 and 10 or 1 for k,v in pairs(n)do if c("numpad"..v[1])==3 then nudge[k]=nudge[k]-i p(k)end if c("numpad"..v[2])==3 then nudge[k]=nudge[k]+i p(k)end end end)end
-- || NUDGE || --
local function mainMenu()

  local width, height = graphics.getHUDResolution()
  local mX, mY = input.getMousePos(true)
  local dcX, dcY = width/2 + nudge.h -46, 70 + nudge.v + 293

  if seedMenuSelected > 0 or seedMenuInit == 1 then
    --seedmenuhigh:draw(dcX, dcY)
    if inputListener() then
      if currentseed == defaultseed then
        currentseed = ""
      end
      currentseed = currentseed..inputListener()
    elseif input.checkKeyboard("backspace") == input.PRESSED then
      currentseed = currentseed:sub(1, #currentseed - 1)
    end
    if currentseed ~= lastseed or seedMenuInit == 1 then
      misc.setRunSeed(math.max(tonumber(stringtonum(currentseed)) or 0, 1))
      lastseed = currentseed
    end
  end
  if input.checkMouse("left") == input.PRESSED then
    if (mX >= dcX and mX <= dcX + 170 and mY >= dcY and mY <= dcY + 21) then
      if seedMenuSelected == 1 then seedMenuSelected = 0 else seedMenuSelected = 1 end
    else
      seedMenuSelected = 0
    end
  end
  graphics.color(Color.fromHex(0x1C1B23))
  graphics.alpha(0.6)
  graphics.rectangle(dcX, dcY, dcX + graphics.textWidth("Seed: "..currentseed, graphics.FONT_DEFAULT) + 7, dcY + graphics.textHeight("S", graphics.FONT_DEFAULT))
  if (mX >= dcX and mX <= dcX + 170 and mY >= dcY and mY <= dcY + 21) or seedMenuSelected > 0 then
    graphics.color(Color.fromHex(0xEFD27B))
  else
    graphics.color(Color.fromHex(0xC0C0C0))
  end
  graphics.alpha(1)
  graphics.print("Seed: "..currentseed, dcX + 7, dcY + 3)



end

callback("globalRoomStart", function(room)
  if tostring(room) == "<Room:Vanilla:Start>" then
    seedMenuInit = 1
    graphics.bindDepth(-1, mainMenu)
  end
end)

local parentsAll = {ParentObject.find("enemies")}
local parentsToAdd = {
		Object.find("B"),
		Object.find("BNoSpawn"),
		Object.find("BNoSpawn2"),
		Object.find("BNoSpawn3"),
}

for k,v in ipairs(parentsToAdd) do
		parentsAll[#parentsAll + 1] = v
end
local parents = {}
for k,v in pairs(parentsAll) do
		table.insert(parents, v)
end

function getOrderedNamespaces()
	local namespaces = { [1] = "vanilla" }
	for i,v in ipairs(modloader.getMods()) do
		namespaces[i+1] = v
	end
	return namespaces
end

function swapTable(t)
	local new_table = {}
	for key,value in pairs(t) do
		new_table[value] = key
	end
	return new_table
end

function raycastCustom(x,y,dx,dy,lineFunction,limited,precision)
	if lineFunction(x,y,0,0) then return x, y end
	local _x,_y = x,y
	local _maxD = 0
	if limited then
		_maxD = math.sqrt(dx^2 + dy^2)
	else
		local _maxW, _maxH = Stage.getDimensions()
		_maxD = math.sqrt(_maxW^2 + _maxH^2) * 2
	end
	--math functions use physics coordinates
	local _angle = math.atan2(-dy,dx)*(180/math.pi)
	local _fx, _fy = _x + _maxD * math.cos(_angle * (math.pi/180)), _y - _maxD * math.sin(_angle * (math.pi/180))
	local precision = precision or 0.5
	local _sx, _sy = dx > 0, dy > 0
	while math.sqrt((_fx - _x)^2 + (_fy - _y)^2) > precision do
		local __x, __y, __fx, __fy = 0,0,0,0
		if _sx then __x = math.floor(_x) ; __fx = math.ceil(_fx)
		else __x = math.ceil(_x) ; __fx = math.floor(_fx) end
		if _sy then __y = math.floor(_y) ; __fy = math.ceil(_fy)
		else __y = math.ceil(_y) ; __fy = math.floor(_fy) end
		if lineFunction(__x,__y,(__fx-__x)/2,(__fy-__y)/2)
		then _fx = _fx - (_fx-_x)/2 ; _fy = _fy - (_fy-_y)/2
		else _x = _x + (_fx-_x)/2 ; _y = _y + (_fy-_y)/2
		end
	end
	return _x,_y
end
--

function iLDT(x,y,dx,dy) --iLDT = "intersectsLineDifferentTeam"
		for _,object in ipairs(parents) do
				for _,instance in ipairs(object:findAllLine(x,y,x+dx,y+dy)) do
						if (not isa(instance, "ActorInstance")) or (instance:get("team") ~= "player") then return true end
				end
		end
		return false
end

function nullRay(x,y,dx,dy)
	for _,object in ipairs(parents) do
			for _,instance in ipairs(object:findAllLine(x,y,x+dx,y+dy)) do
					if (not isa(instance, "ActorInstance")) or (instance:get("team") == "201203102301230123012301203") then return true end
			end
	end
	return false
end

callback("onPlayerHUDDraw", function(player)

end)

function angleRay(x, y, angle)
	local x2 = x + math.sin(math.rad(angle + 90)) * 50
	local y2 = y + math.cos(math.rad(angle + 90)) * 50
	local wallX, wallY = raycastCustom(x,y,x2-x,y2-y,nullRay)
	return wallX, wallY
end

function calcDistanceInsts(i1, i2) if (not i2) or (not i1) then return 0 else return math.sqrt((i2.x - i1.x) ^ 2 + (i2.y - i1.y) ^ 2) end end

local direction = 0
local roundingTolerance = 10
local precision = 50
local plob = Object.find("P")
local timer = 0
local stepPerFrame = 8
local points = {}
local scanDistance = 200
local rope = Object.find("Rope")
local ropes = {}

local objEfOutline = Object.find("EfOutline", "vanilla")
local tOutline

local actorPObj = ParentObject.find("actors")
local sonarColour = Color.GREEN
local backColor = Color.fromHex(0x000000)

local function echolocationv1()
  --graphics.setChannels(false, true, false, true)
  --sonarColour = Color.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
  --backColor = Color.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
  if input.checkKeyboard("P") ~= input.HELD then
    local player = plob:find(1)
    local data = player:getData()

    graphics.color(backColor)
    local width, height = Stage.getDimensions()
    graphics.rectangle(0, 0, width, height)
    graphics.color(sonarColour)
    local i1, i2 = {}, {}
    for i = 1, stepPerFrame, 1 do

      direction = direction + 1
      local wX, wY = angleRay(player.x, player.y - 10, direction)
      local xyTab = {x = wX, y = wY}

      if i == 1 then i1 = xyTab
      elseif i == stepPerFrame then i2 = xyTab end
      points[direction] = xyTab
      local tempRope = rope:findLine(player.x, player.y, player.x + math.sin(math.rad(direction + 90)) * 1000, player.y + math.cos(math.rad(direction + 90)) * 1000)
      if tempRope then
        ropes[tempRope.id] = tempRope
      end


    end
    for _, instance in pairs(ropes) do
      if instance and instance:isValid() then
        local dist = calcDistanceInsts(player, instance)
        graphics.alpha(120/dist)
        graphics.rectangle(instance.x, instance.y, instance.x + 2, instance.y + instance:get("height_box")*16, true)
      end
    end
    graphics.alpha(0.7)
    graphics.triangle(i1.x, i1.y, i2.x, i2.y, player.x, player.y + 8 - player:getAnimation("idle").height, true)
    graphics.alpha(1)
    if direction >= 360 then
      direction = 0
    end
    graphics.alpha(0.2)
    graphics.circle(player.x, player.y, timer * 3, true)
    graphics.alpha(1)
    for index, pointSet in ipairs(points) do
      local previousPos = points[index-1]
      if previousPos then
        graphics.alpha(120/calcDistanceInsts(player, pointSet))
        graphics.line(pointSet.x, pointSet.y, previousPos.x, previousPos.y)
      end
    end
  end
end

--[[local distance = 400
local collisionObjects = {Object.find("B"), Object.find("BNoSpawn"), Object.find("BNoSpawn2"), Object.find("BNoSpawn3")}
local function echolocationv2()
  local player = plob:find(1)
  local foundColliders = {}
  for _, object in ipairs(collisionObjects) do
    for __, instance in ipairs(object:findAllEllipse(player.x - distance, player.y - distance, player.x + distance, player.y + distance)) do
      table.insert(foundColliders, instance)
    end
  end
  graphics.color(backColor)
  local width, height = Stage.getDimensions()
  graphics.rectangle(0, 0, width, height)
  graphics.drawImage{x = player.x, y = player.y, image = player.sprite, subimage = player.subimage, xscale = player.xscale, color = Color.WHITE}
  graphics.color(Color.WHITE)
  for _, collider in ipairs(foundColliders) do
    local boxWidth, boxHeight = collider:get("width_box"), collider:get("height_box")
    graphics.color(Color.WHITE)
    graphics.rectangle(collider.x, collider.y, collider.x + boxWidth*16, collider.y + boxHeight*16, true)
    graphics.color(Color.BLACK)
    graphics.rectangle(collider.x+1, collider.y+1, collider.x-1 + boxWidth*16, collider.y-1 + boxHeight*16, false)
  end
end]]

local additionalObjects = {
  ParentObject.find("mapObjects"),
  Object.find("FireTrail"),
  Object.find("ChainLightning"),
  Object.find("EfMissileEnemy"),
  Object.find("EfGrenadeEnemy"),
  Object.find("JellyMissile"),
  Object.find("WispBMine"),
  Object.find("MushDust"),
  Object.find("SpitterBullet"),
  Object.find("BugBullet"),
  Object.find("SpiderBullet"),
  Object.find("GuardBullet"),
  Object.find("ScavengerBullet"),
  Object.find("IfritBullet"),
  Object.find("IfritTower"),
  Object.find("ImpGLaser"),
  Object.find("ImpPortal"),
  Object.find("TurtleMissile"),
  Object.find("Boss1Shield"),
  Object.find("BossSkill1"),
  Object.find("BossSkill2"),
  Object.find("Boss1Bullet1"),
  Object.find("WurmMissile"),
  Object.find("ChefKnife"),
  Object.find("CowboyDynamite"),
  Object.find("HuntressBolt1"),
  Object.find("HuntressBoomerang"),
  Object.find("HuntressBolt2"),
  Object.find("HuntressBolt3"),
  Object.find("HuntressGrenade"),
  Object.find("EngiGrenade"),
  Object.find("EngiMine"),
  Object.find("EngiHarpoon"),
  Object.find("EngiTurret"),
  Object.find("PoisonTrail"),
  Object.find("FeralDiseaseMaster"),
  Object.find("FeralDisease"),
  Object.find("FeralDisease"),
  Object.find("Dot2"),
  Object.find("RiotGrenade"),
  Object.find("SniperBar"),
  Object.find("SniperDrone"),
  Object.find("ConsHand"),
  Object.find("ConsRod"),
  Object.find("JanitorBaby"),
  Object.find("JanitorGauge"),
  Object.find("Teleporter"),
  Object.find("TeleporterFake"),
  Object.find("Base"),
  Object.find("Geyser"),
  Object.find("EfExp"),
  Object.find("EfGold"),
  Object.find("EfHeal"),
  Object.find("EfHeal2"),
  Object.find("SuckerPacket"),
  Object.find("EfDeskPlant"),
  Object.find("EfBrain"),
  Object.find("EfBomb"),
  Object.find("EfLantern"),
  Object.find("EfSawmerang"),
  Object.find("EfThqwib"),
  Object.find("Home"),
  Object.find("EfChestRain"),
  Object.find("EfDecoy"),
  Object.find("EfTNTStick"),
  Object.find("EfBubbleShield"),
  Object.find("EfBlizzard"),
  Object.find("EfMeteorShower"),
  Object.find("EfSmite"),
  Object.find("EfWarbanner"),
  Object.find("EfMissile"),
  Object.find("EfMissileSmall"),
  Object.find("EfMissileMagic"),
  Object.find("EfMissileBox"),
  Object.find("JellyMissileFriendly"),
  Object.find("EfMine"),
  Object.find("EfPoisonMine"),
  Object.find("EfPoison2"),
  Object.find("EfMortar"),
  Object.find("EfSticky"),
  Object.find("EfNugget"),
  Object.find("Dot"),
  Object.find("EfSpikestrip"),
  Object.find("EfFirework"),
  Object.find("EfThorns"),
  Object.find("EfLightningRing"),
  Object.find("EfPoison"),
  Object.find("EfMushroom"),
  Object.find("EfIceCrystal"),
  Object.find("EfMark"),
  Object.find("EfScope"),
  Object.find("EfFireworkBurst"),
  Object.find("EfJetpack"),
  Object.find("EffFlies"),
  Object.find("EfLaserBlast"),
  Object.find("EfStun"),
  Object.find("EfFear"),
  Object.find("EfOil"),
  Object.find("EfLevel"),
  Object.find("Buff"),
  Object.find("CustomBar"),
  Object.find("EfSparks"),
  Object.find("EfBullet2"),
  Object.find("MinerDust"),
  Object.find("EfCircle"),
  Object.find("EfFlash"),
  Object.find("WhiteFlash"),
  Object.find("EfTrail"),
  Object.find("EfDodge"),
  Object.find("EfDamage"),
  Object.find("BugGuts"),
  Object.find("BossText"),
  Object.find("EfDust1"),
  Object.find("EfDust2"),
  Object.find("EfRay"),
  Object.find("EfRayFront"),
  Object.find("Waterfall"),
  Object.find("Pod"),
  Object.find("PodBehind"),
  Object.find("MinerPod"),
  Object.find("PigBeach"),
  Object.find("object415"),
  Object.find("Deadman"),
  Object.find("FeralCage"),
  Object.find("BlockDestroy"),
  Object.find("BlockDestroy2"),
  Object.find("ArtifactButton"),
  Object.find("MushroomButton"),
  Object.find("GlowingRope"),
  Object.find("ArtifactNoise"),
  Object.find("SpawnArtifact2"),
  Object.find("Blastdoor"),
  Object.find("BlastdoorRight"),
  Object.find("BlastdoorPanel"),
  Object.find("HologramProjector"),
  Object.find("Barrel3"),
  Object.find("Door"),
  Object.find("Sign"),
  Object.find("Medcab"),
  Object.find("GunChest"),
  Object.find("Gauss"),
  Object.find("GaussActive"),
  Object.find("Medbay"),
  Object.find("MedbayActive"),
  Object.find("Usechest"),
  Object.find("UsechestActive"),
  Object.find("HiddenHand"),
  Object.find("DancingGolem"),
  Object.find("WallArtifact"),
  Object.find("Screen"),
  Object.find("RainSplash"),
  Object.find("B"),
}

local function giveOutline(actor, alpha)
  local data = actor:getData()
  local depth = -11
  if actor:getObject() == plob then alpha, depth = 1, -13 end
  if data.outline and data.outline:isValid() then
    data.outline:destroy()
    data.outline = nil
  end
  actor.depth = depth
  data.outline = objEfOutline:create(actor.x, actor.y)
  data.outline:set("parent", actor.id)
  data.outline.depth = actor.depth + 1
  data.outline.blendColor = sonarColour
  data.outline.alpha = alpha
  actor.blendColor = backColor
  graphics.drawImage{
    x = actor.x, y = actor.y, image = actor.sprite, subimage = actor.subimage, xscale = actor.xscale, color = backColor
  }
end

local function outlineManager()
  for _, actor in ipairs(actorPObj:findAll()) do
    giveOutline(actor, 120/calcDistanceInsts(actor, plob:findNearest(actor.x, actor.y)))
  end
  for _, object in ipairs(additionalObjects) do
    for __, actor in ipairs(object:findAll()) do
      giveOutline(actor, 120/calcDistanceInsts(actor, plob:findNearest(actor.x, actor.y)))
    end
  end
end

--callback("onDraw", outlineManager)

callback("onPlayerDrawAbove", function()
  --graphics.setChannels(true, true, true, true)
end)

callback("onStageEntry", function()
  --graphics.bindDepth(-9, echolocationv1)
end)
