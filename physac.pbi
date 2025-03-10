; /**********************************************************************************************
; *
; *   Physac v1.1 - 2D Physics library For videogames
; *
; *   DESCRIPTION:
; *
; *   Physac is a small 2D physics library written in pure C. The engine uses a fixed time-Step thread loop
; *   To simluate physics. A physics Step contains the following phases: get collision information,
; *   apply dynamics, collision solving And position correction. It uses a very simple struct For physic
; *   bodies With a position vector To be used in any 3D rendering API.
; *
; *   CONFIGURATION:
; *
; *   #define PHYSAC_IMPLEMENTATION
; *       Generates the implementation of the library into the included file.
; *       If Not defined, the library is in header only mode And can be included in other headers
; *       Or source files without problems. But only ONE file should hold the implementation.
; *
; *   #define PHYSAC_STATIC (defined by Default)
; *       The generated implementation will stay private inside implementation file And all
; *       internal symbols And functions will only be visible inside that file.
; *
; *   #define PHYSAC_NO_THREADS
; *       The generated implementation won't include pthread library and user must create a secondary thread to call PhysicsThread().
; *       It is so important that the thread where PhysicsThread() is called must Not have v-sync Or any other CPU limitation.
; *
; *   #define PHYSAC_STANDALONE
; *       Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
; *       internally in the library And input management And drawing functions must be provided by
; *       the user (check library implementation For further details).
; *
; *   #define PHYSAC_DEBUG
; *       Traces log messages when creating And destroying physics bodies And detects errors in physics
; *       calculations And reference exceptions; it is useful for debug purposes
; *
; *   #define PHYSAC_MALLOC()
; *   #define PHYSAC_FREE()
; *       You can Define your own malloc/free implementation replacing stdlib.h malloc()/free() functions.
; *       Otherwise it will include stdlib.h And use the C standard library malloc()/free() function.
; *
; *
; *   NOTE 1: Physac requires multi-threading, when InitPhysics() a second thread is created To manage physics calculations.
; *   NOTE 2: Physac requires Static C library linkage To avoid dependency on MinGW DLL (-Static -lpthread)
; *
; *   Use the following code To compile:
; *   gcc -o $(NAME_PART).exe $(FILE_NAME) -s -Static -lraylib -lpthread -lopengl32 -lgdi32 -lwinmm -std=c99
; *
; *   VERY THANKS To:
; *       - raysan5: helped With library design
; *       - ficoos: added support For Linux
; *       - R8D8: added support For Linux
; *       - jubalh: fixed implementation of time calculations
; *       - a3f: fixed implementation of time calculations
; *       - Define-private-public: added support For OSX
; *       - pamarcos: fixed implementation of physics steps
; *       - noshbar: fixed some memory leaks
; *
; *
; *   LICENSE: zlib/libpng
; *
; *   Copyright (c) 2016-2020 Victor Fisac (github: @victorfisac)
; *
; *   This software is provided "as-is", without any express Or implied warranty. In no event
; *   will the authors be held liable For any damages arising from the use of this software.
; *
; *   Permission is granted To anyone To use this software For any purpose, including commercial
; *   applications, And To alter it And redistribute it freely, subject To the following restrictions:
; *
; *     1. The origin of this software must Not be misrepresented; you must not claim that you
; *     wrote the original software. If you use this software in a product, an acknowledgment
; *     in the product documentation would be appreciated but is Not required.
; *
; *     2. Altered source versions must be plainly marked As such, And must Not be misrepresented
; *     As being the original software.
; *
; *     3. This notice may Not be removed Or altered from any source distribution.
; *
; **********************************************************************************************/

XIncludeFile "raymath.pbi"

;XIncludeFile "HighResTimer.pbi"

;UseModule HighResTimer

;>----------------------------------------------------------------------------------
;Defines And Macros
;----------------------------------------------------------------------------------
#PHYSAC_MAX_BODIES = 64
#PHYSAC_MAX_MANIFOLDS = 4096
#PHYSAC_MAX_VERTICES = 24
#PHYSAC_CIRCLE_VERTICES = 24

#PHYSAC_COLLISION_ITERATIONS = 100
#PHYSAC_PENETRATION_ALLOWANCE = 0.05
#PHYSAC_PENETRATION_CORRECTION = 0.4

#PHYSAC_PI = 3.1415926535897932385
#PHYSAC_DEG2RAD = (#PHYSAC_PI / 180.0)

Global.i startTime, currentTime

;>----------------------------------------------------------------------------------
; Types And Structures Definition
; NOTE: Below types are required For PHYSAC_STANDALONE usage
;-----------------------------------------------------------------------------------
; #if Defined(PHYSAC_STANDALONE)
;     // Vector2 type
;     typedef struct Vector2 {
;         float x;
;         float y;
;     } Vector2;
; 
;     // Boolean type
;     #if !Defined(_STDBOOL_H)
;         typedef enum { false, true } bool;
;         #define _STDBOOL_H
;     #endif
; #endif

Enumeration PhysicsShapeType 
  #PHYSICS_CIRCLE 
  #PHYSICS_POLYGON 
EndEnumeration

; Mat2 type (used For polygon shape rotation matrix)
Structure Matr2 Align #PB_Structure_AlignC
  m00.rl_float
  m01.rl_float
  m10.rl_float
  m11.rl_float
EndStructure

Structure PolygonData Align #PB_Structure_AlignC
  vertexCount.rl_uint                           ; Current used vertex And normals count
  positions.Vector2[#PHYSAC_MAX_VERTICES] ; Polygon vertex positions vectors
  normals.Vector2[#PHYSAC_MAX_VERTICES]   ; Polygon vertex normals vectors
EndStructure

Structure PhysicsBody2 Align #PB_Structure_AlignC
  id.rl_uint                                    ; Reference unique identifier
  enabled.rl_bool                               ; Enabled dynamics state (collisions are calculated anyway)
  position.Vector2                              ; Physics body shape pivot
  velocity.Vector2                              ; Current linear velocity applied To position
  force.Vector2                                 ; Current linear force (reset To 0 every Step)
  angularVelocity.rl_float                      ; Current angular velocity applied To orient
  torque.rl_float                               ; Current angular force (reset To 0 every Step)
  orient.rl_float                               ; Rotation in radians
  inertia.rl_float                              ; Moment of inertia
  inverseInertia.rl_float                       ; Inverse value of inertia
  mass.rl_float                                 ; Physics body mass
  inverseMass.rl_float                          ; Inverse value of mass
  staticFriction.rl_float                       ; Friction when the body has Not movement (0 To 1)
  dynamicFriction.rl_float                      ; Friction when the body has movement (0 To 1)
  restitution.rl_float                          ; Restitution coefficient of the body (0 To 1)
  useGravity.rl_bool                            ; Apply gravity force To dynamics
  isGrounded.rl_bool                            ; Physics grounded on other body state
  freezeOrient.rl_bool                          ; Physics rotation constraint
  ;shape.PhysicsShape                           ; Physics body shape information (type, radius, vertices, normals)
EndStructure

Structure PhysicsShape Align #PB_Structure_AlignC
  type.rl_int                                   ; Physics shape type (circle Or polygon)
  body.PhysicsBody2                             ; Shape physics body reference
  radius.rl_float                               ; Circle shape radius (used For circle shapes)
  transform.Matr2                               ; Vertices transform matrix 2x2
  vertexData.PolygonData                        ; Polygon shape vertices position and normals data (just used for polygon shapes)
EndStructure

Structure PhysicsBodyData Align #PB_Structure_AlignC
  id.rl_uint                                    ; Reference unique identifier
  enabled.rl_bool                               ; Enabled dynamics state (collisions are calculated anyway)
  position.Vector2                              ; Physics body shape pivot
  velocity.Vector2                              ; Current linear velocity applied To position
  force.Vector2                                 ; Current linear force (reset To 0 every Step)
  angularVelocity.rl_float                      ; Current angular velocity applied To orient
  torque.rl_float                               ; Current angular force (reset To 0 every Step)
  orient.rl_float                               ; Rotation in radians
  inertia.rl_float                              ; Moment of inertia
  inverseInertia.rl_float                       ; Inverse value of inertia
  mass.rl_float                                 ; Physics body mass
  inverseMass.rl_float                          ; Inverse value of mass
  staticFriction.rl_float                       ; Friction when the body has Not movement (0 To 1)
  dynamicFriction.rl_float                      ; Friction when the body has movement (0 To 1)
  restitution.rl_float                          ; Restitution coefficient of the body (0 To 1)
  useGravity.rl_bool                            ; Apply gravity force To dynamics
  isGrounded.rl_bool                            ; Physics grounded on other body state
  freezeOrient.rl_bool                          ; Physics rotation constraint
  shape.PhysicsShape                            ; Physics body shape information (type, radius, vertices, normals)
EndStructure

;typedef struct PhysicsBodyData *PhysicsBody;
Structure PhysicsBody Extends PhysicsBodyData Align #PB_Structure_AlignC
EndStructure

Structure PhysicsManifoldData Align #PB_Structure_AlignC
  id.rl_uint                                    ; Reference unique identifier
  bodyA.PhysicsBody                             ; Manifold first physics body reference
  bodyB.PhysicsBody                             ; Manifold second physics body reference
  penetration.rl_float                          ; Depth of penetration from collision
  normal.Vector2                                ; Normal direction vector from 'a' To 'b'
  contacts.Vector2[2]                           ; Points of contact during collision
  contactsCount.rl_uint                         ; Current collision number of contacts
  restitution.rl_float                          ; Mixed restitution during collision
  dynamicFriction.rl_float                      ; Mixed dynamic friction during collision
  staticFriction.rl_float                       ; Mixed static friction during collision
EndStructure ;*PhysicsManifold

Structure PhysicsManifold Extends PhysicsManifoldData Align #PB_Structure_AlignC
EndStructure

;>----------------------------------------------------------------------------------
; Module Functions Declaration
;-----------------------------------------------------------------------------------
Declare InitPhysics()                                                                                                     ; Initializes physics values, pointers And creates physics loop thread
Declare RunPhysicsStep()                                                                                                  ; Run physics Step, To be used If PHYSICS_NO_THREADS is set in your main loop
Declare SetPhysicsTimeStep(delta.rl_double)                                                                               ; Sets physics fixed time Step in milliseconds. 1.666666 by Default
Declare.rl_bool IsPhysicsEnabled()                                                                                        ; Returns true If physics thread is currently enabled
Declare SetPhysicsGravity(x.rl_float, y.rl_float)                                                                         ; Sets physics Global gravity force
Declare CreatePhysicsBodyCircle(*result.PhysicsBody, *pos.Vector2, radius.rl_float, density.rl_float)                     ; Creates a new circle physics body with generic parameters
Declare CreatePhysicsBodyRectangle(*result.PhysicsBody, *pos.Vector2, width.rl_float, height.rl_float, density.rl_float)  ; Creates a new rectangle physics body with generic parameters
Declare CreatePhysicsBodyPolygon(*result.PhysicsBody, *pos.Vector2, radius.rl_float, sides.rl_int, density.rl_float)      ; Creates a new polygon physics body With generic parameters
Declare PhysicsAddForce(*body.PhysicsBody, *force.Vector2)                                                                ; Adds a force to a physics body
Declare PhysicsAddTorque(*body.PhysicsBody, amount.rl_float)                                                              ; Adds an angular force To a physics body
Declare PhysicsShatter(*body.PhysicsBody, *position.Vector2, force.rl_float)                                              ; Shatters a polygon shape physics body To little physics bodies With explosion force
Declare.rl_int GetPhysicsBodiesCount()                                                                                    ; Returns the current amount of created physics bodies
Declare GetPhysicsBody(*result.PhysicsBody, index.rl_int)                                                                 ; Returns a physics body of the bodies pool at a specific index
Declare.rl_int GetPhysicsShapeType(index.rl_int)                                                                          ; Returns the physics body shape type (PHYSICS_CIRCLE Or PHYSICS_POLYGON)
Declare.rl_int GetPhysicsShapeVerticesCount(index.rl_int)                                                                 ; Returns the amount of vertices of a physics body shape
Declare GetPhysicsShapeVertex(*result.Vector2, *body.PhysicsBody, vertex.rl_int)                                          ; Returns transformed position of a body shape (body position + vertex transformed position)
Declare SetPhysicsBodyRotation(*body.PhysicsBody, radians.rl_float)                                                       ; Sets physics body shape transform based on radians parameter
Declare DestroyPhysicsBody(*body.PhysicsBody)                                                                             ; Unitializes And destroy a physics body
Declare ClosePhysics()                                                                                                    ; Unitializes physics pointers And closes physics loop thread


; /***********************************************************************************
; *
; *   PHYSAC IMPLEMENTATION
; *
; ************************************************************************************/

; #if Defined(PHYSAC_IMPLEMENTATION)
; 
; #if !Defined(PHYSAC_NO_THREADS)
;     #include <pthread.h>            // Required For: pthread_t, pthread_create()
; #endif
; 
; #if Defined(PHYSAC_DEBUG)
;     #include <stdio.h>              // Required For: printf()
; #endif
; 
; #include <stdlib.h>                 // Required For: malloc(), free(), srand(), rand()
; #include <math.h>                   // Required For: cosf(), sinf(), fabs(), sqrtf()
; #include <stdint.h>                 // Required For: uint64_t
; 
; #if !Defined(PHYSAC_STANDALONE)
;     #include "raymath.h"            // Required For: Vector2Add(), Vector2Subtract()
; #endif
; 
; // Time management functionality
; #include <time.h>                   // Required For: time(), clock_gettime()
; #if Defined(_WIN32)
;     // Functions required To query time on Windows
;     #if Defined(__cplusplus)
;     extern "C" {                                    // Prevents name mangling of functions
;     #endif
;     int __stdcall QueryPerformanceCounter(unsigned long long int* lpPerformanceCount);
;     int __stdcall QueryPerformanceFrequency(unsigned long long int* lpFrequency);
;     #if Defined(__cplusplus)
;     }
;     #endif
; #elif Defined(__linux__)
;     #if _POSIX_C_SOURCE < 199309L
;         #undef _POSIX_C_SOURCE
;         #define _POSIX_C_SOURCE 199309L // Required For CLOCK_MONOTONIC If compiled With c99 without gnu ext.
;     #endif
;     #include <sys/time.h>           // Required For: timespec
; #elif Defined(__APPLE__)            // macOS also defines __MACH__
;     #include <mach/mach_time.h>     // Required For: mach_absolute_time()
; #endif

;>----------------------------------------------------------------------------------
; Defines And Macros
;-----------------------------------------------------------------------------------
;#define     min(a,b)                    (((a)<(b))?(a):(b))
;#define     max(a,b)                    (((a)>(b))?(a):(b))

#PHYSAC_FLT_MAX = 1621428954312505753.6 ; 3.402823466e+38f
#PHYSAC_EPSILON = 0.000001
#PHYSAC_K = 1.0 / 3.0
#PHYSAC_VECTOR_ZERO = 0.0

;>----------------------------------------------------------------------------------
; Global Variables Definition
;-----------------------------------------------------------------------------------

;#if !Defined(PHYSAC_NO_THREADS)
;Static pthread_t physicsThreadId;                           // Physics thread id
;#endif
Global.i physicsThreadId

Global.rl_uint usedMemory = 0                               ; Total allocated dynamic memory
Global.rl_bool physicsThreadEnabled = #False                ; Physics thread enabled state
Global.rl_double baseTime = 0.0                             ; Offset time for MONOTONIC clock
Global.rl_double startTime = 0.0                            ; Start time in milliseconds
Global.rl_double deltaTime = 1.0 / 60.0 / 10.0 * 1000       ; Delta time used for physics steps, in milliseconds
Global.rl_double currentTime = 0.0                          ; Current time in milliseconds
Global.rl_quad frequency = 0                                ; Hi-res clock frequency

Global.rl_double accumulator = 0.0                          ; Physics time step delta time accumulator
Global.rl_uint stepsCount = 0                               ; Total physics steps processed

Global.Vector2 gravityForce                                 ; Physics world gravity force
InitVector2(@gravityForce, 0.0, 9.81)

Global Dim bodies.PhysicsBody(#PHYSAC_MAX_BODIES-1)           ; Physics bodies pointers Array
Global.rl_uint physicsBodiesCount = 0                       ; Physics world current bodies counter
Global Dim g_contacts.PhysicsManifold(#PHYSAC_MAX_MANIFOLDS-1)  ; Physics bodies pointers array
Global.rl_uint physicsManifoldsCount = 0                    ; Physics world current manifolds counter

;>----------------------------------------------------------------------------------
; Module Internal Functions Declaration
;-----------------------------------------------------------------------------------
Declare.rl_int FindAvailableBodyIndex()                                                                     ; Finds a valid index For a new physics body initialization
Declare CreateRandomPolygon(*result.PolygonData, radius.rl_float, sides.rl_int)                             ; Creates a random polygon shape with max vertex distance from polygon pivot
Declare CreateRectanglePolygon(*result.PolygonData, *pos.Vector2, *size.Vector2)                            ; Creates a rectangle polygon shape based on a min And max positions
Declare.i PhysicsLoop(*arg)                                                                                 ; Physics loop thread function
Declare PhysicsStep()                                                                                       ; Physics steps calculations (dynamics, collisions And position corrections)
Declare.rl_int FindAvailableManifoldIndex()                                                                 ; Finds a valid index For a new manifold initialization
Declare CreatePhysicsManifold(*result.PhysicsManifold, *a.PhysicsBody, *b.PhysicsBody)                      ; Creates a new physics manifold To solve collision
Declare DestroyPhysicsManifold(*manifold.PhysicsManifold)                                                   ; Unitializes And destroys a physics manifold
Declare SolvePhysicsManifold(*manifold.PhysicsManifold)                                                     ; Solves a created physics manifold between two physics bodies
Declare SolveCircleToCircle(*manifold.PhysicsManifold)                                                      ; Solves collision between two circle shape physics bodies
Declare SolveCircleToPolygon(*manifold.PhysicsManifold)                                                     ; Solves collision between a circle To a polygon shape physics bodies
Declare SolvePolygonToCircle(*manifold.PhysicsManifold)                                                     ; Solves collision between a polygon To a circle shape physics bodies
Declare SolveDifferentShapes(*manifold.PhysicsManifold, *bodyA.PhysicsBody, *bodyB.PhysicsBody)             ; Solve collision between two different types of shapes
Declare SolvePolygonToPolygon(*manifold.PhysicsManifold)                                                    ; Solves collision between two polygons shape physics bodies
Declare IntegratePhysicsForces(*body.PhysicsBody)                                                           ; Integrates physics forces into velocity
Declare InitializePhysicsManifolds(*manifold.PhysicsManifold)                                               ; Initializes physics manifolds To solve collisions
Declare IntegratePhysicsImpulses(*manifold.PhysicsManifold)                                                 ; Integrates physics collisions impulses To solve collisions
Declare IntegratePhysicsVelocity(*body.PhysicsBody)                                                         ; Integrates physics velocity into position And forces
Declare CorrectPhysicsPositions(*manifold.PhysicsManifold)                                                  ; Corrects physics bodies positions based on manifolds collision information
Declare.rl_float FindAxisLeastPenetration(*faceIndex.long, *shapeA.PhysicsShape, *shapeB.PhysicsShape)      ; Finds polygon shapes axis least penetration
Declare FindIncidentFace(*v0.Vector2, *v1.Vector2, *ref.PhysicsShape, *inc.PhysicsShape, index.rl_int)      ; Finds two polygon shapes incident face
Declare.rl_int Clip(*normal.Vector2, clip.rl_float, *faceA.Vector2, *faceB.Vector2)                         ; Calculates clipping based on a normal And two faces
Declare.rl_bool BiasGreaterThan(valueA.rl_float, valueB.rl_float)                                           ; Check If values are between bias range
Declare TriangleBarycenter(*result.Vector2, *v1.Vector2, *v2.Vector2, *v3.Vector2)                          ; Returns the barycenter of a triangle given by 3 points

Declare Init_QTimer()                                                                                       ; Initializes hi-resolution MONOTONIC timer
Declare.rl_double GetTimeCount()                                                                              ; Get hi-res MONOTONIC time measure in mseconds
Declare.rl_double GetCurrentTime()                                                                          ; Get current time measure in milliseconds

; Math functions
Declare MathCross(*result.Vector2, value.rl_float, *vector.Vector2)                                         ; Returns the cross product of a vector And a value
Declare.rl_float MathCrossVector2(*v1.Vector2, *v2.Vector2)                                                 ; Returns the cross product of two vectors
Declare.rl_float MathLenSqr(*vector.Vector2)                                                                ; Returns the len square root of a vector
Declare.rl_float MathDot(*v1.Vector2, *v2.Vector2)                                                          ; Returns the dot product of two vectors
Declare.rl_float DistSqr(*v1.Vector2, *v2.Vector2)                                                          ; Returns the square root of distance between two vectors
Declare MathNormalize(*vector.Vector2)                                                                      ; Returns the normalized values of a vector

; #if Defined(PHYSAC_STANDALONE)
; Static Vector2 Vector2Add(Vector2 v1, Vector2 v2);                                                          // Returns the sum of two given vectors
; Static Vector2 Vector2Subtract(Vector2 v1, Vector2 v2);                                                     // Returns the subtract of two given vectors
; #endif

Declare Mat2Radians(*result.Matr2, radians.rl_float)                                                         ; Creates a matrix 2x2 from a given radians value
Declare Mat2Set(*matrix.Matr2, radians.rl_float)                                                             ; Set values from radians To a created matrix 2x2
Declare Mat2Transpose(*result.Matr2, *matrix.Matr2)                                                           ; Returns the transpose of a given matrix 2x2
Declare Mat2MultiplyVector2(*result.Vector2, *matrix.Matr2, *vector.Vector2)                                 ; Multiplies a vector by a matrix 2x2


CompilerSelect #PB_Compiler_OS
    
  CompilerCase #PB_OS_Linux
    
    #CLOCK_MONOTONIC = 1
    
    Structure TimeSpec
      Second.i
      NanoSecond.l
    EndStructure
    
    ImportC "-lrt"
      clock_gettime(ClockID.l, *TimeSpecA.TimeSpec)
    EndImport
    
  CompilerCase #PB_OS_MacOS
    
    Structure TimeBase
      Numerator.l
      Denominator.l
    EndStructure
    
    ImportC ""
      mach_absolute_time.q()
      mach_timebase_info(*TimeBaseA.TimeBase)
    EndImport
    
CompilerEndSelect

;>----------------------------------------------------------------------------------
; Module Functions Definition
;-----------------------------------------------------------------------------------

; Initializes physics values, pointers And creates physics loop thread
Procedure InitPhysics()
;     #if !Defined(PHYSAC_NO_THREADS)
;         // NOTE: If defined, user will need To create a thread For PhysicsThread function manually
;         // Create physics thread using POSIXS thread libraries
;         pthread_create(&physicsThreadId, NULL, &PhysicsLoop, NULL);
;     #endif
  physicsThreadId = CreateThread(@PhysicsLoop(), 0)
  
  ; Initialize high resolution timer
  Init_QTimer()

;     #if Defined(PHYSAC_DEBUG)
;         printf("[PHYSAC] physics module initialized successfully\n");
;     #endif

  accumulator = 0.0
EndProcedure

; Returns true If physics thread is currently enabled
Procedure.rl_bool IsPhysicsEnabled()
  ProcedureReturn physicsThreadEnabled
EndProcedure

; Sets physics Global gravity force
Procedure SetPhysicsGravity(x.rl_float, y.rl_float)
  gravityForce\x = x
  gravityForce\y = y
EndProcedure

; Creates a new circle physics body With generic parameters
Procedure CreatePhysicsBodyCircle(*result.PhysicsBody, *pos.Vector2, radius.rl_float, density.rl_float)
  Protected.rl_int newId = FindAvailableBodyIndex()

  If newId <> -1
    ; Initialize new body With generic values
    With *result
      \id = newId
      \enabled = #True
      \position\x = *pos\x
      \position\y = *pos\y
      \velocity\x = #PHYSAC_VECTOR_ZERO
      \velocity\y = #PHYSAC_VECTOR_ZERO
      \force\x = #PHYSAC_VECTOR_ZERO
      \force\y = #PHYSAC_VECTOR_ZERO
      \angularVelocity = 0.0
      \torque = 0.0
      \orient = 0.0
      \shape\type = #PHYSICS_CIRCLE
      CopyStructure(*result, \shape\body, PhysicsBody)
      ;\shape\body = *result
      \shape\radius = radius
      
      Mat2Radians(@\shape\transform, 0.0)
      
      ClearStructure(@\shape\vertexData, PhysicsShape)

      \mass = #PHYSAC_PI * radius * radius * density
      
      If \mass <> 0.0
        \inverseMass = 1.0 / \mass
      Else
        \inverseMass = 0.0
      EndIf
      
      \inertia = \mass * radius * radius
      
      If \inertia <> 0.0
        \inverseInertia = 1.0 / \inertia
      Else
        \inverseInertia = 0.0
      EndIf
      
      \staticFriction = 0.4
      \dynamicFriction = 0.2
      \restitution = 0.0
      \useGravity = #True
      \isGrounded = #False
      \freezeOrient = #False

      ; Add new body To bodies pointers Array And update bodies count
      CopyStructure(*result, @bodies(physicsBodiesCount), PhysicsBody)
      ;bodies(physicsBodiesCount) = *result
      
      physicsBodiesCount + 1
    EndWith
  EndIf
  
;   #if Defined(PHYSAC_DEBUG)
;     printf("[PHYSAC] created polygon physics body id %i\n", newBody->id);
;   #endif
;   
;   ;else
;   #if Defined(PHYSAC_DEBUG)
;     printf("[PHYSAC] new physics body creation failed because there is any available id to use\n");
;   #endif

EndProcedure

; Creates a new rectangle physics body With generic parameters
Procedure CreatePhysicsBodyRectangle(*result.PhysicsBody, *pos.Vector2, width.rl_float, height.rl_float, density.rl_float)
  Protected.rl_int newId = FindAvailableBodyIndex()
  Protected.Vector2 size, center, p1, p2
  Protected.rl_float area = 0.0, inertia = 0.0, D, triangleArea, intx2, inty2
  Protected.rl_int i, nextIndex
  
  If newId <> -1
    ; Initialize new body With generic values
    With *result
      \id = newId
      \enabled = #True
      \position\x = *pos\x
      \position\y = *pos\y
      \velocity\x = #PHYSAC_VECTOR_ZERO
      \velocity\y = #PHYSAC_VECTOR_ZERO
      \force\x = #PHYSAC_VECTOR_ZERO
      \force\y = #PHYSAC_VECTOR_ZERO
      \angularVelocity = 0.0
      \torque = 0.0
      \orient = 0.0
      \shape\type = #PHYSICS_POLYGON
      CopyStructure(*result, @\shape\body, PhysicsBody)
      ;\shape\body = *result
      \shape\radius = 0.0
      
      Mat2Radians(@\shape\transform, 0.0)
      
      InitVector2(@size, width, height)
      CreateRectanglePolygon(@\shape\vertexData, *pos, @size)

      ; Calculate centroid And moment of inertia
      InitVector2(@center, 0.0, 0.0)
      
      area = 0.0
      inertia = 0.0

      For i = 0 To \shape\vertexData\vertexCount - 1
        ; Triangle vertices, third vertex implied As (0, 0)
        p1\x = \shape\vertexData\positions[i]\x
        p2\y = \shape\vertexData\positions[i]\y
        
        If (i + 1) < \shape\vertexData\vertexCount
          nextIndex = (i + 1)
        Else
          nextIndex = 0
        EndIf
          
        p2\x = \shape\vertexData\positions[nextIndex]\x
        p2\y = \shape\vertexData\positions[nextIndex]\y
        
        D = MathCrossVector2(@p1, @p2)
        
        triangleArea = D / 2

        area + triangleArea

        ; Use area To weight the centroid average, Not just vertex position
        center\x + triangleArea * #PHYSAC_K * (p1\x + p2\x)
        center\y + triangleArea * #PHYSAC_K * (p1\y + p2\y)

        intx2 = p1\x * p1\x + p2\x * p1\x + p2\x * p2\x
        inty2 = p1\y * p1\y + p2\y * p1\y + p2\y * p2\y
        inertia + (0.25 * #PHYSAC_K * D) * (intx2 + inty2)
      Next

      center\x * 1.0 / area
      center\y * 1.0 / area

      ; Translate vertices To centroid (make the centroid (0, 0) For the polygon in model space)
      ; Note: this is Not really necessary
      For i = 0 To \shape\vertexData\vertexCount - 1
        \shape\vertexData\positions[i]\x - center\x
        \shape\vertexData\positions[i]\y - center\y
      Next

      \mass = density * area
      
      If \mass <> 0.0
        \inverseMass = 1.0 / \mass
      Else
        \inverseMass = 0.0
      EndIf
      
      \inertia = density * inertia
      
      If \inertia <> 0.0
        \inverseInertia = 1.0 / \inertia 
      Else
        \inverseInertia = 0.0
      EndIf
      
      \staticFriction = 0.4
      \dynamicFriction = 0.2
      \restitution = 0.0
      \useGravity = #True
      \isGrounded = #False
      \freezeOrient = #False

      ; Add new body To bodies pointers Array And update bodies count
      CopyStructure(*result, @bodies(physicsBodiesCount), PhysicsBody)
;       bodies(physicsBodiesCount)\angularVelocity = *result\angularVelocity
;       bodies(physicsBodiesCount)\dynamicFriction = *result\dynamicFriction
;       bodies(physicsBodiesCount)\enabled = *result\enabled
;       bodies(physicsBodiesCount)\force = *result\force
;       bodies(physicsBodiesCount)\freezeOrient = *result\freezeOrient
;       bodies(physicsBodiesCount)\id = *result\id
;       bodies(physicsBodiesCount)\inertia = *result\inertia
;       bodies(physicsBodiesCount)\inverseInertia = *result\inverseInertia
;       bodies(physicsBodiesCount)\inverseMass = *result\inverseMass
;       bodies(physicsBodiesCount)\isGrounded = *result\isGrounded
;       bodies(physicsBodiesCount)\mass = *result\mass
;       bodies(physicsBodiesCount)\orient = *result\orient
;       bodies(physicsBodiesCount)\position = *result\position
;       bodies(physicsBodiesCount)\restitution = *result\restitution
;       bodies(physicsBodiesCount)\shape = *result\shape
;       bodies(physicsBodiesCount)\staticFriction = *result\staticFriction
;       bodies(physicsBodiesCount)\torque = *result\torque
;       bodies(physicsBodiesCount)\useGravity = *result\useGravity
;       bodies(physicsBodiesCount)\velocity = *result\velocity
      
      physicsBodiesCount + 1
    EndWith
  EndIf
  
;   #if Defined(PHYSAC_DEBUG)
;     printf("[PHYSAC] created polygon physics body id %i\n", newBody->id);
;   #endif
;   
;   ;else
;   
;   #if Defined(PHYSAC_DEBUG)
;     printf("[PHYSAC] new physics body creation failed because there is any available id to use\n");
;   #endif

EndProcedure

; Creates a new polygon physics body With generic parameters
Procedure CreatePhysicsBodyPolygon(*result.PhysicsBody, *pos.Vector2, radius.rl_float, sides.rl_int, density.rl_float)
  Protected.rl_int newId = FindAvailableBodyIndex()
  Protected.Vector2 center, position1, position2
  Protected.rl_float area, inertia, cross, triangleArea, intx2, inty2, inverseMass
  Protected.rl_int i, nextIndex
  
  If newId <> -1
    ; Initialize new body With generic values
    ;Debug "Hier!!!!"
    
    With *result
      \id = newId
      \enabled = #True
      \position\x = *pos\x
      \position\y = *pos\y
      \velocity\x = #PHYSAC_VECTOR_ZERO
      \velocity\y = #PHYSAC_VECTOR_ZERO
      \force\x = #PHYSAC_VECTOR_ZERO
      \force\y = #PHYSAC_VECTOR_ZERO
      \angularVelocity = 0.0
      \torque = 0.0
      \orient = 0.0
      \shape\type = #PHYSICS_POLYGON
      CopyStructure(*result, @\shape\body, PhysicsBody)
      
      Mat2Radians(@\shape\transform, 0.0)
      
      CreateRandomPolygon(@\shape\vertexData, radius, sides)

      ; Calculate centroid And moment of inertia
      InitVector2(@center, 0.0, 0.0)
      
      area = 0.0
      inertia = 0.0

      For i = 0 To \shape\vertexData\vertexCount - 1
        ; Triangle vertices, third vertex implied As (0, 0)
        position1 = \shape\vertexData\positions[i]
        
        If (i + 1) < \shape\vertexData\vertexCount
          nextIndex = (i + 1)
        Else
          nextIndex = 0
        EndIf
        
        position2 = \shape\vertexData\positions[nextIndex]

        cross = MathCrossVector2(@position1, @position2)
        
        triangleArea = cross / 2

        area + triangleArea

        ; Use area To weight the centroid average, Not just vertex position
        center\x + triangleArea * #PHYSAC_K * (position1\x + position2\x)
        center\y + triangleArea * #PHYSAC_K * (position1\y + position2\y)

        intx2 = position1\x * position1\x + position2\x * position1\x + position2\x * position2\x
        inty2 = position1\y * position1\y + position2\y * position1\y + position2\y * position2\y
        inertia + (0.25 * #PHYSAC_K * cross) * (intx2 + inty2)
      Next

      center\x * 1.0 / area
      center\y * 1.0 / area

      ; Translate vertices To centroid (make the centroid (0, 0) For the polygon in model space)
      ; Note: this is Not really necessary
      For i = 0 To \shape\vertexData\vertexCount - 1
        \shape\vertexData\positions[i]\x - center\x
        \shape\vertexData\positions[i]\y - center\y
      Next

      \mass = density * area
      
      If \mass <> 0.0
        inverseMass = 1.0 / \mass
      Else
        inverseMass = 0.0
      EndIf
      
      \inertia = density * inertia
      
      If \inertia <> 0.0
        \inverseInertia = 1.0 / \inertia
      Else
        \inverseInertia = 0.0
      EndIf
      
      \staticFriction = 0.4
      \dynamicFriction = 0.2
      \restitution = 0.0
      \useGravity = #True
      \isGrounded = #False
      \freezeOrient = #False

      ; Add new body To bodies pointers Array And update bodies count
      CopyStructure(*result, @bodies(physicsBodiesCount), PhysicsBody)
      
      physicsBodiesCount + 1

      ;#if Defined(PHYSAC_DEBUG)
      ;  printf("[PHYSAC] created polygon physics body id %i\n", newBody->id);
      ;#endif
    EndWith
  EndIf
  
  ;else
;   #if Defined(PHYSAC_DEBUG)
;     printf("[PHYSAC] new physics body creation failed because there is any available id to use\n");
;   #endif
EndProcedure

; Adds a force To a physics body
Procedure PhysicsAddForce(*body.PhysicsBody, *force.Vector2)
  If *body <> #Null
    Vector2Add(*body\force, *body\force, *force)
  EndIf
EndProcedure

; Adds an angular force To a physics body
Procedure PhysicsAddTorque(*body.PhysicsBody, amount.rl_float)
  If *body <> #Null
    *body\torque + amount
  EndIf
EndProcedure

; Shatters a polygon shape physics body To little physics bodies With explosion force
Procedure PhysicsShatter(*body.PhysicsBody, *position.Vector2, force.rl_float)
  Protected.PolygonData vertexData, newData
  Protected.rl_int i, j, nextIndex, count, nextVertex
  Protected.Vector2 positionA, positionB, positionC, center, offset, face, bodyPos, vout
  Protected.Vector2 p1, p2, pointA, pointB, forceDirection
  Protected.rl_float alpha, beta, gamma, triangleArea, D, intx2, inty2, area, inertia
  Protected.rl_bool collision = #False
  Protected.Matr2 trans
  Protected.PhysicsBody newBody
  
  If *body <> #Null
    If *body\shape\type = #PHYSICS_POLYGON
      vertexData = *body\shape\vertexData
      collision = #False

      For i = 0 To vertexData\vertexCount - 1
        positionA = *body\position
        
        Vector2Add(@vout, *body\position, vertexData\positions[i])
        Mat2MultiplyVector2(@vout, *body\shape\transform, @vout)
        
        positionB = vout
        
        If (i + 1) < vertexData\vertexCount
          nextIndex = (i + 1)
        Else
          nextIndex = 0
        EndIf
        
        Vector2Add(@vout, *body\position, vertexData\positions[nextIndex])
        Mat2MultiplyVector2(@vout, *body\shape\transform, @vout)
        
        positionC = vout

        ; Check collision between each triangle
        alpha = ((positionB\y - positionC\y) * (*position\x - positionC\x) + (positionC\x - positionB\x) * (*position\y - positionC\y)) / ((positionB\y - positionC\y) * (positionA\x - positionC\x) + (positionC\x - positionB\x) * (positionA\y - positionC\y))

        beta = ((positionC\y - positionA\y) * (*position\x - positionC\x) + (positionA\x - positionC\x) * (*position\y - positionC\y)) / ((positionB\y - positionC\y) * (positionA\x - positionC\x) + (positionC\x - positionB\x) * (positionA\y - positionC\y))

        gamma = 1.0 - alpha - beta

        If ((alpha > 0.0) And (beta > 0.0) And (gamma > 0.0))
          collision = #True
          Break
        EndIf
      Next

      If collision = #True
        count = vertexData\vertexCount
        
        bodyPos = *body\position
        
        Dim vertices.Vector2(count)
        
        trans = *body\shape\transform
        
        For i = 0 To count - 1
          
          vertices(i) = vertexData\positions[i]

          ; Destroy shattered physics body
          DestroyPhysicsBody(*body)

          For i = 0 To count - 1
            
            If (i + 1) < count
              nextIndex = (i + 1)
            Else
              nextIndex = 0
            EndIf
            
            TriangleBarycenter(@center, vertices(i), vertices(nextIndex), #PHYSAC_VECTOR_ZERO)
            
            Vector2Add(@center, @bodyPos, @center)
            
            Vector2Subtract(@offset, @center, @bodyPos)

            CreatePhysicsBodyPolygon(@newBody, @center, 10, 3, 10)  ; Create polygon physics body with relevant values

            ClearStructure(@newData, PolygonData) ;newData = 0
            newData\vertexCount = 3
            
            Vector2Subtract(@newData\positions[0], @vertices(i), offset)
            Vector2Subtract(@newData\positions[1], @vertices(nextIndex), offset)
            Vector2Subtract(@newData\positions[2], *position, @center)

            ; Separate vertices To avoid unnecessary physics collisions
            newData\positions[0]\x * 0.95
            newData\positions[0]\y * 0.95
            newData\positions[1]\x * 0.95
            newData\positions[1]\y * 0.95
            newData\positions[2]\x * 0.95
            newData\positions[2]\y * 0.95

            ; Calculate polygon faces normals
            For j = 0 To newData\vertexCount - 1
              
              If (j + 1) < newData\vertexCount
                nextVertex = (j + 1)
              Else
                nextVertex = 0
              EndIf
              
              Vector2Subtract(@face, @newData\positions[nextVertex], @newData\positions[j])

              newData\normals[j]\x = face\y 
              newData\normals[j]\y = -face\x
              
              MathNormalize(@newData\normals[j])
            Next

            ; Apply computed vertex Data To new physics body shape
            newBody\shape\vertexData = newData
            newBody\shape\transform = trans

            ; Calculate centroid And moment of inertia
            center\x = #PHYSAC_VECTOR_ZERO
            center\y = #PHYSAC_VECTOR_ZERO
            area = 0.0
            inertia = 0.0

            For j = 0 To newBody\shape\vertexData\vertexCount - 1
              ; Triangle vertices, third vertex implied As (0, 0)
              p1 = newBody\shape\vertexData\positions[j]
              
              If (j + 1) < newBody\shape\vertexData\vertexCount
                nextVertex = (j + 1)
              Else
                nextVertex = 0
              EndIf
              
              p2 = newBody\shape\vertexData\positions[nextVertex]

              D = MathCrossVector2(@p1, @p2)
              triangleArea = D / 2

              area + triangleArea

              ; Use area To weight the centroid average, Not just vertex position
              center\x + triangleArea * #PHYSAC_K * (p1\x + p2\x)
              center\y + triangleArea * #PHYSAC_K * (p1\y + p2\y)

              intx2 = p1\x * p1\x + p2\x * p1\x + p2\x * p2\x
              inty2 = p1\y * p1\y + p2\y * p1\y + p2\y * p2\y
              inertia + (0.25 * #PHYSAC_K * D) * (intx2 + inty2)
            Next

            center\x * 1.0 / area
            center\y * 1.0 / area

            newBody\mass = area
            
            If newBody\mass <> 0.0
              newBody\inverseMass = 1.0 / newBody\mass
            Else
              newBody\inverseMass = 0.0
            EndIf 
            
            newBody\inertia = inertia
            
            If newBody\inertia <> 0.0
              newBody\inverseInertia = 1.0 / newBody\inertia
            Else
              newBody\inverseInertia = 0.0
            EndIf

            ; Calculate explosion force direction
            pointA = newBody\position
            
            Vector2Subtract(@pointB, @newData\positions[1], @newData\positions[0])
            
            pointB\x / 2.0
            pointB\y / 2.0
            
            Define.Vector2 v1, v2
            
            Vector2Add(@v1, @newData\positions[0], @pointB)
            
            Vector2Add(@v2, @pointA, @v1)
            
            Vector2Subtract(@forceDirection, @v2, @newBody\position)
            
            MathNormalize(@forceDirection)
            
            forceDirection\x * force
            forceDirection\y * force

            ; Apply force To new physics body
            PhysicsAddForce(@newBody, @forceDirection);
          Next
        Next
      EndIf
    EndIf
  EndIf
;   #if Defined(PHYSAC_DEBUG)
;     ; else
;     printf("[PHYSAC] error when trying to shatter a null reference physics body");
;   #endif
EndProcedure

; Returns the current amount of created physics bodies
Procedure.rl_int GetPhysicsBodiesCount()
  ProcedureReturn physicsBodiesCount
EndProcedure

; Returns a physics body of the bodies pool at a specific index
Procedure GetPhysicsBody(*result.PhysicsBody, index.rl_int)
  If index < physicsBodiesCount
    If bodies(index) = #Null
      ;#if Defined(PHYSAC_DEBUG)
      ;  printf("[PHYSAC] error when trying to get a null reference physics body");
      ;#endif
    EndIf
  Else
    ;#if Defined(PHYSAC_DEBUG)
    ;  ;else
    ;  printf("[PHYSAC] physics body index is out of bounds");
    ;#endif
  EndIf
  ;*result = bodies(index)
  CopyStructure(bodies(index), *result, PhysicsBody)
EndProcedure

; Returns the physics body shape type (PHYSICS_CIRCLE Or PHYSICS_POLYGON)
Procedure.rl_int GetPhysicsShapeType(index.rl_int)
  Protected.rl_int result = -1

  If index < physicsBodiesCount
    If bodies(index) <> #Null 
      result = bodies(index)\shape\type

      ;#if Defined(PHYSAC_DEBUG)
      ;  ;else
      ;  printf("[PHYSAC] error when trying to get a null reference physics body");
      ;#endif
    EndIf
    ;#if Defined(PHYSAC_DEBUG)
    ;  ;else
    ;  ;printf("[PHYSAC] physics body index is out of bounds");
    ;#endif
  EndIf
  ProcedureReturn result
EndProcedure

; Returns the amount of vertices of a physics body shape
Procedure.rl_int GetPhysicsShapeVerticesCount(index.rl_int)
  Protected.rl_int result = 0
  
  If index < physicsBodiesCount
    If bodies(index) <> #Null
      Select bodies(index)\shape\type
        Case #PHYSICS_CIRCLE
          result = #PHYSAC_CIRCLE_VERTICES
        Case #PHYSICS_POLYGON
          result = bodies(index)\shape\vertexData\vertexCount
      EndSelect
    EndIf
    ;#if Defined(PHYSAC_DEBUG)
    ;else
    ;printf("[PHYSAC] error when trying to get a null reference physics body");
    ;#endif
  EndIf
  ;#if Defined(PHYSAC_DEBUG)
  ;else
  ;printf("[PHYSAC] physics body index is out of bounds");
  ;#endif
  
  ProcedureReturn result
EndProcedure

; Returns transformed position of a body shape (body position + vertex transformed position)
Procedure GetPhysicsShapeVertex(*result.Vector2, *body.PhysicsBody, vertex.rl_int)
  Protected.Vector2 position, vout
  Protected.PolygonData vertexData
  
  InitVector2(@position, 0, 0)

  If *body <> #Null
    Select *body\shape\type
      Case #PHYSICS_CIRCLE
        position\x = *body\position\x + Cos(360.0 / #PHYSAC_CIRCLE_VERTICES * vertex * #PHYSAC_DEG2RAD) * *body\shape\radius
        position\y = *body\position\y + Sin(360.0 / #PHYSAC_CIRCLE_VERTICES * vertex * #PHYSAC_DEG2RAD) * *body\shape\radius
      Case #PHYSICS_POLYGON
        vertexData = *body\shape\vertexData
        
        Mat2MultiplyVector2(@vout, *body\shape\transform, @vertexData\positions[vertex])
        
        Vector2Add(@vout, *body\position, @vout)
        
        position = vout
        ;InitVector2(@position, vout\x, vout\y)
    EndSelect
  EndIf
  
  ;#if Defined(PHYSAC_DEBUG)
    ;else
    ;printf("[PHYSAC] error when trying to get a null reference physics body");
  ;#endif

  ;*result = position
  InitVector2(*result, position\x, position\y)
EndProcedure

; Sets physics body shape transform based on radians parameter
Procedure SetPhysicsBodyRotation(*body.PhysicsBody, radians.rl_float)
  If *body <> #Null
    *body\orient = radians

    If *body\shape\type = #PHYSICS_POLYGON
      Mat2Radians(*body\shape\transform, radians)
    EndIf
  EndIf
EndProcedure

; Unitializes And destroys a physics body
Procedure DestroyPhysicsBody(*body.PhysicsBody)
  Protected.rl_int id, index, i
  
  If *body <> #Null
    id = *body\id
    index = -1

    For i = 0 To physicsBodiesCount - 1
      If bodies(i)\id = id
        index = i
        Break
      EndIf
    Next

    If index = -1
      ;#if Defined(PHYSAC_DEBUG)
        ;printf("[PHYSAC] Not possible to find body id %i in pointers array\n", id);
      ;#endif
      ProcedureReturn 0
    EndIf

    ; Free body allocated memory
    ;PHYSAC_FREE(body);
    ;usedMemory -= SizeOf(PhysicsBodyData);
    ClearStructure(@bodies(index), PhysicsBody)

    ; Reorder physics bodies pointers Array And its catched index
    For i = index To physicsBodiesCount - 1
      If (i + 1) < physicsBodiesCount
        bodies(i) = bodies(i + 1)
      EndIf
    Next

    ; Update physics bodies count
    physicsBodiesCount - 1

;     #if Defined(PHYSAC_DEBUG)
;       printf("[PHYSAC] destroyed physics body id %i\n", id);
;     #endif
  EndIf
  
;   #if Defined(PHYSAC_DEBUG)
;     ;else
;     printf("[PHYSAC] error trying to destroy a null referenced body\n");
;   #endif
EndProcedure

; Unitializes physics pointers And exits physics loop thread
Procedure ClosePhysics()
  Protected.rl_int i
  
  ; Exit physics loop thread
  physicsThreadEnabled = #False

;   #if !Defined(PHYSAC_NO_THREADS)
;     pthread_join(physicsThreadId, NULL);
;   #endif

  ; Unitialize physics manifolds dynamic memory allocations
  For i = physicsManifoldsCount - 1 To 0 Step -1
    DestroyPhysicsManifold(g_contacts(i))
  Next
  
  ; Unitialize physics bodies dynamic memory allocations
  For i = physicsBodiesCount - 1 To 0 Step -1
    DestroyPhysicsBody(bodies(i))
  Next
      
;   #if Defined(PHYSAC_DEBUG)
;     If (physicsBodiesCount > 0 || usedMemory != 0)
;       printf("[PHYSAC] physics module closed with %i still allocated bodies [MEMORY: %i bytes]\n", physicsBodiesCount, usedMemory);
;     ElseIf (physicsManifoldsCount > 0 || usedMemory != 0)
;       printf("[PHYSAC] physics module closed with %i still allocated manifolds [MEMORY: %i bytes]\n", physicsManifoldsCount, usedMemory);
;     Else
;       printf("[PHYSAC] physics module closed successfully\n")
;     EndIf
;   #endif
EndProcedure

;>----------------------------------------------------------------------------------
; Module Internal Functions Definition
;-----------------------------------------------------------------------------------
; Finds a valid index For a new physics body initialization
Procedure.rl_int FindAvailableBodyIndex()
  Protected.rl_int index = -1, i, k, currentId
  
  For i = 0 To #PHYSAC_MAX_BODIES - 1
    currentId = i

    ; Check If current id already exist in other physics body
    For k = 0 To physicsBodiesCount - 1
      If bodies(k)\id = currentId
        currentId + 1
        Break
      EndIf
    Next

    ; If it is Not used, use it As new physics body id
    If currentId = i
      index = i
      Break
    EndIf
  Next

  ProcedureReturn index
EndProcedure

; Creates a random polygon shape With max vertex distance from polygon pivot
Procedure CreateRandomPolygon(*result.PolygonData, radius.rl_float, sides.rl_int)
  Protected.PolygonData PolyData
  Protected.rl_int i, nextIndex
  Protected.Vector2 face
  
  PolyData\vertexCount = sides

  ; Calculate polygon vertices positions
  For i = 0 To PolyData\vertexCount - 1
    PolyData\positions[i]\x = Cos(360.0 / sides * i * #PHYSAC_DEG2RAD) * radius
    PolyData\positions[i]\y = Sin(360.0 / sides * i * #PHYSAC_DEG2RAD) * radius
  Next

  ; Calculate polygon faces normals
  For i = 0 To PolyData\vertexCount - 1
    If (i + 1) < sides
      nextIndex = (i + 1)
    Else
      nextIndex = 0
    EndIf
      
    Vector2Subtract(@face, @PolyData\positions[nextIndex], @PolyData\positions[i])

    PolyData\normals[i]\x = face\y 
    PolyData\normals[i]\y = -face\x
    
    MathNormalize(@PolyData\normals[i])
  Next

  ;*result = PolyData
  CopyStructure(@PolyData, *result, PolygonData)
EndProcedure

; Creates a rectangle polygon shape based on a min And max positions
Procedure CreateRectanglePolygon(*result.PolygonData, *pos.Vector2, *size.Vector2)
  Protected.PolygonData PolyData
  Protected.rl_int i, nextIndex
  Protected.Vector2 face
  
  PolyData\vertexCount = 4

  ; Calculate polygon vertices positions
  InitVector2(@PolyData\positions[0], *pos\x + *size\x / 2, *pos\y - *size\y / 2)
  InitVector2(@PolyData\positions[1], *pos\x + *size\x / 2, *pos\y + *size\y / 2)
  InitVector2(@PolyData\positions[2], *pos\x - *size\x / 2, *pos\y + *size\y / 2)
  InitVector2(@PolyData\positions[3], *pos\x - *size\x / 2, *pos\y - *size\y / 2)

  ; Calculate polygon faces normals
  For i = 0 To PolyData\vertexCount - 1
    If (i + 1) < PolyData\vertexCount
      nextIndex = (i + 1)
    Else
      nextIndex = 0
    EndIf
    
    Vector2Subtract(@face, @PolyData\positions[nextIndex], @PolyData\positions[i])

    PolyData\normals[i]\x = face\y 
    PolyData\normals[i]\y = -face\x
    
    MathNormalize(@PolyData\normals[i])
  Next

  ;*result = PolyData
  CopyStructure(@PolyData, *result, PolygonData)
EndProcedure

; Physics loop thread function
Procedure.i PhysicsLoop(*arg)
  ;#if Defined(PHYSAC_DEBUG)
    ;printf("[PHYSAC] physics thread created successfully\n");
  ;#endif

  ; Initialize physics loop thread values
  physicsThreadEnabled = #True

  ; Physics update loop
  While (physicsThreadEnabled)
    RunPhysicsStep()
  Wend

  ProcedureReturn #Null
EndProcedure

; Physics steps calculations (dynamics, collisions And position corrections)
Procedure PhysicsStep()
  Protected.rl_int i, j
  Protected.PhysicsManifold manifold, newManifold
  Protected.PhysicsBody body, bodyA, bodyB
  
  ; Update current steps count
  stepsCount + 1

  ; Clear previous generated collisions information
  For i = physicsManifoldsCount - 1 To 0 Step -1
    
    manifold = g_contacts(i)
    
    If manifold <> #Null
      DestroyPhysicsManifold(@manifold)
    EndIf
    
  Next

  ; Reset physics bodies grounded state
  For i = 0 To physicsBodiesCount - 1
    ;body = bodies(i)
    CopyStructure(bodies(i), body, PhysicsBody)
    body\isGrounded = #False
  Next

  ; Generate new collision information
  For i = 0 To physicsBodiesCount - 1
    ;bodyA = bodies(i)
    CopyStructure(bodies(i), bodyA, PhysicsBody)

    If bodyA <> #Null
      For j = i + 1 To physicsBodiesCount - 1
        
        ;bodyB = bodies(j)
        CopyStructure(bodies(i), bodyB, PhysicsBody)

        If bodyB <> #Null
          If ((bodyA\inverseMass = 0) And (bodyB\inverseMass = 0))
            Continue
          EndIf
          
          CreatePhysicsManifold(@manifold, @bodyA, @bodyB)
          
          SolvePhysicsManifold(@manifold)

          If manifold\contactsCount > 0
            ; Create a new manifold With same information As previously solved manifold And add it To the manifolds pool last slot
            CreatePhysicsManifold(@newManifold, @bodyA, @bodyB)
            
            newManifold\penetration = manifold\penetration
            newManifold\normal = manifold\normal
            ;CopyArray(manifold\contacts(), newManifold\contacts())
            newManifold\contacts[0] = manifold\contacts[0]
            newManifold\contacts[1] = manifold\contacts[1]
            newManifold\contactsCount = manifold\contactsCount
            newManifold\restitution = manifold\restitution
            newManifold\dynamicFriction = manifold\dynamicFriction
            newManifold\staticFriction = manifold\staticFriction
          EndIf
        
        EndIf
      Next
    EndIf
  Next

  ; Integrate forces To physics bodies
  For i = 0 To physicsBodiesCount - 1
    ;body = bodies(i)
    CopyStructure(bodies(i), body, PhysicsBody)
        
    If body <> #Null
      IntegratePhysicsForces(@body)
    EndIf
  Next

  ; Initialize physics manifolds To solve collisions
  For i = 0 To physicsManifoldsCount - 1
    manifold = g_contacts(i)
        
    If manifold <> #Null
      InitializePhysicsManifolds(@manifold)
    EndIf
  Next

  ; Integrate physics collisions impulses To solve collisions
  For i = 0 To #PHYSAC_COLLISION_ITERATIONS - 1
    For j = 0 To physicsManifoldsCount - 1
      manifold = g_contacts(i)
            
      If manifold <> #Null
        IntegratePhysicsImpulses(@manifold)
      EndIf
    Next
  Next

  ; Integrate velocity To physics bodies
  For i = 0 To physicsBodiesCount - 1
    ;body = bodies(i)
    CopyStructure(bodies(i), body, PhysicsBody)
        
    If body <> #Null
      IntegratePhysicsVelocity(body)
    EndIf
  Next

  ; Correct physics bodies positions based on manifolds collision information
  For i = 0 To physicsManifoldsCount - 1
    manifold = g_contacts(i)
        
    If manifold <> #Null
      CorrectPhysicsPositions(@manifold)
    EndIf
  Next

  ; Clear physics bodies forces
  For i = 0 To physicsBodiesCount - 1
    ;body = bodies(i)
    CopyStructure(bodies(i), body, PhysicsBody)
        
    If body <> #Null
      body\force\x = #PHYSAC_VECTOR_ZERO
      body\force\y = #PHYSAC_VECTOR_ZERO
      body\torque = 0.0
    EndIf
  Next
  
EndProcedure

; Wrapper To ensure PhysicsStep is run With at a fixed time Step
Procedure RunPhysicsStep()
  Protected.rl_double delta
  
  ; Calculate current time
  currentTime = GetCurrentTime()
  
  
  ; Calculate current delta time
  delta = currentTime - startTime

  ; Store the time elapsed since the last frame began
  accumulator + delta

  ; Fixed time stepping loop
  While accumulator >= deltaTime
    PhysicsStep()
    Debug "Die aktuelle Zeit: " + currentTime
    accumulator - deltaTime
  Wend

  ; Record the starting of this frame
  startTime = currentTime
EndProcedure

Procedure SetPhysicsTimeStep(delta.rl_double)
  deltaTime = delta
EndProcedure

; Finds a valid index For a new manifold initialization
Procedure.rl_int FindAvailableManifoldIndex()
  Protected.rl_int i, k, index, currentId
  
  index = -1
  
  For i = 0 To #PHYSAC_MAX_MANIFOLDS - 1
    currentId = i

    ; Check If current id already exist in other physics body
    For k = 0 To physicsManifoldsCount - 1
      If g_contacts(k)\id = currentId
        currentId + 1
        Break
      EndIf
    Next

    ; If it is Not used, use it As new physics body id
    If currentId = i
      index = i
      Break
    EndIf
  Next

  ProcedureReturn index
EndProcedure

; Creates a new physics manifold To solve collision
Procedure CreatePhysicsManifold(*result.PhysicsManifold, *a.PhysicsBody, *b.PhysicsBody)
  Protected.rl_int newId
  
  ;PhysicsManifold newManifold = (PhysicsManifold)PHYSAC_MALLOC(SizeOf(PhysicsManifoldData));
  ;usedMemory += SizeOf(PhysicsManifoldData);

  newId = FindAvailableManifoldIndex()
  
  If newId <> -1
    
    With *result
      ; Initialize new manifold With generic values
      \id = newId
      CopyStructure(*a, @\bodyA, PhysicsBody)
      CopyStructure(*b, @\bodyB, PhysicsBody)
      \penetration = 0
      \normal\x = #PHYSAC_VECTOR_ZERO
      \normal\y = #PHYSAC_VECTOR_ZERO
      \contacts[0]\x = #PHYSAC_VECTOR_ZERO
      \contacts[0]\y = #PHYSAC_VECTOR_ZERO
      \contacts[1]\x = #PHYSAC_VECTOR_ZERO
      \contacts[1]\y = #PHYSAC_VECTOR_ZERO
      \contactsCount = 0
      \restitution = 0.0
      \dynamicFriction = 0.0
      \staticFriction = 0.0
    EndWith
    
    ;Debug("ManifoldsCount: "+Str(physicsManifoldsCount))
    
    *result = g_contacts(physicsManifoldsCount)
    ; Add new body To bodies pointers Array And update bodies count
    ;CopyStructure(*result, @g_contacts(physicsManifoldsCount), PhysicsManifold)
    physicsManifoldsCount + 1
  EndIf
  
  ;#if Defined(PHYSAC_DEBUG)
    ;else
    ;printf("[PHYSAC] new physics manifold creation failed because there is any available id to use\n");
  ;#endif
EndProcedure

; Unitializes And destroys a physics manifold
Procedure DestroyPhysicsManifold(*manifold.PhysicsManifold)
  Protected.rl_int i, id, index
  
  If *manifold <> #Null
    id = *manifold\id
    index = -1

    For i = 0 To physicsManifoldsCount - 1
      If g_contacts(i)\id = id
        index = i
        Break
      EndIf
    Next

    If index = -1
;       #if Defined(PHYSAC_DEBUG)
;         printf("[PHYSAC] Not possible to manifold id %i in pointers array\n", id);
;       #endif
      ProcedureReturn 0
    EndIf      

    ; Free manifold allocated memory
    ;FreeStructure(*manifold)
    
    ;usedMemory -= SizeOf(PhysicsManifoldData);
    ClearStructure(@g_contacts(index), PhysicsManifold)

    ; Reorder physics manifolds pointers Array And its catched index
    For i = index To physicsManifoldsCount - 1
      If (i + 1) < physicsManifoldsCount
        g_contacts(i) = g_contacts(i + 1)
      EndIf
    Next

    ; Update physics manifolds count
    physicsManifoldsCount - 1
  EndIf
  
;   #if Defined(PHYSAC_DEBUG)
;     ;else
;     printf("[PHYSAC] error trying to destroy a null referenced manifold\n");
;   #endif
EndProcedure

; Solves a created physics manifold between two physics bodies
Procedure SolvePhysicsManifold(*manifold.PhysicsManifold)
  
  Select *manifold\bodyA\shape\type
    Case #PHYSICS_CIRCLE
      Select *manifold\bodyB\shape\type
        Case #PHYSICS_CIRCLE 
          SolveCircleToCircle(*manifold)
        Case #PHYSICS_POLYGON 
          SolveCircleToPolygon(*manifold)
      EndSelect
    Case #PHYSICS_POLYGON
      Select *manifold\bodyB\shape\type
        Case #PHYSICS_CIRCLE 
          SolvePolygonToCircle(*manifold)
        Case #PHYSICS_POLYGON 
          SolvePolygonToPolygon(*manifold)
      EndSelect
  EndSelect
  
  ; Update physics body grounded state If normal direction is down And grounded state is Not set yet in previous manifolds
  If Not *manifold\bodyB\isGrounded
    *manifold\bodyB\isGrounded = Bool(*manifold\normal\y < 0)
  EndIf
EndProcedure

; Solves collision between two circle shape physics bodies
Procedure SolveCircleToCircle(*manifold.PhysicsManifold)
  Protected.PhysicsBody bodyA, bodyB
  Protected.Vector2 normal
  Protected.rl_float distSqr, radius, distance
  
  bodyA = *manifold\bodyA
  bodyB = *manifold\bodyB

  If ((bodyA = #Null) Or (bodyB = #Null))
    ProcedureReturn 0
  EndIf

  ; Calculate translational vector, which is normal
  Vector2Subtract(@normal, @bodyB\position, @bodyA\position)

  distSqr = MathLenSqr(normal);
  radius = bodyA\shape\radius + bodyB\shape\radius

  ; Check If circles are Not in contact
  If distSqr >= radius * radius
    *manifold\contactsCount = 0
    ProcedureReturn 0
  EndIf

  distance = Sqr(distSqr)
  
  *manifold\contactsCount = 1

  If distance = 0.0
    *manifold\penetration = bodyA\shape\radius
    InitVector2(*manifold\normal, 1.0, 0.0)
    *manifold\contacts[0] = bodyA\position
  Else
    *manifold\penetration = radius - distance
    InitVector2(*manifold\normal, normal\x / distance, normal\y / distance) ; Faster than using MathNormalize() due to sqrt is already performed
    *manifold\contacts[0]\x = *manifold\normal\x * bodyA\shape\radius + bodyA\position\x 
    *manifold\contacts[0]\y = *manifold\normal\y * bodyA\shape\radius + bodyA\position\y
  EndIf

  ; Update physics body grounded state If normal direction is down
  If Not bodyA\isGrounded
    bodyA\isGrounded = Bool(*manifold\normal\y < 0)
  EndIf
EndProcedure

; Solves collision between a circle To a polygon shape physics bodies
Procedure SolveCircleToPolygon(*manifold.PhysicsManifold)
  Protected.PhysicsBody bodyA, bodyB
  
  bodyA = *manifold\bodyA
  bodyB = *manifold\bodyB

  If ((bodyA = #Null) Or (bodyB = #Null))
    ProcedureReturn 0
  EndIf

  SolveDifferentShapes(*manifold, @bodyA, @bodyB)
EndProcedure

; Solves collision between a circle To a polygon shape physics bodies
Procedure SolvePolygonToCircle(*manifold.PhysicsManifold)
  Protected.PhysicsBody bodyA, bodyB
  
  bodyA = *manifold\bodyA
  bodyB = *manifold\bodyB

  If ((bodyA = #Null) Or (bodyB = #Null))
    ProcedureReturn 0
  EndIf

  SolveDifferentShapes(*manifold, @bodyB, @bodyA)
    
  *manifold\normal\x * -1.0
  *manifold\normal\y * -1.0
EndProcedure

; Solve collision between two different types of shapes
Procedure SolveDifferentShapes(*manifold.PhysicsManifold , *bodyA.PhysicsBody, *bodyB.PhysicsBody)
  Protected.rl_int i, faceNormal, nextIndex
  Protected.Vector2 normal, center, vout1, vout2, vout3, v1, v2
  Protected.rl_float separation, currentSeparation, dot1, dot2
  Protected.PolygonData vertexData
  
  *manifold\contactsCount = 0

  ; Transform circle center To polygon transform space
  center = *bodyA\position
  
  Mat2Transpose(@vout1, *bodyB\shape\transform)
  
  Vector2Subtract(@vout2, @center, *bodyB\position)
  
  Mat2MultiplyVector2(@center, @vout1, @vout2)

  ; Find edge With minimum penetration
  ; It is the same concept As using support points in SolvePolygonToPolygon
  separation = -#PHYSAC_FLT_MAX
  faceNormal = 0
  vertexData = *bodyB\shape\vertexData

  For i = 0 To vertexData\vertexCount - 1
    
    Vector2Subtract(@vout3, @center, @vertexData\positions[i])
    
    currentSeparation = MathDot(@vertexData\normals[i], @vout3)

    If currentSeparation > *bodyA\shape\radius
      ProcedureReturn 0
    EndIf

    If currentSeparation > separation
      separation = currentSeparation
      faceNormal = i
    EndIf
  Next

  ; Grab face's vertices
  v1 = vertexData\positions[faceNormal]
  
  If (faceNormal + 1) < vertexData\vertexCount
    nextIndex = (faceNormal + 1)
  Else
    nextIndex = 0
  EndIf
  
  v2 = vertexData\positions[nextIndex]

  ; Check To see If center is within polygon
  If separation < #PHYSAC_EPSILON
    *manifold\contactsCount = 1
    
    Mat2MultiplyVector2(@normal, *bodyB\shape\transform, @vertexData\normals[faceNormal])
    
    *manifold\normal\x = -normal\x
    *manifold\normal\y = -normal\y
    
    *manifold\contacts[0]\x = *manifold\normal\x * *bodyA\shape\radius + *bodyA\position\x 
    *manifold\contacts[0]\y = *manifold\normal\y * *bodyA\shape\radius + *bodyA\position\y
    
    *manifold\penetration = *bodyA\shape\radius
    
    ProcedureReturn 0
  EndIf

  ; Determine which voronoi region of the edge center of circle lies within
  Vector2Subtract(@vout1, @center, @v1)
  Vector2Subtract(@vout2, @v2, @v1)
  
  dot1 = MathDot(@vout1, @vout2)
  
  Vector2Subtract(@vout1, @center, @v2)
  Vector2Subtract(@vout2, @v1, @v2)
  
  dot2 = MathDot(@vout1, @vout2)
  
  *manifold\penetration = *bodyA\shape\radius - separation

  If dot1 <= 0.0  ; Closest To v1
    
    If DistSqr(@center, @v1) > *bodyA\shape\radius * *bodyA\shape\radius
      ProcedureReturn 0
    EndIf

    *manifold\contactsCount = 1
    
    Vector2Subtract(@normal, @v1, @center)
    
    Mat2MultiplyVector2(@normal, *bodyB\shape\transform, @normal)
        
    MathNormalize(@normal)
    
    *manifold\normal = normal
    
    Mat2MultiplyVector2(@v1, *bodyB\shape\transform, @v1)
    
    Vector2Add(@v1, @v1, *bodyB\position)
    
    *manifold\contacts[0] = v1
    
  ElseIf dot2 <= 0.0  ; Closest To v2
    
    If DistSqr(@center, @v2) > *bodyA\shape\radius * *bodyA\shape\radius
      ProcedureReturn 0
    EndIf

    *manifold\contactsCount = 1;
    
    Vector2Subtract(@normal, @v2, @center)
    
    Mat2MultiplyVector2(@v2, *bodyB\shape\transform, @v2)
    
    Vector2Add(@v2, @v2, *bodyB\position);
    
    *manifold\contacts[0] = v2
    
    Mat2MultiplyVector2(@normal, *bodyB\shape\transform, @normal)
    
    MathNormalize(@normal)
    
    *manifold\normal = normal
    
  Else  ; Closest To face
    
    normal = vertexData\normals[faceNormal]
    
    Vector2Subtract(@vout1, @center, @v1)

    If MathDot(@vout1, @normal) > *bodyA\shape\radius
      ProcedureReturn 0
    EndIf

    Mat2MultiplyVector2(@normal, *bodyB\shape\transform, @normal)
    
    *manifold\normal\x = -normal\x 
    *manifold\normal\y = -normal\y
    
    *manifold\contacts[0]\x = *manifold\normal\x * *bodyA\shape\radius + *bodyA\position\x 
    *manifold\contacts[0]\y = *manifold\normal\y * *bodyA\shape\radius + *bodyA\position\y
    
    *manifold\contactsCount = 1
  EndIf
EndProcedure

; Solves collision between two polygons shape physics bodies
Procedure SolvePolygonToPolygon(*manifold.PhysicsManifold)
  Protected.PhysicsShape bodyA, bodyB, refPoly, incPoly
  Protected.rl_int faceA, faceB, referenceIndex, currentPoint
  Protected.rl_float penetrationA, penetrationB, refC, negSide, posSide, separation
  Protected.rl_bool flip
  Protected.PolygonData refData
  Protected.Vector2 v1, v2, sidePlaneNormal, refFaceNormal, normal
  
  Dim incidentFace.Vector2(1)
  
  If ((*manifold\bodyA = #Null) Or (*manifold\bodyB = #Null))
    ProcedureReturn
  EndIf

  bodyA = *manifold\bodyA\shape
  bodyB = *manifold\bodyB\shape
  
  *manifold\contactsCount = 0

  ; Check For separating axis With A shape's face planes
  faceA = 0
  penetrationA = FindAxisLeastPenetration(@faceA, @bodyA, @bodyB)
    
  If penetrationA >= 0.0
    ProcedureReturn 0
  EndIf

  ; Check For separating axis With B shape's face planes
  faceB = 0
  penetrationB = FindAxisLeastPenetration(@faceB, @bodyB, @bodyA)
    
  If penetrationB >= 0.0
    ProcedureReturn 0
  EndIf

  referenceIndex = 0
  flip = #False  ; Always point from A shape to B shape

  ; Determine which shape contains reference face
  If BiasGreaterThan(penetrationA, penetrationB)
    refPoly = bodyA
    incPoly = bodyB
    referenceIndex = faceA
  Else
    refPoly = bodyB
    incPoly = bodyA
    referenceIndex = faceB
    flip = #True
  EndIf

  FindIncidentFace(@incidentFace(0), @incidentFace(1), @refPoly, @incPoly, referenceIndex)

  ; Setup reference face vertices
  refData = refPoly\vertexData
  
  v1 = refData\positions[referenceIndex]
  
  If (referenceIndex + 1) < refData\vertexCount
    referenceIndex = (referenceIndex + 1)
  Else
    referenceIndex = 0
  EndIf
  
  v2 = refData\positions[referenceIndex]

  ; Transform vertices To world space
  
  Mat2MultiplyVector2(@v1, @refPoly\transform, @v1)
  
  Vector2Add(@v1, @v1, @refPoly\body\position)
  
  Mat2MultiplyVector2(@v2, @refPoly\transform, @v2)
  
  Vector2Add(@v2, @v2, @refPoly\body\position)

  ; Calculate reference face side normal in world space
  Vector2Subtract(@sidePlaneNormal, @v2, @v1)
  
  MathNormalize(@sidePlaneNormal)

  ; Orthogonalize
  refFaceNormal\x = sidePlaneNormal\y 
  refFaceNormal\y = -sidePlaneNormal\x
  
  refC = MathDot(@refFaceNormal, @v1)
  negSide = MathDot(@sidePlaneNormal, @v1) * -1
  posSide = MathDot(@sidePlaneNormal, @v2)
  
  normal\x = -sidePlaneNormal\x
  normal\y = -sidePlaneNormal\y
  
  ; Clip incident face To reference face side planes (due To floating point error, possible To Not have required points
  If Clip(@normal, negSide, @incidentFace(0), @incidentFace(1)) < 2
    ProcedureReturn 0
  EndIf

  If Clip(@sidePlaneNormal, posSide, @incidentFace(0), @incidentFace(1)) < 2
    ProcedureReturn 0
  EndIf

  ; Flip normal If required
  If flip = #True
    *manifold\normal\x = -refFaceNormal\x 
    *manifold\normal\y = -refFaceNormal\y 
  Else
    *manifold\normal = refFaceNormal
  EndIf

  ; Keep points behind reference face
  currentPoint = 0  ; Clipped points behind reference face
  separation = MathDot(@refFaceNormal, @incidentFace(0)) - refC
    
  If separation <= 0.0
    *manifold\contacts[currentPoint]\x = @incidentFace(0)\x
    *manifold\contacts[currentPoint]\y = @incidentFace(0)\y
    *manifold\penetration = -separation
    currentPoint + 1
  Else
    *manifold\penetration = 0.0
  EndIf

  separation = MathDot(@refFaceNormal, @incidentFace(1)) - refC

  If separation <= 0.0
    *manifold\contacts[currentPoint] = incidentFace(1)
    *manifold\penetration + -separation
    
    currentPoint + 1

    ; Calculate total penetration average
    *manifold\penetration / currentPoint
  EndIf

  *manifold\contactsCount = currentPoint
    
EndProcedure

; Integrates physics forces into velocity
Procedure IntegratePhysicsForces(*body.PhysicsBody)
  
  If ((*body = #Null) Or (*body\inverseMass = 0.0) Or (Not *body\enabled))
    ProcedureReturn 0
  EndIf

  *body\velocity\x + (*body\force\x * *body\inverseMass) * (deltaTime / 2.0)
  *body\velocity\y + (*body\force\y * *body\inverseMass) * (deltaTime / 2.0)

  If *body\useGravity = #True
    *body\velocity\x + gravityForce\x * (deltaTime / 1000 / 2.0)
    *body\velocity\y + gravityForce\y * (deltaTime / 1000 / 2.0)
  EndIf

  If Not *body\freezeOrient
    *body\angularVelocity + *body\torque * *body\inverseInertia * (deltaTime / 2.0)
  EndIf
  
EndProcedure

; Initializes physics manifolds To solve collisions
Procedure InitializePhysicsManifolds(*manifold.PhysicsManifold)
  Protected.PhysicsBody bodyA, bodyB
  Protected.rl_int i
  Protected.Vector2 radiusA, radiusB, crossA, crossB, radiusV, vg
  
  bodyA = *manifold\bodyA
  bodyB = *manifold\bodyB

  If ((bodyA = #Null) Or (bodyB = #Null))
    ProcedureReturn 0
  EndIf

  ; Calculate average restitution, Static And dynamic friction
  *manifold\restitution = Sqr(bodyA\restitution * bodyB\restitution)
  *manifold\staticFriction = Sqr(bodyA\staticFriction * bodyB\staticFriction)
  *manifold\dynamicFriction = Sqr(bodyA\dynamicFriction * bodyB\dynamicFriction)

  For i = 0 To *manifold\contactsCount - 1
    ; Caculate radius from center of mass To contact
    Vector2Subtract(@radiusA, *manifold\contacts[i], @bodyA\position)
    Vector2Subtract(@radiusB, *manifold\contacts[i], @bodyB\position)

    MathCross(@crossA, bodyA\angularVelocity, @radiusA)
    MathCross(@crossB, bodyB\angularVelocity, @radiusB)

    InitVector2(@radiusV, 0.0, 0.0)
    
    radiusV\x = bodyB\velocity\x + crossB\x - bodyA\velocity\x - crossA\x
    radiusV\y = bodyB\velocity\y + crossB\y - bodyA\velocity\y - crossA\y

    ; Determine If we should perform a resting collision Or Not
    ; The idea is If the only thing moving this object is gravity, then the collision should be performed without any restitution
    vg\x = gravityForce\x * deltaTime / 1000 : vg\y = gravityForce\y * deltaTime / 1000
    If MathLenSqr(@radiusV) < MathLenSqr(@vg) + #PHYSAC_EPSILON
      *manifold\restitution = 0
    EndIf
  Next
EndProcedure

; Integrates physics collisions impulses To solve collisions
Procedure IntegratePhysicsImpulses(*manifold.PhysicsManifold)
  Protected.PhysicsBody bodyA, bodyB
  Protected.rl_int i
  Protected.Vector2 radiusA, radiusB, radiusV, impulseV, tangent, tangentImpulse, vout1, vout2, vout3
  Protected.rl_float contactVelocity, raCrossN, rbCrossN, inverseMassSum, impulse, impulseTangent, absImpulseTangent
  
  bodyA = *manifold\bodyA
  bodyB = *manifold\bodyB
  
  If ((bodyA = #Null) Or (bodyB = #Null))
    ProcedureReturn 0
  EndIf
  
  ; Early out And positional correct If both objects have infinite mass
  If Abs(bodyA\inverseMass + bodyB\inverseMass) <= #PHYSAC_EPSILON
    bodyA\velocity\x = #PHYSAC_VECTOR_ZERO
    bodyA\velocity\y = #PHYSAC_VECTOR_ZERO
    
    bodyB\velocity\x = #PHYSAC_VECTOR_ZERO
    bodyB\velocity\y = #PHYSAC_VECTOR_ZERO
    
    ProcedureReturn 0
  EndIf
  
  For i = 0 To *manifold\contactsCount - 1
    ; Calculate radius from center of mass To contact
    Vector2Subtract(@radiusA, *manifold\contacts[i], @bodyA\position)
    Vector2Subtract(@radiusB, *manifold\contacts[i], @bodyB\position)
    
    ; Calculate relative velocity
    InitVector2(@radiusV, 0.0, 0.0)
    
    MathCross(@vout1, bodyB\angularVelocity, @radiusB)
    MathCross(@vout2, bodyA\angularVelocity, @radiusA)
    
    radiusV\x = bodyB\velocity\x + vout1\x - bodyA\velocity\x - vout2\x
    radiusV\y = bodyB\velocity\y + vout1\y - bodyA\velocity\y - vout2\y
    
    ; Relative velocity along the normal
    contactVelocity = MathDot(@radiusV, *manifold\normal)
    
    ; Do Not resolve If velocities are separating
    If contactVelocity > 0.0
      ProcedureReturn 0
    EndIf
    
    raCrossN = MathCrossVector2(@radiusA, *manifold\normal)
    rbCrossN = MathCrossVector2(@radiusB, *manifold\normal)
    
    inverseMassSum = bodyA\inverseMass + bodyB\inverseMass + (raCrossN * raCrossN) * bodyA\inverseInertia + (rbCrossN * rbCrossN) * bodyB\inverseInertia
    
    ; Calculate impulse scalar value
    impulse = -(1.0 + *manifold\restitution) * contactVelocity
    impulse / inverseMassSum
    impulse / *manifold\contactsCount
    
    ; Apply impulse To each physics body
    impulseV\x = *manifold\normal\x * impulse 
    impulseV\y = *manifold\normal\y * impulse
    
    If bodyA\enabled = #True
      bodyA\velocity\x + bodyA\inverseMass * (-impulseV\x)
      bodyA\velocity\y + bodyA\inverseMass * (-impulseV\y)
      
      If Not bodyA\freezeOrient
        InitVector2(@vout3, -impulseV\x, -impulseV\y)
        bodyA\angularVelocity + bodyA\inverseInertia * MathCrossVector2(@radiusA, @vout3)
      EndIf
    EndIf
    
    If bodyB\enabled = #True
      
      bodyB\velocity\x + bodyB\inverseMass * (impulseV\x)
      bodyB\velocity\y + bodyB\inverseMass * (impulseV\y)
      
      If Not bodyB\freezeOrient
        bodyB\angularVelocity + bodyB\inverseInertia * MathCrossVector2(@radiusB, @impulseV)
      EndIf
    EndIf
    
    ; Apply friction impulse To each physics body
    MathCross(@vout1, bodyB\angularVelocity, @radiusB)
    MathCross(@vout2, bodyA\angularVelocity, @radiusA)
    
    radiusV\x = bodyB\velocity\x + vout1\x - bodyA\velocity\x - vout2\x
    radiusV\y = bodyB\velocity\y + vout1\y - bodyA\velocity\y - vout2\y
    
    tangent\x = radiusV\x - *manifold\normal\x * MathDot(@radiusV, *manifold\normal) 
    tangent\y = radiusV\y - *manifold\normal\y * MathDot(@radiusV, *manifold\normal)
    
    MathNormalize(@tangent)
    
    ; Calculate impulse tangent magnitude
    impulseTangent = -MathDot(@radiusV, @tangent)
    impulseTangent / inverseMassSum
    impulseTangent / *manifold\contactsCount
    
    absImpulseTangent = Abs(impulseTangent)
    
    ; Don't apply tiny friction impulses
    If absImpulseTangent <= #PHYSAC_EPSILON
      ProcedureReturn 0
    EndIf
    
    ; Apply coulumb's law
    InitVector2(@tangentImpulse, 0.0, 0.0)
    
    If absImpulseTangent < impulse * *manifold\staticFriction
      InitVector2(@tangentImpulse, tangent\x * impulseTangent, tangent\y * impulseTangent)
    Else
      InitVector2(@tangentImpulse, tangent\x * -impulse * *manifold\dynamicFriction, tangent\y * -impulse * *manifold\dynamicFriction)
    EndIf
    
    ; Apply friction impulse
    If bodyA\enabled = #True
      bodyA\velocity\x + bodyA\inverseMass * (-tangentImpulse\x)
      bodyA\velocity\y + bodyA\inverseMass * (-tangentImpulse\y)
      
      If Not bodyA\freezeOrient
        InitVector2(@vout3, -tangentImpulse\x, -tangentImpulse\y)
        bodyA\angularVelocity + bodyA\inverseInertia * MathCrossVector2(@radiusA, @vout3)
      EndIf
    EndIf
    
    If bodyB\enabled = #True
      bodyB\velocity\x + bodyB\inverseMass * (tangentImpulse\x)
      bodyB\velocity\y + bodyB\inverseMass * (tangentImpulse\y)
      
      If Not bodyB\freezeOrient
        bodyB\angularVelocity + bodyB\inverseInertia * MathCrossVector2(@radiusB, @tangentImpulse)
      EndIf
    EndIf
  Next
EndProcedure

; Integrates physics velocity into position And forces
Procedure IntegratePhysicsVelocity(*body.PhysicsBody)
  If (*body = #Null) Or (Not *body\enabled)
    ProcedureReturn 0
  EndIf

  *body\position\x + *body\velocity\x * deltaTime
  *body\position\y + *body\velocity\y * deltaTime

  If Not *body\freezeOrient
    *body\orient + *body\angularVelocity * deltaTime
  EndIf

  Mat2Set(*body\shape\transform, *body\orient)

  IntegratePhysicsForces(*body)
EndProcedure

; Corrects physics bodies positions based on manifolds collision information
Procedure CorrectPhysicsPositions(*manifold.PhysicsManifold)
  Protected.PhysicsBody bodyA, bodyB
  Protected.Vector2 correction
  
  bodyA = *manifold\bodyA
  bodyB = *manifold\bodyB

  If ((bodyA = #Null) Or (bodyB = #Null))
    ProcedureReturn 0
  EndIf

  InitVector2(@correction, 0.0, 0.0)
  correction\x = (fmax(*manifold\penetration - #PHYSAC_PENETRATION_ALLOWANCE, 0.0) / (bodyA\inverseMass + bodyB\inverseMass)) * *manifold\normal\x * #PHYSAC_PENETRATION_CORRECTION
  correction\y = (fmax(*manifold\penetration - #PHYSAC_PENETRATION_ALLOWANCE, 0.0) / (bodyA\inverseMass + bodyB\inverseMass)) * *manifold\normal\y * #PHYSAC_PENETRATION_CORRECTION

  If bodyA\enabled = #True
    bodyA\position\x - correction\x * bodyA\inverseMass
    bodyA\position\y - correction\y * bodyA\inverseMass
  EndIf

  If bodyB\enabled = #True
    bodyB\position\x + correction\x * bodyB\inverseMass
    bodyB\position\y + correction\y * bodyB\inverseMass
  EndIf
EndProcedure

; Returns the extreme point along a direction within a polygon
Procedure GetSupport(*result.Vector2, *shape.PhysicsShape, *dir.Vector2)
  Protected.rl_float bestProjection = -#PHYSAC_FLT_MAX, projection
  Protected.Vector2 bestVertex, vertex
  Protected.PolygonData PolyData = *shape\vertexData
  Protected.rl_int i
  
  InitVector2(@bestVertex, 0.0, 0.0)

  For i = 0 To PolyData\vertexCount - 1
    vertex = PolyData\positions[i]
    projection = MathDot(@vertex, *dir)

    If projection > bestProjection
      bestVertex = vertex
      bestProjection = projection
    EndIf
  Next
  
  *result = bestVertex
  
EndProcedure

; Finds polygon shapes axis least penetration
Procedure.rl_float FindAxisLeastPenetration(*faceIndex.long, *shapeA.PhysicsShape, *shapeB.PhysicsShape)
  Protected.rl_float bestDistance = -#PHYSAC_FLT_MAX, distance
  Protected.rl_int bestIndex = 0
  Protected.PolygonData dataA = *shapeA\vertexData
  Protected.rl_int i
  Protected.Vector2 normal, transNormal, support, vertex, vout1, vout2
  Protected.Matr2 buT

  For i = 0 To dataA\vertexCount - 1
    ; Retrieve a face normal from A shape
    normal = dataA\normals[i]
    Mat2MultiplyVector2(@transNormal, *shapeA\transform, @normal)

    ; Transform face normal into B shape's model space
    Mat2Transpose(@buT, *shapeB\transform)
    Mat2MultiplyVector2(@normal, @buT, @transNormal);

    ; Retrieve support point from B shape along -n
    InitVector2(@vout1, -normal\x, -normal\y)
    GetSupport(@support, *shapeB, @vout1)

    ; Retrieve vertex on face from A shape, transform into B shape's model space
    vertex = dataA\positions[i]
    Mat2MultiplyVector2(@vertex, *shapeA\transform, @vertex)
    Vector2Add(@vertex, @vertex, *shapeA\body\position)
    Vector2Subtract(@vertex, @vertex, *shapeB\body\position)
    Mat2MultiplyVector2(@vertex, @buT, @vertex)

    ; Compute penetration distance in B shape's model space
    Vector2Subtract(@vout2, @support, @vertex)
    distance = MathDot(@normal, @vout2)

    ; Store greatest distance
    If distance > bestDistance
      bestDistance = distance
      bestIndex = i
    EndIf
  Next

  PokeL(*faceIndex, bestIndex)
  
  ProcedureReturn bestDistance
EndProcedure

; Finds two polygon shapes incident face
Procedure FindIncidentFace(*v0.Vector2, *v1.Vector2, *ref.PhysicsShape, *inc.PhysicsShape, index.rl_int)
  Protected.PolygonData refData, incData
  Protected.Vector2 referenceNormal
  Protected.rl_int i, incidentFace
  Protected.rl_float minDot, dot
  Protected.Matr2 mout
  
  refData = *ref\vertexData
  incData = *inc\vertexData

  referenceNormal = refData\normals[index]

  ; Calculate normal in incident's frame of reference
  Mat2MultiplyVector2(@referenceNormal, *ref\transform, @referenceNormal) ; To world space
  
  Mat2Transpose(@mout, *inc\transform)
  Mat2MultiplyVector2(@referenceNormal, @mout, @referenceNormal) ; To incident's model space

  ; Find most anti-normal face on polygon
  incidentFace = 0
  minDot = #PHYSAC_FLT_MAX

  For i = 0 To incData\vertexCount - 1
    
    dot = MathDot(@referenceNormal, @incData\normals[i])

    If dot < minDot
      minDot = dot
      incidentFace = i
    EndIf
    
  Next

  ; Assign face vertices For incident face
  Mat2MultiplyVector2(*v0, *inc\transform, @incData\positions[incidentFace])
  Vector2Add(*v0, *v0, *inc\body\position)
  
  If (incidentFace + 1) < incData\vertexCount
    incidentFace = (incidentFace + 1)
  Else
    incidentFace = 0
  EndIf
  
  Mat2MultiplyVector2(*v1, *inc\transform, @incData\positions[incidentFace])
  Vector2Add(*v1, *v1, *inc\body\position)
  
EndProcedure

; Calculates clipping based on a normal And two faces
Procedure.rl_int Clip(*normal.Vector2, clip.rl_float, *faceA.Vector2, *faceB.Vector2)
  Protected.rl_int sp = 0
  Protected.rl_float distanceA, distanceB, alpha
  Protected.Vector2 delta, normal
  Dim out.Vector2(2)
  
  InitVector2(@out(0), *faceA\x, *faceA\y)
  InitVector2(@out(1), *faceB\x, *faceB\y)

  ; Retrieve distances from each endpoint To the line
  distanceA = MathDot(@normal, *faceA) - clip
  distanceB = MathDot(@normal, *faceB) - clip

  ; If negative (behind plane)
  If distanceA <= 0.0
    ;sp++
    out(sp+1)\x = *faceA\x
    out(sp+1)\y = *faceA\y
  EndIf

  If distanceB <= 0.0
    ;sp++
    out(sp+1)\x = *faceB\x
    out(sp+1)\y = *faceB\y
  EndIf

  ; If the points are on different sides of the plane
  If (distanceA * distanceB) < 0.0
    ; Push intersection point
    alpha = distanceA / (distanceA - distanceB)
    
    out(sp)\x = *faceA\x
    out(sp)\y = *faceA\y
    
    Vector2Subtract(@delta, *faceB, *faceA)
    
    delta\x * alpha
    delta\y * alpha
    
    Vector2Add(@out(sp), @out(sp), @delta)
    sp + 1
  EndIf

  ; Assign the new converted values
  *faceA = out(0)
  *faceB = out(1)

  ProcedureReturn sp
EndProcedure

; Check If values are between bias range
Procedure.rl_bool BiasGreaterThan(valueA.rl_float, valueB.rl_float)
  ProcedureReturn Bool(valueA >= (valueB * 0.95 + valueA * 0.01))
EndProcedure

; Returns the barycenter of a triangle given by 3 points
Procedure TriangleBarycenter(*result.Vector2, *v1.Vector2, *v2.Vector2, *v3.Vector2)
  *result\x = (*v1\x + *v2\x + *v3\x) / 3
  *result\y = (*v1\y + *v2\y + *v3\y) / 3
EndProcedure

; Initializes hi-resolution MONOTONIC timer
;-Init_QTimer = HighResTimer::Initialize()
Procedure Init_QTimer()
  srand_(time_(#Null));              // Initialize random seed
  
  ;RandomSeed(Date())
  
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows 
      QueryPerformanceFrequency_(@frequency)
      
    CompilerCase #PB_OS_Linux
      Define.timespec now
      If clock_gettime(#CLOCK_MONOTONIC, @now) = 0
        frequency = 1000000000
      EndIf
      
    CompilerCase #PB_OS_MacOS
      Define.timebase timebase
      mach_timebase_info(@timebase)
      frequency = (timebase\Denominator * 1000000000) / timebase\Numerator
      
  CompilerEndSelect
  
  baseTime = GetTimeCount();      // Get MONOTONIC clock time offset
  startTime = GetCurrentTime();   // Get current time
EndProcedure


; Get hi-res MONOTONIC time measure in seconds
;-GetTimeCount = HighResTimer::Consult()
Procedure.rl_double GetTimeCount()
  Protected.rl_double value = 0
  
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows 
      QueryPerformanceCounter_(@value)

    CompilerCase #PB_OS_Linux
      Define.timespec now
      clock_gettime(#CLOCK_MONOTONIC, @now)
      value = now\Second * 1000000000 + now\NanoSecond
      
    CompilerCase #PB_OS_MacOS
      value = mach_absolute_time()
      
  CompilerEndSelect
  
  Debug "time: " + Str(value)
  ProcedureReturn value
EndProcedure

;-GetCurrentTime = HighResTimer::Consult()
; // Get current time in milliseconds
Procedure.rl_double GetCurrentTime()
  Protected t.rl_double = GetTimeCount() - baseTime
  ProcedureReturn t / frequency * 1000
EndProcedure


; Returns the cross product of a vector And a value
Procedure MathCross(*result.Vector2, value.rl_float, *vector.Vector2)
  *result\x = -value * *vector\y 
  *result\y = value * *vector\x
EndProcedure

; Returns the cross product of two vectors
Procedure.rl_float MathCrossVector2(*v1.Vector2, *v2.Vector2)
  ProcedureReturn (*v1\x * *v2\y - *v1\y * *v2\x)
EndProcedure

; Returns the len square root of a vector
Procedure.rl_float MathLenSqr(*vector.Vector2)
  ProcedureReturn (*vector\x * *vector\x + *vector\y * *vector\y)
EndProcedure

; Returns the dot product of two vectors
Procedure.rl_float MathDot(*v1.Vector2, *v2.Vector2)
  ProcedureReturn (*v1\x * *v2\x + *v1\y * *v2\y)
EndProcedure

; Returns the square root of distance between two vectors
Procedure.rl_float DistSqr(*v1.Vector2, *v2.Vector2)
  Protected.Vector2 dir 
  
  Vector2Subtract(@dir, *v1, *v2)
  
  ProcedureReturn MathDot(@dir, @dir)
EndProcedure

; Returns the normalized values of a vector
Procedure MathNormalize(*vector.Vector2)
  Protected.rl_float length, ilength
  Protected.Vector2 aux
  
  aux\x = *vector\x
  aux\y = *vector\y
  
  length = Sqr(aux\x * aux\x + aux\y * aux\y)

  If length = 0
    length = 1.0
  EndIf
      
  ilength = 1.0 / length

  *vector\x * ilength
  *vector\y * ilength
  
EndProcedure

; #if Defined(PHYSAC_STANDALONE)
; // Returns the sum of two given vectors
; Static inline Vector2 Vector2Add(Vector2 v1, Vector2 v2)
; {
;     Return (Vector2){ v1.x + v2.x, v1.y + v2.y };
; }
; 
; // Returns the subtract of two given vectors
; Static inline Vector2 Vector2Subtract(Vector2 v1, Vector2 v2)
; {
;     Return (Vector2){ v1.x - v2.x, v1.y - v2.y };
; }
; #endif

; Creates a matrix 2x2 from a given radians value
Procedure Mat2Radians(*result.Matr2, radians.rl_float)
  Protected.rl_float c, s
  
  c = Cos(radians)
  s = Sin(radians)
  
  *result\m00 = c
  *result\m01 = -s
  *result\m10 = s
  *result\m11 = c

EndProcedure

; Set values from radians To a created matrix 2x2
Procedure Mat2Set(*matrix.Matr2, radians.rl_float)
  Protected.rl_float cos, sin
  
  cos = Cos(radians)
  sin = Sin(radians)

  *matrix\m00 = cos
  *matrix\m01 = -sin
  *matrix\m10 = sin
  *matrix\m11 = cos
  
EndProcedure

; Returns the transpose of a given matrix 2x2
Procedure Mat2Transpose(*result.Matr2, *matrix.Matr2)
  *result\m00 = *matrix\m00
  *result\m01 = *matrix\m10
  *result\m10 = *matrix\m01
  *result\m11 = *matrix\m11
EndProcedure

; Multiplies a vector by a matrix 2x2
Procedure Mat2MultiplyVector2(*result.Vector2, *matrix.Matr2, *vector.Vector2)
  *result\x = *matrix\m00 * *vector\x + *matrix\m01 * *vector\y
  *result\y = *matrix\m10 * *vector\x + *matrix\m11 * *vector\y
EndProcedure

;UnuseModule HighResTimer
; IDE Options = PureBasic 6.20 - C Backend (MacOS X - arm64)
; CursorPosition = 1394
; FirstLine = 1377
; Folding = ----------
; EnableThread
; EnableXP
; DPIAware