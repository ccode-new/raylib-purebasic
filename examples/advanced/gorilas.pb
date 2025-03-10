; /*******************************************************************************************
; *
; *   raylib - classic game: gorilas
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
#MAX_BUILDINGS = 15
#MAX_EXPLOSIONS = 200
#MAX_PLAYERS = 2

#BUILDING_RELATIVE_ERROR = 30           ; Building size random range %
#BUILDING_MIN_RELATIVE_HEIGHT = 20      ; Minimum height in % of the screenHeight
#BUILDING_MAX_RELATIVE_HEIGHT = 60      ; Maximum height in % of the screenHeight
#BUILDING_MIN_GRAYSCALE_COLOR = 120     ; Minimum gray color For the buildings
#BUILDING_MAX_GRAYSCALE_COLOR = 200     ; Maximum gray color For the buildings

#MIN_PLAYER_POSITION = 5                ; Minimum x position %
#MAX_PLAYER_POSITION = 20               ; Maximum x position %

#GRAVITY = 9.81
#DELTA_FPS = 60

; //----------------------------------------------------------------------------------
; // Types And Structures Definition
; //----------------------------------------------------------------------------------
Structure TPlayer
  position.Vector2
  size.Vector2

  aimingPoint.Vector2
  aimingAngle.rl_int
  aimingPower.rl_int

  previousPoint.Vector2
  previousAngle.rl_int
  previousPower.rl_int

  impactPoint.Vector2

  isLeftTeam.rl_bool                ; This player belongs To the left Or To the right team
  isPlayer.rl_bool                  ; If is a player Or an AI
  isAlive.rl_bool
EndStructure

Structure TBuilding
  rectangle.Rectangle
  color.rl_ColorLong
EndStructure

Structure TExplosion
  position.Vector2
  radius.rl_int
  active.rl_bool
EndStructure

Structure TBall
  position.Vector2
  speed.Vector2
  radius.rl_int
  active.rl_bool
EndStructure

; //------------------------------------------------------------------------------------
; // Global Variables Declaration
; //------------------------------------------------------------------------------------
#screenWidth = 800
#screenHeight = 450

Global.rl_bool gameOver = #False
Global.rl_bool pause = #False

Global Dim player.TPlayer(#MAX_PLAYERS)
Global Dim building.TBuilding(#MAX_BUILDINGS)
Global Dim explosion.TExplosion(#MAX_EXPLOSIONS)
Global.TBall ball

Global.rl_int playerTurn = 0
Global.rl_bool ballOnAir = #False

Global.Vector2 mousePos

; //------------------------------------------------------------------------------------
; // Module Functions Declaration (local)
; //------------------------------------------------------------------------------------
Declare InitGame()                  ; Initialize game
Declare UpdateGame()                ; Update game (one frame)
Declare DrawGame()                  ; Draw game (one frame)
Declare UnloadGame()                ; Unload game
Declare UpdateDrawFrame()           ; Update and Draw (one frame)

; Additional Module functions
Declare InitBuildings()
Declare InitPlayers()
Declare.rl_bool UpdatePlayer(playerTurn.rl_int)
Declare.rl_bool UpdateBall(playerTurn.rl_int)

;-Main
; Initialization (Note windowTitle is unused on Android)
;>---------------------------------------------------------
InitWindow(#screenWidth, #screenHeight, "classic game: gorilas")

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
UnloadGame()              ; Unload loaded data (textures, sounds, models...)

CloseWindowRayLib()       ; Close window and OpenGL context
;---------------------------------------------------------------------------------------


; //------------------------------------------------------------------------------------
; // Module Functions Definitions (local)
; //------------------------------------------------------------------------------------

; Initialize game variables
Procedure InitGame()
  Protected.rl_int i
  ; Init shoot
  ball\radius = 10
  ballOnAir = #False
  ball\active = #False

  InitBuildings()
  InitPlayers()

  ; Init explosions
  For i = 0 To #MAX_EXPLOSIONS - 1
    InitVector2(@explosion(i)\position, 0.0, 0.0)
    explosion(i)\radius = 30
    explosion(i)\active = #False
  Next
EndProcedure

; Update game (one frame)
Procedure UpdateGame()
  Protected.rl_bool leftTeamAlive, rightTeamAlive
  Protected.rl_int i
  
  If Not gameOver 
    If IsKeyPressed('P')
      pause = Bool(Not pause)
    EndIf

    If Not pause
      If Not ballOnAir
        ballOnAir = UpdatePlayer(playerTurn)  ; If we are aiming
      Else
        If UpdateBall(playerTurn)             ; If collision
          ; Game over logic
          leftTeamAlive = #False
          rightTeamAlive = #False

          For i = 0 To #MAX_PLAYERS - 1
            If player(i)\isAlive = #True
              If player(i)\isLeftTeam 
                leftTeamAlive = #True
              EndIf
              If Not player(i)\isLeftTeam
                rightTeamAlive = #True
              EndIf
            EndIf
          Next

          If leftTeamAlive And rightTeamAlive
            ballOnAir = #False
            ball\active = #False

            playerTurn + 1

            If playerTurn = #MAX_PLAYERS
              playerTurn = 0
            EndIf
          Else
            gameOver = #True
            ;// If (leftTeamAlive) left team wins
            ;// If (rightTeamAlive) right team wins
          EndIf
        EndIf
      EndIf
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
  Protected.rl_int i
  Protected.Vector2 drawV1, drawV2
  
  BeginDrawing()
  
  ClearBackground(#COLOR_RAYWHITE)
  
  If Not gameOver
    ; Draw buildings
    For i = 0 To #MAX_BUILDINGS - 1 
      DrawRectangleRec(@building(i)\rectangle, building(i)\color)
    Next
    
    ; Draw explosions
    For i = 0 To #MAX_EXPLOSIONS - 1
      If explosion(i)\active 
        DrawCircle(explosion(i)\position\x, explosion(i)\position\y, explosion(i)\radius, #COLOR_RAYWHITE)
      EndIf
    Next
    
    ; Draw players
    For i = 0 To #MAX_PLAYERS - 1
      If player(i)\isAlive = #True
        If (player(i)\isLeftTeam) 
          DrawRectangle(player(i)\position\x - player(i)\size\x / 2, player(i)\position\y - player(i)\size\y / 2,
                        player(i)\size\x, player(i)\size\y, #COLOR_BLUE)
        Else 
          DrawRectangle(player(i)\position\x - player(i)\size\x / 2, player(i)\position\y - player(i)\size\y / 2,
                        player(i)\size\x, player(i)\size\y, #COLOR_RED)
        EndIf
      EndIf
    Next
    
    ; Draw ball
    If ball\active = #True 
      DrawCircle(ball\position\x, ball\position\y, ball\radius, #COLOR_MAROON)
    EndIf
    
    ; Draw the angle And the power of the aim, And the previous ones
    If Not ballOnAir
      ; Draw shot information
;       If player(playerTurn)\isLeftTeam = #True
;         DrawTextRayLib("Previous Point " + Str(player(playerTurn)\previousPoint\x) + ", " + Str(player(playerTurn)\previousPoint\y), 20, 20, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Previous Angle " + Str(player(playerTurn)\previousAngle), 20, 50, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Previous Power " + Str(player(playerTurn)\previousPower), 20, 80, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Aiming Point " + Str(player(playerTurn)\aimingPoint\x) + ", " + Str(player(playerTurn)\aimingPoint\y), 20, 110, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Aiming Angle " + Str(player(playerTurn)\aimingAngle), 20, 140, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Aiming Power " + Str(player(playerTurn)\aimingPower), 20, 170, 20, #COLOR_DARKBLUE)   
;       Else
;         DrawTextRayLib("Previous Point " + Str(player(playerTurn)\previousPoint\x) +", " + Str(player(playerTurn)\previousPoint\y), #screenWidth * 3 / 4, 20, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Previous Angle " + Str(player(playerTurn)\previousAngle), #screenWidth * 3 / 4, 50, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Previous Power " + Str(player(playerTurn)\previousPower), #screenWidth * 3 / 4, 80, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Aiming Point " + Str(player(playerTurn)\aimingPoint\x) + ", " + Str(player(playerTurn)\aimingPoint\y), #screenWidth * 3 / 4, 110, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Aiming Angle " + Str(player(playerTurn)\aimingAngle), #screenWidth * 3 / 4, 140, 20, #COLOR_DARKBLUE)
;         DrawTextRayLib("Aiming Power " + Str(player(playerTurn)\aimingPower), #screenWidth * 3 / 4, 170, 20, #COLOR_DARKBLUE)
;       EndIf
      
      ; Draw aim
      If player(playerTurn)\isLeftTeam = #True
        ; Previous aiming
        InitVector2(@drawV1, player(playerTurn)\position\x - player(playerTurn)\size\x / 4, player(playerTurn)\position\y - player(playerTurn)\size\y / 4)
        InitVector2(@drawV2, player(playerTurn)\position\x + player(playerTurn)\size\x / 4, player(playerTurn)\position\y + player(playerTurn)\size\y / 4)
        
        DrawTriangle(@drawV1, @drawV2, @player(playerTurn)\previousPoint, #COLOR_GRAY)
        
        ; Actual aiming
        DrawTriangle(@drawV1, @drawV2, @player(playerTurn)\aimingPoint, #COLOR_DARKBLUE)
      Else
        ; Previous aiming
        InitVector2(@drawV1, player(playerTurn)\position\x - player(playerTurn)\size\x / 4, player(playerTurn)\position\y + player(playerTurn)\size\y / 4)
        InitVector2(@drawV2, player(playerTurn)\position\x + player(playerTurn)\size\x / 4, player(playerTurn)\position\y - player(playerTurn)\size\y / 4)
        
        DrawTriangle(@drawV1, @drawV2, @player(playerTurn)\previousPoint, #COLOR_GRAY)
        
        ; Actual aiming
        DrawTriangle(@drawV1, @drawV2, @player(playerTurn)\aimingPoint, #COLOR_MAROON)
      EndIf
    EndIf
    
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

; //--------------------------------------------------------------------------------------
; // Additional Module functions
; //--------------------------------------------------------------------------------------
Procedure InitBuildings()
  ; Horizontal generation
  Protected.rl_int currentWidth = 0
  Protected.rl_int i

  ; We make sure the absolute error randomly generated For each building, has As a minimum value the screenWidth.
  ; This way all the screen will be filled With buildings. Each building will have a different, random width.

  Protected.rl_float relativeWidth = 100 / (100 - #BUILDING_RELATIVE_ERROR)
  Protected.rl_float buildingWidthMean = (#screenWidth * relativeWidth / #MAX_BUILDINGS) + 1      ; We add one to make sure we will cover the whole screen.

  ; Vertical generation
  Protected.rl_int currentHeighth = 0
  Protected.rl_int grayLevel

  ; Creation
  For i = 0 To #MAX_BUILDINGS - 1
    ; Horizontal
    building(i)\rectangle\x = currentWidth
    building(i)\rectangle\width = GetRandomValue(buildingWidthMean * (100 - #BUILDING_RELATIVE_ERROR / 2) / 100 + 1, buildingWidthMean * (100 + #BUILDING_RELATIVE_ERROR) / 100)

    currentWidth + building(i)\rectangle\width

    ; Vertical
    currentHeighth = GetRandomValue(#BUILDING_MIN_RELATIVE_HEIGHT, #BUILDING_MAX_RELATIVE_HEIGHT)
    building(i)\rectangle\y = #screenHeight - (#screenHeight * currentHeighth / 100)
    building(i)\rectangle\height = #screenHeight * currentHeighth / 100 + 1

    ; Color
    grayLevel = GetRandomValue(#BUILDING_MIN_GRAYSCALE_COLOR, #BUILDING_MAX_GRAYSCALE_COLOR)
    building(i)\color = RGBA(grayLevel, grayLevel, grayLevel, 255)
  Next
EndProcedure

Procedure InitPlayers()
  Protected.rl_int i, j
  
  For i = 0 To #MAX_PLAYERS - 1
    player(i)\isAlive = #True

    ; Decide the team of this player
    If i % 2 = 0
      player(i)\isLeftTeam = #True
    Else 
      player(i)\isLeftTeam = #False
    EndIf

    ; Now there is no AI
    player(i)\isPlayer = #True

    ; Set size, by Default by now
    InitVector2(@player(i)\size, 40, 40)

    ; Set position
    If player(i)\isLeftTeam = #True
      player(i)\position\x = GetRandomValue(#screenWidth * #MIN_PLAYER_POSITION / 100, #screenWidth * #MAX_PLAYER_POSITION / 100)
    Else 
      player(i)\position\x = #screenWidth - GetRandomValue(#screenWidth * #MIN_PLAYER_POSITION / 100, #screenWidth * #MAX_PLAYER_POSITION / 100)
    EndIf
    
    For j = 0 To #MAX_BUILDINGS - 1
      If building(j)\rectangle\x > player(i)\position\x
        ; Set the player in the center of the building
        player(i)\position\x = building(j-1)\rectangle\x + building(j-1)\rectangle\width / 2
        ; Set the player at the top of the building
        player(i)\position\y = building(j-1)\rectangle\y - player(i)\size\y / 2
        Break
      EndIf
    Next

    ; Set statistics To 0
    player(i)\aimingPoint = player(i)\position
    player(i)\previousAngle = 0
    player(i)\previousPower = 0
    player(i)\previousPoint = player(i)\position
    player(i)\aimingAngle = 0
    player(i)\aimingPower = 0

    InitVector2(@player(i)\impactPoint, -100, -100)
  Next
EndProcedure

Procedure.rl_bool UpdatePlayer(playerTurn.rl_int)
  
  GetMousePosition(@mousePos)
  ; If we are aiming at the firing quadrant, we calculate the angle
  If mousePos\y <= player(playerTurn)\position\y
    ; Left team
    If (player(playerTurn)\isLeftTeam And mousePos\x) >= player(playerTurn)\position\x
      GetMousePosition(@mousePos)
      ; Distance (calculating the fire power)
      player(playerTurn)\aimingPower = Sqr(Pow(player(playerTurn)\position\x - mousePos\x, 2) + Pow(player(playerTurn)\position\y - mousePos\y, 2))
      ; Calculates the angle via arcsin
      player(playerTurn)\aimingAngle = ASin((player(playerTurn)\position\y - mousePos\y) / player(playerTurn)\aimingPower) * #RAD2DEG
      ; Point of the screen we are aiming at
      GetMousePosition(@mousePos)
      player(playerTurn)\aimingPoint = mousePos
      
      ; Ball fired
      If IsMouseButtonPressed(#MOUSE_LEFT_BUTTON)
        player(playerTurn)\previousPoint = player(playerTurn)\aimingPoint
        player(playerTurn)\previousPower = player(playerTurn)\aimingPower
        player(playerTurn)\previousAngle = player(playerTurn)\aimingAngle
        ball\position = player(playerTurn)\position
        
        ProcedureReturn #True
      EndIf
      ; Right team
    ElseIf (Not player(playerTurn)\isLeftTeam And mousePos\x) <= player(playerTurn)\position\x
      GetMousePosition(@mousePos)
      ; Distance (calculating the fire power)
      player(playerTurn)\aimingPower = Sqr(Pow(player(playerTurn)\position\x - mousePos\x, 2) + Pow(player(playerTurn)\position\y - mousePos\y, 2))
      ; Calculates the angle via arcsin
      player(playerTurn)\aimingAngle = ASin((player(playerTurn)\position\y - mousePos\y) / player(playerTurn)\aimingPower) * #RAD2DEG
      ; Point of the screen we are aiming at
      GetMousePosition(@mousePos)
      player(playerTurn)\aimingPoint = mousePos
      
      ; Ball fired
      If IsMouseButtonPressed(#MOUSE_LEFT_BUTTON)
        player(playerTurn)\previousPoint = player(playerTurn)\aimingPoint
        player(playerTurn)\previousPower = player(playerTurn)\aimingPower
        player(playerTurn)\previousAngle = player(playerTurn)\aimingAngle
        ball\position = player(playerTurn)\position
        
        ProcedureReturn #True
      EndIf
    Else
      player(playerTurn)\aimingPoint = player(playerTurn)\position
      player(playerTurn)\aimingPower = 0
      player(playerTurn)\aimingAngle = 0
    EndIf
  Else
    player(playerTurn)\aimingPoint = player(playerTurn)\position
    player(playerTurn)\aimingPower = 0
    player(playerTurn)\aimingAngle = 0
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure.rl_bool UpdateBall(playerTurn.rl_int)
  Protected.rl_int i
  Protected.Rectangle playerRec
  
  Static.rl_int explosionNumber = 0
  
  ; Activate ball
  If Not ball\active
    If player(playerTurn)\isLeftTeam = #True
      ball\speed\x = Cos(player(playerTurn)\previousAngle * #DEG2RAD) * player(playerTurn)\previousPower * 3 / #DELTA_FPS
      ball\speed\y = -Sin(player(playerTurn)\previousAngle * #DEG2RAD) * player(playerTurn)\previousPower * 3 / #DELTA_FPS
      ball\active = #True
    Else
      ball\speed\x = -Cos(player(playerTurn)\previousAngle * #DEG2RAD) * player(playerTurn)\previousPower * 3 / #DELTA_FPS
      ball\speed\y = -Sin(player(playerTurn)\previousAngle * #DEG2RAD) * player(playerTurn)\previousPower * 3 / #DELTA_FPS
      ball\active = #True
    EndIf
  EndIf
  
  ball\position\x + ball\speed\x
  ball\position\y + ball\speed\y
  ball\speed\y + #GRAVITY / #DELTA_FPS
  
  ; Collision
  If (ball\position\x + ball\radius) < 0
    ProcedureReturn #True
  ElseIf (ball\position\x - ball\radius) > #screenWidth 
    ProcedureReturn #True
  Else
    ; Player collision
    For i = 0 To #MAX_PLAYERS - 1
      InitRectangle(@playerRec, player(i)\position\x - player(i)\size\x / 2, player(i)\position\y - player(i)\size\y / 2, 
                    player(i)\size\x, player(i)\size\y)
      If CheckCollisionCircleRec(@ball\position, ball\radius, @playerRec)
        ; We can't hit ourselves
        If i = playerTurn
          ProcedureReturn #False
        Else
          ; We set the impact point
          player(playerTurn)\impactPoint\x = ball\position\x
          player(playerTurn)\impactPoint\y = ball\position\y + ball\radius
          
          ; We destroy the player
          player(i)\isAlive = #False
          ProcedureReturn #True
        EndIf
      EndIf
    Next
    ; Building collision
    ; NOTE: We only check building collision If we are Not inside an explosion
    For i = 0 To #MAX_EXPLOSIONS - 1
      If CheckCollisionCircles(@ball\position, ball\radius, @explosion(i)\position, explosion(i)\radius - ball\radius)
        ProcedureReturn #False
      EndIf
    Next
    
    For i = 0 To #MAX_BUILDINGS - 1
      If CheckCollisionCircleRec(@ball\position, ball\radius, @building(i)\rectangle)
        ; We set the impact point
        player(playerTurn)\impactPoint\x = ball\position\x
        player(playerTurn)\impactPoint\y = ball\position\y + ball\radius
        
        ; We create an explosion
        explosion(explosionNumber)\position = player(playerTurn)\impactPoint
        explosion(explosionNumber)\active = #True
        explosionNumber + 1
        
        ProcedureReturn #True
      EndIf
    Next
  EndIf
  
  ProcedureReturn #False
EndProcedure

  
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 465
; FirstLine = 457
; Folding = --
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)