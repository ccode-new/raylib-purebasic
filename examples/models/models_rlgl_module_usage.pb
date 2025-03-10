; /*******************************************************************************************
; *
; *   raylib [models] example - rlgl Module usage With push/pop matrix transformations
; *
; *   NOTE: This example uses [rlgl] Module functionality (pseudo-OpenGL 1.1 style coding)
; *
; *   Example originally created With raylib 2.5, last time updated With raylib 4.0
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2018-2023 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; //------------------------------------------------------------------------------------
; // Module Functions Declaration
; //------------------------------------------------------------------------------------
Declare DrawSphereBasic(color.rl_ColorLong)   ; Draw sphere without any matrix transformation

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

#SUN_RADIUS = 4.0
#EARTH_RADIUS = 0.6
#EARTH_ORBIT_RADIUS = 8.0
#MOON_RADIUS = 0.16
#MOON_ORBIT_RADIUS = 1.5

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - rlgl module usage with push/pop matrix transformations" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

; Define the camera To look into our 3d world
Define.Camera camera
Init_Vector3(@camera\position, 16.0, 16.0, 16.0)
Init_Vector3(@camera\target, 0.0, 0.0, 0.0)
Init_Vector3(@camera\up, 0.0, 1.0, 0.0)
camera\fovy = 45.0
camera\projection = #CAMERA_PERSPECTIVE

;SetCameraMode(@camera, #CAMERAMODE_FREE)

Define.rl_float rotationSpeed = 0.2         ; General system rotation speed

Define.rl_float earthRotation = 0.0         ; Rotation of earth around itself (days) in degrees
Define.rl_float earthOrbitRotation = 0.0    ; Rotation of earth around the Sun (years) in degrees
Define.rl_float moonRotation = 0.0          ; Rotation of moon around itself
Define.rl_float moonOrbitRotation = 0.0     ; Rotation of moon around earth in degrees

SetTargetFPS(60)                            ; Set our game to run at 60 frames-per-second
;>--------------------------------------------------------------------------------------
DisableCursor()

; Main game loop
While Not WindowShouldClose()               ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  UpdateCamera(@camera, #CAMERA_FREE)
  
  earthRotation + (5.0 * rotationSpeed)
  earthOrbitRotation + (365 / 360.0 * (5.0 * rotationSpeed) * rotationSpeed)
  moonRotation + (2.0 * rotationSpeed)
  moonOrbitRotation + (8.0 * rotationSpeed)
  ;>----------------------------------------------------------------------------------
  
  ; Draw
  ;>----------------------------------------------------------------------------------
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE);
  
  BeginMode3D(@camera)
  
  rlPushMatrix()
  rlScalef(#SUN_RADIUS, #SUN_RADIUS, #SUN_RADIUS)           ; Scale Sun
  DrawSphereBasic(#COLOR_GOLD)                              ; Draw the Sun
  rlPopMatrix()
  
  rlPushMatrix()
  rlRotatef(earthOrbitRotation, 0.0, 1.0, 0.0)              ; Rotation for Earth orbit around Sun
  rlTranslatef(#EARTH_ORBIT_RADIUS, 0.0, 0.0)               ; Translation for Earth orbit
  
  rlPushMatrix()
  rlRotatef(earthRotation, 0.25, 1.0, 0.0)                ; Rotation for Earth itself
  rlScalef(#EARTH_RADIUS, #EARTH_RADIUS, #EARTH_RADIUS)   ; Scale Earth
  
  DrawSphereBasic(#COLOR_BLUE);                           ; Draw the Earth
  rlPopMatrix()
  
  rlRotatef(moonOrbitRotation, 0.0, 1.0, 0.0)               ; Rotation for Moon orbit around Earth
  rlTranslatef(#MOON_ORBIT_RADIUS, 0.0, 0.0)                ; Translation for Moon orbit
  rlRotatef(moonRotation, 0.0, 1.0, 0.0)                    ; Rotation for Moon itself
  rlScalef(#MOON_RADIUS, #MOON_RADIUS, #MOON_RADIUS)        ; Scale Moon
  
  DrawSphereBasic(#COLOR_LIGHTGRAY)                         ; Draw the Moon
  rlPopMatrix()
  
  ; Some reference elements (Not affected by previous matrix transformations)
  Define._Vector3 circlePosV, circleRotV
  Init_Vector3(@circlePosV, 0, 0, 0)
  Init_Vector3(@circleRotV, 1, 0, 0)
  
  DrawCircle3D(@circlePosV, #EARTH_ORBIT_RADIUS, @circleRotV, 90.0, Fade(#COLOR_RED, 0.5))
  DrawGrid(20, 1.0)
  
  EndMode3D()
  
  DrawTextRayLib("EARTH ORBITING AROUND THE SUN!", 400, 10, 20, #COLOR_MAROON)
  DrawFPS(10, 10)
  
  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/models_rlgl_module_usage.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
CloseWindowRayLib()     ; Close window and OpenGL context
;---------------------------------------------------------------------------------------


;>--------------------------------------------------------------------------------------------
; Module Functions Definitions (local)
;--------------------------------------------------------------------------------------------

; Draw sphere without any matrix transformation
; NOTE: Sphere is drawn in world position ( 0, 0, 0 ) With radius 1.0f
Procedure DrawSphereBasic(color.rl_ColorLong)
  Protected.rl_int rings = 16
  Protected.rl_int slices = 16
  
  Protected.rl_int i, j
  
  ; Make sure there is enough space in the internal render batch
  ; buffer To store all required vertex, batch is reseted If required
  rlCheckRenderBatchLimit((rings + 2) * slices * 6)
  
  rlBegin(#RL_TRIANGLES);
  rlColor4ub(PeekA(@color+0), PeekA(@color+1), PeekA(@color+2), PeekA(@color+3))
  
  For i = 0 To (rings + 2) - 1
    For j = 0 To slices - 1
      rlVertex3f(Cos(#DEG2RAD*(270+(180/(rings + 1))*i)) * Sin(#DEG2RAD*(j*360/slices)),
                 Sin(#DEG2RAD*(270+(180/(rings + 1))*i)),
                 Cos(#DEG2RAD*(270+(180/(rings + 1))*i)) * Cos(#DEG2RAD*(j*360/slices)))
      
      rlVertex3f(Cos(#DEG2RAD*(270+(180/(rings + 1))*(i+1))) * Sin(#DEG2RAD*((j+1)*360/slices)),
                 Sin(#DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                 Cos(#DEG2RAD*(270+(180/(rings + 1))*(i+1))) * Cos(#DEG2RAD*((j+1)*360/slices)))
      
      rlVertex3f(Cos(#DEG2RAD*(270+(180/(rings + 1))*(i+1))) * Sin(#DEG2RAD*(j*360/slices)),
                 Sin(#DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                 Cos(#DEG2RAD*(270+(180/(rings + 1))*(i+1))) * Cos(#DEG2RAD*(j*360/slices)))
      
      rlVertex3f(Cos(#DEG2RAD*(270+(180/(rings + 1))*i)) * Sin(#DEG2RAD*(j*360/slices)),
                 Sin(#DEG2RAD*(270+(180/(rings + 1))*i)),
                 Cos(#DEG2RAD*(270+(180/(rings + 1))*i)) * Cos(#DEG2RAD*(j*360/slices)))
      
      rlVertex3f(Cos(#DEG2RAD*(270+(180/(rings + 1))*(i))) * Sin(#DEG2RAD*((j+1)*360/slices)),
                 Sin(#DEG2RAD*(270+(180/(rings + 1))*(i))),
                 Cos(#DEG2RAD*(270+(180/(rings + 1))*(i))) * Cos(#DEG2RAD*((j+1)*360/slices)))
      
      rlVertex3f(Cos(#DEG2RAD*(270+(180/(rings + 1))*(i+1))) * Sin(#DEG2RAD*((j+1)*360/slices)),
                 Sin(#DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                 Cos(#DEG2RAD*(270+(180/(rings + 1))*(i+1))) * Cos(#DEG2RAD*((j+1)*360/slices)))
    Next
  Next
  rlEnd()
EndProcedure
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 61
; FirstLine = 46
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)