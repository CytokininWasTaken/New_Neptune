local allItems = {}

callback("onStageEntry",function()
  for _, mod in ipairs(modloader.getMods()) do
    for _, item in ipairs(Item.findAll(mod)) do
      table.insert(allItems,item)
    end
  end
  for _, item in ipairs(Item.findAll("vanilla")) do
    table.insert(allItems,item)
  end
end)

local function saveItems()
  local player = net.localHost or misc.players[1]
  local itemCounts = {}
  for _, item in ipairs(allItems) do
    local count = player:countItem(item)
    if count > 0 then
      table.insert(itemCounts, {item:getName(),item:getOrigin(),count})
    end
  end
  return itemCounts
end

callback("onStep",function()
  if input.checkKeyboard("M") == input.PRESSED then
    local saveData = saveItems()
    for _, data in ipairs(saveData) do
      print(data)
    end
    save.write("SAVE_DATA",json.encode(saveData))
  end
  if input.checkKeyboard("N") == input.PRESSED then
    Sprite.load("big",1,1,1)
  end
end)

print(json.decode(save.read("SAVE_DATA") or "{}"))
