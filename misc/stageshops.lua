local shop1 = Sprite.load("misc/spr/shop1", 1, 0, 0)
local collis = Object.find("BNoSpawn")
local rope = Object.find("Rope")

local drawshop = function()
  shop1:draw(4670, 1151)
  print(input.getMousePos())
end

local shopSpawnFuncs = {
  ["Desolate Forest"] = function()
    graphics.bindDepth(10, drawshop)
    for _, v in ipairs(collis:findAllRectangle(4673, 1161, 5146, 1280)) do
      v:destroy()
    end

    for i = 4673, 5148, 16 do
      collis:create(i, 1265)
    end
    for i = 4673, 4673 + 290, 16 do
      collis:create(i, 1151)
    end
    for i = 1151, 1265, 16 do
      collis:create(4673, i)
    end
    for i = 4673, 4890, 16 do
      collis:create(i, 1200)
    end
    for i = 1200, 1232, 16 do
      rope:create(4893, i)
    end

    for k, v in ipairs(Object.find("P"):findAll()) do
      v.x, v.y = 4670, 1100
    end
  end

}

registercallback("onStageEntry", function()
  local cStage = Stage.getCurrentStage()
  local name = cStage.displayName
  shopSpawnFuncs[name]()
end)
