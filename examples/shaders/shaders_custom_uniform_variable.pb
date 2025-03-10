; /*******************************************************************************************
; *
; *   raylib [shaders] example - Apply a postprocessing shader And connect a custom uniform variable
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

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [shaders] example - custom uniform variable" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

; Define the camera To look into our 3d world
Define.Camera camera

Init_Vector3(@camera\position, 8.0, 8.0, 8.0)
Init_Vector3(@camera\target, 0.0, 1.5, 0.0)
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)
camera\fovy = 45.0
camera\projection = #CAMERA_PERSPECTIVE

Define.Model model 
LoadModel(@model, "resources/models/barracks.obj")  ; Load OBJ model

Define.Texture2D texture 
LoadTextureRayLib(@texture, "resources/models/barracks_diffuse.png")    ; Load model texture (diffuse map)

;model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture   ; Set model diffuse texture
CopyMemory(@texture, @model\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, SizeOf(texture))

Define._Vector3 position 
Init_Vector3(@position, 0.0, 0.0, 0.0)  ; Set model position

; Load postprocessing shader
; NOTE: Defining 0 (NULL) For vertex shader forces usage of internal Default vertex shader
Define.Shader *shader 
LoadShader(*shader, #Null$, "resources/shaders/glsl"+#GLSL_VERSION+"/swirl.fs")

;Debug shader

; Get variable (uniform) location on the shader To connect With the program
; NOTE: If uniform variable could Not be found in the shader, function returns -1
Define.rl_int swirlCenterLoc = GetShaderLocation(*shader, "center") ;-1 ???
;Debug swirlCenterLoc

Dim swirlCenter.rl_float(1) 
swirlCenter(0) = #SCREEN_WIDTH / 2
swirlCenter(1) = #SCREEN_HEIGHT / 2

; Create a RenderTexture2D To be used For render To texture
Define.RenderTexture2D target 
LoadRenderTexture(@target, #SCREEN_WIDTH, #SCREEN_HEIGHT)

; Setup orbital camera
;SetCameraMode(@camera, #CAMERAMODE_ORBITAL) ; Set an orbital camera mode

SetTargetFPS(60)                            ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()               ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_ORBITAL)
        
  Define.Vector2 mousePosition
  GetMousePosition(@mousePosition)

  swirlCenter(0) = mousePosition\x
  swirlCenter(1) = #SCREEN_HEIGHT - mousePosition\y

  ; Send new value To the shader To be used on drawing
  SetShaderValue(*shader, swirlCenterLoc, @swirlCenter(), #SHADER_UNIFORM_VEC2)
  ;----------------------------------------------------------------------------------

  ; Draw
  ;----------------------------------------------------------------------------------
  BeginTextureMode(@target)                           ; Enable drawing to texture
    ClearBackground(#COLOR_RAYWHITE)                  ; Clear texture background

    BeginMode3D(@camera)                              ; Begin 3d mode drawing
      DrawModel(@model, @position, 0.5, #COLOR_WHITE) ; Draw 3d model with texture
      DrawGrid(10, 1.0)                               ; Draw a grid
    EndMode3D()                                       ; End 3d mode drawing, returns to orthographic 2d mode

    DrawTextRayLib("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, #COLOR_RED)
  EndTextureMode()                                    ; End drawing to texture (now we have a texture available for next passes)

  BeginDrawing()
    ClearBackground(#COLOR_RAYWHITE)                  ; Clear screen background

    ; Enable shader using the custom uniform
    BeginShaderMode(*shader)
      Define.Rectangle texRec
      InitRectangle(@texRec, 0, 0, target\texture\width, -target\texture\height)
      Define.Vector2 texPos
      InitVector2(@texPos, 0, 0)
      ;// NOTE: Render texture must be y-flipped due To Default OpenGL coordinates (left-bottom)
      DrawTextureRec(@target\texture, @texRec, @texPos, #COLOR_WHITE)
    EndShaderMode()

    ; Draw some 2d text over drawn texture
    DrawTextRayLib("(c) Barracks 3D model by Alberto Cano", #SCREEN_WIDTH - 220, #SCREEN_HEIGHT - 20, 10, #COLOR_GRAY)
    
    DrawFPS(10, 10)
    
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/shaders_custom_uniform_variable.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadShader(*shader)          ; Unload shader
UnloadTexture(@texture)        ; Unload texture
UnloadModel(@model)            ; Unload model
UnloadRenderTexture(@target)   ; Unload render texture

CloseWindowRayLib()           ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 98
; FirstLine = 91
; Optimizer
; EnableThread
; EnableXP