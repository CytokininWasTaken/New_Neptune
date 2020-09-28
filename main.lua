require("globals")
--require("spritecollistest")

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

local teststage = require("stages/TESTTIME")

callback("onPlayerStep", function(self)
  if input.checkKeyboard("L") == input.PRESSED then
    Stage.transport(teststage)
  end
end)

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
