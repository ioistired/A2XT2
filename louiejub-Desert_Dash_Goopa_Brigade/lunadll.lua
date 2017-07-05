local iniDone = false;
function onLoop()
   if (not iniDone) then
      Player(1).character = CHARACTER_TOAD;
      iniDone = true;
   end
end