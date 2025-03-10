; /*******************************************************************************************
; *
; *   raylib [models] example - Mesh picking in 3d mode, ground plane, triangle, mesh
; *
; *   Example originally created With raylib 1.7, last time updated With raylib 4.0
; *
; *   Example contributed by Joel Davis (@joeld42) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software
; *
; *   Copyright (c) 2017-2023 Joel Davis (@joeld42) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/
IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

#FLT_MAX = 999999999999999 ;340282346638528859811704183484516925440.0  ; Maximum value of a float, from bit pattern 01111111011111111111111111111111

; Compute barycenter coordinates (u, v, w) For point p With respect To triangle (a, b, c)
; NOTE: Assumes P is on the plane of the triangle
Procedure Vector3Barycenter(*result._Vector3, *p._Vector3, *a._Vector3, *b._Vector3, *c._Vector3)
  Protected._Vector3 v0, v1, v2 
  Init_Vector3(@v0, *b\x - *a\x, *b\y - *a\y, *b\z - *a\z)                  ; Vector3Subtract(b, a)
  
  Init_Vector3(@v1, *c\x - *a\x, *c\y - *a\y, *c\z - *a\z)                  ; Vector3Subtract(c, a)
  
  Init_Vector3(@v2, *p\x - *a\x, *p\y - *a\y, *p\z - *a\z)                  ; Vector3Subtract(p, a)
  
  Protected.rl_float d00 = (v0\x * v0\x + v0\y * v0\y + v0\z * v0\z)  ; Vector3DotProduct(v0, v0)
  Protected.rl_float d01 = (v0\x * v1\x + v0\y * v1\y + v0\z * v1\z)  ; Vector3DotProduct(v0, v1)
  Protected.rl_float d11 = (v1\x * v1\x + v1\y * v1\y + v1\z * v1\z)  ; Vector3DotProduct(v1, v1)
  Protected.rl_float d20 = (v2\x * v0\x + v2\y * v0\y + v2\z * v0\z)  ; Vector3DotProduct(v2, v0)
  Protected.rl_float d21 = (v2\x * v1\x + v2\y * v1\y + v2\z * v1\z)  ; Vector3DotProduct(v2, v1)

  Protected.rl_float denom = d00*d11 - d01*d01

  *result\y = (d11 * d20 - d01 * d21) / denom
  *result\z = (d00 * d21 - d01 * d20) / denom
  *result\x = 1.0 - (*result\z + *result\y)
EndProcedure

; Initialization
;>-------------------------------------------------------------------------------------
#SCREEN_WIDTH = 800
#SCREEN_HEIGHT = 450

InitWindow( #SCREEN_WIDTH, #SCREEN_HEIGHT, "raylib [models] example - mesh picking" )
If Not IsWindowReady()                ; After creating the window, we check
  End                                 ; for errors at initialization.
EndIf                                 ; In case of error at init we end the program.

; Define the camera To look into our 3d world
Define.Camera camera
Init_Vector3(@camera\position, 20.0, 20.0, 20.0)      ; Camera position
Init_Vector3(@camera\target, 0.0, 8.0, 0.0)           ; Camera looking at point
Init_Vector3(@camera\up, 0.0, 1.6, 0.0)               ; Camera up vector (rotation towards target)
camera\fovy = 45.0                                    ; Camera field-of-view Y
camera\projection = #CAMERA_PERSPECTIVE           ; Camera mode type

Define.Ray ray  ; Picking ray

Define.Model tower
LoadModel(@tower, "resources/models/obj/turret.obj")                  ; Load OBJ model

Define.Texture2D texture 
LoadTextureRayLib(@texture, "resources/models/obj/turret_diffuse.png")                ; Load model texture

;tower.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture                ; Set model diffuse texture
CopyStructure(@texture, @tower\materials\maps\texture + #MATERIAL_MAP_DIFFUSE, Texture2D)

Define._Vector3 towerPos
Init_Vector3(@towerPos, 0.0, 0.0, 0.0)                                          ; Set model position

Define.BoundingBox towerBBox
GetMeshBoundingBox(@towerBBox, tower\meshes)                                   ; Get mesh bounding box

; Ground quad
Define._Vector3 g0 
Init_Vector3(@g0, -50.0, 0.0, -50.0)

Define._Vector3 g1
Init_Vector3(@g1, -50.0, 0.0,  50.0)

Define._Vector3 g2
Init_Vector3(@g2, 50.0, 0.0, 50.0)

Define._Vector3 g3 
Init_Vector3(@g3, 50.0, 0.0, -50.0)

; Test triangle
Define._Vector3 ta 
Init_Vector3(@ta, -25.0, 0.5, 0.0)

Define._Vector3 tb 
Init_Vector3(@tb, -4.0, 2.5, 1.0)

Define._Vector3 tc 
Init_Vector3(@tc, -8.0, 6.5, 0.0)

Define._Vector3 bary 
Init_Vector3(@bary, 0.0, 0.0, 0.0)

; Test sphere
Define._Vector3 sp 
Init_Vector3(@sp, -30.0, 5.0, 5.0)

Define.rl_float sr = 4.0

;SetCameraMode(@camera, #CAMERAMODE_FREE)    ; Set a free camera mode

SetTargetFPS(60)                            ; Set our game To run at 60 frames-per-second
;>--------------------------------------------------------------------------------------

; Main game loop
While Not WindowShouldClose()               ; Detect window close button Or ESC key
  ; Update
  ;>----------------------------------------------------------------------------------
  If IsCursorHidden()
    UpdateCamera(@camera, #CAMERA_ORBITAL)
  EndIf

  ; Display information about closest hit
  Define.RayCollision collision
  Define.Vector2 mouse
  
  Define.s hitObjectName = "None"
  
  collision\distance = #FLT_MAX
  collision\hit = #False
  
  Define.rl_ColorLong cursorColor = #COLOR_WHITE

  ; Get ray And test against objects
  GetMousePosition(@mouse)
  GetMouseRay(@ray, @mouse, @camera)

  ; Check ray collision against ground quad
  Define.RayCollision groundHitInfo 
  GetRayCollisionQuad(@groundHitInfo, @ray, @g0, @g1, @g2, @g3);

  If groundHitInfo\hit And groundHitInfo\distance < collision\distance
    collision = groundHitInfo
    cursorColor = #COLOR_GREEN
    hitObjectName = "Ground"
  EndIf

  ; Check ray collision against test triangle
  Define.RayCollision triHitInfo
  GetRayCollisionTriangle(@triHitInfo, @ray, @ta, @tb, @tc)

  If triHitInfo\hit And triHitInfo\distance < collision\distance
    collision = triHitInfo
    cursorColor = #COLOR_PURPLE
    hitObjectName = "Triangle"

    Vector3Barycenter(@bary, @collision\point, @ta, @tb, @tc)
  EndIf

  ; Check ray collision against test sphere
  Define.RayCollision sphereHitInfo 
  GetRayCollisionSphere(@sphereHitInfo, @ray, @sp, sr)

  If sphereHitInfo\hit And sphereHitInfo\distance < collision\distance
    collision = sphereHitInfo
    cursorColor = #COLOR_ORANGE
    hitObjectName = "Sphere"
  EndIf

  ; Check ray collision against bounding box first, before trying the full ray-mesh test
  Define.RayCollision boxHitInfo 
  GetRayCollisionBox(@boxHitInfo, @ray, @towerBBox)

  If boxHitInfo\hit And boxHitInfo\distance < collision\distance
    collision = boxHitInfo
    cursorColor = #COLOR_ORANGE
    hitObjectName = "Box"

    ; Check ray collision against model meshes
    Define.RayCollision meshHitInfo
    Define.rl_int m
    
    For m = 0 To tower\meshCount - 1
      ; NOTE: We consider the model.transform For the collision check but 
      ; it can be checked against any transform Matrix, used when checking against same
      ; model drawn multiple times With multiple transforms
      GetRayCollisionMesh(@meshHitInfo, @ray, tower\meshes + m, @tower\transform)
      If meshHitInfo\hit
        ; Save the closest hit mesh
        If ( Not collision\hit) Or (collision\distance > meshHitInfo\distance)
          collision = meshHitInfo
        EndIf
                    
        Break ; Stop once one mesh collision is detected, the colliding mesh is m
      EndIf
    Next

    If meshHitInfo\hit
      collision = meshHitInfo
      cursorColor = #COLOR_ORANGE
      hitObjectName = "Mesh"
    EndIf
  EndIf
  ;>----------------------------------------------------------------------------------

  ; Draw
  ;-----------------------------------------------------------------------------------
  BeginDrawing()

  ClearBackground(#COLOR_RAYWHITE)

  BeginMode3D(@camera)

  ; Draw the tower
  ; WARNING: If scale is different than 1.0f,
  ; Not considered by GetRayCollisionModel()
  DrawModel(@tower, @towerPos, 1.0, #COLOR_WHITE)

  ; Draw the test triangle
  DrawLine3D(@ta, @tb, #COLOR_PURPLE)
  DrawLine3D(@tb, @tc, #COLOR_PURPLE)
  DrawLine3D(@tc, @ta, #COLOR_PURPLE)

  ; Draw the test sphere
  DrawSphereWires(@sp, sr, 8, 8, #COLOR_PURPLE)

  ; Draw the mesh bbox If we hit it
  If boxHitInfo\hit
    DrawBoundingBox(@towerBBox, #COLOR_LIME)
  EndIf
  
  ; If we hit something, draw the cursor at the hit point
  If collision\hit
    DrawCube(@collision\point, 0.3, 0.3, 0.3, cursorColor)
    DrawCubeWires(@collision\point, 0.3, 0.3, 0.3, #COLOR_RED)

    Define._Vector3 normalEnd
    normalEnd\x = collision\point\x + collision\normal\x
    normalEnd\y = collision\point\y + collision\normal\y
    normalEnd\z = collision\point\z + collision\normal\z

    DrawLine3D(@collision\point, @normalEnd, #COLOR_RED)
  EndIf

  DrawRay(@ray, #COLOR_MAROON)

  DrawGrid(10, 10.0)

  EndMode3D()

  ; Draw some Debug GUI text
  DrawTextRayLib("Hit Object: " + hitObjectName, 10, 50, 10, #COLOR_BLACK)

  If collision\hit
    Define.rl_int ypos = 70

    DrawTextRayLib("Distance: " + StrF(collision\distance, 2), 10, ypos, 10, #COLOR_BLACK)

    DrawTextRayLib("Hit Pos: " + StrF(collision\point\x, 2) + ", " + StrF(collision\point\y, 2) + ", " +
                   StrF(collision\point\z, 2), 10, ypos + 15, 10, #COLOR_BLACK)

    DrawTextRayLib("Hit Norm: " + StrF(collision\normal\x, 2) + ", " + StrF(collision\normal\y, 2) + ", " +
                   StrF(collision\normal\z, 2), 10, ypos + 30, 10, #COLOR_BLACK)

    If triHitInfo\hit And hitObjectName = "Triangle"
      DrawTextRayLib("Barycenter: " + StrF(bary\x, 2) + ", " + StrF(bary\y, 2) +", " + StrF(bary\z, 2), 10, ypos + 45, 10, #COLOR_BLACK)
    EndIf
  EndIf

  DrawTextRayLib("Use Mouse to Move Camera", 10, 430, 10, #COLOR_GRAY)

  DrawTextRayLib("(c) Turret 3D model by Alberto Cano", #SCREEN_WIDTH - 200, #SCREEN_HEIGHT - 20, 10, #COLOR_GRAY)

  DrawFPS(10, 10)

  EndDrawing()
  ;>----------------------------------------------------------------------------------
  
  ; If we want to have a screenshot
  If IsKeyPressed(#KEY_F1)
    TakeScreenshot("screenshots/models_mesh_picking.png")
  EndIf
Wend

; De-Initialization
;>--------------------------------------------------------------------------------------
UnloadModel(@tower)          ; Unload model
UnloadTexture(@texture)      ; Unload texture

CloseWindowRayLib()         ; Close window and OpenGL context
;---------------------------------------------------------------------------------------
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 122
; FirstLine = 114
; Folding = -
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.20 - C Backend (MacOS X - arm64)