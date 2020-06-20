server_help = createPickup (-747.28289794922,-595.95776367188, 8.8203125, 3, 1239,100)
trip_memorial = createPickup (-640.28448486328,-733.54913330078,18.863065719604, 3, 1239,100)
tip_ferry = createPickup (724.55084228516,181.92495727539,3.7781367301941, 3, 1239,100)

function armourBlock(pickup)
    if (pickup == server_help) then -- If it's an armour pickup
        exports.lcs_ui:showTextBox(source,"Welcome to Liberty City!\nThis server is still in development,new" ..
        " features will updates soon!\nWe hope you enjoy your trip in LC!",10000)
    end
    if (pickup == trip_memorial) then -- If it's an armour pickup
        exports.lcs_ui:showTextBox(source,"The Liberty City War Memorial is the name of two monuments in Staunton"..
        " Island and Shoreside Vale, in memory of a war that occurred in Liberty City.\nThe first monument is an "..
        " obelisk located in Belleville Park, Staunton Island. \nThe seond monument is located opposite Francis"..
        " International Airport, Shoreside Vale, outside the Shoreside Terminal. This monument is a statue of a"..
        " kneeling soldier holding a flag, and it features a traffic cone on its head. A plaque on the statue's base"..
         "reads \"For Those Who Fought for Freedom 1936\".",20000)
    end
    if (pickup == tip_ferry) then -- If it's an armour pickup
        exports.lcs_ui:showTextBox(source,"You can take ferry travel from Portland to Staunton.", 10000)
    end

end
addEventHandler("onPlayerPickupHit", root, armourBlock)