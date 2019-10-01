local item = Item("Expanding Stropharia")
item.pickupText = "Activate to spread spores around the screen that poison enemies."

item.sprite = Sprite.load("items/spr/fungus.png", 2, 12, 15)
item.isUseItem = true
item.useCooldown = 75
item:setTier("use")

local enemyparentobj = ParentObject.find("enemies")
local enemymaxnum = 5

local sporecluster = Object.new("strophariaobj")

sporecluster:addCallback("step", function(self)

end)

item:addCallback("use", function(player, embryo)
	local tabofenemies, targets = enemyparentobj:findAll(), {}
	if #tabofenemies > enemymaxnum then maxnum = enemymaxnum else maxnum = #tabofenemies end

	for i = 1, maxnum do
		targets[i] = table.random(tabofenemies)
	end
end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "",
	story = "",
	destination = "",
	date = ""
}
