#!/usr/bin/python2

"""
Example/test scripts for autosetting EM gain and testing count levels
for Andor Ixon Ultra 888 cameras.
"""

from __future__ import print_function
import sys

targetRange = [0.25,0.75] #aim for peak in this fraction of saturation level.
potentialSaturation = 0.98 #if > this fraction of saturation, you might be saturated.

def readlookups(tablename):
    
    """
    Reads ascii lookup table with EM gain, saturation value pairs,
    returns two lists (em gain values, saturation levels) that are
    sorted by increasing em gain value.
    """
    
    try:
        fh = open(tablename, 'r')
    except IOError:
        sys.exit("can't open {}".format(tablename))

    gain = []
    saturation = []
    for line in fh:
        if not line.startswith('#'):
            cols = line.rstrip().split()
            gain.append(float(cols[0]))
            saturation.append(float(cols[1]))
    fh.close()
    #make certain table rows are sorted by increasing gain:
    gain,saturation = zip(*sorted(zip(gain,saturation)))
    return(gain, saturation)


def adviseEMGain(currentGain, currentPeak, g, sat):

    """
    Given current EM gain setting, current peak counts and the
    lookup table for current camera settings, returns an advised EM gain
    setting, predicted peak counts at that setting and advisory message.
    """
    
    msg1 = "Set gain={:.0f} for peak flux of {:.0f}, which is {:.0f}% of saturation."
    msg2 = "Even with gain={:.0f}, peak flux will be {:.0f}, which is saturating."
    msg3 = "Currently saturating, try resetting gain={:.0f} before re-measuring peak."
    advisedGain = None
    predictedPeak = None
    targetLevel = 0.5*(targetRange[0]+targetRange[1])

    #If peak counts start out saturated try cutting gain down
    if currentPeak >= potentialSaturation*sat[g.index(currentGain)]:
        advisedGain = max(1,int(currentGain/10.))
        if currentGain > 1:
            msg = msg3.format(advisedGain)
        else:
            msg = "Currently saturating."
        return(advisedGain, predictedPeak, msg)

    #Predict peak counts over range of em gains, starting at max.  Stop at a maximum
    #em gain for which predicted peak counts is less than the target level.  If this
    #em gain is not the maximum (ie. 1000), advise user to adjust to best gain setting.
    #In the end, you might reach em gain of 1 (disabled).  If the peak counts are still
    #expected to saturate, advise user.  Otherwise, operate with gain disabled.
    for i in range(len(g)-1, -1, -1):

        peakThisGain = (g[i]/currentGain)*currentPeak

        if 0 < i <= (len(g)-1) and peakThisGain < sat[i]*targetLevel:
            
            advisedGain = int(g[i])
            predictedPeak = peakThisGain
            
            if currentGain < g[-1]:
                msg = msg1.format(g[i], peakThisGain, 100*peakThisGain/sat[i])
            else:
                msg = "Current setting is okay."
            break

        elif i == 0:

            predictedPeak = peakThisGain

            if peakThisGain >= sat[i]:
                msg = msg2.format(g[i], peakThisGain)
            else:
                advisedGain = int(g[i])
                msg = msg1.format(g[i], peakThisGain, 100*peakThisGain/sat[i])
                if peakThisGain > sat[i]*targetLevel:
                    msg += " While not saturating, the exposure level is high."

    return(advisedGain, predictedPeak, msg)

def checkEMGain(currentGain, currentPeak, g, sat):

    """
    Given current EM gain setting, current peak counts and the
    lookup table for current camera settings, returns 0 if either 
    the peak counts lie withing a target range or the peak 
    counts lie below the target range but the em gain is maxed out.
    Returns -1 if the peak counts lie below the target range and
    the em gain can be increased.  Returns 1 if the peak counts
    lie above the target range.
    """

    currentSat = float(sat[g.index(currentGain)])

    if targetRange[0] <= currentPeak/currentSat <= targetRange[1]:
        return 0
    elif currentPeak/currentSat < targetRange[0]:
        if currentGain == g[-1]:
            return 0
        else:
            return -1
    elif currentPeak/currentSat > targetRange[1]:
        return 1
    

if __name__ == '__main__':

    g, sat = readlookups(sys.argv[1])
    
    gain = int(sys.argv[2])

    peak = float(sys.argv[3])

    print("Checking on EM gain:")
    print("--------------------")
    notOkay = checkEMGain(gain, peak, g, sat)
    if notOkay:
        print("Current EM gain is not okay.")
    else:
        print("Current EM gain is okay.")
    print()
    
    print("Advice for resetting EM gain to optimal:")
    print("----------------------------------------")
    newGain, newPeak, msg = adviseEMGain(gain, peak, g, sat)
    if newGain == gain:
        print("No changes to EM Gain recommended.")
    else:
        print("Changes to EM Gain are recommended.")
    print(newGain, newPeak, msg)

