local imagic = API.load("imagic");
local textblox = API.load("textblox");
local vectr = API.load("vectr");

local boss = {}

boss.SuperTitle = nil;
boss.Name = nil;
boss.SubTitle = nil;
boss.MaxHP = 100;
boss.HP = boss.MaxHP;
boss.IncludeSupertitle = false;
boss.IncludeSubtitle = false;

boss.Active = false;

local introTimer = 0;

boss.LerpSpeed = 0.2;

local barx = 64;
local bary = 600-24;
local barwid = 800-2*barx;

local titleY = 450;

local barbgimg = Graphics.loadImage(Misc.resolveFile("graphics/HUD/boss_background.png"));
local barimg = Graphics.loadImage(Misc.resolveFile("graphics/HUD/boss_bar.png"));
local bardmg = Graphics.loadImage(Misc.resolveFile("graphics/HUD/boss_dmg.png"));
local barheal = Graphics.loadImage(Misc.resolveFile("graphics/HUD/boss_heal.png"));

local barbg = imagic.Create{x=barx, y=bary, primitive = imagic.TYPE_BOXBORDER, width = barwid, height = 16, depth = 8, texture = barbgimg};

local lerpHP = boss.MaxHP;

local barPos1, barPos2 = 0,0;

local barAppearTime = 200;

boss.TitleDisplayTime = 200;

function boss.onInitAPI()
	registerEvent(boss, "onDraw", "onDraw", false);
	registerEvent(boss, "onTick", "onTick", false);
end

function boss.Start()
	boss.Active = true;
	boss.HP = boss.MaxHP;
	lerpHP = boss.MaxHP;
end

function boss.isReady()
	return boss.Active and introTimer < 0;
end

function boss.isDefeated()
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
	if(boss.Active) then
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
			barPos1 = (introTimer - boss.TitleDisplayTime)/barAppearTime;
			barPos2 = barPos1;
		else
			barPos1 = math.max(lerpHP, boss.HP)/boss.MaxHP;
			barPos2 = math.min(lerpHP, boss.HP)/boss.MaxHP
		end
		
		if(introTimer > boss.TitleDisplayTime + barAppearTime) then
			introTimer = -1;
		end
	end
end

--[[
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
]]

local function computeAlpha(start, finish)
	if(introTimer > boss.TitleDisplayTime) then
		return 255*(1-((introTimer-boss.TitleDisplayTime)/barAppearTime))
	else
		return 255*math.clamp(((introTimer/boss.TitleDisplayTime)/(finish-start))-start);
	end
end

local function printTitle(text, y, scale, fadestart, fadeend)
	if(text) then
		local alpha = computeAlpha(fadestart,fadeend);
		textblox.printExt(text, {x = 400, y = y+2, width=600, font = textblox.FONT_SPRITEDEFAULT4X2, scale = scale, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=5, color=0x00000000+alpha})
		textblox.printExt(text, {x = 400, y = y, width=600, font = textblox.FONT_SPRITEDEFAULT4X2, scale = scale, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_TOP, z=5, color=0xFFFFFF00+alpha})
	end
end

function boss.onDraw()
	if(boss.Active) then
		if(introTimer > 0) then
			printTitle(boss.SuperTitle, titleY, 1, 0, 0.5);
			printTitle(boss.Name, titleY+22, 2, 0.25, 0.75);
			printTitle(boss.SubTitle, titleY+60, 1, 0.5, 1);
		end
		
		if(introTimer < 0 or introTimer > boss.TitleDisplayTime) then
			local str;
			if(boss.IncludeSupertitle and boss.SuperTitle and boss.Name) then
				str = boss.SuperTitle.." "..boss.Name;
			else
				str = boss.Name or boss.SuperTitle;
			end
			if(boss.IncludeSubtitle and boss.SubTitle) then
				str = str.." "..boss.SubTitle;
			end
			
			barbg:Draw{z=5};
			
			local lerpImg;
			if(lerpHP > boss.HP) then
				lerpImg = bardmg;
			else
				lerpImg = barheal;
			end
			imagic.Bar{x=barx+2, y=bary+2, width=barwid-6, height = 10, texture = lerpImg, bgcol = 0xFFFFFF00, percent = barPos1, z=5}
			imagic.Bar{x=barx+2, y=bary+2, width=barwid-6, height = 10, texture = barimg, bgcol = 0xFFFFFF00, percent = barPos2, z=5}
			
			local tx,ty = barx+4, bary+12;
			for i = -1,1,2 do
				textblox.printExt(str, {x = tx+i*2, y = ty, width=600, font = textblox.FONT_SPRITEDEFAULT4X2, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_BOTTOM, z=5, color=0x000000FF})
			end
			for i = -1,1,2 do
				textblox.printExt(str, {x = tx, y = ty+i*2, width=600, font = textblox.FONT_SPRITEDEFAULT4X2, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_BOTTOM, z=5, color=0x000000FF})
			end
			textblox.printExt(str, {x = tx, y = ty, width=600, font = textblox.FONT_SPRITEDEFAULT4X2, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_BOTTOM, z=5})
		end
	end
end

return boss;