local screenWidth, screenHeight = guiGetScreenSize()
root = getRootElement()
player = getLocalPlayer()
local wanted = getPlayerWantedLevel(localPlayer)
local now = getTickCount( )
cantFire = {[40]=true}
Hud = { }
for k=43,46 do cantFire[k] = true end
for k=0,15 do cantFire[k] = true end
local start = getTickCount( )
dxDrawLine_ = dxDrawLine

for k,v in ipairs({"ammo", "armour", "health", "clock", "money", "wanted", "weapon", "breath"}) do 
	setElementData(localPlayer, "Hud:"..v, true)
	Hud[v] = true
end

-- 'round value'
function roundValue(value)
    local var = math.floor((value) + 0.5)
    return var
end

function LibertyCityStories() --======== RENDER ==========--
local now = getTickCount()

-- oxygenio
	local oxigenio = getPedOxygenLevel ( getLocalPlayer() )
	if isElementInWater (getLocalPlayer()) then
	dxDrawRectangle(roundValue(screenWidth - 188),  62, 66, 23, tocolor(255, 255, 255, 100), false)
	dxDrawRectangle(roundValue(screenWidth - 188), 62, 66/1000*oxigenio, 23, tocolor(255, 255, 255, 255), false)
	dxDrawImage(roundValue(screenWidth - 190), 62, 70, 25, "img/bar.png", 0, 0, 0, tocolor(255, 255, 255 , 255), true)
	end

-- Colete
	if not isElementInWater( getLocalPlayer()) then
	local armour = getPedArmor ( getLocalPlayer() )
		if armour>0 then
			dxDrawRectangle(roundValue(screenWidth - 188), 62, 66, 23, tocolor(0, 86, 136, 200), false)
			dxDrawRectangle(roundValue(screenWidth - 188), 62, 68/100*armour, 23, tocolor(40, 114, 179, 255), false)
			dxDrawImage(roundValue(screenWidth - 190), 62, 70, 25, "img/bar.png", 0, 0, 0, tocolor(40, 114, 179, 255), true)
		end
	end
-- Vida
	local health = math.floor( getElementHealth( getLocalPlayer() ))

	dxDrawRectangle(roundValue(screenWidth - 188), 90, 68,24, tocolor(142, 0, 0, 130), false)
	local stat = getPedStat ( getLocalPlayer(), 24 )
		if stat < 1000 then
			dxDrawRectangle(roundValue(screenWidth - 188), 90, 68/100*health, 23, tocolor(142, 0, 0, 255), false)
		else
			dxDrawRectangle(roundValue(screenWidth - 188), 72, 68/200*health, 23, tocolor(142, 0, 0, 255), false)
		end
	dxDrawImage(roundValue(screenWidth - 190), 90, 70, 25, "img/bar.png", 0, 0, 0, tocolor(255, 255, 255 , 255), true)
	
	if stat < 1000 then
	else
		dxDrawImage(roundValue(screenWidth - 175), 72, 12, 12, "img/+.png", 0, 0, 0, tocolor(255, 255, 255 , 255), true)
	end

-- nivel de procurado
local wantedL = getPlayerWantedLevel(localPlayer)
if isElementInWater (getLocalPlayer()) then
	if wanted ~= wantedL then start = getTickCount( ) wanted = wantedL end
		if wantedL ~= 0 then
			for k=1,6 do
			dxDrawImage(roundValue(screenWidth - 230+(k*30)), 150, 27, 23, "img/star2.png", 0, 0, 0, tocolor(255, 255, 255 , 255), false)
		end
		for k=1,wantedL do
			dxDrawImage(roundValue(screenWidth - 230+(k*30)), 150, 27, 23, "img/star1.png", 0, 0, 0, tocolor(255 , 255, 255, now >= start+1500 and 255 or math.abs(math.sin(now/100)*255)), false)
		end
	end
else
if wanted ~= wantedL then start = getTickCount( ) wanted = wantedL end
		if wantedL ~= 0 then
			for k=1,6 do
			dxDrawImage(roundValue(screenWidth - 230+(k*30)), 130, 27, 23, "img/star2.png", 0, 0, 0, tocolor(255, 255, 255 , 255), false)
		end
		for k=1,wantedL do
			dxDrawImage(roundValue(screenWidth - 230+(k*30)), 130, 27, 23, "img/star1.png", 0, 0, 0, tocolor(255 , 255, 255, now >= start+1500 and 255 or math.abs(math.sin(now/100)*255)), false)
		end
	end
end

	
-- Armas
	dxDrawImage(roundValue(screenWidth - 120), 30, 90, 90, "img/"..getPedWeapon(getLocalPlayer())..".png", 0, 0, 0, tocolor(255, 255, 255 , 255), true)

	
-- contagem de munição
	local showammo1 = getPedAmmoInClip (localPlayer,getPedWeaponSlot(localPlayer))
	local showammo2 = getPedTotalAmmo(localPlayer)-getPedAmmoInClip(localPlayer)
local weapon = getPedWeapon(getLocalPlayer())

if ( weapon == 0 ) or ( weapon == 1 ) or ( weapon == 2 ) or ( weapon == 3 ) or ( weapon == 4 ) or ( weapon == 5 ) or ( weapon == 6 ) or ( weapon == 7 ) or ( weapon == 8 ) or ( weapon == 9 ) or ( weapon == 10 ) or ( weapon == 11 ) or ( weapon == 12 ) or ( weapon == 14 ) or ( weapon == 15 ) or ( weapon == 40 ) or ( weapon == 44 ) or ( weapon == 45 ) or ( weapon == 46 ) then
else
	if showammo2 < 999  then
		dxDrawBorderedText2(showammo1.."-"..showammo2, screenWidth - 0, 85, screenWidth - 130, screenHeight - 700, tocolor(255, 255, 255, 200), 1.0, "default-bold", "center", "top", false, false, true)
	end
end


-- Time
	local hour, mins = getTime ()
	local Time = hour .. ":" .. (((mins < 10) and "0"..mins) or mins)
	if hour> 0 then
		dxDrawBorderedText(Time, screenWidth - 150, 25, screenWidth - 160, screenHeight - 700, tocolor(158, 115, 25, 255), 1.3, "pricedown", "center", "top", false, false, true)
	else
		dxDrawBorderedText(Time, screenWidth - 150, 25, screenWidth - 160, screenHeight - 700, tocolor(158, 115, 25, 255), 1.3, "pricedown", "center", "top", false, false, true)
	end

-- Dinheiro
	local money = string.format("%08d", getPlayerMoney(getLocalPlayer()))

	dxDrawBorderedText("$", screenWidth - 35, 115, screenWidth - 328, screenHeight - 700, tocolor(31, 74, 30, 255),
	1.3, "pricedown", "center", "top", false, false, true)
	for i=1,9 do
		dxDrawBorderedText(string.char(string.byte(money, i,i)), screenWidth - 35, 117, screenWidth - 325+i*34, screenHeight - 700, tocolor(31, 74, 30, 255), 1.2, "pricedown", "center", "top", false, false, true)
	end


	
	
end
addEventHandler("onClientRender", root, LibertyCityStories)




local hudTable = { "ammo", "armour", "health", "money", "weapon", "wanted", "breath", "clock" }
addEventHandler("onClientResourceStart", resourceRoot,
    function()
		for id, hudComponents in ipairs(hudTable) do
			setPlayerHudComponentVisible(hudComponents, false)
		end
    end)

addEventHandler("onClientResourceStop", resourceRoot,
    function()
		for id, hudComponents in ipairs(hudTable) do
			setPlayerHudComponentVisible(hudComponents, true)
		end
    end)


function dxDrawBorderedText( text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI )
trans = 155
	dxDrawText ( text, x - 1, y - 1, w - 1, h - 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x + 1, y - 1, w + 1, h - 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x - 1, y + 1, w - 1, h + 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x + 1, y + 1, w + 1, h + 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x - 1, y, w - 1, h, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x + 1, y, w + 1, h, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x, y - 1, w, h - 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x, y + 1, w, h + 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI )
end



function dxDrawBorderedText2( text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI )
trans = 50
	dxDrawText ( text, x - 1, y - 1, w - 1, h - 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x + 1, y - 1, w + 1, h - 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x - 1, y + 1, w - 1, h + 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x + 1, y + 1, w + 1, h + 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x - 1, y, w - 1, h, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x + 1, y, w + 1, h, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x, y - 1, w, h - 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x, y + 1, w, h + 1, tocolor ( 0, 0, 0, trans ), scale, font, alignX, alignY, clip, wordBreak, false )
	dxDrawText ( text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI )
end