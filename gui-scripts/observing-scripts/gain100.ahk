WinActivate, Andor SOLIS for Imaging: X-10331
SetControlDelay, 20
SetKeyDelay, 20, 20
Send {Esc}							; halt video mode (if on)
sleep,100
Send ^q								; open acquisition set-up
sleep,100
Send {tab}{tab}{tab}				; need to activate tabs
sleep,500
Send {Left}{Left}{Left}{Left}{Left}{Left}{Left}	; tab all the way to the left to Setup
sleep,500
SetControlDelay, -1
ControlClick, TEdit1, Acquisition Setup
SetControlDelay, 20
sleep,500
ControlSend, TEdit1, {Backspace 8}{Del 8}100{enter}, Acquisition Setup		; set gain hit enter
sleep,500
Send {F3}							; start video
sleep,100

; copy everything from above but for X-10330 camera below

WinActivate, Andor SOLIS for Imaging: X-10330
Send {Esc}							; halt video mode (if on)
sleep,100
Send ^q								; open acquisition set-up
sleep,100
Send {tab}{tab}{tab}				; need to activate tabs
sleep,500
Send {Left}{Left}{Left}{Left}{Left}{Left}{Left}	; tab all the way to the left to Setup
sleep,500
SetControlDelay, -1
ControlClick, TEdit1, Acquisition Setup
SetControlDelay, 20
sleep,500
ControlSend, TEdit1, {Backspace 8}{Del 8}100{enter}, Acquisition Setup		; set gain hit enter
sleep,500
Send {F3}							; start video