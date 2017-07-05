local imagic = API.load("imagic");
local textblox = API.load("textblox");
local vectr = API.load("vectr");

local boss = {}

boss.SuperTitle = nil;
boss.Name = nil;
boss.SubTitle = nil;
boss.MaxHP = 100;
boss.HP = boss.MaxHP;
boss.IncludeSubtitle = false;

boss.Active = false;

local introTimer = 0;

boss.LerpSpeed = 0.2;

local barx = 64;
local bary = 568;
local barwid = 800-2*barx;

local titleY = 500;

local barbgimg = Graphics.loadImage(Misc.resolveFile("HUD/boss_background.png"));
local barimg = Graphics.loadImage(Misc.resolveFile("HUD/boss_bar.png"));
local bardmg = Graphics.loadImage(Misc.resolveFile("HUD/boss_dmg.png"));
local barheal = Graphics.loadImage(Misc.resolveFile("HUD/boss_heal.png"));

local barbg = imagic.Create{x=barx, y=bary, primitive = imagic.TYPE_BOXBORDER, width = barwid, height = 16, depth = 8, texture = barbgimg};

local lerpHP = boss.MaxHP;

local barPos1, barPos2 = 0,0;

local barAppearTime = 180;

function boss.onInitAPI()
	registerEvent(boss, "onDraw", "onDraw", false);
	registerEvent(boss, "onTick", "onTick", false);
end

function boss.Start()
	boss.Active = true;
end

function boss.Ready()
	return boss.Active and introTimer < 0;
end

function boss.Defeated()
	return boss.HP <= 0;
end

function boss.Heal(amount)
	boss.Damage(-amount);
end

function boss.Damage(amount)
		local oldHP = boss.HP;
		boss.HP = math.min(boss.MaxHP, boss.HP - amount);
		if(math.abs(lerpHP - boss.HP) > math.abs(oldHP - boss.HP)) then
			lerpHP = oldHP;
		end
end

function boss.onTick()
	if(lerpHP > boss.HP) then
		lerpHP = lerpHP - boss.LerpSpeed;
	elseif(lerpHP < boss.HP) then
		lerpHP = lerpHP + boss.LerpSpeed;
	end
	if(math.abs(lerpHP - boss.HP) < boss.LerpSpeed) then
		lerpHP = boss.HP;
	end
	
	if(introTimer > -1) then
		introTimer = introTimer + 1;
		barPos1 = (introTimer - barAppearTime)/200;
		barPos2 = barPos1;
	else
		barPos1 = math.max(lerpHP, boss.HP)/boss.MaxHP;
		barPos2 = math.min(lerpHP, boss.HP)/boss.MaxHP
	end
	
	if(introTimer > 200 + barAppearTime) then
		introTimer = -1;
	end
end

local function computeX(centreTime, steadyDist, steadyTime)
	local sweepTime = 30;
	
	if(introTimer < centreTime - sweepTime) then
		return 1000;
	elseif(introTimer < centreTime) then
		return vectr.lerp(1000, 400 + steadyDist, 1-(centreTime-introTimer)/sweepTime);
	elseif(introTimer < centreTime + steadyTime) then
		return vectr.lerp(400 + steadyDist, 400 - steadyDist, (introTimer-centreTime)/(steadyTime));
	else
		return vectr.lerp(400 - steadyDist, -200, (introTimer-(centreTime+steadyTime))/sweepTime);
	end
end

function boss.onDraw()
	if(boss.Active) then
		if(introTimer > 0) then
			textblox.printExt(boss.SuperTitle or "", {x = computeX(30, 10, 140), y = titleY, width=600, font = textblox.FONT_SPRITEDEFAULT3, scale = 1.5, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=-1})
			textblox.printExt(boss.Title or "", {x = computeX(40, 12, 120), y = titleY+15, width=600, font = textblox.FONT_SPRITEDEFAULT3X2, scale = 1.25, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=-1})
			textblox.printExt(boss.SubTitle or "", {x = computeX(50, 14, 100), y = titleY+42, width=600, font = textblox.FONT_SPRITEDEFAULT3, scale = 1.5, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=-1})
		end
		
		if(introTimer < 0 or introTimer > barAppearTime) then
			local str;
			if(boss.SuperTitle and boss.Title) then
				str = boss.SuperTitle.." "..boss.Title;
			else
				str = boss.Title or boss.SuperTitle;
			end
			if(boss.IncludeSubtitle and boss.SubTitle) then
				str = str.." "..boss.SubTitle;
			end
			textblox.printExt(str, {x = barx+barwid, y = bary+18, width=600, font = textblox.FONT_SPRITEDEFAULT3X2, scale = 0.75, halign = textblox.HALIGN_RIGHT, valign = textblox.VALIGN_TOP, z=-1})
			
			barbg:Draw{z=-1};
			
			local lerpImg;
			if(lerpHP > boss.HP) then
				lerpImg = bardmg;
			else
				lerpImg = barheal;
			end
			imagic.Bar{x=barx+2, y=bary+2, width=barwid-6, height = 10, texture = lerpImg, bgcol = 0xFFFFFF00, percent = barPos1, z=-1}
			imagic.Bar{x=barx+2, y=bary+2, width=barwid-6, height = 10, texture = barimg, bgcol = 0xFFFFFF00, percent = barPos2, z=-1}
			
		end
	end
end

return boss;