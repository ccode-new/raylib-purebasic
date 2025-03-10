; /*******************************************************************************************
; *
; *   raylib [shaders] example - basic lighting
; *
; *   NOTE: This example requires raylib OpenGL 3.3 Or ES2 versions For shaders support,
; *         OpenGL 1.1 does Not support shaders, recompile raylib To OpenGL 3.3 version.
; *
; *   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
; *
; *   Example originally created With raylib 3.0, last time updated With raylib 4.2
; *
; *   Example contributed by Chris Camacho (@codifies) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2019-2023 Chris Camacho (@codifies) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "raymath.pbi"

#GLSL_VERSION = "330"

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [shaders] example - basic lighting" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf

; Define the camera To look into our 3d world
Define.Camera camera
Init_Vector3(@camera\position, 2.0, 4.0, 6.0)           ; Camera position
Init_Vector3(@camera\target, 0.0, 0.5, 0.0)             ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)                 ; Camera up vector (rotation towards target)
camera\fovy = 45.0                                      ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE             ; Camera mode type

; Load plane model from a generated mesh
Define.Model model
Define.Mesh meshModel
GenMeshPlane(@meshModel, 10.0, 10.0, 3, 3)
LoadModelFromMesh(@model, @meshModel)

Define.Model cube
Define.Mesh meshCube
GenMeshCube(@meshCube, 2.0, 4.0, 2.0)
LoadModelFromMesh(@cube, @meshCube)
    
; Load basic lighting shader
Define.Shader shader 
LoadShader(@shader, "resources/shaders/glsl"+#GLSL_VERSION+"/lighting.vs",
                    "resources/shaders/glsl"+#GLSL_VERSION+"/lighting.fs")

;// Get some required shader locations
PokeL(@shader\locs + #SHADER_LOC_VECTOR_VIEW, GetShaderLocation(@shader, "viewPos"))

;Debug PeekL(@shader\locs + #LOC_VECTOR_VIEW)

;// NOTE: "matModel" location name is automatically assigned on shader loading, 
;// no need To get the location again If using that uniform name
;//shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");

;Debug GetShaderLocation(@shader, "ambient")

;// Ambient light level (some basic lighting)
Define.rl_int ambientLoc = GetShaderLocation(@shader, "ambient")

Dim fshader.rl_float(3)
fshader(0) = 0.1
fshader(1) = 0.1
fshader(2) = 0.1
fshader(3) = 0.1

SetShaderValue(@shader, ambientLoc, @fshader(), #SHADER_UNIFORM_VEC4)

; Assign out lighting shader To model

;model.materials[0].shader = shader;
CopyMemory(@shader, @model\materials\shader, SizeOf(shader))
;CopyStructure(@shader, @model\materials\shader, shader)

;cube.materials[0].shader = shader;
CopyMemory(@shader, @cube\materials\shader, SizeOf(shader))
;CopyStructure(@shader, @cube\materials\shader, shader)

; Create lights
Dim lights.Light(#MAX_LIGHTS)

Define._Vector3 lightPosV, lightTargetV
Init_Vector3(@lightTargetV, 0, 0, 0)

Init_Vector3(@lightPosV, -2, 1, -2)
CreateLightRayLib(@lights(0), #LIGHT_POINT, @lightPosV, @lightTargetV, #COLOR_YELLOW, @shader)

Init_Vector3(@lightPosV, 2, 1, 2)
CreateLightRayLib(@lights(1), #LIGHT_POINT, @lightPosV, @lightTargetV, #COLOR_RED, @shader)

Init_Vector3(@lightPosV, -2, 1, 2)
CreateLightRayLib(@lights(2), #LIGHT_POINT, @lightPosV, @lightTargetV, #COLOR_GREEN, @shader)

Init_Vector3(@lightPosV, 2, 1, -2)
CreateLightRayLib(@lights(3), #LIGHT_POINT, @lightPosV, @lightTargetV, #COLOR_BLUE, @shader)

;SetCameraMode(@camera, #CAMERA_ORBITAL)     ; Set an orbital camera mode

SetTargetFPS(60)                                ; Set our game To run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()                   ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_ORBITAL);

  ; Update the shader With the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
  Dim cameraPos.rl_float(2) 
  cameraPos(0) = camera\position\x
  cameraPos(1) = camera\position\y
  cameraPos(2) = camera\position\z
  
  Define.rl_int shader_loc = PeekL(@shader\locs + #SHADER_LOC_VECTOR_VIEW)
  
  SetShaderValue(@shader, shader_loc, @cameraPos(), #SHADER_UNIFORM_VEC3)
        
  ; Check key inputs To enable/disable lights
  If IsKeyPressed(#KEY_Y)
    lights(0)\enabled = Bool( Not lights(0)\enabled )
  EndIf
  
  If IsKeyPressed(#KEY_R)
    lights(1)\enabled = Bool( Not lights(1)\enabled )
  EndIf  
    
  If IsKeyPressed(#KEY_G)
    lights(2)\enabled = Bool( Not lights(2)\enabled )
  EndIf
  
  If IsKeyPressed(#KEY_B)
    lights(3)\enabled = Bool( Not lights(3)\enabled )
  EndIf
        
  ; Update light values (actually, only enable/disable them)
  Define.rl_int i
  
  For i = 0 To #MAX_LIGHTS - 1
    UpdateLightValues(@shader, @lights(i))
  Next
  
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  BeginMode3D(@camera)

    DrawModel(@model, @lightTargetV, 1.0, #COLOR_WHITE)
    DrawModel(@cube, @lightTargetV, 1.0, #COLOR_WHITE)

    ; Draw spheres To show where the lights are
    For i = 0 To #MAX_LIGHTS - 1
      If lights(i)\enabled = #True
        DrawSphereEx(@lights(i)\position, 0.2, 8, 8, lights(i)\color)
      Else 
        DrawSphereWires(@lights(i)\position, 0.2, 8, 8, ColorAlpha(lights(i)\color, 0.3))
      EndIf
    Next

    DrawGrid(10, 1.0)

  EndMode3D()

  DrawFPS(10, 10)

  DrawTextRayLib("Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, #COLOR_DARKGRAY);

  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/shaders_basic_lighting.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadModel(@model)         ; Unload the model
UnloadModel(@cube)          ; Unload the model
UnloadShader(@shader)       ; Unload shader

CloseWindowRayLib()         ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 133
; FirstLine = 124
; Optimizer
; EnableThread
; EnableXP