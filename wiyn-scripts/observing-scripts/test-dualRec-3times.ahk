SetKeyDelay 100,500
WinActivate, Andor SOLIS for Imaging: X-10244
Send {F5}
i=1
While (i<3)
{
	ControlGet,OutVar,Enabled,OWL_Window
	If(OutVar=1)
	{
    sleep,1000
	MsgBox, %OutVar%
	i=i++
	Send {F5}
	}
	else
	{
	sleep,1000
	}
}

MsgBox, 3/3 Sequence done