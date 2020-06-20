addEventHandler("onClientRender", root,
    function()
        local x,y,z = getElementPosition( getLocalPlayer() )
        local rx,ry,rz = getElementRotation(getLocalPlayer())
        local msg = string.format("%f    %f    %f",x,y,z)

        dxDrawText("    "..x.."    "..y.."    "..z.."    "..rz, 354 - 1, 32 - 1, 1389 - 1, 75 - 1, tocolor(0, 0, 0, 255), 2.00, "sans", "right", "top", false, false, false, false, false)
        dxDrawText("    "..x.."    "..y.."    "..z.."    "..rz, 354 + 1, 32 - 1, 1389 + 1, 75 - 1, tocolor(0, 0, 0, 255), 2.00, "sans", "right", "top", false, false, false, false, false)
        dxDrawText("    "..x.."    "..y.."    "..z.."    "..rz, 354 - 1, 32 + 1, 1389 - 1, 75 + 1, tocolor(0, 0, 0, 255), 2.00, "sans", "right", "top", false, false, false, false, false)
        dxDrawText("    "..x.."    "..y.."    "..z.."    "..rz, 354 + 1, 32 + 1, 1389 + 1, 75 + 1, tocolor(0, 0, 0, 255), 2.00, "sans", "right", "top", false, false, false, false, false)
        dxDrawText("#f21d1d    "..x.."#23b74e    "..y.."#4e6ef5    "..z.."#7f7f8b    "..rz, 354, 32, 1389, 75, tocolor(255, 255, 255, 255), 2.00, "sans", "right", "top", false, false, false, true, false)
    end
)

