print("Items loaded.")
--
local items = {"flippers", "wire", "accelerator", "emergencypower", "umbraessence", "cursedscepter", "suctionboots", "stropharia",}

for _, v in ipairs(items) do
  require("items."..v)
end
