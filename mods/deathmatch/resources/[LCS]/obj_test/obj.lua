col = engineLoadCOL( "iz_ShrSdPlcRm.col" )
txd = engineLoadTXD( "PoliceRoom.txd" )
dff = engineLoadDFF( "iz_ShrSdPlcRm.dff" )

engineReplaceCOL( col, 1234 )
engineImportTXD( txd, 1234 )
engineReplaceModel( dff, 1234 )-- replace the model at least

local obj = createObject (1234, 0, 0, 10,0, 0,0)
setElementDoubleSided ( obj, true)

function getID (element)
    return getElementID(element) or getElementData(element,'ID')
end

for i,v in pairs(getElementsByType('object',resourceRoot)) do

    local id = getID(v)
    outputDebugString(id)
end