--  
-- file: c_primitive3D_specularLight.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/primitive3D_specularLight.fx, c_common.lua

local scx,scy = guiGetScreenSize ()

CPrmLightSpecular = { }
CPrmLightSpecular.__index = CPrmLightSpecular

-- worldPosition Vector3() , attenuation Vector1(0-n), color Vector4(0-255,0-255,0-255,0-255) 
function CPrmLightSpecular: create(pos, atten, col )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shader = DxShader( "fx/primitive3D_specularLight.fx" ),
		color = Vector4(col.x, col.y, col.z, col.w),
		position = Vector3(pos.x, pos.y, pos.z),
		attenuation = atten,
		attenuationPower = 2,
		specPower = 16,
		fixedLightDir = false,
		direction = Vector3(0, 0, -1),
		tessSwitch = false,
		tickCount = 0,
		distFade = Vector2(950, 850)
	}
	if cShader.shader then
		cShader.shader:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
		cShader.shader:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shader:setValue( "sLightAttenuationPower", cShader.attenuationPower )
		
		cShader.shader:setValue( "sLightDir", cShader.direction.x, cShader.direction.y, cShader.direction.z )
		cShader.shader:setValue( "bFixedDirection", cShader.fixedLightDir )
		cShader.shader:setValue( "sSpecularPower", cShader.specPower )

		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		cShader.shader:setValue( "sHalfPixel", 1/(scX * 2), 1/(scY * 2) )
		
		if isSM3DBSupported then 
			local distFromCam = ( pos - getCamera().matrix.position ).length
			if ( distFromCam < 4 * atten ) then 	
				cShader.trianglelist = trianglelist.sphere
				cShader.shader:setValue( "sLightBillboard", false )
				cShader.tessSwitch = true
			else
				cShader.trianglelist = trianglelist.plane
				cShader.shader:setValue( "sLightBillboard",  true )
				cShader.tessSwitch = false
			end
			if renderTarget.isOn then
				cShader.shader:setValue( "ColorRT", renderTarget.RTColor )
				cShader.shader:setValue( "NormalRT", renderTarget.RTNormal )
			end			
		end

		self.__index = self
		setmetatable( cShader, self )
		return cShader
	else
		return false
	end
end	

function CPrmLightSpecular: setTesselationByDistance()
	if self.shader and isSM3DBSupported then
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < 4 * self.attenuation ) then 
			if not self.tessSwitch then
				self.trianglelist = trianglelist.sphere
				self.shader:setValue( "sLightBillboard", false )
				self.tessSwitch = true
			end
		else
			if self.tessSwitch then
				self.trianglelist = trianglelist.plane
				self.shader:setValue( "sLightBillboard",  true )
				self.tessSwitch = false
			end
		end		
	end
end
	
function CPrmLightSpecular: setDirection( dir )
	if self.shader then
		self.direction = Vector3(dir.x, dir.y, dir.z)
		self.shader:setValue( "sLightDir", dir.x, dir.y, dir.z )
	end
end	

function CPrmLightSpecular: setFixedDirection( isDir )
	if self.shader then
		self.fixedLightDir = isDir
		self.shader:setValue( "bFixedDirection", isDir )
	end
end	

function CPrmLightSpecular: setSpecularPower( specPow )
	if self.shader then
		self.specPower = specPow
		self.shader:setValue( "sSpecularPower", specPow )
	end
end

function CPrmLightSpecular: setRotation( rotDeg )
	if self.shader then
		local rot = Vector3(math.rad(rotDeg.x), math.rad(rotDeg.y), math.rad(rotDeg.z))
		local dir = Vector3(-math.cos(rot.x) * math.sin(rot.z), math.cos(rot.z) * math.cos(rot.x), math.sin(rot.x))
		self.direction = Vector3(dir.x, dir.y, dir.z)
		self.shader:setValue( "sLightDir", dir.x, dir.y, dir.z )
	end
end	

function CPrmLightSpecular: setDistFade( distFade )
	if self.shader then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CPrmLightSpecular: setPosition( pos )
	if self.shader then
		self.position = Vector3(pos.x, pos.y, pos.z)
		self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
	end
end

function CPrmLightSpecular: setAttenuation( atten )
	if self.shader then
		self.attenuation = atten
		self.shader:setValue( "sLightAttenuation", atten )
		self:setTesselationByDistance()
	end
end

function CPrmLightSpecular: setAttenuationPower( attenPow )
	if self.shader then
		self.attenuationPower = attenPow
		self.shader:setValue( "sLightAttenuationPower", attenPow )
	end
end

function CPrmLightSpecular: setColor( col )
	if self.shader then
		self.color = Vector4(col.x, col.y, col.z, col.w)
		self.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
	end
end

function CPrmLightSpecular: getObjectToCameraAngle()
	if self.position then
		local camMat = getCamera().matrix
		local camFw = camMat:getForward()
		local elementDir = ( self.position - camMat.position ):getNormalized()
		return math.acos( elementDir:dot( camFw ) / ( elementDir.length * camFw.length ))
	else
		return false
	end
end

function CPrmLightSpecular: getDistanceFromViewAngle( inAngle )
	if self.shader then
		return ( self.attenuation / 2 ) / math.atan(inAngle)
	else
		return false
	end
end

function CPrmLightSpecular: draw()
	if self.shader then
		local clipDist = math.min( self.distFade.x, getFarClipDistance() + self.attenuation )
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < clipDist ) and isEntityInFrontalSphere(self.position, self.attenuation) then		
			self.tickCount = self.tickCount + lastFrameTickCount + math.random(500)
			if self.tickCount > tesselationSwitchDelta then            
				self:setTesselationByDistance()
				self.tickCount = 0
			end
			-- draw the outcome
			dxDrawMaterialPrimitive3D( "trianglelist", self.shader, false, unpack( self.trianglelist ) )	
		end
	end
end
        
function CPrmLightSpecular: destroy()
	if self.shader then
		self.shader:destroy()
		self.shader = nil
	end
	self = nil
	return true
end
