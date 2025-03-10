;
; **************
;               *
; Waponez II     **********************************************
;                                                              *
;   Original Waponez is from NC Gamez ! Check it on Aminet...   *
;                                                                *
; *****************************************************************
;
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

Declare MovePlayers()
Declare DisplayBullets()
Declare NewAlienWave()
Declare DisplayAliens()
Declare CheckCollisions()
Declare DisplayExplosions()

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 600

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [game] example - Waponez 2" )
If Not IsWindowReady()                  ; After creating the window, we check
  End                                   ; for errors at initialization.
EndIf 

InitAudioDevice() ; Initialize audio device

; Game config

#PlayerSpeedX = 6
#PlayerSpeedY = 6

#BulletSpeed = 10

#EnemyDelay = 30 ; in ms. The lower the value, the more enemies will be spawn

;
; Our bullet structure, which will be used by the linkedlist Bullet()
;

Structure Bullet
  x.rl_int
  y.rl_int
  Width.rl_int
  Height.rl_int
  *Image.Texture2D
  SpeedX.rl_int
  SpeedY.rl_int
EndStructure

Global NewList Bullet.Bullet()


Structure Explosion
  x.rl_int
  y.rl_int
  State.rl_int
  Delay.rl_int
EndStructure

Global NewList Explosion.Explosion()


Structure Alien
  x.rl_int
  y.rl_int
  Width.rl_int
  Height.rl_int
  Speed.rl_int
  StartImage.rl_int
  EndImage.rl_int
  ImageDelay.rl_int
  NextImageDelay.rl_int
  ActualImage.rl_int
  Armor.rl_int
EndStructure

Global NewList Aliens.Alien()


Procedure AddBullet(*Sprite.Texture2D, x.rl_int, y.rl_int, SpeedX.rl_int, SpeedY.rl_int)
  AddElement(Bullet())
  Bullet()\x      = x
  Bullet()\y      = y
  Bullet()\Width  = *Sprite\width
  Bullet()\Height = *Sprite\height
  Bullet()\Image  = *Sprite
  Bullet()\SpeedX = SpeedX
  Bullet()\SpeedY = SpeedY
EndProcedure
    

MessageRequester("Welcome !", ~"This is a silly shoot-and-collision example using the PureBasic-Waponez II source code.\n\nEnjoy !", 0)

Global.s Path = "Data/"

; Load the sound effects
Global.Sound sndLazer, sndExplosion
LoadSoundRayLib(@sndLazer, Path+"Lazer.wav") ;0
LoadSoundRayLib(@sndExplosion, Path+"Explosion.wav") ;2
    
; Load the player sprites
Global.Texture2D Player_1, Player_2, Player_3
LoadTextureRaylib(@Player_1, Path+"Player_1.png") ;3
LoadTextureRaylib(@Player_2, Path+"Player_2.png") ;0
LoadTextureRaylib(@Player_3, Path+"Player_2.png") ;2
 
; Load the bullets
Global.Texture2D Bullet_1, Bullet_Right, Bullet_Left, Bullet_Diag1, Bullet_Diag2, Bullet_Bottom
LoadTextureRaylib(@Bullet_1, Path+"Bullet_1.png") ;4
LoadTextureRaylib(@Bullet_Right, Path+"Bullet_Right.png") ;6
LoadTextureRaylib(@Bullet_Left, Path+"Bullet_Left.png") ;7
LoadTextureRaylib(@Bullet_Diag1, Path+"Bullet_Diag1.png") ;8
LoadTextureRaylib(@Bullet_Diag2, Path+"Bullet_Diag2.png") ;9
LoadTextureRaylib(@Bullet_Bottom, Path+"Bullet_Bottom.png") ;55

Global.rl_int k, i, BackX, BackY

; Sprite 10 to 15 reserved for the rotating animated alien..
Global Dim Enemy_3.Texture2D(4)
For k = 0 To 4
  LoadTextureRaylib(@Enemy_3(k), Path+"Enemy_3_"+Str(k+1)+".png")
Next
 
; Sprite 20 to 30 reserved for the Explosions...
Global Dim texExplosion.Texture2D(6)
For k = 0 To 6
  LoadTextureRaylib(@texExplosion(k), Path+"Explosion_"+Str(k+1)+".png")
Next
    
; Load the background sprite
Global.Texture2D Back_3
LoadTextureRaylib(@Back_3, Path+"Back_3.png") ;20

Global.Texture2D PlayerImage

Global.rl_int PlayerWidth  = Player_1\width
Global.rl_int PlayerHeight = Player_1\height
Global.rl_int PlayerX = (#SCREEN_WIDTH - PlayerWidth) / 2
Global.rl_int PlayerY = #SCREEN_HEIGHT - 80

Global.rl_int BulletDelay, ScrollDelay, AlienDelay, DeadDelay
Global.rl_int ScrollX, ScrollY

Global.rl_int Fire = 0
Global.rl_int Dead = 0

Global.rl_int Score = 0

SetTargetFPS(60)                  ; Set our game to run at 30 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose() ; Detect window close button Or ESC key
  
  BeginDrawing()
  
  ClearBackground( RGBA($05,$2C,$46,$FF) )
  
  ; Draw the background (an unified one...)
  For BackX = 0 To #SCREEN_WIDTH Step 32
    For BackY = -32 To #SCREEN_HEIGHT Step 32
      DrawTexture(@Back_3, BackX, BackY+ScrollY, #COLOR_WHITE)
    Next
  Next
      
  CheckCollisions()

  MovePlayers()
     
  DisplayBullets()
      
  NewAlienWave()
      
  DisplayAliens()
  
  DisplayExplosions()

  If BulletDelay > 0
    BulletDelay - 1
  EndIf

  If ScrollDelay = 0
    ScrollY + 1
    ScrollDelay = 0
  Else
    ScrollDelay - 1
  EndIf
      
  If ScrollY > 31
    ScrollY = 0
  EndIf
  
  DrawTextRayLib("Score: " + Str(Score), 10, 10, 32, #COLOR_YELLOW)
  
  EndDrawing()
      
Wend

; De-Initialization
;->-------------------------------------------------------------------------------------
StopSoundRayLib(@sndLazer)
StopSoundRayLib(@sndExplosion)

UnloadSound(@sndLazer)
UnloadSound(@sndExplosion)

UnloadTexture(@Player_1)
UnloadTexture(@Player_2)
UnloadTexture(@Player_3)

UnloadTexture(@Bullet_1)
UnloadTexture(@Bullet_Right)
UnloadTexture(@Bullet_Left)
UnloadTexture(@Bullet_Diag1)
UnloadTexture(@Bullet_Diag2)
UnloadTexture(@Bullet_Bottom)

For k = 0 To 4
  UnloadTexture(@Enemy_3(k))
Next

For k = 0 To 6
  UnloadTexture(@texExplosion(k))
Next

UnloadTexture(@Back_3)

CloseWindowRaylib()                     ; Close window and OpenGL context
;>-------------------------------------------------------------------------------------


Procedure MovePlayers()
  Fire = 0
  PlayerImage = Player_1  ; Non-moving player image
  
  If IsGamepadAvailable(#GAMEPAD_PLAYER1)
    If IsGamepadButtonDown(#GAMEPAD_PLAYER1, #GAMEPAD_BUTTON_LEFT_FACE_RIGHT)
      PlayerX + #PlayerSpeedX
      PlayerImage = Player_2  ; Right moving player image
    EndIf
    
    If IsGamepadButtonDown(#GAMEPAD_PLAYER1, #GAMEPAD_BUTTON_LEFT_FACE_LEFT)
      PlayerX - #PlayerSpeedX
      PlayerImage = Player_3  ; Left moving player image
    EndIf
    
    If IsGamepadButtonDown(#GAMEPAD_PLAYER1, #GAMEPAD_BUTTON_LEFT_FACE_UP)
      PlayerY - #PlayerSpeedY
    EndIf
    
    If IsGamepadButtonDown(#GAMEPAD_PLAYER1, #GAMEPAD_BUTTON_LEFT_FACE_DOWN)
      PlayerY + #PlayerSpeedY
    EndIf
    
    If IsGamepadButtonDown(#GAMEPAD_PLAYER1, #GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)
      fire = Bool(Not fire)
    EndIf
    
  EndIf
  
  If IsKeyDown(#KEY_RIGHT) 
    PlayerX + #PlayerSpeedX
    PlayerImage = Player_2  ; Right moving player image
  EndIf
  
  If IsKeyDown(#KEY_LEFT) 
    PlayerX - #PlayerSpeedX
    PlayerImage = Player_3  ; Left moving player image
  EndIf
  
  If IsKeyDown(#KEY_UP) 
    PlayerY - #PlayerSpeedY
  EndIf
  
  If IsKeyDown(#KEY_DOWN)
    PlayerY + #PlayerSpeedY
  EndIf
  

  If PlayerX < 0 : PlayerX = 0 : EndIf
  If PlayerY < 0 : PlayerY = 0 : EndIf

  If PlayerX > #SCREEN_WIDTH - PlayerWidth  : PlayerX = #SCREEN_WIDTH - PlayerWidth : EndIf
  If PlayerY > #SCREEN_HEIGHT - PlayerHeight : PlayerY = #SCREEN_HEIGHT - PlayerHeight : EndIf

 
  If Dead = 1
    AddElement(Explosion())
    Explosion()\x = PlayerX
    Explosion()\y = PlayerY

    Dead = 0
  Else
    If DeadDelay > 0
      DeadDelay-1
;       If db = 1
;         If DeadDelay < 200
;           DrawTexture(@PlayerImage, PlayerX, PlayerY, #COLOR_WHITE)
;         EndIf
;       EndIf
    Else
      DrawTexture(@PlayerImage, PlayerX, PlayerY, #COLOR_WHITE)
    EndIf
  EndIf
  
    
  If IsKeyDown(#KEY_SPACE) Or Fire
    If BulletDelay = 0
      If DeadDelay < 100
        BulletDelay = 10

        ; AddBullet() syntax: (#Sprite, x, y, SpeedX, SpeedY)
        AddBullet(Bullet_1, PlayerX+5 , PlayerY-10,  0          , -#BulletSpeed)       ; Front bullet (Double bullet sprite)
        AddBullet(Bullet_Right, PlayerX+45, PlayerY+6 ,  #BulletSpeed, 0)              ; Right side bullet
        AddBullet(Bullet_Left, PlayerX-11, PlayerY+6 , -#BulletSpeed, 0)               ; Left side bullet
        AddBullet(Bullet_Diag1, PlayerX+45, PlayerY-6 ,  #BulletSpeed, -#BulletSpeed)  ; Front-Right bullet
        AddBullet(Bullet_Diag2, PlayerX-11, PlayerY-6 , -#BulletSpeed, -#BulletSpeed)  ; Front-Left bullet
        AddBullet(Bullet_Bottom, PlayerX+20, PlayerY+45,  0          ,  #BulletSpeed)  ; Rear bullet
     
        PlaySoundRayLib(@sndLazer)    ; Play the 'pffffiiiouuu' laser like sound
      EndIf
    EndIf
  EndIf
  
  If IsKeyPressed(#KEY_F)
    ToggleFullscreen()
  EndIf

EndProcedure


Procedure DisplayBullets()
  
  ResetList(Bullet())
  While NextElement(Bullet())  ; Process all the bullet actually displayed on the screen

    If Bullet()\y < 0          ; If a bullet is now out of the screen, simply delete it..
      DeleteElement(Bullet())
    Else
      If Bullet()\x < 0        ; If a bullet is now out of the screen, simply delete it..
        DeleteElement(Bullet())
      Else
        If Bullet()\x > #SCREEN_WIDTH - Bullet()\Width
          DeleteElement(Bullet())
        Else
          If Bullet()\y > #SCREEN_HEIGHT
            DeleteElement(Bullet())
          Else  
            DrawTexture(Bullet()\Image, Bullet()\x, Bullet()\y, #COLOR_WHITE) ; Display the bullet..
            
            Bullet()\y + Bullet()\SpeedY
            Bullet()\x + Bullet()\SpeedX
          EndIf
        EndIf
      EndIf
    EndIf
    
  Wend

EndProcedure


Procedure NewAlienWave()

  If AlienDelay = 0

    AddElement(Aliens())

    Aliens()\x = Random(#SCREEN_WIDTH - 40)
    Aliens()\y = -32
    Aliens()\Width  = Enemy_3(0)\width
    Aliens()\Height = Enemy_3(0)\height
    Aliens()\Speed  = 3
    Aliens()\StartImage  = 0
    Aliens()\EndImage    = 4
    Aliens()\ImageDelay  =  4
    Aliens()\NextImageDelay = Aliens()\ImageDelay
    Aliens()\ActualImage = 0
    Aliens()\Armor = 1
    
    AlienDelay = Random(#EnemyDelay)
  Else
    AlienDelay - 1
  EndIf

EndProcedure


Procedure DisplayAliens()

  ResetList(Aliens())
  While NextElement(Aliens())

    DrawTexture(@Enemy_3(Aliens()\ActualImage), Aliens()\x, Aliens()\y, #COLOR_WHITE)

    Aliens()\y + Aliens()\Speed

    If Aliens()\NextImageDelay = 0
 
      Aliens()\ActualImage+1

      If Aliens()\ActualImage > Aliens()\EndImage
        Aliens()\ActualImage = Aliens()\StartImage
      EndIf

      Aliens()\NextImageDelay = Aliens()\ImageDelay
    Else
      Aliens()\NextImageDelay-1
    EndIf

    If Aliens()\Armor <= 0
      AddElement(Explosion())
      Explosion()\x = Aliens()\x
      Explosion()\y = Aliens()\y

      Score + 20
      DeleteElement(Aliens())
    Else
      If Aliens()\y > #SCREEN_HEIGHT
        DeleteElement(Aliens())
      EndIf
    EndIf
    
  Wend
  
EndProcedure


Procedure CheckCollisions()

  Define.Rectangle Bullet_Box, Alien_Box, Player_Box

  ResetList(Aliens())
  While NextElement(Aliens())
    ResetList(Bullet())
    While NextElement(Bullet())
      
      InitRectangle(@Bullet_Box, Bullet()\x, Bullet()\y, Bullet()\Width, Bullet()\Height)
      InitRectangle(@Alien_Box, Aliens()\x, Aliens()\y, Aliens()\Width, Aliens()\Height)
      
      ; Check boxes collision
      If CheckCollisionRecs(@Bullet_Box, @Alien_Box)
        Aliens()\Armor-1
        DeleteElement(Bullet())
      EndIf
      
    Wend

    If DeadDelay = 0 ; No more invincible...

      InitRectangle(@Player_Box, PlayerX, PlayerY, PlayerWidth, PlayerHeight)
      InitRectangle(@Alien_Box, Aliens()\x, Aliens()\y, Aliens()\Width, Aliens()\Height)
      
      If CheckCollisionRecs(@Player_Box, @Alien_Box)
        Dead = 1
        DeadDelay = 300

        AddElement(Explosion())
        Explosion()\x = Aliens()\x
        Explosion()\y = Aliens()\y

        DeleteElement(Aliens())
      EndIf
    EndIf
  
  Wend
  
EndProcedure


; DisplayExplosion:
; -----------------

Procedure DisplayExplosions()

  ResetList(Explosion())
  While NextElement(Explosion())   ; Take the etexExplosions objects, one by one.

    ; For each object, display the current etexExplosion image (called state here)
    
    DrawTexture(@texExplosion(Explosion()\State), Explosion()\x, Explosion()\y, #COLOR_WHITE)

    If Explosion()\Delay = 0
      If Explosion()\State = 0  ; Play the sound only at the etexExplosion start.
        PlaySoundRayLib(@sndExplosion)
      EndIf

      If Explosion()\State < 6
        Explosion()\State + 1
        Explosion()\Delay = 3
      Else
        DeleteElement(Explosion())
      EndIf
    Else
      Explosion()\Delay-1
    EndIf
  Wend

EndProcedure
  
  
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 469
; FirstLine = 196
; Folding = --
; Optimizer
; EnableThread
; EnableXP
; DisableDebugger
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)
; EnablePurifier