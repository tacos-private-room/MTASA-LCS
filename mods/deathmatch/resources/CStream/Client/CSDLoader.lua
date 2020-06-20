debug.sethook(nil)
loadedDefintions = {}

function string.count (text, search)
	if ( not text or not search ) then return false end
	
	return select ( 2, text:gsub ( search, "" ) );
end


function toBoolean(input)
	return (string.count(input,'tru') > 0)
end

function prepMap(resource)
setTimer ( loadMap, 500, 1,resource)
end


function loadMap(resource)
	local temp = {}
	local File = fileOpen(':'..resource..'/gta3.CSD')
	
	loadedDefintions[resource] = {}
	local Data =  fileRead(File, fileGetSize(File))
	local Proccessed = split(Data,10)
	fileClose (File)

	for iA,vA in pairs(Proccessed) do
		local SplitA = split(vA,",")
		for i=1,8 do
			if not SplitA[i] then
				outputDebugString(SplitA[1],'| CSD Error')
				return
			end
		end
		local count = #loadedDefintions[resource]
		loadedDefintions[resource][count+1] = SplitA[1]
		temp[#temp+1] = {SplitA[1],':'..resource..'/Content/models/'..SplitA[2]..'.dff',':'..resource..'/Content/textures/'..SplitA[3]..'.txd',':'..resource..'/Content/coll/'..SplitA[4]..'.col',SplitA[5],toBoolean(SplitA[6]),toBoolean(SplitA[7]),toBoolean(SplitA[8]),SplitA[9] or nil,SplitA[10] or nil}
	end
	for i,v in ipairs(temp) do
		CCreateObjectDefinition(unpack(v))
	end
	
	local temp = nil
	fileDelete(':'..resource..'/gta3.CSD')
end


addEvent( "CSDClientMap", true )
addEventHandler( "CSDClientMap", localPlayer, prepMap)

function getMaps()
	local list = {}
	for i,v in pairs(loadedDefintions) do
		table.insert(list,i)
	end
	return list
end


addEventHandler ( "onClientResourceStop", root, 
    function (resource)
		if loadedDefintions[resource] then
			for iA,vA in pairs(loadedDefintions[resource]) do
				local SplitA = split(vA,",")
				exports.CStream:unloadModel(SplitA[1])
			end
		end
		loadedDefintions[resource] = nil
   end 
)

triggerServerEvent ( "CSDServerMap", resourceRoot )