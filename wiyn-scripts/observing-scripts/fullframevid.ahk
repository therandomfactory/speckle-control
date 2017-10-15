WinActivate, Andor SOLIS for Imaging: X-10331
SetControlDelay, 20
SetKeyDelay, 10, 20
Send {Esc}							; halt video mode (if on)
sleep,100
Send ^q								; open acquisition set-up
sleep,100
Send {tab}{tab}{tab}				; need to activate tabs
sleep,500
Send {Left}{Left}{Left}{Left}{Left}{Left}{Left}	; tab all the way to the left to Setup
sleep,500
Control, Choose, 4, TComboBox14, Acquisition Setup  ;set to 30Mhz
Control, Choose, 4, TComboBox6, Acquisition Setup   ;set to 30MHz, need both lines bc ClassNN is dynamic
Send {Ctrl Down}{tab}{Ctrl Up}		; ctrl tab once to the right to select 'Binning'
sleep,500
SetControlDelay, -1
ControlClick, TRadioButton11, Acquisition Setup ; select the fullframe radio button
sleep,500
Send {Enter}						; click default button on dialog box which is 'OK'
sleep,100
Send {F3}							; start video

; copy everything from above but for X-10330 camera below

WinActivate, Andor SOLIS for Imaging: X-10330
sleep,100
SetControlDelay, 20
SetKeyDelay, 10, 20
Send {Esc}							; halt video mode (if on)
sleep,100
Send ^q								; open acquisition set-up
sleep,100
Send {tab}{tab}{tab}				; need to activate tabs
sleep,500
Send {Left}{Left}{Left}{Left}{Left}{Left}{Left}	; tab all the way to the left to Setup
sleep,500
Control, Choose, 4, TComboBox14, Acquisition Setup  ;set to 30Mhz
Control, Choose, 4, TComboBox6, Acquisition Setup   ;set to 30MHz, need both lines bc ClassNN is dynamic
Send {Ctrl Down}{tab}{Ctrl Up}		; ctrl tab once to the right to select 'Binning'
sleep,500
SetControlDelay, -1
ControlClick, TRadioButton11, Acquisition Setup ; select the fullframe radio button
sleep,500
Send {Enter}						; click default button on dialog box which is 'OK'
sleep,100
Send {F3}							; start video


