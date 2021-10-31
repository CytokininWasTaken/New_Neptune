
local temple = Sprite.load("tileTemple","stages/spr/Ancient Temple.png",1,0,0)
local splash = Sprite.find("WaterfallSplash","vanilla")
Sprite.load("tallMountains1","stages/spr/tallMountains1.png",1,0,-740)
Sprite.load("tallMountains2","stages/spr/tallMountains2.png",1,0,-800)
local hubSprites = {
  Sprite.load("hubSecret1","stages/spr/hubSecret1",1,0,0),
  Sprite.load("hubSecret2","stages/spr/hubSecret2",1,0,0),
}

local hiddenAreaObject = Object.new("Secret Area")
hiddenAreaObject:addCallback("step",function(self)
  self.x,self.y = self.x - self.x % 16, self.y - self.y % 16
  if self:collidesWith(misc.players[1],self.x,self.y) then
    self.alpha = math.max(self.alpha - 0.05,0.15)
  else
    self.alpha = math.min(self.alpha + 0.1, 1)
  end
end)

local hubWorld = require("stages/Space Between Spaces")

local locationalWater = Object.new("Custom Water")
local waterColourA = Color.fromHex(0xceeceb)
local waterColourB = Color.fromHex(0x7c88b8)

locationalWater:addCallback("draw",function(self)
  local data = self:getData()
  local yo,w,h = data.yoff or 0, data.width or 100, data.height or 100
  graphics.color(waterColourA) graphics.alpha(0.2)
  graphics.line(self.x,self.y+yo,self.x+w,self.y+yo)
  graphics.color(waterColourB) graphics.alpha(0.2)
  graphics.rectangle(self.x-1,self.y+yo,self.x+w-1,self.y+h)
end)

locationalWater:addCallback("step",function(self)
  local data = self:getData()
  data.timer = (data.timer or 0) + 0.015
  data.yoff = math.round(math.cos(data.timer) * 3)
  data.players = {}
  for _, player in ipairs(misc.players) do
    if player:isValid() and player.x > self.x and player.x < self.x+(data.width or 100) and player.y > self.y+data.yoff and player.y < self.y+data.yoff+(data.height or 100) then
      particles.bubble:burst("below",player.x+math.random(-2,2),player.y+math.random(-2,2),1)
      player:set("pVspeed",math.min(player:get("pVspeed"),player:get("pVspeed")*0.8))
      player:getData().inWater = true
      player.depth = self.depth +1
    else
      player.depth = -8
    end
  end
  if math.chance(50) then
    particles.bubble:burst("below",self.x+math.random(data.width or 100),self.y+data.yoff,1)
  end
end)

local waterfallSplash = Object.new("Waterfall Splash")
waterfallSplash.sprite = Sprite.find("WaterfallSplash")
waterfallSplash:addCallback("create",function(self)
  local data = self:getData()
  data.trueY = self.yd
  self.spriteSpeed,self.alpha = 0.2,0.5
end)
waterfallSplash:addCallback("draw",function(self)
  for i = 1,4 do
    graphics.drawImage{self.sprite,self.x+self.sprite.width*i,self.y,subimage=self.subimage,alpha = self.alpha}
  end
end)
waterfallSplash:addCallback("step",function(self)
  local data = self:getData()
  if data.parent and data.trueY then
    self.y = data.trueY + data.parent:getData().yoff
  end
end)


local waterfall = Object.find("Waterfall")
local stageStuff = {}
callback("onPlayerStep", function(player)
  if input.checkKeyboard("L") == input.PRESSED then
    Stage.transport(hubWorld)
  end
  if input.checkKeyboard("O") == input.PRESSED then
    player.x,player.y = 248,970
    local w = locationalWater:create(0,1120)
    local ws = waterfallSplash:create(174,1120)
    ws:getData().parent = w
    local data = w:getData()
    data.width,data.height,data.yoff = 1000,1000,0
    w.depth = 16
    stageStuff.water1 = w

    local t = hiddenAreaObject:create(48,576)
    t.sprite = hubSprites[1]
    local tt = hiddenAreaObject:create(1024,1056)
    tt.sprite = hubSprites[2]


  end

  for _, v in ipairs(waterfall:findAll()) do
    local data = v:getData()
    data.trueY = data.trueY or v.y
    if stageStuff.water1 then
      v.y = data.trueY + stageStuff.water1:getData().yoff
    end
    v.depth = 11
  end
end)

callback("onDraw",function()

end)
