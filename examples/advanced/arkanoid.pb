; /*******************************************************************************************
; *
; *   raylib - classic game: arkanoid
; *
; *   Sample game developed by Marc Palau And Ramon Santamaria
; *
; *   This game has been created using raylib v1.3 (www.raylib.com)
; *   raylib is licensed under an unmodified zlib/libpng license (View raylib.h For details)
; *
; *   Copyright (c) 2015 Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; //----------------------------------------------------------------------------------
; // Some Defines
; //----------------------------------------------------------------------------------
#PLAYER_MAX_LIFE = 5
#LINES_OF_BRICKS = 5
#BRICKS_PER_LINE = 20

; //----------------------------------------------------------------------------------
; // Types And Structures Definition
; //----------------------------------------------------------------------------------
Structure TPlayer
  position.Vector2
  size.Vector2
  life.rl_int
EndStructure
  
Structure TBall
  position.Vector2
  speed.Vector2
  radius.rl_int
  active.rl_bool
EndStructure

Structure TBrick
  position.Vector2
  active.rl_bool
EndStructure

; //------------------------------------------------------------------------------------
; // Global Variables Declaration
; //------------------------------------------------------------------------------------
#screenWidth = 800
#screenHeight = 450

Global.rl_bool gameOver = #False
Global.rl_bool pause = #False

Global.TPlayer player
Global.TBall ball
Global Dim brick.TBrick(#LINES_OF_BRICKS, #BRICKS_PER_LINE)
Global.Vector2 brickSize

Global.Vector2 brickSize
Global.rl_int initialDownPosition

; //------------------------------------------------------------------------------------
; // Module Functions Declaration (local)
; //------------------------------------------------------------------------------------
Declare InitGame()                  ; Initialize game
Declare UpdateGame()                ; Update game (one frame)
Declare DrawGame()                  ; Draw game (one frame)
Declare UnloadGame()                ; Unload game
Declare UpdateDrawFrame()           ; Update and Draw (one frame)

; //------------------------------------------------------------------------------------
; // Program main entry point
; //------------------------------------------------------------------------------------

;-Main
; Initialization (Note windowTitle is unused on Android)
;>---------------------------------------------------------
InitWindow(#screenWidth, #screenHeight, "classic game: arkanoid")

InitGame()

SetTargetFPS(60)
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  ; Update And Draw
  ;>----------------------------------------------------------------------------------
  UpdateDrawFrame()
  ;-----------------------------------------------------------------------------------
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadGame()                ; Unload loaded data (textures, sounds, models...)

CloseWindowRayLib()         ; Close window and OpenGL context
;---------------------------------------------------------------------------------------

; //------------------------------------------------------------------------------------
; // Module Functions Definitions (local)
; //------------------------------------------------------------------------------------

; Initialize game variables
Procedure InitGame()
  Protected.rl_int i, j
  
  InitVector2(@brickSize, GetScreenWidth() / #BRICKS_PER_LINE, 40)

  ; Initialize player
  InitVector2(@player\position, #screenWidth / 2, #screenHeight * 7 / 8)
  InitVector2(@player\size, #screenWidth / 10, 20)
  player\life = #PLAYER_MAX_LIFE

  ; Initialize ball
  InitVector2(@ball\position, #screenWidth / 2, #screenHeight * 7 / 8 - 30)
  InitVector2(@ball\speed, 0, 0)
  ball\radius = 7
  ball\active = #False

  ; Initialize bricks
  initialDownPosition = 50

  For i = 0 To #LINES_OF_BRICKS - 1
    For j = 0 To #BRICKS_PER_LINE - 1
      InitVector2(@brick(i, j)\position, j * brickSize\x + brickSize\x / 2, i * brickSize\y + initialDownPosition)
      brick(i, j)\active = #True
    Next
  Next
EndProcedure

; Update game (one frame)
Procedure UpdateGame()
  Protected.Rectangle playerRec
  Protected.rl_int i, j
  
  If Not gameOver
    If IsKeyPressed(#KEY_P) 
      pause = Bool(Not pause)
    EndIf
    
    If Not pause
      ; Player movement logic
      If IsKeyDown(#KEY_LEFT) 
        player\position\x - 5
      EndIf
      
      If Int(player\position\x - player\size\x / 2) <= 0 
        player\position\x = player\size\x / 2.0
      EndIf
      
      If IsKeyDown(#KEY_RIGHT) 
        player\position\x + 5
      EndIf
      
      If Int(player\position\x + player\size\x / 2) >= #screenWidth 
        player\position\x = #screenWidth - player\size\x / 2.0
      EndIf

      ; Ball launching logic
      If Not ball\active
        If IsKeyPressed(#KEY_SPACE)
          ball\active = #True
          InitVector2(@ball\speed, 0, -5)
        EndIf
      EndIf

      ; Ball movement logic
      If ball\active
        ball\position\x + ball\speed\x
        ball\position\y + ball\speed\y
      Else
        InitVector2(@ball\position, player\position\x, ((#screenHeight * 7.0) / 8.0) - 30)
      EndIf

      ; Collision logic: ball vs walls
      If (Int(ball\position\x + ball\radius) >= #screenWidth) Or (Int(ball\position\x - ball\radius) <= 0)
        ball\speed\x * -1
      EndIf
      
      If (Int(ball\position\y - ball\radius) <= 0) 
        Debug(ball\position\y)
        
        ball\speed\y = 0
        
        If Int(ball\speed\y) <= 0
          ball\speed\y = 5
          ball\speed\y * -1.0
        EndIf
        
;         If ball\speed\y > 0
;           ball\speed\y * -1.0
;         Else
;           ball\speed\y + 1.0
;         EndIf
      EndIf
      
;       Debug(ball\position\y + ball\radius)
;       Debug(ball\speed\y)
      
      
      If (Int(ball\position\y + ball\radius) >= #screenHeight)
        
        InitVector2(@ball\speed, 0, 0)
        ball\active = #False

        player\life - 1
      EndIf

      ; Collision logic: ball vs player
      InitRectangle(@playerRec, player\position\x - (player\size\x / 2.0), player\position\y - (player\size\y / 2.0), 
                    player\size\x, player\size\y)
      
      If CheckCollisionCircleRec(@ball\position, ball\radius, @playerRec)
        ;Debug "Kollision"
        If Int(ball\speed\y) > 0
          ball\speed\y * -1
          ball\speed\x = (ball\position\x - player\position\x) / (player\size\x / 2) * 5
        EndIf
      EndIf

      ; Collision logic: ball vs bricks
      For i = 0 To #LINES_OF_BRICKS - 1
        For j = 0 To #BRICKS_PER_LINE - 1
          If brick(i, j)\active
            ;Hit below
            If (Int(ball\position\y - ball\radius) <= Int(brick(i, j)\position\y + brickSize\y / 2)) And
              (Int(ball\position\y - ball\radius) > Int(brick(i, j)\position\y + brickSize\y / 2 + ball\speed\y)) And
              (Abs(ball\position\x - brick(i, j)\position\x) < Int(brickSize\x / 2 + ball\radius * 2 / 3)) And (Int(ball\speed\y) < 0)
              
              brick(i, j)\active = #False
              If ball\speed\y < 0
                ball\speed\y * -1
              EndIf
              
            ; Hit above
            ElseIf (Int(ball\position\y + ball\radius) >= Int(brick(i, j)\position\y - brickSize\y / 2)) And
                  (Int(ball\position\y + ball\radius) < Int(brick(i, j)\position\y - brickSize\y / 2 + ball\speed\y)) And
                  (Abs(ball\position\x - brick(i, j)\position\x) < Int(brickSize\x / 2 + ball\radius * 2 / 3)) And (Int(ball\speed\y) > 0)
              
            brick(i, j)\active = #False
            ;ball\speed\y * -1
                        
            ; Hit left
            ElseIf ((ball\position\x + ball\radius) >= (brick(i, j)\position\x - brickSize\x / 2)) And
                  ((ball\position\x + ball\radius) < (brick(i, j)\position\x - brickSize\x / 2 + ball\speed\x)) And
                  (Abs(ball\position\y - brick(i, j)\position\y) < (brickSize\y / 2 + ball\radius * 2 / 3)) And (ball\speed\x > 0)
              
              brick(i, j)\active = #False
              If ball\speed\y < 0
                ball\speed\x * -1
              EndIf
              
            ; Hit right
            ElseIf ((ball\position\x - ball\radius) <= (brick(i, j)\position\x + brickSize\x / 2)) And
                  ((ball\position\x - ball\radius) > (brick(i, j)\position\x + brickSize\x / 2 + ball\speed\x)) And
                  (Abs(ball\position\y - brick(i, j)\position\y) < (brickSize\y / 2 + ball\radius * 2 / 3)) And (ball\speed\x < 0)
              
              brick(i, j)\active = #False
              ;ball\speed\x * -1
            EndIf
          EndIf
        Next
      Next
    EndIf

    ; Game over logic
    If player\life <= 0
      gameOver = #True
    Else
      gameOver = #False
      
      For i = 0 To #LINES_OF_BRICKS - 1
        For j = 0 To #BRICKS_PER_LINE - 1
          If brick(i, j)\active
            gameOver = #False
          EndIf
        Next
      Next
    EndIf
  Else
    If IsKeyPressed(#KEY_ENTER)
      InitGame()
      gameOver = #False
    EndIf
  EndIf
EndProcedure

; Draw game (one frame)
Procedure DrawGame()
  Protected.rl_int i, j
  
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  If Not gameOver
    ; Draw player bar
    DrawRectangle(player\position\x - player\size\x / 2, player\position\y - player\size\y / 2, player\size\x, player\size\y, #COLOR_BLACK)
    
    ; Draw player lives
    For i = 0 To player\life - 1 
      DrawRectangle(20 + 40 * i, #screenHeight - 30, 35, 10, #COLOR_LIGHTGRAY)
    Next
    
    ; Draw ball
    DrawCircleV(@ball\position, ball\radius, #COLOR_MAROON)
    Debug player\position\y
    
    ; Draw bricks
    For i = 0 To #LINES_OF_BRICKS - 1
      For j = 0 To #BRICKS_PER_LINE - 1
        If brick(i, j)\active
          If Mod((i + j), 2) = 0
            DrawRectangle(brick(i, j)\position\x - brickSize\x / 2, brick(i, j)\position\y - brickSize\y / 2, brickSize\x, brickSize\y, #COLOR_RED)
          Else 
            DrawRectangle(brick(i, j)\position\x - brickSize\x / 2, brick(i, j)\position\y - brickSize\y / 2, brickSize\x, brickSize\y, #COLOR_DARKGRAY)
          EndIf
        EndIf
      Next
    Next
    
    If pause = #True
      DrawTextRayLib("GAME PAUSED", #screenWidth / 2 - MeasureText("GAME PAUSED", 40) / 2, #screenHeight / 2 - 40, 40, #COLOR_GRAY)
    EndIf  
  Else 
    DrawTextRayLib("PRESS [ENTER] TO PLAY AGAIN", GetScreenWidth() / 2 - MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20) / 2, GetScreenHeight() / 2 - 50, 20, #COLOR_GRAY)
  EndIf
  
  EndDrawing()
EndProcedure

; Unload game variables
Procedure UnloadGame()
  ; TODO: Unload all dynamic loaded Data (textures, sounds, models...)
EndProcedure

; Update And Draw (one frame)
Procedure UpdateDrawFrame()
  UpdateGame()
  DrawGame()
EndProcedure
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 216
; FirstLine = 202
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)