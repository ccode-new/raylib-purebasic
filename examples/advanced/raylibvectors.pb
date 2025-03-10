IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

XIncludeFile "raymath.pbi"


InitWindow(500, 500, "Vector-Test")

SetTargetFPS(60)

Define.Vector2 player 
InitVector2(@player, 30.0, 70.0)

Define.rl_float playerAngle

Define.Vector2 enemy 
InitVector2(@enemy, 300.0, 300.0)

Define.rl_int hp = 20

Define.Vector2 vec0, vec1, vec2, vec3, vec4, vec5

While Not WindowShouldClose()
  
  If IsKeyDown(#KEY_LEFT)
    player\x - 2.0
  EndIf
  
  If IsKeyDown(#KEY_RIGHT)
    player\x + 2.0
  EndIf
  
  If IsKeyDown(#KEY_UP) 
    player\y - 2.0
  EndIf
  
  If IsKeyDown(#KEY_DOWN) 
    player\y + 2.0
  EndIf

  playerAngle = ATan(player\y / player\x) * #RAD2DEG

  BeginDrawing()
  
  ClearBackground(#COLOR_BLACK)

  DrawCircleV(@player, 20.0, #COLOR_DARKGREEN)
  
  Vector2Zero(@vec0)
  
  DrawLineV(@vec0, @player, #COLOR_GREEN)

  DrawCircleSectorLines(@vec0, 30, 90, (90 - playerAngle), 100, #COLOR_DARKBLUE)
  
  DrawTextRayLib(StrF(playerAngle, 3), vec0\x + 30 + 5, 15, 10, #COLOR_DARKBLUE)

  If hp > 0
    DrawTextRayLib("HP: " + Str(hp), 330, 30, 20, #COLOR_DARKPURPLE)
    DrawCircleV(@enemy, 20.0, #COLOR_DARKPURPLE)
    
    Vector2Subtract(@vec1, @enemy, @player)
    
    If vec1\x <= 80.0 And vec1\x >= -80.0 And vec1\y <= 80.0 And vec1\y >= -80.0
      DrawLineV(@player, @enemy, #COLOR_PURPLE)
    EndIf
    
    vec2\x = enemy\x + 5 : vec2\y = enemy\y
    Vector2Normalize(@vec3, @vec2)
    
    Vector2Subtract(@vec4, @enemy, @player)
    
    Vector2Normalize(@vec5, @vec4)
    
    DrawTextRayLib("Relation: " + StrF(Vector2DotProduct(@vec3, @vec5), 3), 330, 50, 20, #COLOR_DARKPURPLE)
  EndIf

  DrawTextRayLib("Player vector " + StrF(player\x, 3) + ", " + StrF(player\y, 3), 20, 400, 20, #COLOR_LIGHTGRAY)
  
  DrawTextRayLib("Player vector length from the origin " + StrF(Vector2Length(@player), 3), 20, 430, 20, #COLOR_LIGHTGRAY)
  
  Vector2Subtract(@vec1, @enemy, @player)
  
  DrawTextRayLib("Distance between player and enemy " +  StrF(Vector2Length(@vec1), 3), 20, 460, 20, #COLOR_LIGHTGRAY)

  EndDrawing()
Wend 

CloseWindowRayLib()
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 30
; FirstLine = 22
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)