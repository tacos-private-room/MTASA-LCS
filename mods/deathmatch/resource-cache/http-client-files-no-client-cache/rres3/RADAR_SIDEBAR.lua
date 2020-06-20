--///////////////////////////--
--//     (c) 2018-2019     //--
--//       by Lorenzo      //--
--//    Lake-Gaming.com    //--
--///////////////////////////--

--Resolution 1920x1080

local screenwidth,screenheight = guiGetScreenSize()

local MapLegendenName = {"MAP Legende",
"Ammunation",}
local MapLegendenImage = {"IMAGES/EMPTY.png",
"IMAGES/18.png",}

local sidebarFont=dxCreateFont("SEGOEUI.ttf",10)
function renderSidebarF11()
	if(isPlayerMapVisible(lp)==true)then
		local di=0
		for i=1,#MapLegendenName do
			dxDrawRectangle(screenwidth-260,20,240,20+(di*20.2),tocolor(0,0,0,255),false)
			dxDrawText(tostring(MapLegendenName[i]),screenwidth-230,21+(di*20),100,40,tocolor(255,255,255,255),1.10,sidebarFont,"left","top",false,false,true,false,false)
			dxDrawImage(screenwidth-255,21+(di*20),20,20,MapLegendenImage[i],0,0,0,tocolor(255, 255, 255, 255),true)
			di=di+1
		end
		dxDrawRectangle(screenwidth-260,40,240,1.5,tocolor(0,150,255,255),false)
	end
end
addEventHandler("onClientRender",root,renderSidebarF11)