proc postProcess { fname } {
  sendToArchive $fname
}


proc sendToArchive { fname } {
  if { [file exists $fname] } {
     if { [file exists /bits/bin/postproc] } {
        if { [file executable /bits/bin/postproc] } {
            debuglog "Queueing $fname for archiving"
            catch {exec /bits/bin/postproc $fname} result
        } else {
            set result "ERROR /bits/bin/postproc not executable"
        }
     } else {
        set result "ERROR /bits/bin/postproc not found"
     }
  } else {
     set result "ERROR Image not found : $fname"
  }
  debuglog "postProcess: $result"
  return $result
}
