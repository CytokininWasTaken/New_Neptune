local item = Item("Mechsuit Drop Command")
item.pickupText = "its gonna be boomer moment tbh"

item.sprite = Sprite.load("items/spr/mechsuit.png", 2, 12, 15)
item.isUseItem = true
item.useCooldown = 40
item:setTier("use")

local mechSprites = {
	idle = Sprite.load("items/spr/mechsuit/idle.png", 1, 12, 15),
	walk = Sprite.load("items/spr/mechsuit/walk.png", 8, 12, 15),
	shoot1 = Sprite.load("items/spr/mechsuit/shoot1.png", 11, 12, 15),
	jump = Sprite.load("items/spr/mechsuit/jump.png", 1, 12, 15),
}

local mechSuitObj = Object.new("Macro Combat Suit")

mechSuitObj:addCallback("create", function(self)
	local selfTab = self:getData()
	selfTab.inAir, selfTab.hSpeed = 0, 0


end)

mechSuitObj:addCallback("draw", function(self)
	local drawSprite = mechSprites.idle
	local selfTab = self:getData()



	if selfTab.inAir > 0 then
		drawSprite = mechSprites.jump
	elseif selfTab.hSpeed ~= 0 then
		drawSprite = mechSprites.walk
	end

	graphics.drawImage{

		image = drawSprite,
		x = self.x,
		y = self.y,

		xscale = self.xscale,

	}
end)

--------------------------------------------------------------------------------

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
