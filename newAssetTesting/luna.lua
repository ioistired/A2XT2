local rewards = API.load("a2xt_rewards")
local eventu = API.load("eventu")

function onStart()
	eventu.run (function()
		eventu.waitSeconds(1)
		rewards:give{type="raocoin", quantity=28}
	end)
end