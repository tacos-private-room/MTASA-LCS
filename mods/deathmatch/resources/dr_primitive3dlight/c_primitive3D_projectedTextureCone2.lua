--  
-- file: c_primitive3D_projectedTextureCone2.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/primitive3D_projectedTextureCone2.fx, c_common.lua

local scx,scy = guiGetScreenSize ()

CPrmTextureProjCone2 = { }
CPrmTextureProjCone2.__index = CPrmTextureProjCone2

-- texture, worldPosition Vector3(), elementRotation Vector3(), texSize Vector2(), color Vector4(0-255,0-255,0-255,0-255)
function CPrmTextureProjCone2: create(tex, pos, atten, rot, texSiz, col )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shader = DxShader( "fx/primitive3D_projectedTextureCone2.fx" ),
		texture = tex,
		textureSize = texSiz,
		projectionFov = Vector2(70, 60),
		lightNearClip = 0,
		color = Vector4(col.x, col.y, col.z, col.w),
		position = Vector3(pos.x, pos.y, pos.z),
		rotation = Vector3(rot.x, rot.y, rot.z),
		attenuation = atten,
		attenuationPower = 2,
		tessSwitch = false,
		tickCount = 0,
		distFade = Vector2(950, 850)
	}
	if cShader.shader then

		cShader.shader:setValue( "sTexture", cShader.texture )
		cShader.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
		cShader.shader:setValue( "sPicSize", cShader.textureSize.x, cShader.textureSize.y )
		cShader.shader:setValue( "sProjFov", math.rad(cShader.projectionFov.x), math.rad(cShader.projectionFov.y) )
		cShader.shader:setValue( "sLightNearClip", cShader.lightNearClip )
		
		cShader.shader:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shader:setValue( "sLightRotation", math.rad(cShader.rotation.x), math.rad(cShader.rotation.y), math.rad(cShader.rotation.z) )		

		cShader.shader:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shader:setValue( "sLightAttenuationPower", cShader.attenuationPower )

		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		cShader.shader:setValue( "sHalfPixel", 1/(scX * 2), 1/(scY * 2) )
		
		if isSM3DBSupported then 
			local distFromCam = ( pos - getCamera().matrix.position ).length
			if ( distFromCam < 8 * atten ) then 	
				cShader.trianglelist = trianglelist.cube
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

function CPrmTextureProjCone2: setTesselationByDistance()
	if self.shader and isSM3DBSupported then
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < 8 * self.attenuation ) then 
			if not self.tessSwitch then
				self.trianglelist = trianglelist.cube
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

function CPrmTextureProjCone2: setDirection( dir )
	if self.shader then
		local vecLen = math.sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z)
		local rot = Vector3(math.asin(dir.z / vecLen), 0, -math.atan2(dir.x, dir.y))
		self.rotation = Vector3(math.deg(rot.x), math.deg(rot.y), math.deg(rot.z))
		self.shader:setValue( "sLightRotation", math.deg(rot.x), math.deg(rot.y), math.deg(rot.z) )
	end
end	
	
function CPrmTextureProjCone2: setRotation( rot )
	if self.shader then
		self.rotation = Vector3(rot.x, rot.y, rot.z)
		self.shader:setValue( "sLightRotation", math.rad( rot.x ), math.rad( rot.y ), math.rad( rot.z ))
	end
end	

function CPrmTextureProjCone2: setTexture( tex )
	if self.shader then
		self.texture = tex
		self.shader:setValue( "sTexture", tex )
	end
end

function CPrmTextureProjCone2: setTextureSize( texSize )
	if self.shader then
		self.textureSize = Vector2(texSize.x, texSize.y )
		self.shader:setValue( "sPicSize", texSize.x, texSize.y )
	end
end

function CPrmTextureProjCone2: setProjectionFov( projFov )
	if self.shader then
		self.projectionFov = Vector2(projFov.x, projFov.y )
		self.shader:setValue( "sProjFov", math.rad(projFov.x), math.rad(projFov.y) )
	end
end
	
function CPrmTextureProjCone2: setLightNearClip( lNearClip )
	if self.shader then
		self.lightNearClip = lNearClip
		self.shader:setValue( "sLightNearClip", lNearClip )
	end
end
		
function CPrmTextureProjCone2: setDistFade( distFade )
	if self.shader then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CPrmTextureProjCone2: setPosition( pos )
	if self.shader then
		self.position = Vector3(pos.x, pos.y, pos.z)
		self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
	end
end

function CPrmTextureProjCone2: setAttenuation( atten )
	if self.shader then
		self.attenuation = atten
		self.shader:setValue( "sLightAttenuation", atten )
		self:setTesselationByDistance()
	end
end

function CPrmTextureProjCone2: setAttenuationPower( attenPow )
	if self.shader then
		self.attenuationPower = attenPow
		self.shader:setValue( "sLightAttenuationPower", attenPow )
	end
end

function CPrmTextureProjCone2: setColor( col )
	if self.shader then
		self.color = Vector4(col.x, col.y, col.z, col.w)
		self.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w / 255 )
	end
end

function CPrmTextureProjCone2: getObjectToCameraAngle()
	if self.position then
		local camMat = getCamera().matrix
		local camFw = camMat:getForward()
		local elementDir = ( self.position - camMat.position ):getNormalized()
		return math.acos( elementDir:dot( camFw ) / ( elementDir.length * camFw.length ))
	else
		return false
	end
end

function CPrmTextureProjCone2: getDistanceFromViewAngle( inAngle )
	if self.shader then
		return ( self.attenuation / 2 ) / math.atan(inAngle)
	else
		return false
	end
end

function CPrmTextureProjCone2: draw()
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
        
function CPrmTextureProjCone2: destroy()
	if self.shader then
		self.shader:destroy()
		self.shader = nil
	end
	self = nil
	return true
end
