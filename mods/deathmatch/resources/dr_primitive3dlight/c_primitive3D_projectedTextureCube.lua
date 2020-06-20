--  
-- file: c_primitive3D_projectedTextureCube.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/primitive3D_projectedTextureCube.fx, c_common.lua

local scx,scy = guiGetScreenSize ()

CPrmTextureProjCube = { }
CPrmTextureProjCube.__index = CPrmTextureProjCube

-- texture, worldPosition Vector3(), elementRotation Vector3(), texSize Vector2(), color Vector4(0-255,0-255,0-255,0-255) 
function CPrmTextureProjCube: create(tex, pos, atten, rot, col )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shader = DxShader( "fx/primitive3D_projectedTextureCube.fx" ),
		texture = tex,
		color = Vector4(col.x, col.y, col.z, col.w),
		position = Vector3(pos.x, pos.y, pos.z),
		rotation = Vector3(rot.x, rot.y, rot.z),
		rotationSpeed = Vector3(0, 0, 0),
		attenuation = atten,
		attenuationPower = 2,
		tessSwitch = false,
		tickCount = 0,
		distFade = Vector2(950, 850),
		destBlend = 6 -- see D3DBLEND https://msdn.microsoft.com/en-us/library/windows/desktop/bb172508%28v=vs.85%29.aspx
	}

	if cShader.shader then
		cShader.shader:setValue( "sCubeTexture", cShader.texture )
		
		cShader.shader:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
		cShader.shader:setValue( "sLightRotation", math.rad(cShader.rotation.x), math.rad(cShader.rotation.y), math.rad(cShader.rotation.z) )
		cShader.shader:setValue( "sLightRotationSpeed", cShader.rotationSpeed.x, cShader.rotationSpeed.y, cShader.rotationSpeed.z )
		
		cShader.shader:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shader:setValue( "sLightAttenuationPower", cShader.attenuationPower )
		
		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		
		cShader.shader:setValue( "fDestBlend" ,cShader.destBlend )
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		cShader.shader:setValue( "sHalfPixel", 1/(scX * 2), 1/(scY * 2) )
		
		if isSM3DBSupported then 
			local distFromCam = ( pos - getCamera().matrix.position ).length
			if ( distFromCam < 8 * atten ) then 	
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

function CPrmTextureProjCube: setTesselationByDistance()
	if self.shader and isSM3DBSupported then
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < 8 * self.attenuation ) then 
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

function CPrmTextureProjCube: setBlendAdd( isAddBlend )
	if self.shader then
		if isAddBlend then
			self.destBlend = 2
			self.shader:setValue( "fDestBlend" ,2 )
		else
			self.destBlend = 6
			self.shader:setValue( "fDestBlend" ,6 )
		end		
	end
end

function CPrmTextureProjCube: setTexture( tex )
	if self.shader then
		self.texture = tex
		self.shader:setValue( "sCubeTexture", tex )
	end
end

function CPrmTextureProjCube: setDistFade( distFade )
	if self.shader then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CPrmTextureProjCube: setPosition( pos )
	if self.shader then
		self.position = Vector3(pos.x, pos.y, pos.z),
		self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
	end
end

function CPrmTextureProjCube: setAttenuation( atten )
	if self.shader then
		self.attenuation = atten
		self.shader:setValue( "sLightAttenuation", atten )
		self:setTesselationByDistance()
	end
end

function CPrmTextureProjCube: setAttenuationPower( attenPow )
	if self.shader then
		self.attenuationPower = attenPow
		self.shader:setValue( "sLightAttenuationPower", attenPow )
	end
end

function CPrmTextureProjCube: setRotation( rot )
	if self.shader then
		self.rotation = Vector3(rot.x, rot.y, rot.z)
		self.shader:setValue( "sLightRotation", math.rad(rot.x), math.rad(rot.y), math.rad(rot.z) )
	end
end

function CPrmTextureProjCube: setRotationSpeed( rotSpeed )
	if self.shader then
		self.rotationSpeed = Vector3(rotSpeed.x, rotSpeed.y, rotSpeed.z)
		self.shader:setValue( "sLightRotationSpeed", rotSpeed.x, rotSpeed.y, rotSpeed.z )
	end
end

function CPrmTextureProjCube: setColor( col )
	if self.shader then
		self.color = Vector4(col.x, col.y, col.z, col.w)
		self.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
	end
end

function CPrmTextureProjCube: getObjectToCameraAngle()
	if self.position then
		local camMat = getCamera().matrix
		local camFw = camMat:getForward()
		local elementDir = ( self.position - camMat.position ):getNormalized()
		return math.acos( elementDir:dot( camFw ) / ( elementDir.length * camFw.length ))
	else
		return false
	end
end

function CPrmTextureProjCube: getDistanceFromViewAngle( inAngle )
	if self.shader then
		return ( self.attenuation / 2 ) / math.atan(inAngle)
	else
		return false
	end
end

function CPrmTextureProjCube: draw()
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
        
function CPrmTextureProjCube: destroy()
	if self.shader then
		self.shader:destroy()
		self.shader = nil
	end
	self = nil
	return true
end
