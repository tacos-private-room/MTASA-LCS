--  
-- file: c_primitive3D_projectedTextureConeNoNRM.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/primitive3D_projectedTextureConeNoNRM.fx, c_common.lua

local scx,scy = guiGetScreenSize ()

CPrmTextureProjConeNoNRM = { }
CPrmTextureProjConeNoNRM.__index = CPrmTextureProjConeNoNRM
	 
-- texture, worldPosition Vector3(), elementRotation Vector3(), texSize Vector2(), color Vector4(0-255,0-255,0-255,0-255) 
function CPrmTextureProjConeNoNRM: create(tex, pos, atten, rot, texSiz, col, isProjPos )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shader = DxShader( "fx/primitive3D_projectedTextureConeNoNRM.fx" ),
		texture = tex,
		textureSize = texSiz,
		projectionFov = 45,
		color = Vector4(col.x, col.y, col.z, col.w),
		position = Vector3(pos.x, pos.y, pos.z),
		setProjectionPosition = isProjPos,
		projectionPositionNormal = Vector3(0,0,1),
		projectionPositionSearchLength = 50,
		rotation = Vector3(rot.x, rot.y, rot.z),
		attenuation = atten,
		attenuationPower = 2,
		surAttenuation = 0.3,
		surAttenuationPower = 2,
		surOffset = 0,
		tessSwitch = false,
		tickCount = 0,
		distFade = Vector2(950, 850),
		destBlend = 6 -- see D3DBLEND https://msdn.microsoft.com/en-us/library/windows/desktop/bb172508%28v=vs.85%29.aspx
	}

	if cShader.shader then
		cShader.shader:setValue( "sTexture", cShader.texture )
		cShader.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
		cShader.shader:setValue( "sPicSize", cShader.textureSize.x, cShader.textureSize.y )
		cShader.shader:setValue( "sProjFov", math.rad(cShader.projectionFov) )
		
		cShader.shader:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shader:setValue( "sLightRotation", math.rad(cShader.rotation.x), math.rad(cShader.rotation.y), math.rad(cShader.rotation.z) )
		
		cShader.shader:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shader:setValue( "sLightAttenuationPower", cShader.attenuationPower )
		
		cShader.shader:setValue( "sSurfaceAttenuation", cShader.surAttenuation )
		cShader.shader:setValue( "sSurfaceAttenuationPower", cShader.surAttenuationPower )
		
		cShader.shader:setValue( "sSurfaceOffset", cShader.surOffset )
		
		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		
		cShader.shader:setValue( "fDestBlend" ,cShader.destBlend )
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		cShader.shader:setValue( "sHalfPixel", 1/(scX * 2), 1/(scY * 2) )
		
		cShader.shader:setValue( "bProjectionPosition", cShader.setProjectionPosition )
		cShader.shader:setValue( "sSurfaceNormal", cShader.projectionPositionNormal.x, cShader.projectionPositionNormal.y, cShader.projectionPositionNormal.z )
		
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
			end
		end

		self.__index = self
		setmetatable( cShader, self )
		return cShader
	else
		return false
	end
end

function CPrmTextureProjConeNoNRM: setTesselationByDistance()
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

function CPrmTextureProjConeNoNRM: setBlendAdd( isAddBlend )
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

function CPrmTextureProjConeNoNRM: setTexture( tex )
	if self.shader then
		self.texture = tex
		self.shader:setValue( "sTexture", tex )
	end
end

function CPrmTextureProjConeNoNRM: setTextureSize( texSize )
	if self.shader then
		self.textureSize = Vector2(texSize.x, texSize.y )
		self.shader:setValue( "sPicSize", texSize.x, texSize.y )
	end
end

function CPrmTextureProjConeNoNRM: setTextureFov( fov )
	if self.shader then
		self.projectionFov = fov
		self.shader:setValue( "sProjFov", fov )
	end
end

function CPrmTextureProjConeNoNRM: setDistFade( distFade )
	if self.shader then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CPrmTextureProjConeNoNRM: setViewMatrix( inMat )
	if self.shader then
		rot = inMat:getRotationZXY()
		self.rotation = Vector3(rot.x, rot.y, rot.z),
		self.shader:setValue( "sLightRotation", math.rad(rot.x), math.rad(rot.y), math.rad(rot.z) )
		local pos = inMat.position
		if self.setProjectionPosition then
			local offPos = pos + inMat.forward * self.projectionPositionSearchLength
			if not isLineOfSightClear(pos.x, pos.y, pos.z, offPos.x, offPos.y, offPos.z, true, false, false) then
				local isHit, hitX, hitY, hitZ, _, norX, norY, norZ = processLineOfSight(pos.x, pos.y, pos.z, offPos.x, offPos.y, offPos.z,
					true, false, false)
				self.position = Vector3( hitX, hitY, hitZ ),
				self.shader:setValue( "sLightPosition", hitX, hitY, hitZ )
				self.shader:setValue( "sSurfaceNormal", norX, norY, norZ )
			else
				return false
			end
		else
			self.position = Vector3(pos.x, pos.y, pos.z )
			self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
		end
	end
end

function CPrmTextureProjConeNoNRM: setAutoProjectionSurfaceNormal( nor )
	if self.shader then
		self.projectionPositionNormal = Vector3(nor.x, nor.y, nor.z)
		self.shader:setValue( "sSurfaceNormal", nor.x, nor.y, nor.z )
	end
end

function CPrmTextureProjConeNoNRM: setAutoProjectionEnabled( isAutoProj )
	if self.shader then
		self.setProjectionPosition = isAutoProj
		self.shader:setValue( "bProjectionPosition", self.setProjectionPosition )
	end
end

function CPrmTextureProjConeNoNRM: setAutoProjectionSearchLength( serLen )
	if self.shader then
		self.projectionPositionSearchLength = serLen
	end
end

function CPrmTextureProjConeNoNRM: setPosition( pos )
	if self.shader then
		self.position = Vector3(pos.x, pos.y, pos.z)
		self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
	end
end

function CPrmTextureProjConeNoNRM: setAttenuation( atten )
	if self.shader then
		self.attenuation = atten
		self.shader:setValue( "sLightAttenuation", atten )
		self:setTesselationByDistance()
	end
end

function CPrmTextureProjConeNoNRM: setAttenuationPower( attenPow )
	if self.shader then
		self.attenuationPower = attenPow
		self.shader:setValue( "sLightAttenuationPower", attenPow )
	end
end

function CPrmTextureProjConeNoNRM: setSurfaceAttenuation( atten )
	if self.shader then
		self.surAttenuation = atten
		self.shader:setValue( "sSurfaceAttenuation", atten )
	end
end

function CPrmTextureProjConeNoNRM: setSurfaceAttenuationPower( attenPow )
	if self.shader then
		self.surAttenuationPower = attenPow
		self.shader:setValue( "sSurfaceAttenuationPower", attenPow )
	end
end

function CPrmTextureProjConeNoNRM: setSurfaceOffset( surOffs )
	if self.shader then
		self.surOffset = surOffs
		self.shader:setValue( "sSurfaceOffset", surOffs )
	end
end

function CPrmTextureProjConeNoNRM: setRotation( rot )
	if self.shader then
		self.rotation = Vector3(rot.x, rot.y, rot.z),
		self.shader:setValue( "sLightRotation", math.rad(rot.x), math.rad(rot.y), math.rad(rot.z) )
	end
end

function CPrmTextureProjConeNoNRM: setColor( col )
	if self.shader then
		self.color = Vector4(col.x, col.y, col.z, col.w)
		self.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
	end
end

function CPrmTextureProjConeNoNRM: getObjectToCameraAngle()
	if self.position then
		local camMat = getCamera().matrix
		local camFw = camMat:getForward()
		local elementDir = ( self.position - camMat.position ):getNormalized()
		return math.acos( elementDir:dot( camFw ) / ( elementDir.length * camFw.length ))
	else
		return false
	end
end

function CPrmTextureProjConeNoNRM: getDistanceFromViewAngle( inAngle )
	if self.shader then
		return ( self.attenuation / 2 ) / math.atan(inAngle)
	else
		return false
	end
end

function CPrmTextureProjConeNoNRM: draw()
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
        
function CPrmTextureProjConeNoNRM: destroy()
	if self.shader then
		self.shader:destroy()
		self.shader = nil
	end
	self = nil
	return true
end
