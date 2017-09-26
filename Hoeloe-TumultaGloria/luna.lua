local boss = API.load("boss_retcon");
boss.section = 0;

function onTick()
	if(lunatime.time() > 3) then
		boss.Begin();
	end
end