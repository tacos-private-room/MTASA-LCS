
-- Selected: #FFFFFF
-- Normal: #78aafa

DGS = exports.dgs

-- LCS COLOR:
cNormal = tocolor(120,170,250,255)
cHover = tocolor(255,255,255,255)
cTrans = tocolor(255,255,255,0)
cTitle = tocolor(200,10,10,255)

--[[
label = DGS:dgsCreateLabel(0,0,1,1,"#FFFFFFSTART GAME",true)
DGS:dgsSetProperty(label,"alignment",{"center","center"})
DGS:dgsSetProperty(label,"textSize",{1.5,1.5})
DGS:dgsSetProperty(label,"shadow",{3,3,tocolor(0,0,0,255),5})
DGS:dgsSetProperty(label,"font","bankgothic")
DGS:dgsSetProperty(label,"textColor",tocolor(120,170,250,255))
DGS:dgsSetProperty(label,"colorcoded",true)
--]]

-- dev msg


selectMenu = "TITLE_1"
stackMenu = {}
-- stack impl

function stack_menuPush(newMenu) 
    table.insert(stackMenu, newMenu)
end

function stack_menuPop() 
    if #stackMenu > 0 then
        return table.remove(stackMenu, #stackMenu)
    end
end


menuYOff = 0.06
function btn_startGame() 
    outputChatBox("start game")
end
function btn_options() 
    --outputChatBox("options")
    local sfx = playSound("blip.wav")
    setMenu("OPTIONS")
end
function btn_credit() 
    outputChatBox("credit")
end
function btn_exit() 
    triggerServerEvent ( "server_kickPlayer", resourceRoot, "Hello World!" )
end

function btn_audio() 
    outputChatBox("audio")
end

function btn_display() 
    outputChatBox("display")
end

function btn_language() 
    local sfx = playSound("blip.wav")
    setMenu("LANGUAGES")
end

function btn_english() 
    outputChatBox("eng")
end

function btn_chinese() 
    outputChatBox("chn")
end

function btn_back()
    local previorusMenu = stack_menuPop()
    setMenu(previorusMenu,true)
end
menus = {}

mainMenuItems = {
    { ["name"] = "START GAME",["type"] = "btn",["call"] = btn_startGame },
    { ["name"] = "OPTIONS",["type"] = "btn",["call"] = btn_options },
    { ["name"] = "CREDIT",["type"] = "btn" ,["call"] = btn_credit },
    { ["name"] = "EXIT GAME",["type"] = "btn",["call"] = btn_exit  },
}
OptionMenuItems = {
    { ["name"] = "AUDIO SETUP",["type"] = "btn",["call"] = btn_audio },
    { ["name"] = "DISPLAY SETUP",["type"] = "btn",["call"] = btn_display },
    { ["name"] = "LANGUAGE SETUP",["type"] = "btn" ,["call"] = btn_language },
    { ["name"] = "BACK",["type"] = "btn",["call"] = btn_back  },
}
LanguageMenuItems = {
    { ["name"] = "ENGLISH",["type"] = "btn",["call"] = btn_english },
    { ["name"] = "CHINESE",["type"] = "btn",["call"] = btn_chinese },
    { ["name"] = "BACK",["type"] = "btn",["call"] = btn_back  },
}



function gui_createMenu(items)
    if #items > 0 then
        --Find center index start drawing
        local mid = math.floor(#items / 2) + 1
        --outputChatBox(mid)
        
        -- 重中间往上开始绘制
        local offsetY = 0.5
        for i=mid,1,-1 do 
            --outputChatBox(items[i]["name"])
            local btn = gui_createMenuItem(items[i]["name"],0,offsetY)
            addEventHandler("onDgsMouseClickDown", btn,items[i]["call"])
            offsetY = offsetY - menuYOff
        end
        -- 重中间往下开始绘制
        
        if #items > mid then
            offsetY = 0.5
            for i=mid+1,#items do
                offsetY = offsetY + menuYOff
                local btn = gui_createMenuItem(items[i]["name"],0,offsetY)
                addEventHandler("onDgsMouseClickDown", btn,items[i]["call"])
            end
        end

        for k, v in pairs(items) do
            --outputChatBox(v["name"])
        end
    end

end

function gui_createMenuItem(name,x,y) 
    local ptr = DGS:dgsCreateButton(x,y,1,0.05,name,true)
    DGS:dgsSetProperty(ptr,"alignment",{"center","center"})
    DGS:dgsSetProperty(ptr,"font","bankgothic")
    DGS:dgsSetProperty(ptr,"textSize",{1.5,1.5})
    DGS:dgsSetProperty(ptr,"shadow",{2,2,tocolor(0,0,0,255),5})
    DGS:dgsSetProperty(ptr,"textColor",cNormal)
    DGS:dgsSetProperty(ptr,"color",{cTrans,cTrans,cTrans})
    -- add event handler
    addEventHandler("onDgsMouseEnter", ptr,onGuiItemHover)
    addEventHandler("onDgsMouseLeave", ptr,onGuiItemLeave)
    
    table.insert(menus, ptr)
    return ptr
end

function gui_createdevInfo() 
    lb_credit = DGS:dgsCreateLabel(0,0,1,1,"MTA:LCS - DEV BUILD (By nurupo)",true)
    DGS:dgsSetProperty(lb_credit,"alignment",{"left","bottom"})
    DGS:dgsSetProperty(lb_credit,"font","sans")
    DGS:dgsSetProperty(lb_credit,"textColor",cHover)
end

function gui_createTitle(title)
    local lb_title = DGS:dgsCreateLabel(-0.03,0.03,1,1,title,true)
    DGS:dgsSetProperty(lb_title,"alignment",{"right","top"})
    DGS:dgsSetProperty(lb_title,"textSize",{3,3})
    DGS:dgsSetProperty(lb_title,"font","pricedown")
    DGS:dgsSetProperty(lb_title,"textColor",cTitle)
    DGS:dgsSetProperty(lb_title,"shadow",{5,5,tocolor(0,0,0,255),0})
    table.insert(menus, lb_title)
    return lb_title
end
function gui_clearMenu() 
    for i = 1,#menus do 
        destroyElement(menus[i])
    end
    menus = {}
end
function onGuiItemHover() 
    DGS:dgsSetProperty(source,"textColor",cHover)
    local sfx = playSound("blip.wav")
    setSoundVolume(sfx, 0.5)
end

function onGuiItemLeave() 
    DGS:dgsSetProperty(source,"textColor",cNormal)
end


function setMenu(menuName,back)
    back = back or false
    if not back then stack_menuPush(selectMenu) end
    selectMenu = menuName
    menu()
end

function renderMainMenu()
    --Draw Title
    gui_createTitle("MAIN MENU")
    --Draw Main GUI
    gui_createMenu(mainMenuItems)
end

function renderOptionMenu()
    --Draw Title
    gui_createTitle("OPTIONS")
    --Draw Main GUI
    gui_createMenu(OptionMenuItems)

end
function renderLanguageMenu()
    --Draw Title
    gui_createTitle("LANGUAGES")
    --Draw Main GUI
    gui_createMenu(LanguageMenuItems)

end

function renderLogoVideo()
    local browser = DGS:dgsCreateMediaBrowser(256,256) --Create Multi Media Browser
    local image = DGS:dgsCreateImage(0,0,1,1,browser,true)  --Apply the browser to a dgs-dximage
    table.insert(menus, browser)
    table.insert(menus, image)
    DGS:dgsSetProperty(image,"alignment",{"center","center"})

    if selectMenu == "TITLE_1" then
        DGS:dgsMediaLoadMedia(browser,"Logo.webm","VIDEO")  --Load the gif file into multi media browser
    elseif selectMenu == "TITLE_2" then
        DGS:dgsMediaLoadMedia(browser,"GTAtitles.webm","VIDEO")  --Load the gif file into multi media browser
    end

    DGS:dgsMediaPlay(browser)

end

function renderTitleScreen() 
    local title_src = DGS:dgsCreateImage(0,0,1,1,"title.png",true)
    DGS:dgsSetProperty(title_src,"alignment",{"center","center"})
    table.insert(menus, title_src)
    -- WAIT 
    setTimer ( function()
        selectMenu = "MAIN_MENU" 
        return menu()
    end, 5000,0 )
end 


-- backrenders
function renderBackground() 
    
    local bk = DGS:dgsCreateImage(0,0,1,1,"frontend_background.png",true)
    DGS:dgsSetProperty(bk,"alignment",{"center","center"})
    --[[
    local x,y = guiGetScreenSize ()
    dxDrawImage ( 0, 0, x, y, "frontend_background.png")
    --]]
end

function menu() 
    renderBackground() 
    --render credit
    gui_createdevInfo()
    -- render Main Menu
    gui_clearMenu()

    showCursor(true)
    if selectMenu == "TITLE_SRC" then 
        return renderTitleScreen()
    elseif selectMenu == "MAIN_MENU" then 
        return renderMainMenu()
    elseif selectMenu == "OPTIONS" then 
        return renderOptionMenu()
    elseif selectMenu == "LANGUAGES" then 
        return renderLanguageMenu()
    elseif selectMenu == "TITLE_1" or selectMenu == "TITLE_2" then 
        return renderLogoVideo()
    end


end
-- Menu item handler 

menu()


--addEventHandler("onClientRender", root, renderBackground)

-- show coursor for debug

addEventHandler( "onClientKey", root, function(button,press) 
    -- deal with opening video
    if selectMenu == "TITLE_1" or selectMenu == "TITLE_2" then 
        if press and button == "mouse1" then 
            if selectMenu == "TITLE_1" then 
                selectMenu = "TITLE_2" 
                return menu() 
            elseif selectMenu == "TITLE_2" then 
                selectMenu = "TITLE_SRC" 
                return menu() 
            --[[
            elseif selectMenu == "TITLE_SRC" then 
                selectMenu = "MAIN_MENU" 
                return menu() 
            --]]
            end
        end
    end
    
    if press and button == "k" then
        if isCursorShowing(getLocalPlayer()) then
            showCursor(false)
        else 
            showCursor(true)
        end
        
        return true
    end
    return false
end )


