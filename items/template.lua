local item = Item("name")
item.pickupText = "."

item.sprite = Sprite.load("items/spr/flippers.png", 2, 12, 15)
item.isUseItem = true
item.useCooldown = 40
item:setTier("use")

item:addCallback("use", function(player, embryo)

end)

registercallback("onPlayerStep", function(player)

end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "",
	story = "",
	destination = "",
	date = ""
}
