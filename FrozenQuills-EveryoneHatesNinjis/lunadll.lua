
--dir = 0

--[[kill boos with fireballs
   for k,v in pairs(findnpcs(43,-1)) do
      for l,w in pairs(findnpcs(13,-1)) do
         local bb = { l = v.x - 8, r = v.x+v:mem(0x88,FIELD_DFLOAT) + 8, t = v.y - 8, b = v.y + v:mem(0x90,FIELD_DFLOAT) + 8 }
         local bf = { l = w.x, r = w.x+w:mem(0x88,FIELD_DFLOAT), t = w.y, b = w.y + w:mem(0x90,FIELD_DFLOAT) }
         
         if(bb.l < bf.r and bb.r > bf.l and bb.t < bf.b and bb.b > bf.t) then
            v:kill()
            w:kill()
         end
         
      end
   end
 ]]--

local colliders = API.load("colliders");
local hit = false;
local angle = 0;
local positions = {};
local dTheta = 0.03;
 
local left = 700;
local right =  800 - left;
local up = 400;
local down = 800 - up;
local speed = 1.4;


function onLoad()

end

function setNpcSpeed(npcid, speed)
   local p = mem(0x00b25c18, FIELD_DWORD) -- Get the pointer to the NPC speed array
   mem(p + (0x4 * npcid), FIELD_FLOAT, speed)
end

local tt = 0
--local fishpile = Graphics.loadImage("fishpile.png");
function onLoopSection0(asdf)
  --[[if tt == 0 then
    player:mem(0x108, FIELD_WORD, 0);
  end
  
  tt = 1;]]
end

local ded = false
local frame = false;
local warping = false;
function onLoopSection1(asdf)

  screen = player.sectionObj.boundary
  if frame == false then
    m = player.x
    frame = true
  end
  
    
  for  k,v in pairs(NPC.get(77, 1))  do
      
      if player.x <= v.x - left + 32 and player:mem(0x14C,FIELD_WORD) ~= 0 and ded == false and player:mem(0x14A,FIELD_WORD) == 0 then 
        player:kill();
        ded = true
      end
  
      if v.x > m then
        screen.left = v.x - left
        screen.right = v.x + right
        m = v.x
      end
      player.sectionObj.boundary = screen

      if v.x > -169285 then
        setNpcSpeed(77, 0);
      end

  end
  
    if player.x > -169444 then
    triggerEvent("ohnoes")
  end
  
  --[[for  k,v in pairs(NPC.get(242, 1))  do
    Graphics.drawImageToScene(fishpile, v.x, v.y-256);
  end]]
end




local t = 0
local coins = 99
local robbed = false
local got50 = false
function onLoopSection2(asdf)
  if t == 0 then
    mem(0x00B2C5A8,FIELD_WORD,0);
  end
  for  k,v in pairs(NPC.get(77, 2))  do
    if(colliders.collide(player, v)) then
      playSFX(14);
      mem(0x00B2C5A8,FIELD_WORD,0);
      robbed = true;
    end
  end
  if mem(0x00B2C5A8,FIELD_WORD) >= 50 and robbed == true and got50 == false then
    triggerEvent("got50")
    got50 = true
  end
  if mem(0x00B2C5A8,FIELD_WORD) > 90 then
    mem(0x00B2C5A8,FIELD_WORD,90);
  end
  t = t + 1;
  
  --[[for  k,v in pairs(NPC.get(242, 2))  do
    Graphics.drawImageToScene(fishpile, v.x, v.y-256);
  end]]
end

function onKeyUp(key, plIndex)

	end
	
function onKeyDown(key, plIndex)

  if key == KEY_DOWN and (player.section == 0 or player.section == 1 or player.section == 3) then
      player.speedY = 10;
    end

end

	
function onEvent(e)
  if(e == "steal2") then
    for  k,v in pairs(NPC.get(77, 1))  do
      v.direction = DIR_LEFT;
    end
  end
  
  if(e == "steal3") then
    for  k,v in pairs(NPC.get(77, 1))  do
      v.direction = DIR_RIGHT;
      setNpcSpeed(77, 5);
    end
  end
  
  if(e == "arrived2") then
    mem(0x00B2C5A8,FIELD_WORD,coins);
  end
  
  if(e == "rob") then
    player.speedX = 0;
    setNpcSpeed(77, 6);
  end
  
  if(e == "nevada5") or (e == "revert") then
    for  k,v in pairs(NPC.get(89, 2))  do
      v.direction = DIR_RIGHT;
      setNpcSpeed(89, 2);
      robbed = true;
    end
  end
  
  if(e == "showleek") then
    c = mem(0x00B2C5A8,FIELD_WORD) - 50
    mem(0x00B2C5A8,FIELD_WORD,c);
  end

end
