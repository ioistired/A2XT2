
local colliders = API.load("colliders")
local hit = false;
local angle = 0;
local positions = {};
local dTheta = 0.03;
local particles = API.load("particles")

local fog = particles.Emitter(0, 0, Misc.resolveFile("particles/p_fog.ini"), 1)
fog:AttachToCamera(Camera.get()[1]);
fog:Scale(1.2)

function setNpcSpeed(npcid, speed)
   local p = mem(0x00b25c18, FIELD_DWORD) -- Get the pointer to the NPC speed array
   mem(p + (0x4 * npcid), FIELD_FLOAT, speed)
end

function onLoop()
    if player.section == 1 and fog.enabled == false and stopFalling == false then
      fog.enabled = true
    elseif player.section ~= 1 and fog.enabled == true then
      fog.enabled = false
    end
    
    if player.section == 9 and player.y < -21408 then
      fog.enabled = true
    end

    bigsaws = NPC.get(152, -1);

    angle = angle + dTheta;

    for k,v in pairs(bigsaws) do
      local circle = colliders.Circle(v.x+50, v.y+52, 60);
      if(v:mem(0x128, FIELD_WORD) ~= -1) then
        if (colliders.collide(player, circle) and hit == false and v.layerName.str ~= "donthurt") then
            player:harm();
        end
      end
      
      boomerangs = NPC.get(292, -1)
      for kb,vb in pairs(boomerangs) do
        local box = colliders.Circle(vb.x+16, vb.y+16, 40);
        if colliders.collide(box, circle) then
          vb:kill();
        end
      end
      
      for ki, vi in pairs(NPC.get(80, player.section)) do
        if(colliders.collide(vi, v)) then
          vi.speedY = -7;
          if(vi.layerName.str == "Spawned NPCs") then
            vi.speedX = -6;
          end
        end
      end
      
      for ki, vi in pairs(NPC.get(1, player.section)) do
        if(colliders.collide(vi, v) and v.layerName.str ~= "donthurt") then
          vi:kill(2);
        end
      end
      
      for ki, vi in pairs(NPC.get(175, player.section)) do
        if(colliders.collide(vi, v)) then
          vi:kill(2);
        end
      end
      
      for ki, vi in pairs(NPC.get(174, player.section)) do
        if(colliders.collide(vi, v)) then
          vi:kill(2);
        end
      end
      
      for ki, vi in pairs(NPC.get(177, player.section)) do
        if(colliders.collide(vi, v)) then
          vi:kill(2);
        end
      end
      
      for ki, vi in pairs(NPC.get(173, player.section)) do
        if(colliders.collide(vi, v)) then
          vi:kill(2);
        end
      end
      
      for ki, vi in pairs(NPC.get(172, player.section)) do
        if(colliders.collide(vi, v)) then
          vi:kill(2);
        end
      end
      
      for ki, vi in pairs(NPC.get(130, player.section)) do
        if(colliders.collide(vi, v)) then
          vi:kill(2);
        end
      end

      
      --WHEE ROTATIONS
      if player.section == 2 or player.section == 8 or player.section == 9 then
        if(v.layerName.str == "dan1") then
          if(positions[v.layerName.str] == nil) then
              
            for ki, vi in pairs(NPC.get(103, player.section)) do
              if(vi.layerName.str == v.layerName.str) then
                vi.x = v.x+40;
                vi.y = v.y+48;
              end
            end
            
            pos = {};
            pos["X"] = v.x;
            pos["Y"] = v.y;
            positions[v.layerName.str] = pos
          end
          v.x = 170 * math.cos(angle) + positions[v.layerName.str]["X"];
          v.y = 170 * math.sin(angle) + positions[v.layerName.str]["Y"];
        end
        if(v.layerName.str == "dan2") then
          if(positions[v.layerName.str] == nil) then
            pos = {};
            pos["X"] = v.x;
            pos["Y"] = v.y;
            positions[v.layerName.str] = pos
          end
          v.x = -170 * math.cos(angle) + positions[v.layerName.str]["X"];
          v.y = -170 * math.sin(angle) + positions[v.layerName.str]["Y"];
        end
        if(v.layerName.str == "dan3") then
          if(positions[v.layerName.str] == nil) then
          
                      
            for ki, vi in pairs(NPC.get(103, player.section)) do
              if(vi.layerName.str == v.layerName.str) then
                vi.x = v.x+40;
                vi.y = v.y+48;
              end
            end
            
            pos = {};
            pos["X"] = v.x;
            pos["Y"] = v.y;
            positions[v.layerName.str] = pos
          end
          v.x = 170 * math.cos(-angle) + positions[v.layerName.str]["X"];
          v.y = 170 * math.sin(-angle) + positions[v.layerName.str]["Y"];
        end
        if(v.layerName.str == "dan4") then
          if(positions[v.layerName.str] == nil) then
            pos = {};
            pos["X"] = v.x;
            pos["Y"] = v.y;
            positions[v.layerName.str] = pos
          end
          v.x = -170 * math.cos(-angle) + positions[v.layerName.str]["X"];
          v.y = -170 * math.sin(-angle) + positions[v.layerName.str]["Y"];
        end
        if(v.layerName.str == "dan5") then
          if(positions[v.layerName.str] == nil) then
            pos = {};
            pos["X"] = v.x;
            pos["Y"] = v.y;
            positions[v.layerName.str] = pos
          end
          v.x = -170 * math.cos(angle*1.5) + positions[v.layerName.str]["X"];
          v.y = -170 * math.sin(angle*1.5) + positions[v.layerName.str]["Y"];
        end
        if(v.layerName.str == "dan6") then
          if(positions[v.layerName.str] == nil) then
            pos = {};
            pos["X"] = v.x;
            pos["Y"] = v.y;
            positions[v.layerName.str] = pos
          end
          v.x = 170 * math.cos(angle*2.1) + positions[v.layerName.str]["X"];
          v.y = 170 * math.sin(angle*2.1) + positions[v.layerName.str]["Y"];
        end
      end
    end
	end


  
function onLoopSection0()
  local bigsaws = NPC.get(152, 0)
  local saws = NPC.get(179, 0)
  local k = 40
  for _,v in pairs(bigsaws) do
    v:mem(0x12A, FIELD_WORD, 180)
    k = k + 20
  end
  for _,v in pairs(saws) do
    v:mem(0x12A, FIELD_WORD, 180)
    k = k + 20
  end
end


function onLoopSection2()
  local bigsaws = NPC.get(152, 2)
  local saws = NPC.get(179, 2)
  local k = 40
  for _,v in pairs(bigsaws) do
    v:mem(0x12A, FIELD_WORD, 180)
    k = k + 20
  end
  for _,v in pairs(saws) do
    v:mem(0x12A, FIELD_WORD, 180)
    k = k + 20
  end
end

function onLoopSection3()
  local bigsaws = NPC.get(152, 3)
  local saws = NPC.get(179, 3)
  local k = 40
  for _,v in pairs(bigsaws) do
    v:mem(0x12A, FIELD_WORD, 180)
    k = k + 20
  end
  for _,v in pairs(saws) do
    if(v.y < -139424) then
      v:mem(0x12A, FIELD_WORD, 180)
      v:mem(0x74, FIELD_WORD, -1)
    else
      v:kill(9)
    end
    k = k + 20
  end
end

function onLoopSection4()
  local keys = NPC.get(31, 4)
  local num = 0
  local offscreen = 0
  for _,v in pairs(keys) do
    num = num + 1
    if(v:mem(0x128, FIELD_WORD) == -1) then
      offscreen = 1
      v:kill(9)
    end
  end
  if(offscreen == 1) then
    NPC.spawn(31, -119968, -120352, 4, false)
  end
end
  

function onLoopSection9()
  local platforms = NPC.get(106, 9)
  local k = 20
  for _,v in pairs(platforms) do
    if(v.y > -22816) then
      v:mem(0x12A, FIELD_WORD, 180)
      v:mem(0x74, FIELD_WORD, -1)
    else
      v:kill(9)
    end
    k = k + 20
  end
end

local T = 0
local wobble = 0.5
local fallingSaw = false
local f = 2
local stopFalling = false
function onLoopSection1()
  local l = Layer.get("whee")
  if fallingSaw == false then
    if T % 10 == 0 then
      wobble = -wobble
      T = 1
    end
    l.speedX = wobble
    T = T + 1
  elseif f < 32 then
    l.speedX = 0
    l.speedY = f
    f = f + 1
  elseif stopFalling == false then
    stopFalling = true
    l.speedY = 0
    playSFX(68)
    playMusic(20)
    fog.enabled = false
  end

end


function onEvent(e)
  if e == "whoops" then
    fallingSaw = true
  end
end


function onCameraUpdate()
	fog:Draw();
end
