
proc colorPrint { msg colour { bg black } } {
  return  "[getColour $colour]$msg[getColour $bg]"
}

proc getColour {colour {background False}} {
    set colourArr(black)       "0;30"
    set colourArr(blue)        "0;34"
    set colourArr(blueLight)   "1;34"
    set colourArr(brown)       "0;33"
    set colourArr(cyan)        "0;36"
    set colourArr(cyanLight)   "1;36"
    set colourArr(grayDark)    "1;30"
    set colourArr(grayLight)   "0;37"
    set colourArr(green)       "0;32"
    set colourArr(greenLight)  "1;32"
    set colourArr(nothing)     "0"
    set colourArr(purple)      "0;35"
    set colourArr(purpleLight) "1;35"
    set colourArr(red)         "0;31"
    set colourArr(redLight)    "1;31"
    set colourArr(white)       "1;37"
    set colourArr(yellow)      "1;33"
    set colourEnd              "m\002"
    set colourStart            "\001\033\["

    if {$colour eq "names"} {
        return [lsort [array names colourArr]]
    }
    if {! [info exist colourArr($colour)]} {
        error [format "ERROR: %s got a non existing colour (%s)" \
                   [getProcName] $colour]
    }
    set colourCode $colourArr($colour)
    # No need to check for nothing, replace out of range does nothing.
    if {$background} {
        set colourCode [string replace $colourCode 2 2 4]
    }
    return "$colourStart$colourCode$colourEnd"
}

proc colorTest { } {
   puts stdout [colorPrint "test a red line" red]
   puts stdout [colorPrint "test a blue line" blue]
   puts stdout [colorPrint "test a green line" green]
}




