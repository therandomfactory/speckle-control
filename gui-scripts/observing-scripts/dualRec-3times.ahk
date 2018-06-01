SetKeyDelay 100,500
WinActivate, Andor SOLIS for Imaging: X-10331
Send {F5}							; start recording

; copy everything from above but for X-10330 camera below

WinActivate, Andor SOLIS for Imaging: X-10330
Send {F5}							; start recording

sleep,50000
MsgBox,,, 1/3 Sequence done,2

WinActivate, Andor SOLIS for Imaging: X-10331
Send {F5}							; start recording

; copy everything from above but for X-10330 camera below

WinActivate, Andor SOLIS for Imaging: X-10330
Send {F5}							; start recording

sleep,50000
MsgBox,,, 2/3 Sequence done,2

WinActivate, Andor SOLIS for Imaging: X-10331
Send {F5}							; start recording

; copy everything from above but for X-10330 camera below

WinActivate, Andor SOLIS for Imaging: X-10330
Send {F5}							; start recording

sleep,52000
MsgBox, 3/3 Sequence done