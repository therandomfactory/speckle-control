#!/usr/bin/tclsh

proc gdbdump { name pid } { 
  exec sudo /home/speckle/speckle-control/debug/gdbdump $name $pid
}


set procs [split [exec ps axw] "\n"]
set pids 1
foreach l $procs {
  if { [lsearch $l "/usr/bin/wish"] > -1 } {
    if { [lindex $l 5] == "/home/speckle/speckle-control/andor/andorCameraServer.tcl" } {
      set PID($pids) [lindex $l 0]
      incr pids 1
    }
  }
}


if { [info exists PID(1)] } {
  puts stdout "Found cameraServer $PID(1)"
  catch {gdbdump /usr/bin/wish $PID(1)}
}

if { [info exists PID(2)] } {
  puts stdout "Found cameraServer $PID(2)"
  catch {gdbdump /usr/bin/wish $PID(2)}
}

set logs [split [exec ls /tmp] "\n"]
set lblue "none"
set lred "none"
set mlog "none"

exec mkdir -p /tmp/speckleDiagnostics
foreach l $logs {
  if { [string range $l 0 11] == "speckle_blue" } { 
    set lblue $l
  }
  if { [string range $l 0 10] == "speckle_red" } {
    set lred $l
  }
  if { [string range $l 0 9] == "speckleLog" } {
    set mlog $l
  }
}

if { [file exists /tmp/$lblue] } {
    exec cp /tmp/$lblue /tmp/speckleDiagnostics/.
}
if { [file exists /tmp/$lred] } {
    exec cp /tmp/$lred /tmp/speckleDiagnostics/.
}
if { [file exists /tmp/$mlog] } {
    exec cp /tmp/$mlog /tmp/speckleDiagnostics/.
}

if { [file exists /tmp/gdbdump.$PID(1)] } {
  exec cat /tmp/gdbdump.$PID(1) > /tmp/speckleDiagnostics/gdbdump.$PID(1)
}

if { [file exists /tmp/gdbdump.$PID(2)] } {
  exec cat /tmp/gdbdump.$PID(2) > /tmp/speckleDiagnostics/gdbdump.$PID(2)
}

cd /tmp
set dname /tmp/speckleDiagnostics_[clock seconds].tar.gz
exec tar cvzf $dname ./speckleDiagnostics
puts stdout "Saved diagnostics to $dname"



