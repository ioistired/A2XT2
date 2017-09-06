local rewards = API.load("a2xt_rewards")
local eventu = API.load("eventu")

function onEvent (eventName)
	if eventName == "Reward"  then
		eventu.run (function()
			eventu.waitSeconds(1)
			rewards:give{type="raocoin", quantity=28}
		end)
	end
end