local item = Item("Expanding Stropharia")
item.pickupText = "Activate to spread spores around the screen that explode for 600% damage."

item.sprite = Sprite.load("items/spr/fungus.png", 2, 15, 15)
item.isUseItem = true
item.useCooldown = 60
item:setTier("use")

local trackrad = 60
local explosionsize = 40
local explodetime = 40

local clustercount = 20
local enemies = ParentObject.find("enemies")
local sporesprite = Sprite.load("items/spr/funguspart.png", 1, 4, 4)
local sporecluster = Object.new("strophariaobj")
local clusters = {}
local poisonpart = ParticleType.find("SporeOld")


local drawfunc = function()
	for _, v in ipairs(clusters) do
		if v:isValid() then
			local clst = v:getData()
			for i = 1, 5 do
				graphics.drawImage{
					image = sporesprite,
					x	= v.x + clst.spots[i].Xpos,
					y = v.y + clst.spots[i].Ypos,
					angle = clst.spots[i].angle,
					alpha = v.alpha
				}
				clst.spots[i].angle = clst.spots[i].angle + 0.5
			end
		end
	end
end

registercallback("onStageEntry", function() graphics.bindDepth(-7, drawfunc) clusters = {} end)

sporecluster:addCallback("create", function(self)
	table.insert(clusters, self)
	local clst = self:getData()
	clst.spots = {}
	for i = 1, 5 do
		clst.spots[i] =	{Xpos = math.random(-100, 100) / 10, Ypos = math.random(-100, 100) / 10, angle = math.random(0, 360)}
	end
end)

sporecluster:addCallback("step", function(self)
	local clst = self:getData()
	if not clst.isdespawning then
		self.alpha = self.alpha + 0.1
		if self.alpha > explodetime then
			clst.isdespawning = true
			misc.fireExplosion(self.x, self.y, (1/19) * explosionsize, (1/4) * explosionsize, self:get("damage") * 6, "player"):set("poison_dot", 10)
			for i = 1, 200 do
				poisonpart:burst("above", self.x + math.random(-10, 10), self.y + math.random(-10, 10), 1)
			end
		end
	else
		self.alpha = math.clamp(self.alpha - 0.1, 0, 2)
	end
		clst.target = enemies:findEllipse(self.x - trackrad, self.y - trackrad, self.x + trackrad, self.y + trackrad)

		local speedc = 200
		local deltaX, deltaY = 0, 0
		if clst.target and clst.target:isValid() then
			self:set("pHspeed",clst.target:get("pHspeed")):set("pVspeed", clst.target:get("pVspeed"))
			deltaX, deltaY = clst.target.x - self.x, clst.target.y - self.y
			speedc = calcDistanceInsts(self, clst.target) / 3
		elseif (self.alpha < 100) then
			deltaX, deltaY = clst.targets.x - self.x, clst.targets.y - self.y
		end
		if not clst.isdespawning then self.x, self.y = self.x + deltaX / 200, self.y + deltaY / 200 end

	if clst.isdespawning and self.alpha == 0 then

		self:destroy()
	end
end)

item:addCallback("use", function(player, embryo)
	local mult
	if embryo then mult = 2 else mult = 1 end
	for i = 1, clustercount * mult do
		math.randomseed(os.time() * i)
		spawnX, spawnY = player.x + math.random(-400, 400), player.y + math.random(-250, 200)
		local cluster = sporecluster:create(player.x, player.y)
		local clst = cluster:getData()
		clst.targets = {x = spawnX, y = spawnY}
		cluster.alpha = math.random(-500, -100) / 100
		cluster:set("damage", player:get("damage"))
	end
end)


-- Set the log for the item, just like the first example item
item:setLog{
	group = "use",
	description = "&r&Spread spores&!& around the screen that &r&explode for 600% damage&!& and &b&poison victms&!&.",
	story = [[[TRANSLATED] "You're telling me this is our culprit? A sophisticated poisoning scheme, concocted by a ******* mushroom!? Looks like something I'd put in my stew, the thing does. Frankly, private, I think you're full of shit."

[ORIGINAL] ,::;___: ;;:  ^^**^ _---__--:;# ><|> ERR: Unable to fetch UNTRANSLATED information]],
	destination = "SPOR-Corp Fungi Research group,\nNE Corpo District\nLilia 46P1",
	date = "DATE INFORMATION NOT SUPPLIED",
	priority = "&or&Extremely Volatile/Biological",
}
