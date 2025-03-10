;reasing.pbi

;Declare
Declare.f EaseLinearNone(t.f, b.f, c.f, d.f) ; Ease: Linear
Declare.f EaseLinearIn(t.f, b.f, c.f, d.f)   ; Ease: Linear In
Declare.f EaseLinearOut(t.f, b.f, c.f, d.f)  ; Ease: Linear Out
Declare.f EaseLinearInOut(t.f, b.f, c.f, d.f); Ease: Linear In Out
Declare.f EaseSineIn(t.f, b.f, c.f, d.f)     ; Ease: Sine In
Declare.f EaseSineOut(t.f, b.f, c.f, d.f)    ; Ease: Sine Out
Declare.f EaseSineInOut(t.f, b.f, c.f, d.f)  ; Ease: Sine In Out
Declare.f EaseCircIn(t.f, b.f, c.f, d.f)     ; Ease: Circular In
Declare.f EaseCircOut(t.f, b.f, c.f, d.f)    ; Ease: Circular Out
Declare.f EaseCircInOut(t.f, b.f, c.f, d.f)  ; Ease: Circular In Out
Declare.f EaseCubicIn(t.f, b.f, c.f, d.f)    ; Ease: Cubic In
Declare.f EaseCubicOut(t.f, b.f, c.f, d.f)   ; Ease: Cubic Out
Declare.f EaseCubicInOut(t.f, b.f, c.f, d.f) ; Ease: Cubic In Out
Declare.f EaseQuadIn(t.f, b.f, c.f, d.f)     ; Ease: Quadratic In
Declare.f EaseQuadOut(t.f, b.f, c.f, d.f)    ; Ease: Quadratic Out
Declare.f EaseQuadInOut(t.f, b.f, c.f, d.f)  ; Ease: Quadratic In Out
Declare.f EaseExpoIn(t.f, b.f, c.f, d.f)     ; Ease: Exponential In
Declare.f EaseExpoOut(t.f, b.f, c.f, d.f)    ; Ease: Exponential Out
Declare.f EaseExpoInOut(t.f, b.f, c.f, d.f)  ; Ease: Exponential In Out
Declare.f EaseBackIn(t.f, b.f, c.f, d.f)     ; Ease: Back In
Declare.f EaseBackOut(t.f, b.f, c.f, d.f)    ; Ease: Back Out
Declare.f EaseBackInOut(t.f, b.f, c.f, d.f)  ; Ease: Back In Out
Declare.f EaseBounceIn(t.f, b.f, c.f, d.f)   ; Ease: Bounce In
Declare.f EaseBounceOut(t.f, b.f, c.f, d.f)  ; Ease: Bounce Out
Declare.f EaseBounceInOut(t.f, b.f, c.f, d.f); Ease: Bounce In Out
Declare.f EaseElasticIn(t.f, b.f, c.f, d.f)  ; Ease: Elastic In
Declare.f EaseElasticOut(t.f, b.f, c.f, d.f) ; Ease: Elastic Out
Declare.f EaseElasticInOut(t.f, b.f, c.f, d.f) ; Ease: Elastic In Out


; Linear Easing functions
Procedure.f EaseLinearNone(t.f, b.f, c.f, d.f) ; Ease: Linear
  ProcedureReturn (c * t / d + b)
EndProcedure
  
Procedure.f EaseLinearIn(t.f, b.f, c.f, d.f) ; Ease: Linear In
  ProcedureReturn (c * t / d + b)
EndProcedure

Procedure.f EaseLinearOut(t.f, b.f, c.f, d.f) ; Ease: Linear Out
  ProcedureReturn (c * t / d + b)
EndProcedure  
  
Procedure.f EaseLinearInOut(t.f, b.f, c.f, d.f) ; Ease: Linear In Out
  ProcedureReturn (c * t / d + b)
EndProcedure

; Sine Easing functions
Procedure.f EaseSineIn(t.f, b.f, c.f, d.f) ; Ease: Sine In
  ProcedureReturn (-c * Cos(t / d * (#PI / 2.0)) + c + b) 
EndProcedure
  
Procedure.f EaseSineOut(t.f, b.f, c.f, d.f) ; Ease: Sine Out
  ProcedureReturn (c * Sin(t / d * (#PI / 2.0)) + b)
EndProcedure

Procedure.f EaseSineInOut(t.f, b.f, c.f, d.f) ; Ease: Sine In Out
  ProcedureReturn (-c / 2.0 * (Cos(#PI * t / d) - 1.0) + b)      
EndProcedure

; Circular Easing functions
Procedure.f EaseCircIn(t.f, b.f, c.f, d.f) ; Ease: Circular In
  t / d 
  ProcedureReturn (-c * (Sqr(1.0 - t * t) - 1.0) + b)
EndProcedure
  
Procedure.f EaseCircOut(t.f, b.f, c.f, d.f) ; Ease: Circular Out
  t = t / d - 1.0 
  ProcedureReturn (c * Sqr(1.0 - t * t) + b)
EndProcedure

Procedure.f EaseCircInOut(t.f, b.f, c.f, d.f) ; Ease: Circular In Out
  t / d / 2.0
  If t < 1.0
    ProcedureReturn (-c / 2.0 * (Sqr(1.0 - t * t) - 1.0) + b)
  EndIf
  t - 2.0
  ProcedureReturn (c / 2.0 * (Sqr(1.0 - t * t) + 1.0) + b)
EndProcedure

; Cubic Easing functions
Procedure.f EaseCubicIn(t.f, b.f, c.f, d.f) ; Ease: Cubic In
  t / d 
  ProcedureReturn (c * t * t * t + b)
EndProcedure

Procedure.f EaseCubicOut(t.f, b.f, c.f, d.f) ; Ease: Cubic Out
  t = t / d - 1.0
  ProcedureReturn (c * (t * t * t + 1.0) + b)    
EndProcedure
  
Procedure.f EaseCubicInOut(t.f, b.f, c.f, d.f) ; Ease: Cubic In Out
  t / d / 2.0
  If t < 1.0
    ProcedureReturn (c / 2.0 * t * t * t + b)
  EndIf
  t - 2.0 
  ProcedureReturn (c / 2.0 * (t * t * t + 2.0) + b)
EndProcedure

; Quadratic Easing functions
Procedure.f EaseQuadIn(t.f, b.f, c.f, d.f) ; Ease: Quadratic In
  t / d 
  ProcedureReturn (c * t * t + b)
EndProcedure

Procedure.f EaseQuadOut(t.f, b.f, c.f, d.f) ; Ease: Quadratic Out
  t / d 
  ProcedureReturn (-c * t * (t - 2.0) + b)
EndProcedure
  
Procedure.f EaseQuadInOut(t.f, b.f, c.f, d.f) ; Ease: Quadratic In Out
  t / d / 2
  If t < 1 
    ProcedureReturn ((c / 2) * (t * t)) + b
  EndIf
  ProcedureReturn (-c / 2.0 * (((t - 1.0) * (t - 3.0)) - 1.0) + b)
EndProcedure

; Exponential Easing functions
Procedure.f EaseExpoIn(t.f, b.f, c.f, d.f) ; Ease: Exponential In
  If t = 0
    ProcedureReturn b
  Else
    ProcedureReturn (c * Pow(2.0, 10.0 * (t / d - 1.0)) + b)
  EndIf 
EndProcedure
  
Procedure.f EaseExpoOut(t.f, b.f, c.f, d.f) ; Ease: Exponential Out
  If t = d
    ProcedureReturn (b + c)
  Else
    ProcedureReturn (c * (-Pow(2.0, -10.0 * t / d) + 1.0) + b)
  EndIf
EndProcedure
  
Procedure.f EaseExpoInOut(t.f, b.f, c.f, d.f) ; Ease: Exponential In Out
  If t = 0 
    ProcedureReturn b
  EndIf
  
  If t = d 
    ProcedureReturn (b + c)
  EndIf
  
  t / d / 2.0
  If t < 1.0 
    ProcedureReturn (c / 2.0 * Pow(2.0, 10.0 * (t - 1.0)) + b)
  EndIf

  ProcedureReturn (c / 2.0 * (-Pow(2.0, -10.0 * (t - 1.0)) + 2.0) + b)
EndProcedure

; Back Easing functions
Procedure.f EaseBackIn(t.f, b.f, c.f, d.f) ; Ease: Back In
  Protected.f s = 1.70158
  t / d
  Protected.f postFix = t
  
  ProcedureReturn (c * (postFix) * t * ((s + 1.0) * t - s) + b)
EndProcedure

Procedure.f EaseBackOut(t.f, b.f, c.f, d.f) ; Ease: Back Out
  Protected.f s = 1.70158
  t = t / d - 1.0
  ProcedureReturn (c * (t * t * ((s + 1.0) * t + s) + 1.0) + b)
EndProcedure

Procedure.f EaseBackInOut(t.f, b.f, c.f, d.f) ; Ease: Back In Out
  Protected.f s = 1.70158
  Protected.f postFix
  
  t / d / 2.0
  
  If t < 1.0
    s * 1.525
    ProcedureReturn (c / 2.0 * (t * t * ((s + 1.0) * t - s)) + b)
  EndIf
  
  t - 2.0
  
  postFix = t
  
  s * 1.525
  
  ProcedureReturn (c / 2.0 * ((postFix) * t * ((s + 1.0) * t + s) + 2.0) + b)
EndProcedure

; Bounce Easing functions
Procedure.f EaseBounceIn(t.f, b.f, c.f, d.f) ; Ease: Bounce In
  ProcedureReturn (c - EaseBounceOut(d - t, 0.9, c, d) + b)
EndProcedure

Procedure.f EaseBounceOut(t.f, b.f, c.f, d.f) ; Ease: Bounce Out
  Protected.f postFix
  
  t / d
  
  If t < (1.0 / 2.75)
    ProcedureReturn (c * (7.5625 * t * t) + b)
  ElseIf t < (2.0 / 2.75)
    t - (1.5 / 2.75)
    postFix = t
    ProcedureReturn (c * (7.5625 * (postFix) * t + 0.75) + b)
  ElseIf t < (2.5 / 2.75)
    t - (2.25 / 2.75)
    postFix = t
    ProcedureReturn (c * (7.5625 * (postFix) * t + 0.9375) + b)
  Else
    t - (2.625 / 2.75)
    postFix = t
    ProcedureReturn (c * (7.5625 * (postFix) * t + 0.984375) + b)
  EndIf
EndProcedure

Procedure.f EaseBounceInOut(t.f, b.f, c.f, d.f) ; Ease: Bounce In Out
  If t < (d / 2.0) 
    ProcedureReturn (EaseBounceIn(t * 2.0, 0.0, c, d) * 0.5 + b)
  Else 
    ProcedureReturn (EaseBounceOut(t * 2.0 - d, 0.0, c, d) * 0.5 + c * 0.5 + b)
  EndIf
EndProcedure

; Elastic Easing functions
Procedure.f EaseElasticIn(t.f, b.f, c.f, d.f) ; Ease: Elastic In
  Protected.f p, a, s, postFix
  
  If t = 0
    ProcedureReturn b
  EndIf
  
  t / d
  If t = 1.0
    ProcedureReturn (b + c)
  EndIf

  p = d * 0.3
  a = c
  s = p / 4.0
  
  t - 1.0
  postFix = a * Pow(2.0, 10.0 * t)

  ProcedureReturn (-(postFix * Sin((t * d - s) * (2.0 * #PI) / p )) + b)
EndProcedure

Procedure.f EaseElasticOut(t.f, b.f, c.f, d.f) ; Ease: Elastic Out
  Protected.f p, a, s
  
  If t = 0
    ProcedureReturn b
  EndIf
  
  t / d
  If t = 1.0
    ProcedureReturn (b + c)
  EndIf

  p = d * 0.3
  a = c
  s = p / 4.0

  ProcedureReturn (a * Pow(2.0, -10.0 * t) * Sin((t * d - s) * (2.0 * #PI) / p) + c + b)
EndProcedure

Procedure.f EaseElasticInOut(t.f, b.f, c.f, d.f) ; Ease: Elastic In Out
  Protected.f p, a, s, postFix
  
  If t = 0
    ProcedureReturn b
  EndIf
  
  t / d / 2.0
  If t = 2.0
    ProcedureReturn (b + c)
  EndIf

  p = d * (0.3 * 1.5)
  a = c
  s = p / 4.0

  If t < 1.0
    t - 1.0
    postFix = a * Pow(2.0, 10.0 * t)
    ProcedureReturn -0.5 * (postFix * Sin((t * d - s) * (2.0 * #PI) / p)) + b
  EndIf
  
  t - 1.0
  postFix = a * Pow(2.0, -10.0 * t)

  ProcedureReturn (postFix * Sin((t * d - s) * (2.0 * #PI) / p) * 0.5 + c + b)
EndProcedure

; IDE Options = PureBasic 6.00 LTS - C Backend (MacOS X - arm64)
; CursorPosition = 25
; Folding = -----
; Optimizer
; EnableThread
; EnableXP