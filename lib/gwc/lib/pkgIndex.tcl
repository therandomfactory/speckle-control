set ext so
set OS [ exec uname ]

if { $OS == "Darwin" } {
set ext dylib    
}

package ifneeded GWC 2.71 [list source [file join $dir GWC.tcl]]
package ifneeded gwc 2.71 [list load [file join $dir libgwc.$ext]]
package ifneeded msg 2.71 [list load [file join $dir libmsg.$ext]]
package ifneeded names 2.71 [list load [file join $dir libnames.$ext]]
