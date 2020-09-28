print("Items loaded.")
--
local items = {"mechsuit", "flippers", "wire", "accelerator", "emergencypower", "umbraessence", "cursedphylactery", "suctionboots", "stropharia", "crystalblood", "spool", "necrovial", "insurancepaper", "orrery"}

for _, v in ipairs(items) do
  if not modloader.checkFlag("NN_DisableItem_"..v) then
    require("items."..v)
  end
end
