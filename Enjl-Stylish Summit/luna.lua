--------------------------------------------------
-- Level code
-- Created 22:38 2018-8-8
--------------------------------------------------

local particles = API.load("particles")

local e_snow = particles.Emitter(0,0,Misc.resolveFile("snowy.ini"))
e_snow:AttachToCamera(Camera.get()[1])

-- Run code on level start
function onLoadSection()
    e_snow:setPrewarm(5)
end

-- Run code every frame (~1/65 second)
-- (code will be executed before game logic will be processed)
function onTick()
    --Your code here
end

-- Run code when internal event of the SMBX Engine has been triggered
-- eventName - name of triggered event
function onDraw()
    e_snow:Draw(0)
end

