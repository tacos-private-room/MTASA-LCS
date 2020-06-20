Resource: primitive3DLightBasic v0.1.4
Author: Ren712
Contact: knoblauch700@o2.pl

IMPORTANT:
This resource doesn't provide any entity/light sorting, exported functions,
entity limit. It provides classes that can be used in other resources.
Number keys 1 to 0 allow you to create selected entities for testing purposes.


Description:
This resource adds an ability to create simple light sources and more.
The purpose of this resource is  to give an efficient alternative to
dynamic lighting resource and introduce deferred rendering
approach. Light (or any other effect) is produced after world is rendered
based on information (scene depth, world normals, texture color) generated before. 

More detailed description is presented here:
https://gamedevelopment.tutsplus.com/articles/forward-rendering-vs-deferred-rendering--gamedev-12342

The outcome is drawn on dxDrawMaterialPrimitive3D billboard/shape. 
You can add virtually limitless number of lights.

Instead of primitive3DLightBasic this provides proper blending with world
texture color and interpolated normals passed by a separate rt_renderTarget 
resource.

Effects:
CPrmLightDirectional - Creates a global directional light
CPrmLightPoint - Creates a point light.
CPrmLightPointNoNRM - Same as above but no normal shading
CPrmLightSpot - Creates a spot light.
CPrmLightSpotNoNRM - Same as above but no normal shading
CPrmLightSpecular - Creates a specular light.
CPrmLightDark - Creates an inverted color point light
CPrmLightDarkNoNRM - Same as above but no normal shading
CPrmTexture - Creates a 2D quad
CPrmTextureNoDB - Creates a 2D quad (basic method)
CPrmTextureProj - Creates a projected 2D texture
CPrmTextureProj2 - Creates a projected 2D texture type2
CPrmTextureProjNoDB - Creates a projected 2D texture (basic method)
CPrmTextureProjNoNRM - Same as above but no normal shading
CPrmTextureProjCone - Creates a projected 2D texture (perspective projection)
CPrmTextureProjCone2 - Creates a projected 2D texture type2 (perspective projection)
CPrmTextureProjConeNoDB - Creates a projected 2D texture (basic method)
CPrmTextureProjConeNoNRM - Same as above but no normal shading
CPrmTextureProjCube - Creates a projected cube texture
CPrmTextureProjCubeNoNRM - Same as above but no normal shading

Requirements:
Shader model 3.0 GFX, readable depth buffer in PS access. 

test.lua lets you create lights in front of the camera view.
