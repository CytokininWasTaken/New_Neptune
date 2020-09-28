local artifact = Artifact.new("Shared Items")
artifact.unlocked = true

artifact.loadoutSprite = Sprite.load("artifacts/spr/prey2.png", 2, 18, 18)
artifact.loadoutText = "Picking up an item gives it to every player."

callback("onItemPickup", function(item, player)
  if artifact.active then
    for _, player2 in ipairs(misc.players) do
      print(net.localPlayer, player, player2, not(player2 == player))
      if not(player2 == player) then
        player2:giveItem(item:getItem(), 1)
      end
    end
  end
end)
