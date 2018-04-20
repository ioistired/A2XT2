--------------------------------------------------
-- Level code
-- Created 15:30 2016-9-14
--------------------------------------------------

local particles = API.load("particles");

local spark1 = particles.Emitter(-119503,-120415, Misc.resolveFile("particles/p_spark_electric.ini"));
local burnsmoke = particles.Emitter(-119296,-120065, Misc.resolveFile("particles/p_smoke_large.ini"));
local heat1 = particles.Emitter(-139888,-140279, Misc.resolveFile("particles/p_spark_heat_simple.ini"));
local heat2 = particles.Emitter(-139730,-140276, Misc.resolveFile("particles/p_spark_heat_simple.ini"));

local pipesmoke1 = particles.Emitter(-139570,-140362, Misc.resolveFile("particles/p_smoke_small.ini"));
local pipesmoke2 = particles.Emitter(-139537,-140362, Misc.resolveFile("particles/p_smoke_small.ini"));

function onCameraUpdate()
    spark1:Draw();
    burnsmoke:Draw(-15.0);
    heat1:Draw(-75);
    heat2:Draw(-75);
    pipesmoke1:Draw(-75);
    pipesmoke2:Draw(-75);
end

-- Run code on level start
function onStart()
    --Your code here
end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    --Your code here
end

-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onEvent(eventName)
    --Your code here
end

