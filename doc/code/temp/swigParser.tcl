#!/usr/bin/tclsh
#
#  Scan for  _wrap_[type]*Get*Image*( where type can be any Andor image access function
#  Foreach scan for "  std::vector< uint16_t > data2 ;"
#  and then add
#"
#  int nx, ny;
#  std::vector<uint16_t/uint32_t> pImageData;
#  unsigned short/int *pccdData;
#"
#
#  then scan for and replace e.g.
#       result = (unsigned int)GetMostRecentImage(arg1,arg2);
#  with 
#"
#       nx = arg1;
#       ny = arg2;
#       pccdData = (unsigned short *)CCD_locate_buffer("tempobs", 2 , nx, ny, 1, 1 );
#       result = (unsigned int)GetMostRecentImage(pImageData,arg1*arg2);
#       copy(pImageData.begin(), pImageData.end(), pccdData);
#"
#
#
puts stdout "Editing  andorWrap.cpp"
set fin [open  andorWrap.cpp r]
set fout [open  andorWrap.cpp.modded w]
while { [gets $fin rec] > -1 } {
   set doit 0
   if { [string range $rec 0 24] == "_wrap_GetMostRecentImage(" } {
       set doit 1, set typ uint32_t;
       set match "result = (unsigned int)GetMostRecentImage(arg1,arg2);"
   }
   if { [string range $rec 0 26] == "_wrap_GetMostRecentImage16(" } {
       set doit 1; set typ uint16_t
       set match "result = (unsigned int)GetMostRecentImage16(arg1,arg2);"
   }
   if { [string range $rec 0 20] == "_wrap_GetOldestImage(" } {
       set doit 1, set typ uint32_t
       set match "result = (unsigned int)GetOldestImage(arg1,arg2);"
   }
   if { [string range $rec 0 22] == "_wrap_GetOldestImage16(" } {
       set doit 1; set typ uint16_t
       set match "result = (unsigned int)GetOldestImage16(arg1,arg2);"
   }
   if { $doit } {
      puts stdout "    Processing [lindex [split $rec (] 0]"
      puts $fout $rec
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      puts $fout "  int nx, ny;
  std::vector<[set type]> pImageData;
  [set type] *pccdData;
  char tbuffer\[8\];"
      gets $fin rec
      while { [string trim $rec] != $match } {
         puts $fout $rec ; gets $fin rec
      }
      puts $fout "       nx = arg1;
       ny = arg2;
       strcpy(tbuffer,\"tempobs\");
       pccdData = ([set type] *)CCD_locate_buffer(tbuffer, sizeof([set typ]) , nx, ny, 1, 1 );
       result = (unsigned int)GetMostRecentImage(pImageData,nx*ny);
       copy(pImageData.begin(), pImageData.end(), pccdData);"
   } else {
      puts $fout $rec
   }
   if { [string trim $rec] == "#define SWIGTCL" } {
      puts $fout "#include \"tcl.h\""
      puts $fout "#include \"ccd.h\""
   }
}

close $fin
close $fout
exec mv  andorWrap.cpp  andorWrap.cpp.original
exec mv  andorWrap.cpp.modded  andorWrap.cpp

puts stdout "Original moved to  andorWrap.cpp.original"

