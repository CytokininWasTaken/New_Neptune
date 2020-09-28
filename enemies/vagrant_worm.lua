print("Vagrant Worm loaded")
local body = {
  main = Sprite.load("enemies/spr/jellywormbody", 1, 16, 16),
  head = Sprite.load("enemies/spr/jellywormhead", 1, 20, 20)
}


local vars = {
  sections = 10,
  followdist = 5,
  deltaMult = 0.1,

}

local bodyTarget = Object.find("Lizard")

vagrantworm = Object.new("Vagrant Worm")

vagrantworm:addCallback("create", function(self)
  local sT = self:getData()
  sT.parts = {}

  for i = 1, vars.sections do
    sT.parts[i + 1] = {spr = body.main, x = self.x, y = self.y, target = bodyTarget:create(self.x, self.y), angle = 0}
  end
  sT.parts[1] = {spr = body.head, x = self.x, y = self.y, target = bodyTarget:create(self.x, self.y), angle = 0}

end)

vagrantworm:addCallback("draw", function(self)
  local sT = self:getData()

  for i, v in ipairs(sT.parts) do
    local vt = v.target
    vt:set("pVspeed", 0):set("pHspeed", 0):set("pGravity1", 0):set("pGravity2", 0):set("state", "idle")
    if i == 1 then
      local self = Object.find("P"):findNearest(0, 0)
      v.x, v.y = self.x, self.y
      vt.x, vt.y = v.x, v.y
    else
      if math.abs(calcDistanceInsts(vt, sT.parts[i - 1].target)) > vars.followdist then
        local dx, dy = v.x - sT.parts[i - 1].target.x, vt.y - sT.parts[i - 1].target.y
        v.x, v.y = v.x - dx * vars.deltaMult, vt.y - dy * vars.deltaMult
        vt.x, vt.y = v.x, v.y
        v.angle = calcAngleInsts(v, sT.parts[i - 1])
      end
    end
    graphics.drawImage{
      image = v.spr,
      x = v.x,
      y = v.y,
      angle = v.angle or 0,

    }
  end
end)
