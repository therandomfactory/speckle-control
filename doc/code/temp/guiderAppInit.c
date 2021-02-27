
 
#include "tcl.h"
#include "guider.h"

void initguider ();
int guiderAppInit(Tcl_Interp *interp);



extern GUIDER Guider;

extern int tcl_locateStars(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
extern int tcl_calcCentroid(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
extern int tcl_onscreenMsg(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
extern int tcl_onscreenMarker(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);


int guiderAppInit(Tcl_Interp *interp)
{
  /* Initialize the new commands */
 
    Tcl_CreateCommand ( interp, "locatestars",(Tcl_CmdProc *) tcl_locateStars, NULL,NULL);
    Tcl_CreateCommand ( interp, "calccentroid",(Tcl_CmdProc *) tcl_calcCentroid, NULL,NULL);
    Tcl_CreateCommand ( interp, "onscreenmsg",(Tcl_CmdProc *) tcl_onscreenMsg, NULL,NULL);
    Tcl_CreateCommand ( interp, "onscreenmarker",(Tcl_CmdProc *) tcl_onscreenMarker, NULL,NULL);
    initguider();

  return TCL_OK;
}


void initguider ()
{

    int i;

    for (i=0;i<MAXROI;i++) {   
       Guider.roi[i].xc = 320;
       Guider.roi[i].yc = 240;
       Guider.roi[i].xs = 32;
       Guider.roi[i].ys = 32;
       Guider.roi[i].dispx = 0;
       Guider.roi[i].dispy = 0;
       Guider.roi[i].zoom = 1.0;
       Guider.roi[i].type = 0;
       Guider.roi[i].lockx = 0.0;
       Guider.roi[i].locky = 0.0;
       Guider.roi[i].gain = 0.8;
       Guider.roi[i].weight = 1.0;

       Guider.roi[i].nsaturated = 0;
       Guider.roi[i].mean = 0.0;
       Guider.roi[i].xcorr = 0.0;
       Guider.roi[i].ycorr = 0.0;
       Guider.roi[i].fmax = 0.0;
       Guider.roi[i].fmin = 0.0;
       Guider.roi[i].fwhm = 0.0;
    }


}



