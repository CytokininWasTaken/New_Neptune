print("Sprite collis test loaded")

local collisthing = Sprite.load("spr/collistestersprite", 1, 0, 0)

local spriteobj = Object.new("Test thing")
spriteobj.sprite = collisthing
local playerobj = Object.find("P")

spriteobj:addCallback("step", function(self)
  local player = playerobj:findNearest(self.x, self.y)

  if player then
    if self:collidesWith(player, self.x, self.y) then
      self.alpha = 0.5
    else
      self.alpha = 1
    end
  end
end)
