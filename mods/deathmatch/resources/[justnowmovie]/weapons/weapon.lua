
function w2(player,cmd,weapon_id) 
    if not weapon_id then
        outputChatBox("[用法]: /w2 (武器ID)",player)
        return
    end
    giveWeapon ( player, weapon_id, 99999999 )
end
addCommandHandler('w2',w2,false,false)