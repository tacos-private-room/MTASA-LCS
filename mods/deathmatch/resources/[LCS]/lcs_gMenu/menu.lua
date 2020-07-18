function mainMenu()

    local x,y = guiGetScreenSize ()
    dxDrawImage ( 0, 0, x, y, "loadsc0.png")
end


addEventHandler("onClientRender", root, mainMenu)