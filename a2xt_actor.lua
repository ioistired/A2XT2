-- STILL SUPER WIP
local costumes = API.load("a2xt_costumes")
local message  = API.load("a2xt_message")

local animatx = API.load("animatx")
local rng = API.load("rng")

local a2xt_actor = {}


function a2xt_actor.onInitAPI()
	registerEvent (a2xt_actor, "onTick")
	registerEvent (a2xt_actor, "onDraw")
end



--*********************
--** Enums           **
--*********************
a2xt_actor.EMOTE = {
                    VICTORY = 1,
                    ANGER = 2,
                    SHOCK = 3,
                    SAD = 4,
                    HAPPY = 5,
                    NOTAMUSED = 6,
                    CONFUSED = 7
                   }


--***************************
--** Actor class           **
--***************************
local Actor = {}
local allActors = {}


function Actor.__index(obj,key)
	if     (key == "sprite")  then
		return (obj.sprites[1])


	elseif (key == "accelX") then
		return (obj._accelX)
	elseif (key == "accelY") then
		return (obj._accelY)
	elseif (key == "frictionX") then
		return (obj._frictionX)
	elseif (key == "frictionY") then
		return (obj._frictionY)


	elseif (key == "grounded")  then
		local result = obj.y >= obj.groundY and {true} or {false}
		return result[1]


	elseif (key == "_type") then
		return "a2xt actor";

	elseif (key == "meta") then
		return Actor;

	else
		return rawget(Actor, key)
	end
end


local instReadonly = {width=1, height=1, sprite=1}

function Actor.__newindex(obj,key,val)

	if     (instReadonly[key] ~= nil)  then 
		error ("The Actor class' "..key.." property is read-only.");


	elseif (key == "direction") then
		if  val == DIR_LEFT  then
			obj._direction = -1
		elseif  val == DIR_RIGHT  then
			obj._direction = 1
		else
			obj._direction = rng.randomEntry{-1,1}
		end

	elseif (key == "accelX") then
		obj._frictionX = 0
		obj._accelX = val
		obj:StopWalking()
	elseif (key == "accelY") then
		obj._frictionY = 0
		obj._accelY = val
		obj:StopWalking()
	elseif (key == "frictionX") then
		obj._accelX = 0
		obj._frictionX = val
		obj:StopWalking()
	elseif (key == "frictionY") then
		obj._accelY = 0
		obj._frictionY = val
		obj:StopWalking()


	elseif (key == "_type") then
		error("Cannot set the type of Actor objects.",2);

	else
		-- Basic rawset
		rawset(obj, key, val);
	end
end


--*************************************
--** Actor create function           **
--*************************************
function Actor.create(args, preset)
	-- Create
	local p = {};

	-- Assign the animset argument to the one in args if necessary 
	if  args.preset ~= nil  then
		preset = args.preset
	end


	-- Display properties
	local sprTable = args.sprites
	if  type(args.sprites) ~= "table"  then
		sprTable = {args.sprites}
	end
	local offsetTable = args.offsets
	if  type(args.offsets) ~= "table"  then
		offsetTable = {args.offsets}
	end

	p.sprites = {}
	p.offsets = {}
	for k,v in pairs(sprTable) do
		p.sprites[k] = v
	end
	for k,v in pairs(offsetTable) do
		p.offsets[k] = v
	end

	p.scale      = args.scale      or  1
	p.squash     = args.squash     or  0
	p.animSpeed  = args.animSpeed  or  1

	p.animFixed  = false
	p.animFrozen = false
	p._direction = 1
	p.mirrored   = false

	p.floatAmount = args.floatAmount  or  0


	-- Animation state/frame presets (standardized for the player character sheets)
	p.moveAnims   = {}
	if  args.moveAnims ~= nil  then
		p.moveAnims.walk      = args.moveAnims.walk       or  1
		p.moveAnims.carryWalk = args.moveAnims.carryWalk  or  2
		p.moveAnims.air       = args.moveAnims.air        or  3
		p.moveAnims.carryAir  = args.moveAnims.carryAir   or  4

		p.moveAnims.victory   = args.moveAnims.victory    or  5
		p.moveAnims.angry     = args.moveAnims.angry      or  5
		p.moveAnims.shock     = args.moveAnims.shock      or  5
		p.moveAnims.sad       = args.moveAnims.sad        or  5
	end
	p.moveFrames  = {}
	if  args.moveFrames ~= nil  then
		p.moveFrames.stand      = args.moveFrames.stand       or  1
		p.moveFrames.duck       = args.moveFrames.duck        or  2
		p.moveFrames.rise       = args.moveFrames.rise        or  1
		p.moveFrames.fall       = args.moveFrames.fall        or  2

		p.moveFrames.victory    = args.moveFrames.victory     or  1
		p.moveFrames.angry      = args.moveFrames.angry       or  2
		p.moveFrames.shock      = args.moveFrames.shock       or  3
		p.moveFrames.sad        = args.moveFrames.sad         or  4
		p.moveFrames.happy      = args.moveFrames.happy       or  5
		p.moveFrames.notamused  = args.moveFrames.notamused   or  5
		p.moveFrames.confused   = args.moveFrames.confused    or  5
	end

	p.walkAnim = nil
	p.airAnim  = nil
	p.talkAnim = nil


	-- Movement stuff
	p.x            = args.x        or  0
	p.y            = args.y        or  0
	p.z            = args.z        or  args.depth    or  args.priority  or  0

	p.groundY      = args.groundY  or  0

	p.holdX        = args.holdX
	p.holdY        = args.holdY
	p.heldObj      = nil
	p._walkRoutine = nil


	-- Assign metatable, save in and return
	setmetatable(p, Actor)
	table.insert(allActors, p)
	return p;
end

a2xt_actor.Actor = function(args)
	return Actor.create(args)
end


--**************************
--** Actor update         **
--**************************
function Actor:Update()

	-- Update physics
	self.speedX = self.speedX  or  0
	self.speedY = self.speedY  or  0

	self.speedMaxX = self.speedMaxX  or  0
	self.speedMaxY = self.speedMaxY  or  0

	self.gravity = self.gravity  or  0.25

	self._accelX = self._accelX  or  0
	self._accelY = self._accelY  or  0
	self._frictionX = self._frictionX  or  0
	self._frictionY = self._frictionY  or  0


	if  self.gravity ~= 0  then
		self.speedY = self.speedY + self.gravity
	end

	if  self.accelX ~= 0  then
		self.speedX = self.speedX + self.accelX
	end
	if  self.accelY ~= 0  then
		self.speedY = self.speedY + self.accelY
	end
	if  self.frictionX > 0  and  self.speedX ~= 0  then
		local sign = math.abs(self.speedX)/self.speedX
		self.speedX = sign*(math.max(0, math.abs(self.speedX) - self.frictionX))
	end
	if  self.frictionY > 0  then
		local sign = math.abs(self.speedY)/self.speedY
		self.speedY = sign*(math.max(0, math.abs(self.speedY) - self.frictionY))
	end

	if  self.speedMaxX > 0  then
		self.speedX = math.max(math.min(self.speedX, speedMaxX), -self.speedMaxX)
	end
	if  self.speedMaxY > 0  then
		self.speedY = math.max(math.min(self.speedY, speedMaxY), -self.speedMaxY)
	end


	-- Update position
	self.x = self.x + self.speedX
	self.y = math.min(self.groundY, self.y + self.speedY)


	-- Update animation based on speed
	if  speedX == 0  then

		-- Change to standing when grounded
		if  self.grounded  and  not self.animFixed  then
			self.sprite.state = self.walkAnim  or  self.moveAnims.walk
			if  self.heldObj ~= nil  then
				self.sprite.state = self.walkAnim  or  self.moveAnims.carryWalk
			end
			self.sprite.frame = self.moveFrames.stand
			self.sprite.speed = 0
		end
	else
		self.direction = math.abs(self.speedX)/self.speedX
		
		-- Walk on the ground
		if  self.grounded  and  not self.animFixed  then
			self.sprite.speed = self.animSpeed

			if  self.heldObj ~= nil  then
				self.sprite:SetState{state=self.walkAnim  or  self.moveAnims.carryWalk}
			else
				self.sprite:SetState{state=self.walkAnim  or  self.moveAnims.walk}
			end
		end
	end


	if  self.grounded  then
		self.airAnim  = nil

	else
		self.animFixed = false
		self.walkAnim  = nil

		self.sprite.speed = 0
		self.sprite.state = self.airAnim  or  self.moveAnims.air
		if  self.speedY < 0  then
			self.sprite.frame = self.moveFrames.rise
		else
			self.sprite.frame = self.moveFrames.fall
		end
	end


	if  self.animFrozen  then
		self.sprite.speed = 0
	end


	local mirroredMult = self.mirrored and {-1} or {1}
	self.sprite.xScale = (self.scale + 0.5*squash) * self._direction * mirroredMult[1]
	self.sprite.yScale = self.scale - 0.5*squash



	-- Update animatx sprites
	for  k,v in ipairs(self.sprites)  do
		for  k2,v2 in pairs(self.sprite)  do
			v[k2] = v2
		end
		v.x = self.x + self.offsets[k].x
		v.y = self.y + self.offsets[k].y
	end
end

function Actor:Draw()
	for  k,v in ipairs(self.sprites)  do
		v:render()
	end
end


function a2xt_actor.onTick()
	for  k,v in pairs(allActors)  do
		v:Update()
	end
end

function a2xt_actor.onDraw()
	for  k,v in pairs(allActors)  do
		v:Draw()
	end
end


--************************************
--** Actor method functions         **
--************************************
function Actor:FreezeAnim()
	if  not self.animFrozen  then
		self.animFrozen = true
	end
end
function Actor:UnfreezeAnim()
	if  self.animFrozen  then
		self.animFrozen = false
		self.sprite.speed = self.animSpeed
	end
end

--[[StillFrame args:
	- state     (int)
	- frame     (int)
--]]
function Actor:StillFrame(args)
	self:FreezeAnim()
	self.animFixed = true
	self.sprite.state = args.state
	self.sprite.frame = args.frame
end


function Actor:StopWalking()
	if  self._walkRoutine ~= nil  then
		eventu.abort(self._walkRoutine)
	end
end

--[[ Walk args:
	- target     (obj)      if an object with an x value, the actor will walk to this object
	- targetX    (int)      if specified, the actor will walk to this X position
	- precision  (int)      the minimum distance to the target/targetX that the actor must get before it can stop walking
	- follow     (bool)     if true, the actor will continue to follow the target even after arriving at the precision distance
	- speed      (int)      the walk speed;  if walking to a target, this is treated as math.abs(speed), otherwise this directly sets the actor's speedX
	- accel      (number)   if specified, the actor will accelerate and decelerate at this rate;  otherwise, walking starts and stops instantly
	- anim       (int)      the animation state to use for the walking until the actor becomes airborn;  if not specified, defaults to actor.moveAnims.walk
--]]
function Actor:Walk(args)
	-- Cancel any active walk routine and animation freezing
	self:StopWalking()
	self:UnfreezeAnim()

	-- Set the walking animation to the new state
	self.walkAnim = args.anim  or  self.moveAnims.walk

	-- If a target x is specified, make a dummy target with that x coordinate
	if  args.targetX ~= nil  then
		args.target = args.target  or  {x=args.targetX}
	end

	-- If there is a specific target to walk to, then keep doing so until the target has been reached
	if  args.target ~= nil  then
		_,self._walkRoutine = eventu.run(function()
			local precision = args.precision  or  16
			local follow = args.follow
			local accel = args.accel
			local speed = math.abs(args.speed)
			local animState = args.animState  or  self.moveAnims.walk

			local dist = math.abs(self.x - args.target.x)

			while  (dist > precision  or  follow)  do
				dist = math.abs(self.x - args.target.x)

				-- If further than the precision, speed up/move
				if dist > precision
					if  accel ~= nil  then
						self._accelX = accel
						self._frictionX = 0
						self.speedMaxX = speed
					else
						self.speedX = speed
					end

				-- If close enough to the target, slow down/stop
				else
					if  accel ~= nil  then
						self._accelX = 0
						self._frictionX = accel
					else
						self.speedX = 0
					end
				end

				-- Yield
				eventu.waitFrames(0)
			end
			self.speedX = 0
		end)


	-- If a target or targetX was not specified, just start walking in the appropriate direction
	else
		self.speedX = args.speed
	end
end

--[[ Jump args:
	- strength   (int)      the initial speed of the jump
	- gravity    (int)      if specified, changes the actor's gravity
	- anim       (int)      the animation state to use for the jump;  if not specified, defaults to actor.moveAnims.air
--]]
function Actor:Jump(args)
	
end

--[[ Talk args:
	- message        (string)   the line of dialogue to call a message box with
	- voice          (string)   voice clip to use
	- messageArgs    (table)    arguments for the message box
	- anim           (int)      the animation state to use for the talking animation
--]]
function Actor:Talk(args)
	
end

function Actor:HoldProp(obj)
	
end

function Actor:RaiseProp(obj)
	
end

function Actor:DestroyHeld()
	
end

function Actor:DropHeld()
	
end

function Actor:ToPlayer(args)
end

function Actor:ToNPC(args)
end


--***************************
--** Preset actors         **
--***************************
local playerSeqs = {
                    [1]="3,4,5",
                    [2]="3,4,5",
                    [3]="-1",
                    [4]="-1",
                    [5]="-1"
                   }
local threeWalkSeq = animatx.Sequence ("3,4,5,4")
local fourWalkSeq = animatx.Sequence ("3,4,5,6")

local playerSet    = animatx.Set {sheet=Graphics.loadImage("actors/anmx_player.png"), states=6, frames=6, sequences=playerSeqs}

-- Still figuring out how to structure things, thinking of defining the properties in ini files
local charData = {
                  demo      = {},
                  iris      = {},
                  kood      = {},
                  raocow    = {},
                  sheath    = {},

                  science   = {},
                  garish    = {},
                  mishi     = {},
                  pandamona = {},
                  calleoca  = {},
                  pily      = {},
                  nevada    = {},
                 }


--[[ PlaceCharacter args:
	- char           (string)   the name of the character
	- x              (number)   the x coordinate to place them at
	- y              (number)   the y coordinate to place them at
--]]
function a2xt_actor.PlaceCharacter(args)
	
end


a2xt_actor.CHARS = {}
a2xt_actor.NAMES = {-- Players
                    "DEMO","IRIS","KOOD","RAOCOW","SHEATH",

                    -- Siblings
                    "SCIENCE","GARISH","MISHI","PANDAMONA","CALLEOCA","PILY","NEVADA",

                    -- Uncles
                    "BROADSWORD","ASBESTOS","DENMARK","REWIND","PUMPERNICKEL","UBERNICKEL",

                    -- Second Cousins
                    "RESPECT","WASHINGTON","DELICIOUS","NOISE",

                    -- Major supporting NPCs
                    "PAL","FEED",

                    -- World 1
                    "NOCTEL",

                    -- World 2
                    "ALABASTA","BRISKET","SALTINE",

                    -- World 3
                    "DICKSON","ULTPANDA",

                    -- World 4
                    "MERCENARY",

                    -- World 7
                    "RAOBOT",

                    -- World 9
                    "SERAC",

                    -- Hub
                    "BARKEEP","CUSTOMERS",

                    -- Misc
                    "CHRONOTON"
                   }

for  _,v in (a2xt_actor.NAMES)  do
	--a2xt_actor.CHARS[v] = a2xt_actor.Actor()
end

-- Switch the player between the player object and the animatX actor
function a2xt_actor.playerToActor()
end
function a2xt_actor.playerToNPC()
end
function a2xt_actor.npcToPlayer()
end
function a2xt_actor.npcToActor()
end
