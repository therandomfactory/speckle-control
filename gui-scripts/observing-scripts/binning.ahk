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
Control, Choose, 3, TComboBox14, Acquisition Setup  ;set to 20Mhz
Control, Choose, 3, TComboBox6, Acquisition Setup   ;set to 20MHz, need both lines bc ClassNN is dynamic
Send {Ctrl Down}{tab}{Ctrl Up}		; ctrl tab once to the right to select 'Binning'
sleep,500
SetControlDelay, -1
ControlClick, TRadioButton9, Acquisition Setup				; select the 256x256 radio button
SetControlDelay, 20
sleep,100

; copy everything from above but for X-10330 camera below

WinActivate, Andor SOLIS for Imaging: X-10330
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
Control, Choose, 3, TComboBox14, Acquisition Setup  ;set to 20Mhz
Control, Choose, 3, TComboBox6, Acquisition Setup   ;set to 20MHz, need both lines bc ClassNN is dynamic
Send {Ctrl Down}{tab}{Ctrl Up}		; ctrl tab once to the right to select 'Binning'
sleep,500
SetControlDelay, -1
ControlClick, TRadioButton9, Acquisition Setup				; select the 256x256 radio button
SetControlDelay, 20
sleep,100


