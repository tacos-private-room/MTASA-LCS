DGS = exports.dgs

label = DGS:dgsCreateLabel(0,0,1,1,"#FFFFFFSTART GAME\n#78aafaOPTIONS\nCREDIT\nEXIT GAME",true)
DGS:dgsSetProperty(label,"alignment",{"center","center"})
DGS:dgsSetProperty(label,"textSize",{1.7,1.7})
DGS:dgsSetProperty(label,"shadow",{1,1,tocolor(0,0,0,255),5})
DGS:dgsSetProperty(label,"font","bankgothic")
DGS:dgsSetProperty(label,"textColor",tocolor(120,170,250,255))
DGS:dgsSetProperty(label,"colorcoded",true)

label2 = DGS:dgsCreateLabel(0,0,1,1,"MTA:LCS - DEV BUILD (By nurupo)",true)
DGS:dgsSetProperty(label2,"alignment",{"left","bottom"})
DGS:dgsSetProperty(label2,"font","sans")





function mainMenu()
    local x,y = guiGetScreenSize ()
    dxDrawImage ( 0, 0, x, y, "frontend_background.png")
end


addEventHandler("onClientRender", root, mainMenu)