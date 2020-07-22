function game_spawnPlayer(source) 
    spawnPlayer(source,-744.14739990234,-582.71356201172,8.8197898864746)
    fadeCamera(source,true)
    setCameraTarget(source ,source )

    --Show welcome msg
    exports.lcs_ui:showTextBox(source,"Welcome to Liberty City Stories Freeroam!",3000)
    setTimer ( function(source)
        exports.lcs_ui:showTextBox(source,"We Wish you have a good time play around in here.",3000)
    end, 4000, 1,source )

    setTimer ( function(source)
        exports.lcs_ui:showTextBox(source,"Greeting from developer - Nurupo",3000)
    end, 8000, 1,source )
end

addEventHandler( "onPlayerWasted", getRootElement( ),
	function()
		setTimer( game_spawnPlayer, 2000, 1, source )
	end
)