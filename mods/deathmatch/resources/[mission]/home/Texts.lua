--- EDIT HERE, YOU CAN USE YOUR LANGUAGE
function DRAW_TEXTS()

setElementData(getLocalPlayer(),"START", "Home Invasion") --- Mission title

setElementData(getLocalPlayer(),"CHAT_1", "Damn! What the fuck...?") --- Start conversation between CJ and Ryder
setElementData(getLocalPlayer(),"CHAT_2", "Man, what you doing? Digging graves?")
setElementData(getLocalPlayer(),"CHAT_3", "Damn, where the fuck did I put it, man?")
setElementData(getLocalPlayer(),"CHAT_4", "Put what, nigga?")
setElementData(getLocalPlayer(),"CHAT_5", "Man, the fucking water.")
setElementData(getLocalPlayer(),"CHAT_6", "I need a little something before I go deal with things.")
setElementData(getLocalPlayer(),"CHAT_7", "What things, fool?")
setElementData(getLocalPlayer(),"CHAT_8", "My homie. LB - he told me about this army motherfucker who's got all the guns we need.")
setElementData(getLocalPlayer(),"CHAT_9", "Not that old school Emmet bullshit neither!")
setElementData(getLocalPlayer(),"CHAT_10", "I'm down. Let's roll.")
setElementData(getLocalPlayer(),"CHAT_11", "Yeah, you always down, homie.")
setElementData(getLocalPlayer(),"CHAT_12", "Apart from when you ain't around here.")
setElementData(getLocalPlayer(),"CHAT_13", "Nigga, fuck you.")
setElementData(getLocalPlayer(),"CHAT_14", "Damn! Man, you want some of this?")
setElementData(getLocalPlayer(),"CHAT_15", "No, man - I'm cool on that. Where we going?")
setElementData(getLocalPlayer(),"CHAT_16", "This till overlooking East Beach.")
setElementData(getLocalPlayer(),"CHAT_17", "Better yet, we better wait until it's dark,")
setElementData(getLocalPlayer(),"CHAT_18", "catch the motherfucker while he is in bed!")
setElementData(getLocalPlayer(),"CHAT_19", "Yeah. I'm feeling that.")
setElementData(getLocalPlayer(),"CHAT_20", "Yeah. yeah. that's it, that's it...")
setElementData(getLocalPlayer(),"CHAT_21", "Come on, nigga, what you waiting for? Look!")
setElementData(getLocalPlayer(),"CHAT_22", "Let it go!")
setElementData(getLocalPlayer(),"CHAT_23", "Where is this old motherfucker? Where in hell is he?")
setElementData(getLocalPlayer(),"CHAT_24", "Relax man. We ain't there yet.")
setElementData(getLocalPlayer(),"CHAT_25", "Yeah, right, Carl. You always right.")
setElementData(getLocalPlayer(),"CHAT_26", "That's my homie. Mister right.")
setElementData(getLocalPlayer(),"CHAT_27", "Shut up.")
setElementData(getLocalPlayer(),"CHAT_28", "You can't stop me.")
setElementData(getLocalPlayer(),"CHAT_29", "Who can't?")
setElementData(getLocalPlayer(),"CHAT_30", "Whatever.") --- End conversation between CJ and Ryder

setElementData(getLocalPlayer(),"INFO_A", "Park the truck near the house and get the guns.") --- Start info mission
setElementData(getLocalPlayer(),"INFO_B", "Park the car in reverse, fit it in the point.")
setElementData(getLocalPlayer(),"INFO_C", "Enter the house.")
setElementData(getLocalPlayer(),"INFO_D", "Take the guns back to the truck.")
setElementData(getLocalPlayer(),"INFO_E", "Enter the truck and go back to Ryder's house.") --- End info mission

setElementData(getLocalPlayer(),"END", "Mission passed") --- Mission finished
setElementData(getLocalPlayer(),"MONEY", "50000") --- You can change the mission reward
end
addEventHandler("onClientResourceStart", root, DRAW_TEXTS)