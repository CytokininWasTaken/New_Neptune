
if not modloader.checkFlag("NN_NoItems") then
  require("items.items")
end

if not modloader.checkFlag("NN_NoSurvivors") then
  require("survivors.survivors")
end

if not modloader.checkFlag("NN_NoArtifacts") then
  require("artifacts.artifacts")
end

if not modloader.checkFlag("NN_NoTitle") then
  local sprTitle = Sprite.load("spr/NN_title", 1, 205, 44)
	local sprTitleV = Sprite.find("sprTitle", "vanilla")
	sprTitleV:replace(sprTitle)
end
