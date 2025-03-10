; /**********************************************************************************************
; *
; *   libpartikel v0.0.3 ALPHA
; *   [https://github.com/dbriemann/libpartikel]
; *
; *
; *   A simple particle system built With And For raylib, To be used As header only library.
; *
; *
; *   FEATURES:
; *       - Supports all platforms that raylib supports
; *
; *   DEPENDENCIES:
; *       raylib >= v2.5.0 And all of its dependencies
; *
; *   CONFIGURATION:
; *   #define LIBPARTIKEL_IMPLEMENTATION
; *       Generates the implementation of the library into the included file.
; *       If Not defined, the library is in header only mode And can be included in other headers
; *       Or source files without problems. But only ONE file should hold the implementation.
; *
; *   LICENSE: zlib/libpng
; *
; *   libpartikel is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
; *   BSD-like license that allows Static linking With closed source software:
; *
; *   Copyright (c) 2017 David Linus Briemann (@Raging_Dave)
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
;IncludePath "./../../"                  ; First we need to include
XIncludeFile "raylib.pbi"               ; the raylib-purebasic import

EnableExplicit                          ; All variables have to be defined before use

UseModule ray                           ; Import the module

; /**  TODOs
;  *
;  * 0) MAYBE switch To purely function pointer based system.. handle Init, Update, Draw etc.
;  *    all As function pointers And make it possible To use a custom one. See current handling
;  *    of Particle deactivation functions As example.
;  *
;  */

Prototype.rl_bool protoDeactivator(*p)

;-Structure-Types

; Min/Max pair structs For various types.
Structure FloatRange Align #PB_Structure_AlignC
  min.rl_float
  max.rl_float
EndStructure

Structure IntRange Align #PB_Structure_AlignC
  min.rl_int
  max.rl_int
EndStructure

; EmitterConfig type
Structure EmitterConfig Align #PB_Structure_AlignC
  direction.Vector2                       ; Direction vector will be normalized.
  velocity.FloatRange                     ; The possible range of the particle velocities.
                                          ; Velocity is a scalar defining the length of the direction vector.
  directionAngle.FloatRange               ; The angle range modiying the direction vector.
  velocityAngle.FloatRange                ; The angle range to rotate the velocity vector.
  offset.FloatRange                       ; The min and max offset multiplier for the particle origin.
  originAcceleration.FloatRange           ; An acceleration towards or from (centrifugal) the origin.
  burst.IntRange                          ; The range of sudden particle bursts.
  capacity.rl_quad                        ; Maximum amounts of particles in the system.
  emissionRate.rl_quad                    ; Rate of emitted particles per second.
  origin.Vector2                          ; Origin is the source of the emitter.
  externalAcceleration.Vector2            ; External constant acceleration. e.g. gravity.
  startColor.rl_ColorLong                 ; The color the particle starts with when it spawns.
  endColor.rl_ColorLong                   ; The color the particle ends with when it disappears.
  age.FloatRange                          ; Age range of particles in seconds.
  blendMode.rl_uint                       ; Color blending mode for all particles of this Emitter.
  texture.Texture2D                       ; The texture used as particle texture.    

  *particle_Deactivator.protoDeactivator  ; Pointer to a function that determines when
                                          ; a particle is deactivated.
EndStructure


; Particle type

; Particle describes one particle in a particle system.
Structure Particle Align #PB_Structure_AlignC
  origin.Vector2                          ; The origin of the particle (never changes).
  position.Vector2                        ; Position of the particle in 2d space.
  velocity.Vector2                        ; Velocity vector in 2d space.
  externalAcceleration.Vector2            ; Acceleration vector in 2d space.
  originAcceleration.rl_float             ; Accelerates velocity vector
  age.rl_float                            ; Age is measured in seconds.
  ttl.rl_float                            ; Ttl is the time to live in seconds.
  active.rl_bool                          ; Inactive particles are neither updated nor drawn.

  *particle_Deactivator.protoDeactivator  ; Pointer To a function that determines when
                                          ; a particle is deactivated.
EndStructure

; Emitter type.

; Emitter is a single (point) source emitting many particles.
Structure Emitter Align #PB_Structure_AlignC
  config.EmitterConfig
  mustEmit.rl_float             ; Amount of particles To be emitted within Next update call.
  offset.Vector2                ; Offset holds half the width and height of the texture.
  isEmitting.rl_bool
  Array *particles.Particle(0)   ; Array of all particles (by pointer).
EndStructure

; ParticleSystem type.
;>----------------------------------------------------------------------------------
Structure ParticleSystem Align #PB_Structure_AlignC
  active.rl_bool
  length.rl_quad
  capacity.rl_quad
  origin.Vector2
  Array *emitters.Emitter(0)
EndStructure

; Function signatures (comments are found in implementation below)
;>----------------------------------------------------------------------------------
Declare.rl_float GetRandomFloat(min.rl_float, max.rl_float)
Declare NormalizeV2(*result.Vector2, *v.Vector2)
Declare RotateV2(*result.Vector2, *v.Vector2, degrees.rl_float)
Declare.rl_ColorLong LinearFade(c1.rl_ColorLong, c2.rl_ColorLong, fraction.rl_float)

Declare.rl_bool Particle_DeactivatorAge(*p.Particle)
Declare Particle_New(*deactivatorFunc)
Declare Particle_Free(*p.Particle)
Declare Particle_Init(*p.Particle, *cfg.EmitterConfig)
Declare Particle_Update(*p.Particle, dt.rl_float)

Declare Emitter_New(*cfg.EmitterConfig)
Declare.rl_bool Emitter_Reinit(*e.Emitter, *cfg.EmitterConfig)
Declare Emitter_Start(*e.Emitter)
Declare Emitter_Stop(*e.Emitter)
Declare Emitter_Free(*e.Emitter)
Declare Emitter_Burst(*e.Emitter)
Declare.rl_uint Emitter_Update(*e.Emitter, dt.rl_float)
Declare Emitter_Draw(*e.Emitter)

Declare ParticleSystem_New()
Declare.rl_bool ParticleSystem_Register(*ps.ParticleSystem, *emitter.Emitter)
Declare.rl_bool ParticleSystem_Deregister(*ps.ParticleSystem, *emitter.Emitter)
Declare ParticleSystem_SetOrigin(*ps.ParticleSystem, *origin.Vector2)
Declare ParticleSystem_Start(*ps.ParticleSystem)
Declare ParticleSystem_Stop(*ps.ParticleSystem)
Declare ParticleSystem_Burst(*ps.ParticleSystem)
Declare ParticleSystem_Draw(*ps.ParticleSystem)
Declare.rl_int ParticleSystem_Update(*ps.ParticleSystem, dt.rl_float)
Declare ParticleSystem_Free(*p.ParticleSystem)


; Utility functions & structs.
;>----------------------------------------------------------------------------------

#RAND_MAX = 2147483647

; GetRandomFloat returns a random float between 0.0 And 1.0.
Procedure.rl_float GetRandomFloat(min.rl_float, max.rl_float)
  Protected.rl_float range = max - min
  Protected.rl_float n = Random(#RAND_MAX, 0) / #RAND_MAX
  ProcedureReturn n * range + min
EndProcedure

; NormalizeV2 normalizes a 2d Vector And returns its unit vector.
Procedure NormalizeV2(*result.Vector2, *v.Vector2)
  Protected.rl_float len
  
  If *v\x = 0 And *v\y = 0
    *result = *v
  EndIf
  
  len = Sqr(*v\x * *v\x + *v\y * *v\y)
  
  *result\x = *v\x / len
  *result\y = *v\y / len

EndProcedure

Procedure RotateV2(*result.Vector2, *v.Vector2, degrees.rl_float)
  Protected.rl_float rad = degrees * #DEG2RAD
  
  *result\x = Cos(rad) * *v\x - Sin(rad) * *v\y
  *result\y = Sin(rad) * *v\x + Cos(rad) * *v\y

EndProcedure


; LinearFade fades from Color c1 To Color c2. Fraction is a value between 0 And 1.
; The interpolation is linear.
Procedure.rl_ColorLong LinearFade(c1.rl_ColorLong, c2.rl_ColorLong, fraction.rl_float)
  Protected.a newr = Red(c2) - Red(c1) * fraction + Red(c1)
  Protected.a newg = Green(c2) - Green(c1) * fraction + Green(c1)
  Protected.a newb = Blue(c2) - Blue(c1) * fraction + Blue(c1)
  Protected.a newa = Alpha(c2) - Alpha(c1) * fraction + Alpha(c1)

  ProcedureReturn RGBA(newr, newg, newb, newa)
EndProcedure


;-Functions

; Particle_DeactivatorAge is the Default deactivator function that
; disables particles only If their age exceeds their time To live.
Procedure.rl_bool Particle_DeactivatorAge(*p.Particle)
  ProcedureReturn Bool(*p\age > *p\ttl)
EndProcedure

; Particle_new creates a new Particle object.
; The deactivator function may be omitted by passing NULL.
Procedure Particle_New(*deactivatorFunc)
  Protected.Particle *p = AllocateStructure(Particle)
  
  InitVector2(*p\position, 0, 0)
  InitVector2(*p\velocity, 0, 0)
  InitVector2(*p\externalAcceleration, 0, 0)
  *p\originAcceleration = 0
  *p\age = 0
  *p\ttl = 0
  *p\active = #False

  *p\particle_Deactivator = @Particle_DeactivatorAge()

  If *deactivatorFunc <> #Null
    *p\particle_Deactivator = *deactivatorFunc
  EndIf
  
  ProcedureReturn *p

EndProcedure

; Particle_free frees all memory used by the Particle.
Procedure Particle_Free(*p.Particle)
  FreeStructure(*p)
EndProcedure

; Particle_Init inits a particle. It is then ready To be updated And drawn.
Procedure Particle_Init(*p.Particle, *cfg.EmitterConfig)
  *p\age = 0
  *p\origin = *cfg\origin

  ; Get a random angle To find an random velocity.
  Protected.rl_float randa = GetRandomFloat(*cfg\directionAngle\min, *cfg\directionAngle\max)

  ; Rotate base direction With the given angle.
  Protected.Vector2 res 
  RotateV2(@res, *cfg\direction, randa)

  ; Get a random value For velocity range (direction is normalized).
  Protected.rl_float randv = GetRandomFloat(*cfg\velocity\min, *cfg\velocity\max)

  ; Multiply direction With factor To set actual velocity in the Particle.
  InitVector2(*p\velocity, res\x * randv, res\y * randv)

  ; Get a random angle To rotate the velocity vector.
  randa = GetRandomFloat(*cfg\velocityAngle\min, *cfg\velocityAngle\max)

  ; Rotate velocity vector With given angle.
  RotateV2(*p\velocity, *p\velocity, randa)

  ; Get a random value For origin offset And apply it To position.
  Protected.rl_float rando = GetRandomFloat(*cfg\offset\min, *cfg\offset\max)
  *p\position\x = *cfg\origin\x + res\x * rando
  *p\position\y = *cfg\origin\y + res\y * rando

  ; Get a random value For the intrinsic particle acceleration
  Protected.rl_float rands = GetRandomFloat(*cfg\originAcceleration\min, *cfg\originAcceleration\max)
  *p\originAcceleration = rands
  *p\externalAcceleration = *cfg\externalAcceleration
  *p\ttl = GetRandomValue(*cfg\age\min, *cfg\age\max)
  *p\active = #True
EndProcedure

; Particle_update updates all properties according To the delta time (in seconds).
; Deactivates the particle If the deactivator function returns true.
Procedure Particle_Update(*p.Particle, dt.rl_float)
  Protected.Vector2 toOrigin
  InitVector2(@toOrigin, 0, 0)
  
  If Not *p\active
    ProcedureReturn 0
  EndIf
  
  *p\age + dt
  
  If *p\particle_Deactivator(*p)
    *p\active = #False
    ProcedureReturn 0
  EndIf    
  
  toOrigin\x = *p\origin\x - *p\position\x
  toOrigin\y = *p\origin\y - *p\position\y
  
  NormalizeV2(@toOrigin, @toOrigin)
  
  ; Update velocity by internal acceleration.
  *p\velocity\x + toOrigin\x * *p\originAcceleration * dt
  *p\velocity\y + toOrigin\y * *p\originAcceleration * dt
  
  ; Update velocity by external acceleration.
  *p\velocity\x + *p\externalAcceleration\x * dt
  *p\velocity\y + *p\externalAcceleration\y * dt
  
  ; Update position by velocity.
  *p\position\x + *p\velocity\x * dt
  *p\position\y + *p\velocity\y * dt
EndProcedure


; Emitter_New creates a new Emitter object.
Procedure Emitter_New(*cfg.EmitterConfig)
  Protected.rl_uint i
  Protected.Emitter *e
  
  *e = AllocateStructure(Emitter)
  If *e = #Null
    ProcedureReturn #Null
  EndIf
  
  With *e\config 
    \age = *cfg\age
    \blendMode = *cfg\blendMode
    \burst = *cfg\burst
    \capacity = *cfg\capacity
    \direction = *cfg\direction
    \directionAngle = *cfg\directionAngle
    \emissionRate = *cfg\emissionRate
    \endColor = *cfg\endColor
    \externalAcceleration = *cfg\externalAcceleration
    \offset = *cfg\offset
    \origin = *cfg\origin
    \originAcceleration = *cfg\originAcceleration
    \particle_Deactivator = *cfg\particle_Deactivator
    \startColor = *cfg\startColor
    \texture = *cfg\texture
    \velocity = *cfg\velocity
    \velocityAngle = *cfg\velocityAngle
  EndWith
  
  *e\offset\x = *e\config\texture\width / 2
  *e\offset\y = *e\config\texture\height / 2
  
  ReDim *e\particles(*e\config\capacity)  ;calloc(e->config.capacity, SizeOf(Particle *));
  ;*e\particles = AllocateMemory(*e\config\capacity * SizeOf(Particle))
  
  If ArraySize(*e\particles()) = #Null
    FreeStructure(*e)
    ProcedureReturn #Null
  EndIf
  
  *e\mustEmit = 0
  
  ; Normalize direction For future uses.
  NormalizeV2(*e\config\direction, *e\config\direction)
  
  For i = 0 To *e\config\capacity - 1
    *e\particles(i) = Particle_New(*e\config\particle_Deactivator)
  Next
  
  ProcedureReturn *e
  
EndProcedure

; Emitter_Reinit reinits the given Emitter With a new EmitterConfig.
Procedure.rl_bool Emitter_Reinit(*e.Emitter, *cfg.EmitterConfig)
  Protected.rl_uint i
  
  If *cfg\capacity > *e\config\capacity
    ; Array needs To be grown To the new size.
    ReDim *e\particles(*e\config\capacity)
    
    If ArraySize(*e\particles()) = #Null
      ProcedureReturn #False
    EndIf
    
    ; Create new Particles
    For i = *e\config\capacity To *cfg\capacity
      *e\particles(i) = Particle_New(*cfg\particle_Deactivator)
    Next
    
  ElseIf *cfg\capacity < *e\config\capacity
    ; First we free the now obsolete Particles.
    For i = *cfg\capacity To *e\config\capacity
      Particle_Free(*e\particles(i))
    Next
    
    ; Array needs To be shrunk To the new size.
    ReDim *e\particles(*cfg\capacity)
    
    If ArraySize(*e\particles()) = #Null
      ProcedureReturn #False
    EndIf
  EndIf
  
  ; Set new config.
  With *e\config 
    \age = *cfg\age
    \blendMode = *cfg\blendMode
    \burst = *cfg\burst
    \capacity = *cfg\capacity
    \direction = *cfg\direction
    \directionAngle = *cfg\directionAngle
    \emissionRate = *cfg\emissionRate
    \endColor = *cfg\endColor
    \externalAcceleration = *cfg\externalAcceleration
    \offset = *cfg\offset
    \origin = *cfg\origin
    \originAcceleration = *cfg\originAcceleration
    \particle_Deactivator = *cfg\particle_Deactivator
    \startColor = *cfg\startColor
    \texture = *cfg\texture
    \velocity = *cfg\velocity
    \velocityAngle = *cfg\velocityAngle
  EndWith
  
  ; Set new Particle deactivator function For all Particles.
  For i = 0 To *e\config\capacity - 1
    *e\particles(i)\particle_Deactivator = *e\config\particle_Deactivator
  Next
  
  ProcedureReturn #True
EndProcedure

; Emitter_Start activates Particle emission.
Procedure Emitter_Start(*e.Emitter)
  *e\isEmitting = #True
EndProcedure

; Emitter_Start deactivates Particle emission.
Procedure Emitter_Stop(*e.Emitter)
  *e\isEmitting = #False
EndProcedure

; Emitter_Free frees all allocated resources.
Procedure Emitter_Free(*e.Emitter)
  Protected.rl_uint i
  For i = 0 To *e\config\capacity - 1
    Particle_Free(*e\particles(i))
  Next
  FreeArray(*e\particles())
  FreeStructure(*e)
EndProcedure

; Emitter_Burst emits a specified amount of particles at once,
; ignoring the state of e->isEmitting. Use this For singular events
; instead of continuous output.
Procedure Emitter_Burst(*e.Emitter)
  Protected.Particle *p = #Null
  Protected.rl_uint emitted = 0
  Protected.rl_int amount
  Protected.rl_uint i
  
  amount = GetRandomValue(*e\config\burst\min, *e\config\burst\max)

  For i = 0 To *e\config\capacity
    *p = *e\particles(i)
    
    If Not *p\active
      Particle_Init(*p, *e\config)
      *p\position = *e\config\origin
      emitted + 1
    EndIf
            
    If emitted >= amount
      ProcedureReturn 0
    EndIf
  Next
EndProcedure

; Emitter_Update updates all particles And returns
; the current amount of active particles.
Procedure.rl_uint Emitter_Update(*e.Emitter, dt.rl_float)
  Protected.rl_uint emitNow = 0
  Protected.Particle *p = #Null
  Protected.rl_uint counter = 0
  Protected.rl_uint i

  If *e\isEmitting
    *e\mustEmit + dt * *e\config\emissionRate
    emitNow = *e\mustEmit ; floor
  EndIf

  For i = 0 To *e\config\capacity - 1
    *p = *e\particles(i)
    If *p\active
      Particle_Update(*p, dt)
      counter + 1
    ElseIf *e\isEmitting And emitNow > 0
      ; emit new particles here
      Particle_Init(*p, *e\config)
      Particle_Update(*p, dt)
      emitNow - 1
      *e\mustEmit - 1
      counter + 1
    EndIf
  Next

  ProcedureReturn counter
EndProcedure

; Emitter_Draw draws all active particles.
Procedure Emitter_Draw(*e.Emitter)
  Protected.Particle *p
  Protected.rl_uint i
  
  BeginBlendMode(*e\config\blendMode)
  For i = 0 To *e\config\capacity - 1
    *p = *e\particles(i)
    If *p\active
      DrawTexture(*e\config\texture,
                  *e\particles(i)\position\x - *e\offset\x,
                  *e\particles(i)\position\y - *e\offset\y,
                  LinearFade(*e\config\startColor, *e\config\endColor, *p\age / *p\ttl))
    EndIf
  Next
  EndBlendMode()
EndProcedure


; ParticleSystem is a set of emitters grouped logically
; together To achieve a specific visual effect.
; While Emitters can be used independently, ParticleSystem
; offers some convenience For handling many Emitters at once.


; Particlesystem_New creates a new particle system
; With the given amount of emitters.
Procedure ParticleSystem_New()
  Protected.ParticleSystem *ps = AllocateStructure(ParticleSystem)
  
  If *ps = #Null
    ProcedureReturn #Null
  EndIf
  
  *ps\active = #False
  *ps\length = 0
  *ps\capacity = 1
  InitVector2(*ps\origin, 0, 0)
  
  ReDim *ps\emitters(*ps\capacity)
  
  If ArraySize(*ps\emitters()) = #Null
    FreeStructure(*ps)
    ProcedureReturn #Null
  EndIf
  
  ProcedureReturn *ps

EndProcedure

; ParticleSystem_Register registers an emitter To the system.
; The emitter will be controlled by all particle system functions.
; Returns true on success And false otherwise.
Procedure.rl_bool ParticleSystem_Register(*ps.ParticleSystem, *emitter.Emitter)
  
  ; If there is no space For another emitter we have To realloc.
  If *ps\length >= *ps\capacity
    ; Double capacity.
    
    ReDim *ps\emitters(2 * *ps\capacity)
    
    If ArraySize(*ps\emitters()) = #Null
      ProcedureReturn #False
    EndIf

    *ps\capacity * 2
  EndIf

  ; Now the new Emitter can be registered.
  *ps\emitters(*ps\length) = *emitter
  *ps\length + 1

  ProcedureReturn #True
EndProcedure

; ParticleSystem_Deregister deregisters an Emitter by its pointer.
; Returns true on success And false otherwise.
Procedure.rl_bool ParticleSystem_Deregister(*ps.ParticleSystem, *emitter.Emitter)
  Protected.rl_uint i
  
  For i = 0 To *ps\length - 1
    If *ps\emitters(i) = *emitter
      ; Remove this emitter by replacing its pointer With the
      ; last pointer, If it is Not the only Emitter.
      If i <> *ps\length - 1
        *ps\emitters(i) = *ps\emitters(*ps\length - 1)
      EndIf
      ; Then NULL the last emitter. It is either a duplicate Or
      ; the removed one.
      *ps\length - 1
      *ps\emitters(*ps\length) = #Null
      ProcedureReturn #True
    EndIf
  Next
  
  ; Emitter Not found.
  ProcedureReturn #False
EndProcedure

; ParticleSystem_SetOrigin sets the origin For all registered Emitters.
Procedure ParticleSystem_SetOrigin(*ps.ParticleSystem, *origin.Vector2)
  Protected.rl_uint i
  
  InitVector2(*ps\origin, *origin\x, *origin\y)
  
  For i = 0 To *ps\length - 1
    InitVector2(*ps\emitters(i)\config\origin, *origin\x, *origin\y)
  Next
EndProcedure

; ParticleSystem_Start runs Emitter_Start on all registered Emitters.
Procedure ParticleSystem_Start(*ps.ParticleSystem)
  Protected.rl_uint i
  
  For i = 0 To *ps\length - 1
    Emitter_Start(*ps\emitters(i))
  Next
EndProcedure

; ParticleSystem_Stop runs Emitter_Stop on all registered Emitters.
Procedure ParticleSystem_Stop(*ps.ParticleSystem)
  Protected.rl_uint i
  
  For i = 0 To *ps\length - 1
    Emitter_Stop(*ps\emitters(i))
  Next
EndProcedure

; ParticleSystem_Burst runs Emitter_Burst on all registered Emitters.
Procedure ParticleSystem_Burst(*ps.ParticleSystem)
  Protected.rl_uint i
  
  For i = 0 To *ps\length - 1
    Emitter_Burst(*ps\emitters(i))
  Next
EndProcedure

; ParticleSystem_Draw runs Emitter_Draw on all registered Emitters.
Procedure ParticleSystem_Draw(*ps.ParticleSystem)
  Protected.rl_uint i
  
  For i = 0 To *ps\length - 1
    Emitter_Draw(*ps\emitters(i))
  Next
EndProcedure

; ParticleSystem_Update runs Emitter_Update on all registered Emitters.
Procedure.rl_uint ParticleSystem_Update(*ps.ParticleSystem, dt.rl_float)
  Protected.rl_uint counter = 0, i
  
  For i = 0 To *ps\length - 1
    counter + Emitter_Update(*ps\emitters(i), dt)
  Next
  
  ProcedureReturn counter
EndProcedure

; ParticleSystem_Free only frees its own resources.
; The emitters referenced here must be freed on their own.
Procedure ParticleSystem_Free(*ps.ParticleSystem)
  FreeArray(*ps\emitters())
  FreeStructure(*ps)
EndProcedure
  
  
; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 179
; FirstLine = 165
; Folding = -----
; Optimizer
; EnableThread
; EnableXP
; Compiler = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)