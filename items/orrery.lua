local item = Item("Ancient Orrery")
item.pickupText = "."

item.sprite = Sprite.load("items/spr/orrery.png", 1, 12, 15)
item:setTier("rare")

local planetInfo = {
  {name = "Mercury", damage = 0.3, speed = 8, dist = 35},
  {name = "Venus", damage = 0.5, speed = 7, dist = 55},
  {name = "Earth", damage = 0.7, speed = 6, dist = 75},
  {name = "Mars", damage = 0.9, speed = 5, dist = 95},
  {name = "Jupiter", damage = 1.2, speed = 4, dist = 115},
  {name = "Saturn", damage = 1.4, speed = 3, dist = 135},
  {name = "Uranus", damage = 1.6, speed = 2, dist = 155},
  {name = "Neptune", damage = 1.8, speed = 1, dist = 175},
}

local efCircle = Object.find("EfCircle")
local planetSprite = Sprite.load("items/spr/planets.png", 8, 20, 20)
local orreryPlanet = Object.new("Orrery Planet")
orreryPlanet.sprite = planetSprite

orreryPlanet:addCallback("create", function(self)
local selfTab = self:getData()
if not selfTab.parent then
  selfTab.parent = Object.find("P"):findNearest(self.x, self.y)
end
selfTab.orbitCounter = 0
selfTab.planet = math.random(8)
end)

local orbit = function(self)
  local selfTab = self:getData()
  local cX, cY = selfTab.parent.x, selfTab.parent.y
  local angle = selfTab.orbitCounter
  local inf = planetInfo[selfTab.planet]

  self.x = cX + math.cos(math.rad(angle)) * inf.dist
  self.y = cY + math.sin(math.rad(angle)) * inf.dist
  return angle + inf.speed / 4
end

orreryPlanet:addCallback("step", function(self)
  local selfTab = self:getData()

  selfTab.orbitCounter = orbit(self)

  if selfTab.orbitCounter % 5 == 0 then
    efCircle:create(self.x, self.y)
  end
  self.subimage = selfTab.planet
  self.angle = self.angle + planetInfo[selfTab.planet].speed / 10
end)

callback("onPlayerDraw", function(player, px, py)
  if input.checkKeyboard("J") == input.PRESSED then
    for i =  1, #planetInfo do
      orreryPlanet:create(player.x, player.y):getData().planet = i

    end
  end
  for i = 1, #planetInfo do
    graphics.alpha(0.2)
  --  graphics.circle(px, py, planetInfo[i].dist, true)
  end
end)

item:setLog{
	group = "rare",
	description = "Killing enemies makes planets orbit you.",
	story = "The planetarium is on its way, but do keep in mind that you'll need to replace some cogs.\nIt's awfully slow, and needs to be cranked every seven seconds lest it stops.\nOh, and moons aren't included, but if you need them we can probably arrange a special delivery.",
	destination = "",
	date = ""
}
