local raocoins = API.load("a2xt_raocoincounter")

local cheats = {}

Cheats.deregister("dressmeup");
Cheats.deregister("captainn");
Cheats.deregister("moneytree");

Cheats.addAlias("itsamemario", "thatisademo")
Cheats.addAlias("itsamemario", "thatsademo")
Cheats.addAlias("itsameluigi", "thatisaniris")
Cheats.addAlias("itsameluigi", "thatsaniris")
Cheats.addAlias("anothercastle", "heyeveryone")
Cheats.addAlias("ibakedacakeforyou", "luigisonlyfriend")
Cheats.addAlias("iamerror", "sleptonthebus")

for _,v in ipairs(Cheats.listCheats()) do
	local n = v:match("^needan(.+)$");
	if(n == nil) then
		n = v:match("^needa(.+)$");
	end
		
	if(n) then
		Cheats.addAlias(v, "gimmie"..n);
	end
end

Cheats.addAlias("donthurtme", "strategyyo")
Cheats.addAlias("1player", "raomode")
Cheats.addAlias("2player", "pprmode")
Cheats.addAlias("speeddemon", "chipmunktime")

Cheats.register("heresmycreditcard", {onActivate = function() raocoins.set(100) return true end, activateSFX = 59})

return cheats;