addEventHandler( 'onClientRender', getRootElement( ), 
    function( )
        --setTime( 1, 0 )
        local time = getElementData( getLocalPlayer(), "time" ) or 10
        setTime( time, 0 )
        local wea = getElementData( getLocalPlayer(), "wea" ) or 0
        setWeather( wea )
    end 
) 