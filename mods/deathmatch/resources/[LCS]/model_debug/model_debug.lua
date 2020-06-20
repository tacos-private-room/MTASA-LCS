function replaceWeapon()
    col = engineLoadCOL( "model.col" )
    txd = engineLoadTXD( "MyModel.txd" )
    dff = engineLoadDFF( "MyModel.dff" )

    engineReplaceCOL( col, 1234 )
    engineImportTXD( txd, 1234 )
    engineReplaceModel( dff, 1234 )-- replace the model at least

end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceWeapon)