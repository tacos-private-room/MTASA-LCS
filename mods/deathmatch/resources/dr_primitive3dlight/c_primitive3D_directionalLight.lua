--  
-- file: c_primitive3D_directionalLight.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/primitive3D_directionalLight.fx, c_common.lua

local scx,scy = guiGetScreenSize ()

CPrmLightDirectional = { }
CPrmLightDirectional.__index = CPrmLightDirectional

-- worldPosition Vector3() , attenuation Vector1(0-n), color Vector4(0-255,0-255,0-255,0-255) 
function CPrmLightDirectional: create( dir, col )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shader = DxShader( "fx/primitive3D_directionalLight.fx" ),
		direction = dir,
		color = Vector4(col.x, col.y, col.z, col.w),
		distFade = Vector2(950, 850)
	}
	if cShader.shader then
		cShader.shader:setValue( "fViewportSize", scX, scY )
		cShader.shader:setValue( "fViewportScale", 1, 1 )
		cShader.shader:setValue( "fViewportPos", 0, 0 )
		cShader.shader:setValue( "bForceFogOn", true )
		
		cShader.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
		cShader.shader:setValue( "sLightDir", cShader.direction.x, cShader.direction.y, cShader.direction.z )
		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		cShader.shader:setValue( "sHalfPixel", 1/(scX * 2), 1/(scY * 2) )
		
		cShader.trianglelist = trianglelist.plane
		
		if renderTarget.isOn then
			cShader.shader:setValue( "ColorRT", renderTarget.RTColor )
			cShader.shader:setValue( "NormalRT", renderTarget.RTNormal )
		end

		self.__index = self
		setmetatable( cShader, self )
		return cShader
	else
		return false
	end
end

function CPrmLightDirectional: setTesselationByDistance()
	-- for compatibility
end

function CPrmLightDirectional: setDirection( dir )
	if self.shader then
		self.direction = Vector3(dir.x, dir.y, dir.z)
		self.shader:setValue( "sLightDir", dir.x, dir.y, dir.z )
	end
end	
	
function CPrmLightDirectional: setRotation( rotDeg )
	if self.shader then
		local rot = Vector3(math.rad(rotDeg.x), math.rad(rotDeg.y), math.rad(rotDeg.z))
		local dir = Vector3(-math.cos(rot.x) * math.sin(rot.z), math.cos(rot.z) * math.cos(rot.x), math.sin(rot.x))
		self.direction = Vector3(dir.x, dir.y, dir.z)
		self.shader:setValue( "sLightDir", dir.x, dir.y, dir.z )
	end
end	

function CPrmLightDirectional: setDistFade( distFade )
	if self.shader then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CPrmLightDirectional: setPosition( pos )
	-- for compatibility
end

function CPrmLightDirectional: setAttenuation( atten )
	-- for compatibility
end

function CPrmLightDirectional: setAttenuationPower( attenPow )
	-- for compatibility
end

function CPrmLightDirectional: setColor( col )
	if self.shader then
		self.color = Vector4(col.x, col.y, col.z, col.w)
		self.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
	end
end

function CPrmLightDirectional: getObjectToCameraAngle()
	-- for compatibility
end

function CPrmLightDirectional: getDistanceFromViewAngle( inAngle )
	-- for compatibility
end

function CPrmLightDirectional: draw()
	if self.shader then
		-- draw the outcome
		dxDrawMaterialPrimitive3D( "trianglelist", self.shader, false, unpack( self.trianglelist ) )
	end
end
        
function CPrmLightDirectional: destroy()
	if self.shader then
		self.shader:destroy()
		self.shader = nil
	end
	self = nil
	return true
end
