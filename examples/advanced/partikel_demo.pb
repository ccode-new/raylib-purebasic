; *   This example has been created using
; *   - raylib 1.8 (www.raylib.com)
; *   - libpartikel (https://github.com/dbriemann/libpartikel)
; *
; *   raylib is licensed under an unmodified zlib/libpng license (View raylib.h For details)
; *   libpartikel is licensed under an unmodified zlib/libpng license (View partikel.h For details)
; *
; *   Copyright (c) 2O19 David Linus Briemann (@Raging_Dave)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "libpartikel.pbi"

; Global Data.
;>----------------------------------------------------------------------------------
#screenWidth = 1000
#screenHeight = 800

Global.rl_uint counter = 0
Global.Camera2D camera

Global.Texture2D texCircle16
Global.Texture2D texCircle8
Global.Texture2D texCircle4

Global.rl_int activePS = 1

Global.ParticleSystem *ps1
Global.Emitter *emitterFountain1
Global.Emitter *emitterFountain2
Global.Emitter *emitterFountain3

Global.ParticleSystem *ps2
Global.Emitter *emitterSwirl1
Global.Emitter *emitterSwirl2
Global.Emitter *emitterSwirl3

Global.ParticleSystem *ps3
Global.Emitter *emitterFlame1
Global.Emitter *emitterFlame2
Global.Emitter *emitterFlame3

; Define a custom particle deactivator function.
Procedure.rl_bool Particle_DeactivatorFountain(*p.Particle)
  ProcedureReturn Bool(*p\position\y > (camera\target\y + camera\offset\y) Or 
                       *p\position\x < (camera\target\x - camera\offset\x) Or
                       *p\position\x > (camera\target\x + camera\offset\x) Or
                       Particle_DeactivatorAge(*p))
EndProcedure

Procedure.rl_bool Particle_DeactivatorOutsideCam(*p.Particle)
  ProcedureReturn Bool(*p\position\y < (camera\target\y - camera\offset\y) Or
                       Particle_DeactivatorAge(*p))
EndProcedure

Procedure OOMExit()
  MessageRequester("X_X", "OUT OF MEMORY.. BYE\n", #PB_MessageRequester_Error)
  End
EndProcedure

Procedure InitFountain()
  Protected.EmitterConfig ecfg1
  
  *ps1 = ParticleSystem_New()
  
  If *ps1 = #Null
    OOMExit()
  EndIf
  
  With ecfg1
    \capacity = 600
    \emissionRate = 200
    \origin\x = 0
    \origin\y = 0
    \offset\min = 1
    \offset\max = 10
    \originAcceleration\min = 0 
    \originAcceleration\max = 0
    \direction\x = 0 
    \direction\y = -1 ; go up
    \directionAngle\min = -6 
    \directionAngle\max = 6 ; angle range -8 To +8 degree deviation from direction
    \velocityAngle\min = 0 
    \velocityAngle\max = 0
    \velocity\min = 700 
    \velocity\max = 730
    \externalAcceleration\x = 0 
    \externalAcceleration\y = 981
    \startColor = RGBA(0, 20, 255, 255) 
    \endColor = RGBA(0, 150, 100, 0)
    \age\min = 1.0 
    \age\max = 3.0
    \texture = texCircle16
    \blendMode = #BLEND_ADDITIVE
    
    
    \particle_Deactivator = @Particle_DeactivatorFountain()
  EndWith
  
  *emitterFountain1 = Emitter_New(@ecfg1)
  
  If *emitterFountain1 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps1, *emitterFountain1)
  
  ecfg1\directionAngle\min = -1.5 
  ecfg1\directionAngle\max = 1.5
  ecfg1\velocity\min = 800 
  ecfg1\velocity\max = 850
  ecfg1\texture = texCircle8
  
  *emitterFountain2 = Emitter_New(@ecfg1)
  
  If *emitterFountain2 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps1, *emitterFountain2)
  
  ecfg1\capacity = 3000
  ecfg1\emissionRate = 1000
  ecfg1\directionAngle\min = -20 
  ecfg1\directionAngle\max = 20
  ecfg1\velocity\min = 500 
  ecfg1\velocity\max = 550
  ecfg1\texture = texCircle16
  ecfg1\age\min = 0.0 
  ecfg1\age\max = 3.0
  
  *emitterFountain3 = Emitter_New(@ecfg1)
  
  If *emitterFountain3 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps1, *emitterFountain3)
  
  ParticleSystem_Start(*ps1)
  
EndProcedure

Procedure InitSwirl()
  Protected.EmitterConfig ecfg
  
  *ps2 = ParticleSystem_New()
  
  If *ps2 = #Null
    OOMExit()
  EndIf

  With ecfg
    \capacity = 2500
    \emissionRate = 500
    \origin\x = 0 
    \origin\y = 0
    \originAcceleration\min = 400 
    \originAcceleration\max = 500
    \offset\min = 30 
    \offset\max = 40
    \direction\x = 0 
    \direction\y = -1 ; go up
    \directionAngle\min = -180 
    \directionAngle\max = 180
    \velocityAngle\min = 90 
    \velocityAngle\max = 90
    \velocity\min = 200 
    \velocity\max = 500
    \startColor = RGBA(244, 20, 0, 255)
    \endColor = RGBA(244, 20, 0, 0)
    \age\min = 2.5 
    \age\max = 5.0
    \texture = texCircle8
    \blendMode = #BLEND_ADDITIVE

    \particle_Deactivator = @Particle_DeactivatorOutsideCam()
  EndWith

  *emitterSwirl1 = Emitter_New(@ecfg)
  
  If *emitterSwirl1 = #Null
    OOMExit()
  EndIf
        
  ParticleSystem_Register(*ps2, *emitterSwirl1)

  ecfg\capacity = 1000
  ecfg\emissionRate = 200
  ecfg\offset\min = 40 
  ecfg\offset\max = 50
  ecfg\startColor = RGBA(244, 0, 111, 255)
  ecfg\endColor = RGBA(244, 0, 111, 0)

  *emitterSwirl2 = Emitter_New(@ecfg)
  
  If *emitterSwirl2 = #Null
   OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps2, *emitterSwirl2)

  ecfg\capacity = 150
  ecfg\emissionRate = 30
  ecfg\offset\min = 20 
  ecfg\offset\max = 30
  ecfg\velocity\min = 100 
  ecfg\velocity\max = 200
  ecfg\startColor = RGBA(255, 211, 0, 255)
  ecfg\endColor = RGBA(255, 211, 0, 0)

  *emitterSwirl3 = Emitter_New(@ecfg)
  
  If *emitterSwirl3 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps2, *emitterSwirl3)

  ParticleSystem_Start(*ps2)
  
EndProcedure

Procedure InitFlame()
  Protected.EmitterConfig ecfg
  
  *ps3 = ParticleSystem_New()
  
  If *ps3 = #Null
    OOMExit()
  EndIf

  With ecfg
    \capacity = 1000
    \emissionRate = 500
    \origin\x = 0 
    \origin\y = 0
    \originAcceleration\min = 50 
    \originAcceleration\max = 100
    \offset\min = 1 
    \offset\max = 10
    \direction\x = 0 
    \direction\y = -1 ; go up
    \directionAngle\min = -90 
    \directionAngle\max = -90
    \velocityAngle\min = 90 
    \velocityAngle\max = 90
    \velocity\min = 30 
    \velocity\max = 150
    \startColor = RGBA(255, 20, 0, 255)
    \endColor = RGBA(255, 20, 0, 0)
    \age\min = 1.0 
    \age\max = 2.0
    \texture = texCircle16
    \blendMode = #BLEND_ADDITIVE

    \particle_Deactivator = @Particle_DeactivatorFountain()
  EndWith

  *emitterFlame1 = Emitter_New(@ecfg)
  
  If *emitterFlame1 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps3, *emitterFlame1)

  ecfg\capacity = 20
  ecfg\emissionRate = 20
  ecfg\startColor = RGBA(255, 255, 255, 255)
  ecfg\endColor = RGBA(255, 255, 255, 0)
  ecfg\age\min = 0.5 
  ecfg\age\max = 1.0

  *emitterFlame2 = Emitter_New(@ecfg)
  
  If *emitterFlame2 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps3, *emitterFlame2)

  ecfg\capacity = 500
  ecfg\emissionRate = 100
  ecfg\directionAngle\min = -3 
  ecfg\directionAngle\max = 3
  ecfg\velocityAngle\min = 0
  ecfg\velocityAngle\max = 0
  ecfg\originAcceleration\min = 0 
  ecfg\originAcceleration\max = 0
  ecfg\startColor = RGBA(125, 125, 125, 30)
  ecfg\endColor = RGBA(125, 125, 125, 10)
  ecfg\age\min = 3.0 
  ecfg\age\max = 5.0

  *emitterFlame3 = Emitter_New(@ecfg)
  
  If *emitterFlame3 = #Null
    OOMExit()
  EndIf
  
  ParticleSystem_Register(*ps3, *emitterFlame3)

  ParticleSystem_Start(*ps3)
    
EndProcedure

Procedure DestroyFountain()
  Emitter_Free(*emitterFountain1)
  Emitter_Free(*emitterFountain2)
  Emitter_Free(*emitterFountain3)

  ParticleSystem_Free(*ps1)
EndProcedure

Procedure DestroySwirl()
  Emitter_Free(*emitterSwirl1)
  Emitter_Free(*emitterSwirl2)
  Emitter_Free(*emitterSwirl3)

  ParticleSystem_Free(*ps2)
EndProcedure

Procedure DestroyFlame()
  Emitter_Free(*emitterFlame1)
  Emitter_Free(*emitterFlame2)
  Emitter_Free(*emitterFlame3)

  ParticleSystem_Free(*ps3)
EndProcedure

; Init sets up all relevant Data.
Procedure Init()
  Protected.Image imgCircle16, imgCircle8, imgCircle4
  
  InitWindow(#screenWidth, #screenHeight, "libpartikel demo")
  
  SetTargetFPS(60)
  
  HideCursor()

  camera\target\x = 0 
  camera\target\y = 0
  camera\offset\x = #screenWidth / 2 
  camera\offset\y = #screenHeight / 2
  camera\rotation = 0.0
  camera\zoom = 1.0

  ; Generate some simple textures.
  GenImageGradientRadial(@imgCircle16, 16, 16, 0.3, #COLOR_WHITE, #COLOR_BLACK)
  LoadTextureFromImage(@texCircle16, @imgCircle16)
  
  GenImageGradientRadial(@imgCircle8, 8, 8, 0.5, #COLOR_WHITE, #COLOR_BLACK)
  LoadTextureFromImage(@texCircle8, @imgCircle8)
  
  GenImageGradientRadial(@imgCircle4, 4, 4, 0.5, #COLOR_WHITE, #COLOR_BLACK)
  LoadTextureFromImage(@texCircle4, @imgCircle4)

  UnloadImage(@imgCircle4)
  UnloadImage(@imgCircle8)
  UnloadImage(@imgCircle16)

  InitFountain()
  InitSwirl()
  InitFlame()
    
EndProcedure

; Destroy And free all the Global Data.
Procedure Destroy()
  DestroyFountain()
  DestroySwirl()
  DestroyFlame()

  UnloadTexture(@texCircle4)
  UnloadTexture(@texCircle8)
  UnloadTexture(@texCircle16)

  ; Close window And OpenGL context
  CloseWindowRayLib()
EndProcedure

Procedure Update(dt.rl_float)
  Protected.Vector2 m 
  Protected.rl_bool trigger
  Protected.rl_int key
  
  GetMousePosition(@m)
  
  m\x - #screenWidth / 2
  m\y - #screenHeight / 2
  
  counter = 0
  
  trigger = #False
  
  key = GetKeyPressed()
  
  Select key
    Case #KEY_ONE
      activePS = 1
    Case #KEY_TWO
      activePS = 2
    Case #KEY_THREE:
      activePS = 3
    Case #KEY_SPACE
      trigger = #True
  EndSelect
  
  Select activePS
    Case 1
      ParticleSystem_SetOrigin(*ps1, @m)
      counter + ParticleSystem_Update(*ps1, dt)
    Case 2
      ParticleSystem_SetOrigin(*ps2, @m)
      counter + ParticleSystem_Update(*ps2, dt)   
    Case 3
      ParticleSystem_SetOrigin(*ps3, @m)
      counter + ParticleSystem_Update(*ps3, dt)
  EndSelect
  
EndProcedure

Procedure Draw()
  ; Draw
  ;>----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_BLACK)

  BeginMode2D(@camera)
  
  ; Draw scene here.
  Select activePS
    Case 1
        ParticleSystem_Draw(*ps1)
    Case 2
        ParticleSystem_Draw(*ps2)
    Case 3
        ParticleSystem_Draw(*ps3)
  EndSelect

  EndMode2D()

  ; Draw HUD etc. here.
  DrawFPS(10, 10)

  DrawTextRayLib("Particles: " + Str(counter), 10, 40, 20, #COLOR_DARKGREEN)
  
  DrawTextRaylib("Press number keys to switch demo.", 580, 10, 20, #COLOR_DARKGREEN)

  DrawTextRayLib("1: Fountain / 2: Swirl / 3: Flame", 580, 40, 20, #COLOR_DARKGREEN)

  EndDrawing()
    
EndProcedure


; Initialization
;>----------------------------------------------------------------------------------
Init()

Global.rl_float dt
; Main game loop
;>----------------------------------------------------------------------------------
While Not WindowShouldClose() ; Detect window close button Or ESC key
  
  dt = GetFrameTime()
  
  Update(dt)

  Draw()
  
Wend

; De-Initialization
;>----------------------------------------------------------------------------------
Destroy()
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 72
; FirstLine = 72
; Folding = ---
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)