; /*******************************************************************************************
; *
; *   raylib [shaders] example - Apply a postprocessing shader To a scene
; *
; *   NOTE: This example requires raylib OpenGL 3.3 Or ES2 versions For shaders support,
; *         OpenGL 1.1 does Not support shaders, recompile raylib To OpenGL 3.3 version.
; *
; *   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), To test this example
; *         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
; *         raylib comes With shaders ready For both versions, check raylib/shaders install folder
; *
; *   Example originally created With raylib 1.3, last time updated With raylib 4.0
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#GLSL_VERSION = "330"

#MAX_POSTPRO_SHADERS = 11

Enumeration PostproShader
  #FX_GRAYSCALE = 0
  #FX_POSTERIZATION
  #FX_DREAM_VISION
  #FX_PIXELIZER
  #FX_CROSS_HATCHING
  #FX_CROSS_STITCHING
  #FX_PREDATOR_VIEW
  #FX_SCANLINES
  #FX_FISHEYE
  #FX_BLOOM
  #FX_BLUR
EndEnumeration
    
Dim postproShaderText.s(12)
postproShaderText(0) = "GRAYSCALE"
postproShaderText(1) = "POSTERIZATION"
postproShaderText(2) = "DREAM_VISION"
postproShaderText(3) = "PIXELIZER"
postproShaderText(4) = "CROSS_HATCHING"
postproShaderText(5) = "CROSS_STITCHING"
postproShaderText(6) = "PREDATOR_VIEW"
postproShaderText(7) = "SCANLINES"
postproShaderText(8) = "FISHEYE"
postproShaderText(9) = "BLOOM"
postproShaderText(10) = "BLUR"


; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [shaders] example - postprocessing shader" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

; Define the camera To look into our 3d world
Define.Camera camera 
Init_Vector3(@camera\position, 2.0, 3.0, 2.0)
Init_Vector3(@camera\target, 0.0, 1.0, 0.0)
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)
camera\fovy = 45.0
camera\projection = 0

Define.Model model 
LoadModel(@model, "resources/models/church.obj") ; Load OBJ model

Define.Texture2D texture 
LoadTextureRayLib(@texture, "resources/models/church_diffuse.png") ; Load model texture (diffuse map)

CopyMemory(texture, model\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, SizeOf(texture))  ; Set model diffuse texture

Define._Vector3 position 
Init_Vector3(@position, 0.0, 0.0, 0.0) ; Set model position

; Load all postpro shaders
; NOTE 1: All postpro shader use the base vertex shader (DEFAULT_VERTEX_SHADER)
; NOTE 2: We load the correct shader depending on GLSL version
Dim shaders.Shader(#MAX_POSTPRO_SHADERS)

; NOTE: Defining 0 (NULL) For vertex shader forces usage of internal Default vertex shader
LoadShader(shaders(#FX_GRAYSCALE), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/grayscale.fs")
LoadShader(shaders(#FX_POSTERIZATION), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/posterization.fs")
LoadShader(shaders(#FX_DREAM_VISION), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/dream_vision.fs")
LoadShader(shaders(#FX_PIXELIZER), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/pixelizer.fs")
LoadShader(shaders(#FX_CROSS_HATCHING), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/cross_hatching.fs")
LoadShader(shaders(#FX_CROSS_STITCHING), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/cross_stitching.fs")
LoadShader(shaders(#FX_PREDATOR_VIEW), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/predator.fs")
LoadShader(shaders(#FX_SCANLINES), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/scanlines.fs")
LoadShader(shaders(#FX_FISHEYE), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/fisheye.fs")
;LoadShader(shaders(#FX_SOBEL), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/sobel.fs")
LoadShader(shaders(#FX_BLOOM), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/bloom.fs")
LoadShader(shaders(#FX_BLUR), #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/blur.fs")

Define.rl_int currentShader = #FX_GRAYSCALE

; Create a RenderTexture2D To be used For render To texture
Define.RenderTexture2D target 
LoadRenderTexture(@target, #SCREEN_WIDTH, #SCREEN_HEIGHT)

; Setup orbital camera
;SetCameraMode(@camera, #CAMERA_ORBITAL) ; Set an orbital camera mode

SetTargetFPS(60)                        ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()           ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_ORBITAL)

  If IsKeyPressed(#KEY_RIGHT)
    currentShader + 1
  ElseIf IsKeyPressed(#KEY_LEFT)
    currentShader - 1
  EndIf
  
  If currentShader >= #MAX_POSTPRO_SHADERS
    currentShader = 0
  ElseIf currentShader < 0
    currentShader = #MAX_POSTPRO_SHADERS - 1
  EndIf
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginTextureMode(@target)                           ; Enable drawing to texture
    ClearBackground(#COLOR_RAYWHITE)                  ; Clear texture background
    BeginMode3D(@camera)                              ; Begin 3d mode drawing
      DrawModel(@model, @position, 0.1, #COLOR_WHITE) ; Draw 3d model with texture
      DrawGrid(10, 1.0)                               ; Draw a grid
    EndMode3D()                                       ; End 3d mode drawing, returns To orthographic 2d mode
 EndTextureMode()                                     ; End drawing to texture (now we have a texture available for next passes)
 
 BeginDrawing()
  ClearBackground(#COLOR_RAYWHITE)                    ; Clear screen background
  
  ; Render generated texture using selected postprocessing shader
  BeginShaderMode(shaders(currentShader))
  ; NOTE: Render texture must be y-flipped due To Default OpenGL coordinates (left-bottom)
    Define.Rectangle target_rec
    Define.Vector2 target_pos
    InitRectangle(@target_rec, 0, 0, target\texture\width, -target\texture\height)
    InitVector2(@target_pos, 0, 0)
    DrawTextureRec(@target\texture, @target_rec, @target_pos, #COLOR_WHITE)
  EndShaderMode()

  ; Draw 2d shapes And text over drawn texture
  DrawRectangle(0, 9, 580, 30, Fade(#COLOR_LIGHTGRAY, 0.7))

  DrawTextRayLib("(c) Church 3D model by Alberto Cano", #SCREEN_WIDTH - 200, #SCREEN_HEIGHT - 20, 10, #COLOR_GRAY)
  DrawTextRayLib("CURRENT POSTPRO SHADER:", 10, 15, 20, #COLOR_BLACK)
  DrawTextRayLib(postproShaderText(currentShader), 330, 15, 20, #COLOR_RED)
  DrawTextRayLib("< >", 540, 10, 30, #COLOR_DARKBLUE)
  
  DrawFPS(700, 15)
            
 EndDrawing()
 ;>----------------------------------------------------------------------------------
 
 ; If we want to have a screenshot
 If IsKeyPressed(#KEY_F1)
   TakeScreenshot("screenshots/shaders_postprocessing.png")
 EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
; Unload all postpro shaders
Define.rl_int i
For i = 0 To #MAX_POSTPRO_SHADERS
  UnloadShader(shaders(i))
Next

UnloadTexture(@texture)       ; Unload texture
UnloadModel(@model)           ; Unload model
UnloadRenderTexture(@target)  ; Unload render texture

CloseWindowRayLib()           ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 53
; FirstLine = 49
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)