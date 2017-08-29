-- Multipoints --
multipoints = API.load("multipoints");
multipoints.addLuaCheckpoint(-159840, -160128, 2);
multipoints.addLuaCheckpoint(-157504, -160128, 2);
-- End Multipoints --


-- ExTable --

local ExTable = {};
ExTable.__index = ExTable;
setmetatable(ExTable, {
	__call = function (cls,...)
		local self = setmetatable({},cls);
		self:init(...);
		return self;
	end
});
function ExTable:init()
	self.table = {};
	self.exValue = 0;
	self.addTable = {}
end

function ExTable:add(value)
	self.exValue = self.exValue+1;
	self.table[self.exValue] = value;
	self.addTable[#self.addTable+1] = value;
end

function ExTable:action()
	local newTable = {};
	for i=1,self.exValue do
		self.addTable = {};
		if (self.table[i]:action()==0) then
			newTable[#newTable+1] = self.table[i];
		end
		if (#self.addTable~=0) then
			for k,v in pairs(self.addTable) do
				newTable[#newTable+1] = v;
			end
		end
		
	end
	self.table = newTable;
	self.exValue = #newTable;
end

function ExTable:draw()
	local i = 1;
	while (i<=#self.table) do
		self.table[i]:draw();
		i = i+1;
	end
end

function ExTable:process()
	self:action();
	self:draw();
end

-- End Extable --

--require("ExTable");


local function openSpriteFiles(spriteFileList)
	newSpriteList = {};
	for key,val in pairs(spriteFileList) do
		newSpriteList[#newSpriteList+1] = Graphics.loadImage(val);
	end
	return newSpriteList;
end


local function sgn(n)
	if (n>0) then
		return 1;
	elseif (n<0) then
		return -1;
	else
		return 0;
	end
end


-- NPC (extension) --

function NPC:overlapsWith(otherx1,othery1,otherx2,othery2)
	return (self.x+self.width>otherx1 and self.x<otherx2 and self.y+self.height>othery1 and self.y<othery2);
end

-- End NPC (extension) --


-- Player (extension) --

function Player:overlapsWith(otherx1,othery1,otherx2,othery2)
	return (self.x+self.width>otherx1 and self.x<otherx2 and self.y+self.height>othery1 and self.y<othery2);
end

-- End Player (extension) --


-- Laser --

local noLaser = false;

local Laser = {}
Laser.__index = Laser;
setmetatable(Laser, {
	__call = function (cls,...)
		local self = setmetatable({},cls);
		self:init(...);
		return self;
	end
});
function Laser:init(ini_x,ini_y,ini_vx,ini_curSectionNum)
	self.x = ini_x;
	self.y = ini_y;
	self.spriteList = openSpriteFiles({
						"Laser.png" --1
					});
	self.vx = ini_vx;
	self.curSection = Section.get(ini_curSectionNum);
	
	self.width = 80;
	self.height = 24;
end

function Laser:draw()
	Graphics.placeSprite(2,self.spriteList[1],self.x,self.y,"",2);
end

function Laser:action()
	self.x = self.x+self.vx;
	if (noLaser or self.x>self.curSection.boundary.right) then
		return 1;
	end
	if (Player(1):overlapsWith(self.x+4,self.y+4,self.x+self.width-4,self.y+self.height-4)) then
		Player(1):harm();
	end
	return 0;
end

-- End Laser --


-- Lakitoff --

local lastPhase = false;

local Lakitoff = {}
Lakitoff.__index = Lakitoff;
setmetatable(Lakitoff, {
	__call = function (cls,...)
		local self = setmetatable({},cls);
		self:init(...);
		return self;
	end
});
function Lakitoff:init(ini_x,ini_y,ini_player,ini_exTable)
	self.x = ini_x;
	self.y = ini_y;
	self.player = ini_player;
	self.exTable = ini_exTable;
	self.spriteList = openSpriteFiles({
						"Lakitoff.png",		--1
						"Lakitoff2.png",    --2
						"Lakitoff3.png"
					});
	self.state = 0;
	self.ouchState = 0;
	self.flashFollow = 0;
	self.flashPeriod = 2; self.flashTimer = 0;
	self.vx = 0;
	self.vy = 0;
	self.a = 0.15;
	
	self.health = 5;
	self.maxHealth = 15;
	self.width = 128;
	self.height = 98;
	self.collisionBox = {xOff = 16,
	                     yOff = 16,
                         w = self.width-32,
                         h = self.height-32};
	self.ouchTime = 90; self.ouchTimer = 0;
	self.maxV2 = 8*8;
	self.aimYOffset = 72;
	self.laserPeriod = 200; self.laserTimer = 120;
	self.spinyPeriod = 300; self.spinyTimer = 40;
	self.deathState = 0;
	self.deathG = 0.3;
	self.deathDelay = 150; self.deathTimer = 0;
	self.moneyObject = 139;
end

function Lakitoff:draw()
	self.flashTimer = self.flashTimer+1;
	if (self.flashTimer>=self.flashPeriod) then
		if (self.flashFollow==0) then self.flashFollow = 1; else self.flashFollow = 0; end
		self.flashTimer = 0;
	end
	if (self.ouchState==0) then
		if (self.laserTimer>=self.laserPeriod-60) then
			Graphics.placeSprite(2,self.spriteList[1+2*self.flashFollow],self.x,self.y,"",2);
		else
			Graphics.placeSprite(2,self.spriteList[1],self.x,self.y,"",2);
		end
	else
		Graphics.placeSprite(2,self.spriteList[1+self.flashFollow],self.x,self.y,"",2);
	end
end

function Lakitoff:action()
	if (self.deathState==0) then
		self.x = Section.get(4).boundary.left+32;
		if (self.ouchState==0) then
			local dy = self.player.y-(self.y+self.aimYOffset);
			local sdy = sgn(dy);
			if (sdy~=sgn(self.vy)) then
				self.vy = self.vy+sdy*self.a*1.5;
			else
				self.vy = self.vy+sdy*self.a;
			end
			local v2 = self.vx^2+self.vy^2;
			if (v2>self.maxV2) then
				local ratio = math.sqrt(self.maxV2/v2);
				self.vx = self.vx*ratio;
				self.vy = self.vy*ratio;
			end
			self.y = self.y+self.vy;
			self.laserTimer = self.laserTimer+1;
			if (self.laserTimer>=self.laserPeriod) then
				self.exTable:add(Laser(self.x+self.width-40,self.y+self.aimYOffset,5,4));
				Audio.playSFX("laser.wav");
				self.laserTimer = 0;
			end
			if (self.state==0) then
				self.spinyTimer = self.spinyTimer+1;
				if (self.spinyTimer>=self.spinyPeriod) then
					local spiny = NPC.spawn(286,self.x+self.width/2,self.y+self.height/2,3);
					spiny.speedX = 3;
					spiny.speedY = -10;
					self.spinyTimer = 0;
				end
			end
			if (Player(1):overlapsWith(self.x+self.collisionBox.xOff,self.y+self.collisionBox.yOff,self.x+self.collisionBox.xOff+self.collisionBox.w,self.y+self.collisionBox.yOff+self.collisionBox.h)) then
				Player(1):harm();
			end
			-- Hit
			if (self.state~=1) then
				local money = NPC.get(self.moneyObject,3);
				for k,v in pairs(money) do
					if ((v:mem(0x136,FIELD_WORD)==-1) and v:overlapsWith(self.x+self.collisionBox.xOff,self.y+self.collisionBox.yOff,self.x+self.collisionBox.xOff+self.collisionBox.w,self.y+self.collisionBox.yOff+self.collisionBox.h)) then
						self.health = self.health-1;
						v:kill();
						if (self.health>0) then
							Audio.playSFX("boss_hit1.wav");
							self.ouchState = 1;
						elseif (self.state==0) then
							Audio.playSFX("boss_hit1.wav");
							NPC.spawn(9,-139616,-140640,3).dontMove = true;
							triggerEvent("Lower platforms");
							noLaser = true;
							self.health = self.maxHealth;
							self.ouchState = 1;
							self.state = 1;
						else
							Audio.playSFX("boss_hit2.wav");
							noLaser = true;
							self.vx = -4;
							self.vy = -2;
							self.deathState = 1;
						end
					end
				end
				if (self.state==1) then
					Layer.get("Lakitu boss"):hide(false);
					money = NPC.get(self.moneyObject,3);
					local spinies = NPC.get(285,3);
					local spinyEggs = NPC.get(286,3);
					for k,v in pairs(money) do
						v:kill();
					end
					for k,v in pairs(spinies) do
						v:kill();
					end
					for k,v in pairs(spinyEggs) do
						v:kill();
					end
				end
			else
				if (lastPhase) then
					self.moneyObject = 108;
					self.ouchTime = 10;
					self.laserTimer = 0;
					self.laserPeriod = 60;
					self.state = 2;
				end
			end
		else
			self.ouchTimer = self.ouchTimer+1;
			if (self.ouchTimer>=self.ouchTime) then
				if (self.state==1) then
					noLaser = false;
					Player(1):mem(0x17C,FIELD_WORD,-1); -- Communicates with lunadll autocode script to start scrolling
				end
				self.ouchState = 0;
				self.ouchTimer = 0;
			end
		end
	else
		self.vy = self.vy+self.deathG;
		self.x = self.x+self.vx;
		self.y = self.y+self.vy;
		self.deathTimer = self.deathTimer+1;
		if (self.deathTimer>=self.deathDelay) then
			local warpOut = Warp.getIntersectingEntrance(-140032,-141248,-140032+32,-141248+32);
			warpOut[1].entranceX = Player(1).x;
			warpOut[1].entranceY = Player(1).y;
			Audio.playSFX("boss_hit3.wav");
			return -1;
		end
	end
	
	return 0;
end

-- End Lakitoff --


-- Main --

function onEvent(eventName)
	if (eventName=="Reached end") then
		lastPhase = true;
	end
end

function onLoad()
	if (Player(1).isValid) then
		Player(1).character = CHARACTER_MARIO;
	end
end

local activeObjects = ExTable();
local sec3;
local iniDone = false;
local function ini()
	activeObjects:add(Lakitoff(-139968,-140576,Player(1),activeObjects));
	iniDone = true;
end

function onLoop()
	if (not iniDone) then
		ini();
	end
	if (Player(1).section==3) then
		--Player(1):mem(0x17C,FIELD_WORD,-1); -- Communicates with lunadll autocode script to start scrolling
		activeObjects:process();
	end
end

-- End Main --