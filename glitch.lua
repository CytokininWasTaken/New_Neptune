
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
