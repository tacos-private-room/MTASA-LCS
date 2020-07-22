function showTextBox(playerSource,msg,time)
    triggerClientEvent ( playerSource, "showClientTextBox", playerSource,msg,time)
end
function testTextbox(playerSource,_,msg,time)
    showTextBox(playerSource,msg,time)
end
addCommandHandler ( "textbox", testTextbox )