-- STILL SUPER WIP
local animDefaults = API.load("base/animdefaults")

local Actor = API.load("actorclass")
local pnpc = API.load("pnpc")
local animatx = API.load("animatx2")
local lunajson = API.load("ext/lunajson")
local rng = API.load("rng")

local costumes = API.load("a2xt_costumes")
local message  = API.load("a2xt_message")
local emote = API.load("a2xt_emote")


local a2xt_actor = {}


function a2xt_actor.onInitAPI()
	registerEvent (a2xt_actor, "onTick")
	registerEvent (a2xt_actor, "onDraw")
end



--*************************************
--** Utility functions               **
--*************************************
local function getPlayerSettingsOffsets(characterId,state)
	local xOffsets = {}
	local yOffsets = {}

	local pSettings = PlayerSettings.get(characterId,state)

	local i=1
	for  y=0,9  do
		for  x=0,9  do
			xOffsets[i] = pSettings:getSpriteOffsetX(x,y)
			yOffsets[i] = pSettings:getSpriteOffsetY(x,y)
			i = i+1
		end
	end

	return xOffsets,yOffsets
end

local function getPlayerSettingsSize(characterId,state)
	local pSettings = PlayerSettings.get(characterId,state)
	return pSettings.hitboxWidth, pSettings.hitboxHeight
end

local function getNPCOffsets(npcId)
	return NPC.config[npcId].gfxoffsetx, NPC.config[npcId].gfxoffsety;
end


--*************************************
--** Misc class variables            **
--*************************************
a2xt_actor.groundY = nil


--*************************************
--** Extended Actor method functions **
--*************************************
local extMethods, playerRoutines
do
	extMethods = {

		StopFollowing = function (self)
			if  self._walkRoutine ~= nil  then
				eventu.abort(self._walkRoutine)
			end
		end,

		StopWalking = function(self)
			self:StopFollowing()
			self.speedX = 0
		end,


		--[[ Walk args:
			- target     (obj)      if an object with an x value, the actor will walk to this object
			- targetX    (int)      if specified, the actor will walk to this X position
			- precision  (int)      the minimum distance to the target/targetX that the actor must get before it can stop walking
			- follow     (bool)     if true, the actor will continue to follow the target even after arriving at the precision distance
			- speed      (int)      the walk speed;  if walking to a target, this is treated as math.abs(speed), otherwise this directly sets the actor's speedX
			- accel      (number)   if specified, the actor will accelerate and decelerate at this rate;  otherwise, walking starts and stops instantly
			- anim       (string)   the animation state to use for the walking until the actor becomes airborn;  if not specified, defaults to actor.moveAnims.walk
		--]]
		Walk = function (self, args)
			local isPlayer = type(self) == "Player"
			local isNpc = type(self) == "NPC"
			local isActor = not isPlayer  and  not isNpc


			-- Cancel any active walk routine and animation freezing
			self:StopWalking()
			if  isActor  then
				self.gfx:unfreeze()
			end

			-- Set the walking animation to the new state
			--self:StartState ("walk")

			-- If a target x is specified, make a dummy target with that x coordinate
			local target = args.target
			if  args.targetX ~= nil  then
				target = target  or  {x=args.targetX}
			end

			-- If there is a specific target to walk to, then keep doing so until the target has been reached
			if  target ~= nil  then
				_,self._walkRoutine = eventu.run(function()
					local precision = args.precision  or  16
					local follow = args.follow
					local accel = args.accel
					local speed = math.abs(args.speed)

					local dist = math.abs(self.x - args.target.x)

					while  (dist > precision  or  follow)  do
						dist = math.abs(self.x - args.target.x)

						-- If further than the precision, speed up/move
						if dist > precision  then
							if  accel ~= nil  and  isActor  then
								self.accelX = accel
								self.frictionX = 0
							else
								self.speedX = speed
							end

							if  math.abs(self.speedX) > speed  then
								self.speedX = math.max(-speed, math.min(speed, self.speedX))
							end


						-- If close enough to the target, slow down/stop
						else
							if  accel ~= nil  and  isActor  then
								self.accelX = 0
								self.frictionX = accel
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
		end,

		--[[ Jump args:
			- strength   (number)   the initial speed of the jump
			- gravity    (number)   if specified, changes the actor's gravity
			- state      (string)   if specified, the state to switch to when performing the jump
		--]]
		Jump = function(self, args)
			self.speedY = -args.strength

			if  type(self) ~= "Player"  and  type(self) ~= "NPC"  then
				self.accelY = args.gravity  or  self.accelY

				if  args.state  then
					self:StartState{state=args.state}
				end
			end
		end,

		--[[ Talk args:
			- text           (string)   the line of dialogue to call a message box with
			- calls a2xt_message.showMessageBox and passes in the arguments for this function
		--]]
		Talk = function (self, args)
			local isPlayer = type(self) == "Player"
			local isNpc = type(self) == "NPC"
			local isActor = not isPlayer  and  not isNpc

			local extra = {target=self, offX=0.5*self.width, offY=-8}

			if  isActor  then
				extra.offX = -self.width
				extra.offY = -self.height*2 - 8
			end
			
			-- add stuff for determining the y offset
			return message.showMessageBox (table.join(args, extra))
		end,

		Emote = function (self, icon)
			if  icon == nil  then
				icon = "blank"
			end
			emote[icon](self.gfx)
		end,

		Ground = function (self)
			if  self.bounds ~= nil  then
				self.y = self.bounds.bottom
			end
		end

		--[[ commented-out functions
		function Actor:HoldProp(obj)
			
		end

		function Actor:RaiseProp(obj)
			
		end

		function Actor:DestroyHeld()
			
		end

		function Actor:DropHeld()
			
		end
		--]]
	}

	for  k,v in pairs(extMethods)  do
		Actor[k] = v
		Player[k] = v
		NPC[k] = v
	end
end



--****************************
--** Namespace pseudoclass  **
--****************************
local Namespace = {}   -- class object
local NamespaceMT = {} -- instance metatable


do  -- metamethods
	function NamespaceMT.__index (self, key)
		if      (key == "_type"  or  key == "__type")  then
			return "Actor Namespace"

		elseif  self.objects.current ~= nil  and  self.objects.current[key] ~= nil  then
			local curr = self.objects.current
			return curr[key]

		else
			return Namespace[key]
		end
	end

	function NamespaceMT.__newindex (self,key,val)

		if  self.objects.current ~= nil  and  self.objects.current[key] ~= nil  then
			self.objects.current[key] = val

		else
			rawset(self, key, val)
		end
	end

	function NamespaceMT.__call (tbl, args)

		-- No args?  NOOOOOOoooOOoooOOOO PROBLEM!
		if  args == nil  then
			args = {}
		end

		-- If the current object isn't set, get it
		local current = tbl.objects.current
		local source = "PLAYER"
		if  current == nil  then
			if  player.character == tbl.playable.id  then
				current = tbl:BecomePlayer ()
			
			-- If an NPC of the player exists, try an NPC
			elseif  tbl:GetNPC()  then
				source = "NPC"
				current = tbl:BecomeNPC ()
			end

			-- Last resort, make a temp table
			if  current == nil  then
				source = "NOTHING"
				current = {x=-999999, y=-999999, direction=DIR_RIGHT}
			end
		end
		--Text.dialog("INITIALIZING "..tbl.name.." FROM "..source..", DIR="..tostring(current.direction))


		-- Generate the object
		if  tbl.objects.actor == nil  then
			local newBounds = newRECTd()
			newBounds.top = player.sectionObj.boundary.top-1000
			newBounds.left = player.sectionObj.boundary.left-1000
			newBounds.right = player.sectionObj.boundary.right+1000
			newBounds.bottom = a2xt_actor.groundY  or  player.sectionObj.boundary.bottom-100

			local specialDefs = {
			                     x      = args.x      or  current.x,
			                     y      = args.y      or  current.y,
			                     z      = args.z      or  -1,
			                     state  = args.state  or  "walk",
			                     direction = args.direction  or  current.direction,
			                     bounds = newBounds,
			                     sceneCoords = true,
			                     debug = true
			                    }
			tbl.objects.actor = Actor(table.join (tbl.actorArgs, specialDefs))
		end

		-- Apply named arguments
		local usableArgs = {"x","y","z","direction","speedX","speedY"}
		--local actorVals = {}
		for  _,v in ipairs (usableArgs)  do
			tbl.objects.actor[v] = args[v]  or  tbl.objects.actor[v]
			--actorVals[v] = tbl.objects.actor[v]
		end
		--actorVals.name = tbl.name
		--Text.dialog(actorVals)

		tbl.objects.actor.state = args.state  or  tbl.objects.actor.state
		tbl.objects.actor.gfx.visible = true
		tbl.objects.current = tbl.objects.actor
	end
end

do
	-- Define wrapper methods
	for  k,v in pairs (extMethods)  do
		Namespace[k] = function(self, ...)
			local obj = self.objects.current
			--Text.dialog("CALLING "..k.." for "..tostring(obj))
			if  obj ~= nil  then
				return obj[k](obj, ...)
			end
		end
	end


	-- Define type-switcing methods for the namespaces
	function Namespace:ToActor () -- Changes the current object into the Actor, initializing the Actor if necessary
		local obj = self.objects.current

		if  obj == nil  then
			self:HijackNPC ()
			self ()

		elseif  obj ~= self.objects.actor  then
			self {x=obj.x+0.5*obj.width, y=obj.y+obj.height, direction=obj.direction, speedX=obj.speedX, speedY=obj.speedY}
		end
	end

	function Namespace:BecomePlayer () -- Changes the current object into the player, changing player.character accordingly
		local current = self.objects.current
		local actor = self.objects.actor
		local npc = self.objects.npc

		if  self.playable.id ~= nil  and  current ~= player  then
			if  current ~= nil  then
				player:mem(0x122, FIELD_WORD, 0)
				player.x = current.x
				player.y = current.y-current.height
				if  current == actor  then
					player.x = current.gfx.xMid - current.width*0.5
					player.y = current.gfx.bottom - current.height
				end
				player.speedX = current.speedX
				player.speedY = current.speedY
				player.direction = current.direction
			end

			self.objects.current = player
			player.character = self.playable.id
		end
		return self.objects.current
	end

	function Namespace:BecomeNPC () -- Changes the current object into an NPC;  if there is no current object, hijacks an existing one if possible
		local current = self.objects.current
		local actor = self.objects.actor
		local npc = self.objects.npc

		if  self.npcId ~= nil  and  (current ~= npc  or  current == nil)  then

			-- If the npc object exists, just use it
			if  npc ~= nil  then
				self.objects.current = npc

			-- Otherwise if the current object exists, spawn a new NPC at its position
			elseif  current ~= nil  then
				local spawnX,spawnY = obj.x, obj.y
				if  obj == self.objects.actor  then
					spawnX = self.objects.current.collision.left
					spawnY = self.objects.current.collision.bottom - NPC.config[self.npcId].height
				end
				local npcRef = NPC.spawn(self.npcId, spawnX, spawnY, true)
				self.objects.npc = pnpc.wrap(npcRef)
				self.objects.current = self.objects.npc

			-- Otherwise, try to get an existing NPC in the section
			else
				self:HijackNPC ()
				self.objects.current = self.objects.npc
			end
		else
			--Text.dialog("FAILED TO BECOME AN NPC. npcId: "..tostring(self.npcId)..", current is NPC:"..tostring(current == npc))
		end
		return self.objects.current
	end

	function Namespace:PlayerReplaceNPC () -- If a valid NPC exists, have the player become this character and replace the NPC
		if  self.objects.npc  ~= nil  then
			self:BecomePlayer()
		else
			local found,npc = self:GetNPC ()
			if  found  then
				self.objects.npc = npc
				self.objects.current = npc
				player.x = npc.x
				player.y = npc.y
				self:BecomePlayer()
			end
		end
	end

	function Namespace:Remove () -- removes the object from the 
		if  player.character ~= self.playable.id  then
			self.objects.current = nil
		end
	end

	function Namespace:GetNPC () -- check for a valid NPC and returns: whether it was found, pnpc reference
		if  self.npcId ~= nil  then
			local available = NPC.get(self.npcId, player.section)
			if  #available > 0  then
				return true, pnpc.wrap(available[1])
			end
		end
		return false, nil
	end

	function Namespace:HijackNPC () -- calls GetNPC and stores the returned pnpc reference in self.objects.npc
		if  self.objects.npc == nil  then
			_,self.objects.npc = self:GetNPC()
		end
	end


	-- Define override events for the namespaces
	function Namespace:_HideObjects ()  --hides/deletes objects when they're not in use

		-- Delete the NPC
		if  self.objects.npc ~= nil  and  self.objects.current ~= self.objects.npc  then
			self.objects.npc:mem(0xDC, FIELD_WORD, 0)
			self.objects.npc:kill(HARM_TYPE_OFFSCREEN)
			self.objects.npc = nil
		end

		-- Hide the Actor object
		if  self.objects.current ~= self.objects.actor  and  self.objects.actor ~= nil  then
			self.objects.actor.gfx.visible = false
		end

		-- Hide the player if they're that character
		if  self.objects.current ~= player  and  player.character == self.playable.id  then
			player:mem(0x122, FIELD_WORD, 8)
		end
	end

	function Namespace:_Hitbox ()       --applies bounding box overrides to the Actor object
		if  self.objects.actor ~= nil  then

			local obj = self.objects.actor

			-- Apply width and height
			if  self.playable.id ~= nil  then
				obj.width, obj.height = getPlayerSettingsSize (self.playable.id, 2)

			elseif  self.npcId ~= nil  then
				obj.width, obj.height = NPC.config[self.npcId].width, NPC.config[self.npcId].height
			end
		end
	end

	function Namespace:_Physics ()      --applies physics overrides to the Actor object
		if  self.objects.actor ~= nil  then

			local obj = self.objects.actor

			-- Apply gravity based on type
			if  obj.contactDown  then
				obj.accelY = 0
				obj.maxSpeedY = 0

			else
				obj.maxSpeedY = Defines.gravity
				if  self.playable.id ~= nil  then
					obj.accelY = Defines.player_grav

				elseif  self.npcId ~= nil  then
					obj.accelY = Defines.npc_grav
				end
			end
		end
	end

	function Namespace:_Animation ()    --applies animation behavior overrides to the Actor object
		if  self.objects.actor ~= nil  then

			-- Apply directional sequences
			local seqProcs = self.sequences.processed
			local seqStrs = self.sequences.strings
			local obj = self.objects.actor
			local gfx = obj.gfx
			local set = gfx.set

			if  obj.direction == DIR_LEFT  or  obj.direction == DIR_RIGHT  then
				for  k3,_ in pairs(set.sequences)  do
					if  seqProcs[obj.direction][k3] ~= nil  then
						set.sequences[k3] = seqProcs[obj.direction][k3]
						obj.directionMirror = false
					else
						set.sequences[k3] = seqProcs.default[k3]
						obj.directionMirror = true
					end
				end
			end

			--Text.dialog(set.sequences)


			-- Apply SpriteOverride sheet and offsets
			---[[
			if  self.gfxType == "playable"  then
				local playerSheet = Graphics.sprites[self.playable.name][2].img

				set.sheet = Graphics.sprites[self.playable.name][2].img
				set.xOffsets, set.yOffsets = getPlayerSettingsOffsets (self.playable.id,2)
				obj.xOffsetGfx, obj.yOffsetGfx = -obj.width*0.5, -obj.height

			elseif  self.gfxType == "npc"  then
				set.sheet = Graphics.sprites.npc[self.npcId].img
				set.xOffsets, set.yOffsets = getNPCOffsets (self.npcId)
			end
			--]]
		end
	end
end



--**************************************************************
--** Load all JSON files into their own dedicated namespaces  **
--**************************************************************

do
	local function makeNamespace (filename)
		-- Get the namespace name
		local name = string.sub(filename, 0, -6);

		-- Get JSON info
		local f = io.open(Misc.resolveFile("actors/"..filename)  or  Misc.resolveFile("../actors/"..filename), "r");
		local content = f:read("*all");
		f:close();

		local ljson = lunajson.decode(content);
		ljson.general = ljson.general      or  {}

		ljson.gfx = ljson.gfx              or  {}
		ljson.gfx.npcStartLeft = ljson.gfx.npcStartLeft  or  1
		ljson.gfx.npcStartRight = ljson.gfx.npcStartRight  or  1

		ljson.sequences = ljson.sequences  or  {}


		-- Set up the Namespace instance
		local inst = {
			json = ljson,

			objects = {
				current = nil,
				actor = nil,
				npc = nil
			},

			playable = {
				name = nil,
				id = nil,
			},

			npcId = nil,

			gfxType = nil,

			actorArgs = {
				scale = 2,
				animSet = nil,
				width = nil,
				height = nil,
				scale = 2,
				xScale = 1,
				yScale = 1,
				state = "walk",
				xAlignGfx = animatx.ALIGN.MID,
				yAlignGfx = animatx.ALIGN.BOTTOM,
				xAlignBox = animatx.ALIGN.MID,
				yAlignBox = animatx.ALIGN.BOTTOM,
				xOffsetGfx = 0,
				yOffsetGfx = 0,
				xOffsetBox = 0,
				yOffsetBox = 0,
				stateDefs = {}
			},

			sequences = {
				processed = {
					[DIR_LEFT] = {},
					[DIR_RIGHT] = {},
					default = {}
				},
				strings = table.clone(ljson.sequences)
			}
		}
		local seqStrs = inst.sequences.strings
		local seqProcs = inst.sequences.processed
		local aArgs = inst.actorArgs
		for  _,v2 in ipairs {"npc","left","right","default"}  do
			seqStrs[v2] = seqStrs[v2]  or  {}
		end


		-- Cache asset IDs and gfx type
		inst.playable.name = ljson.general.player
		inst.playable.id = CHARACTER_CONSTANT[ljson.general.player]
		inst.npcId = ljson.general.npc
		inst.gfxType = ljson.gfx.type


		-- If the Actor uses a playable's or NPC's sheets, automate the properties from animDefaults and NPC.config, respectively
		local setProps = table.clone(ljson.gfx)

		if  inst.gfxType == "playable"  then
			for  k2,v2 in pairs(animDefaults[inst.playable.id][2])  do

				-- construct sequence strings
				local seqStringL,seqStringR = tostring(-v2[1]),tostring(v2[1])

				for i2=2,#v2  do
					seqStringL = seqStringL .. "," .. tostring(-v2[i2])
					seqStringR = seqStringR .. "," .. tostring(v2[i2])
				end
				seqStrs.left[k2] = seqStringL
				seqStrs.right[k2] = seqStringR
			end

			setProps.rows = 10
			setProps.columns = 10
			setProps.isPlayerSheet = true
			setProps.sheet = Graphics.sprites[inst.playable.name][2].img
			--setProps.sheet = Graphics.loadImage(Misc.resolveFile("../graphics/mario/mario-2.png"))

			aArgs.width, aArgs.height = getPlayerSettingsSize(inst.playable.id,2)
			aArgs.xOffsetGfx, aArgs.yOffsetGfx = -aArgs.width*0.5, -aArgs.height
			aArgs.xAlignGfx = animatx.ALIGN.LEFT
			aArgs.yAlignGfx = animatx.ALIGN.TOP
			aArgs.scale = 1
		end

		if  inst.gfxType == "npc"  then
			local config = NPC.config[inst.npcId]
			setProps.rows = config.frames * (config.framestyle+1)
			setProps.columns = 1
			setProps.sheet = Graphics.sprites.npc[inst.npcId].img
			aArgs.scale = 1
		end
		setProps.scale = aArgs.scale


		-- Create a table with _all_ the unique animstate keys.  _All of them_.
		local allKeys = table.join(seqStrs.npc      or  {},
		                           seqStrs.left     or  {},
		                           seqStrs.right    or  {},
		                           seqStrs.default  or  {})


		-- Process EVERY SEQUENCE and create the ActorState definitions
		local seqProps = {isPlayerSheet=(ljson.general.player ~= nil), useOldIndexing=false, rows=ljson.gfx.rows}
		for  k2,v2 in pairs (allKeys)  do

			-- Sequences
			if  seqStrs.npc[k2] ~= nil  then
				seqProcs[DIR_LEFT][k2] = animatx.Sequence (table.join(seqProps, {str=v2, frameOffset=ljson.gfx.npcStartLeft-1}))
				seqProcs[DIR_RIGHT][k2] = animatx.Sequence (table.join(seqProps, {str=v2, frameOffset=ljson.gfx.npcStartRight-1}))

			elseif  seqStrs.left[k2] ~= nil  then
				seqProcs[DIR_LEFT][k2] = animatx.Sequence (table.join(seqProps, {str=v2, frameOffset=ljson.gfx.npcStartLeft-1}))

			elseif  seqStrs.right[k2] ~= nil  then
				seqProcs[DIR_RIGHT][k2] = animatx.Sequence (table.join(seqProps, {str=v2, frameOffset=ljson.gfx.npcStartRight-1}))
			end

			seqProcs.default[k2] = animatx.Sequence (table.join(seqProps, {str=v2}))
		end


		-- Define states
		aArgs.stateDefs = {
			walk = {
				onTick = function(self, actor)

					-- Set the animation state
					if  math.abs(actor.speedX) >= 4  then
						if  actor.gfx.set.sequences.run  then
							actor.gfx:startState{state="run", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.walk  then
							actor.gfx:startState{state="walk", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.idle  then
							actor.gfx:startState{state="idle", resetTimer=true, commands=true}
						end
					elseif  math.abs(actor.speedX) >= 0.25  then
						if  actor.gfx.set.sequences.walk  then
							actor.gfx:startState{state="walk", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.run  then
							actor.gfx:startState{state="run", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.idle  then
							actor.gfx:startState{state="idle", resetTimer=true, commands=true}
						end
					else
						if  actor.gfx.set.sequences.idle  then
							actor.gfx:startState{state="idle", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.walk  then
							actor.gfx:startState{state="walk", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.run  then
							actor.gfx:startState{state="run", resetTimer=true, commands=true}
						end
					end

					-- Switch to standing
					if  actor.speedX == 0  then
						actor:StartState("idle")
					end
				end
			},
			idle = {
				onStart = function(self, actor)

					-- Set the animation state
					if  actor.gfx.set.sequences.idle  then
						actor.gfx:startState {state="idle", resetTimer=true, commands=true}
					elseif  actor.gfx.set.sequences.walk  then
						actor.gfx:startState {state="walk", resetTimer=true, commands=true}
					elseif  actor.gfx.set.sequences.run  then
						actor.gfx:startState {state="run", resetTimer=true, commands=true}
					end
				end,
				onTick = function(self, actor)
					-- Switch to walking
					if  actor.speedX ~= 0  then
						actor:StartState("walk")
					end

					-- Switch to airborn
					if  not actor.contactDown  then
						actor:StartState("air")
					end
				end
			},
			air = {
				onTick = function(self, actor)

				-- Set the animation state
					if  actor.speedY >= 0  then 
						if  actor.gfx.set.sequences.fall  then
							actor.gfx:startState {state="fall", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.jump  then
							actor.gfx:startState {state="jump", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.idle  then
							actor.gfx:startState {state="idle", resetTimer=true, commands=true}
						end
					else
						if  actor.gfx.set.sequences.jump  then
							actor.gfx:startState {state="jump", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.fall  then
							actor.gfx:startState {state="fall", resetTimer=true, commands=true}
						elseif  actor.gfx.set.sequences.idle  then
							actor.gfx:startState {state="idle", resetTimer=true, commands=true}
						end
					end

					-- Switch to grounded
					if  actor.speedY == 0  and  actor.y >= actor.bounds.bottom  then
						actor:StartState("idle")
					end
				end
			}
		}


		-- Define the animation set from the animset and sequences sections of the ini
		setProps.sequences = table.clone(allKeys)
		aArgs.animSet = animatx.Set (setProps)

		-- Store the name because it turns out I actually need it after all
		inst.name = name


		-- Set the metatable and make this thing a dedicated namespace
		setmetatable(inst, NamespaceMT)
		a2xt_actor[name] = inst
		_G["ACTOR_"..string.upper(name)] = a2xt_actor[name]
		table.insert(a2xt_actor.presetNames, name)
	end


	a2xt_actor.presetNames = {}
	for k,v in ipairs (table.join (Misc.listLocalFiles("../actors"), Misc.listLocalFiles("actors")))  do

		if  v ~= "Example.txt"  then
			makeNamespace(v)
		end
	end
end



--*************************************
--** Player's current character      **
--*************************************
a2xt_actor.Player = {
	ToActor = function(self)
		a2xt_actor[CHARACTER_NAME[player.character]]:ToActor()
	end,
	BecomePlayer = function(self)
		a2xt_actor[CHARACTER_NAME[player.character]]:BecomePlayer()
	end,
	BecomeNPC = function(self)
		a2xt_actor[CHARACTER_NAME[player.character]]:BecomeNPC()
	end
}



--*************************************
--** Character-specific stuff        **
--*************************************



--*************************************
--** Library functions               **
--*************************************
function a2xt_actor.ToActors(chars) --Use ACTOR_NAME constants
	for  _,v in ipairs (chars)  do
		v:ToActor()
	end
end

function a2xt_actor.KrewToActors()
	a2xt_actor.ToActors{ACTOR_DEMO, ACTOR_IRIS, ACTOR_KOOD, ACTOR_RAOCOW, ACTOR_SHEATH}
end


--*************************************
--** Library events                  **
--*************************************

function a2xt_actor.onTick ()
	for  k,v in pairs(a2xt_actor.presetNames)  do
		local namespace = a2xt_actor[v]
		local actorObj = namespace.objects.actor
		local currentObj = namespace.objects.current

		if  actorObj ~= nil  and  currentObj == actorObj  then
			actorObj:update()
		end

		namespace:_HideObjects ()
		namespace:_Hitbox ()
		namespace:_Physics ()
		namespace:_Animation ()
	end
end

function a2xt_actor.onDraw ()
	for  _,v in pairs(a2xt_actor.presetNames)  do
		local namespace = a2xt_actor[v]
		local actorObj = namespace.objects.actor
		
		if  actorObj ~= nil  then
			actorObj:draw()
		end
	end
end


return a2xt_actor