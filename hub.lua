woodlandTileset = Sprite.load("woodlandTileset", "stages/Woodland.png", 1, 0, 0)

local hubWorld = require("stages/Tranquil Zone")


callback("onPlayerStep", function(self)
  if input.checkKeyboard("L") == input.PRESSED then
    Stage.transport(hubWorld)
  end
end)

local firstTimeInHub = not save.read("hasVisitedHub")

local hubHelper = Object.base("EnemyClassic", "hubHelper")

hubHelperAnimations = {
  walk = Sprite.load("nn_hubHelperWalk", "spr/hubResources/hubHelper_walk", 7, 11, 13),
  idle = Sprite.load("nn_hubHelperIdle", "spr/hubResources/hubHelper_idle", 1, 11, 13),
  jump = Sprite.load("nn_hubHelperJump", "spr/hubResources/hubHelper_jump", 1, 11, 13),
}
hubHelperAnimations.death = hubHelperAnimations.idle
hubHelper.sprite = hubHelperAnimations.idle
hubHelper:addCallback("step", function(self)
  local data = self:getData()
  if not data.initialized then
    self:setAnimations(hubHelperAnimations)
    self:set("team", "player"):set("target", misc.players[1].id)
    data.initialized = true
    data.subimage = 0
  end
end)

hubHelper:addCallback("draw", function(self)
  --graphics.print(self.subimage, self.x, self.y - 20)
end)

local mapObject = ParentObject.find("mapObjects")
local geyser = Object.find("Geyser")
local robotTeleporter = Object.base("mapObject","robotTeleporter")
local robotTpSprite = Sprite.load("nn_hubTeleporter","spr/hubResources/hubTp", 1, 22, 28)
local robotTpOutline = Sprite.load("nn_hubTeleporterOutline", "spr/hubResources/hubTpOutline", 1, 22, 28)
robotTeleporter.sprite = robotTpSprite
robotTeleporter:addCallback("step", function(self)
  local data = self:getData()
  if not data.initialized then
    data.outlineSprite = robotTpOutline
    data.initialized = true
  end

end)
robotTeleporter:addCallback("draw", function(self)
  local data = self:getData()
  if data.initialized then
    data.outlineSprite:draw(self.x, self.y)
  end
end)

local function initializeHub()
  for _, player in ipairs(misc.players) do
    player.x, player.y = 2211, 922
  end
  for _, object in ipairs(mapObject:findAll()) do
    if object:getObject() ~= geyser then
      object:destroy()
    end
  end
  if modloader.checkMod("Starstorm") then
    local thingsToDelete = {"EscapePod", "Shrine6", "Activator", "MimicChest"}
    for index, string in ipairs(thingsToDelete) do
      thingsToDelete[index] = Object.find(string, "Starstorm")
    end
    for _, object in ipairs(thingsToDelete) do
      for __, instance in ipairs(object:findAll()) do
        instance:destroy()
      end
    end
  end

  robotTeleporter:create(2348, 928)
  if firstTimeInHub then
    --local helperInst = hubHelper:create(2348, 928-7)
    --helperInst.xscale = -1
    --local data = helperInst:getData()
    --data.destination = {2211, 922}
  end
end

local delayCounter = 0
callback("onStageEntry", function()
  if Stage.getCurrentStage() == hubWorld then
    for _, player in ipairs(misc.players) do
      player:getData().hubInitialized = false
      delayCounter = 0
      player.x, player.y = 2211, 922
    end
  end
end)

local black = Object.find("Black")

callback("onPlayerStep", function(player)
  local data = player:getData()
  local stage = Stage.getCurrentStage()
  delayCounter = math.min(delayCounter + 1, 16)
  if stage == hubWorld then
    if net.host and not data.hubInitialized then
      if delayCounter > 15 then
        initializeHub()
        data.hubInitialized = true
      end
    end
    if delayCounter <= 4 then
      black:create(player.x, player.y)
    end
  else
    data.hubInitialized = false
  end
end)
