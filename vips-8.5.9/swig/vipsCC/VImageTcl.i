/* SWIG interface file for vipsCC7
 *
 * 5/9/07
 *      - use g_option_context_set_ignore_unknown_options() so we don't fail
 *        on unrecognied -args (thanks Simon)
 * 3/8/08
 *      - add .tobuffer() / .frombuffer (), .tostring (), .fromstring ()
 *        methods
 *      - add PIL_mode_from_vips () and vips_from_PIL_mode () utility
 *        functions
 * 6/11/09
 *      - arg, std::vector<vips::VImage> was missing the "vips::"
 */

%module VImage

%{
#include <vips/vipscpp.h>

/* We need the C API too for the args init and some of the
 * frombuffer/tobuffer stuff.
 */
#include <vips/vips.h>
%}

/* Need to override assignment to get refcounting working.
 */
%rename(__assign__) vips::VImage::operator=;

%include "std_list.i"
%include "std_complex.i"
%include "std_vector.i"
%include "std_except.i"
%include "std_string.i"
%include "cstring.i"
%include "typemaps.i"

%import "VError.i"
%import "VMask.i"
%import "VDisplay.i"

namespace std {
  %template(IntVector) vector<int>;
  %template(DoubleVector) vector<double>;
  %template(ImageVector) vector<vips::VImage>;
}

/* To get image data to and from VImage (eg. when interfacing with PIL) we
 * need to be able to import and export Python buffer() objects. Add new
 * methods to construct from and return pointer/length pairs, then wrap them
 * ourselves with a couple of typemaps.
 */

%{
struct VBuffer {
  void *data;
  size_t size;
};
%}

%typemap (out) VBuffer {
  $result = PyBuffer_FromMemory ($1.data, $1.size);
}

%typemap (in) VBuffer {
  const char *buffer;
  Py_ssize_t buffer_len;

  if (PyObject_AsCharBuffer ($input, &buffer, &buffer_len) == -1) {
    PyErr_SetString (PyExc_TypeError,"Type error. Unable to get char pointer from buffer");
    return NULL;
  }

  $1.data = (void *) buffer;
  $1.size = buffer_len;
}

/* Functions which return extra values though their parameters need special
 * typemaps.
 */

// double maxpos_avg( double& maxpos_avg_y, double& maxpos_avg_out )
%apply double *OUTPUT { double & maxpos_avg_y };
%apply double *OUTPUT { double & maxpos_avg_out };

// VImage system_image( char* system_image_in_format, char* system_image_out_format, char* system_image_command, char*& system_image_log ) 
%cstring_output_allocate(char **system_image_log, g_free(*$1));

// VImage segment( int& segment_segments ) 
%apply int *OUTPUT { int & segment_segments };

// VImage project( VImage& project_vout ) throw( VError );
// nope ... not sure how to handle this one
//%apply VImage *OUTPUT { VImage & project_vout };

// VImage label_regions( int& label_regions_segments ) 
%apply int *OUTPUT { int & label_regions_segments };

// double correl( VImage correl_sec, int correl_xref, int correl_yref, int correl_xsec, int correl_ysec, int correl_hwindowsize, int correl_hsearchsize, int& correl_x, int& correl_y ) 
%apply int *OUTPUT { int & correl_x };
%apply int *OUTPUT { int & correl_y };

// int _find_lroverlap( VImage _find_lroverlap_sec, int _find_lroverlap_bandno, int _find_lroverlap_xr, int _find_lroverlap_yr, int _find_lroverlap_xs, int _find_lroverlap_ys, int _find_lroverlap_halfcorrelation, int _find_lroverlap_halfarea, int& _find_lroverlap_dy0, double& _find_lroverlap_scale1, double& _find_lroverlap_angle1, double& _find_lroverlap_dx1, double& _find_lroverlap_dy1 ) 
%apply int *OUTPUT { int & _find_lroverlap_dy0 };
%apply double *OUTPUT { double & _find_lroverlap_scale1 };
%apply double *OUTPUT { double & _find_lroverlap_angle1 };
%apply double *OUTPUT { double & _find_lroverlap_dx1 };
%apply double *OUTPUT { double & _find_lroverlap_dy1 };

// int _find_tboverlap( VImage _find_tboverlap_sec, int _find_tboverlap_bandno, int _find_tboverlap_xr, int _find_tboverlap_yr, int _find_tboverlap_xs, int _find_tboverlap_ys, int _find_tboverlap_halfcorrelation, int _find_tboverlap_halfarea, int& _find_tboverlap_dy0, double& _find_tboverlap_scale1, double& _find_tboverlap_angle1, double& _find_tboverlap_dx1, double& _find_tboverlap_dy1 ) 
%apply int *OUTPUT { int & _find_tboverlap_dy0 };
%apply double *OUTPUT { double & _find_tboverlap_scale1 };
%apply double *OUTPUT { double & _find_tboverlap_angle1 };
%apply double *OUTPUT { double & _find_tboverlap_dx1 };
%apply double *OUTPUT { double & _find_tboverlap_dy1 };

// double maxpos_subpel( double& maxpos_subpel_y ) 
%apply double *OUTPUT { double & maxpos_subpel_y };

/* Need the expanded VImage.h in this directory, rather than the usual
 * vips/VImage.h. SWIG b0rks on #include inside class definitions.
 */
%include VImage.h

%extend vips::VImage {
public:
  VBuffer tobuffer () throw (VError)
  {
    VBuffer buffer;

    buffer.data = $self->data ();
    buffer.size = (size_t) $self->Xsize () * $self->Ysize () * 
        IM_IMAGE_SIZEOF_PEL ($self->image ());

    return buffer;
  }

  static VImage frombuffer (VBuffer buffer, int width, int height,
    int bands, TBandFmt format) throw (VError)
  {
    return VImage (buffer.data, width, height, bands, format);
  }

  %cstring_output_allocate_size (char **buffer, int *buffer_len, im_free (*$1))

  void tostring (char **buffer, int *buffer_len) throw (VError)
  {
    void *vips_memory;

    /* Eval the vips image first. This may throw an exception and we want to
     * make sure we do this before we try to malloc() space for the copy.
     */
    vips_memory = $self->data ();

    /* We have to copy the image data to make a string that Python can
     * manage. Use frombuffer() / tobuffer () if you want to avoid the copy
     * and manage memory lifetime yourself.
     */
    *buffer_len = (size_t) $self->Xsize () * $self->Ysize () * 
      IM_IMAGE_SIZEOF_PEL ($self->image ());
    if (!(*buffer = (char *) im_malloc (NULL, *buffer_len))) 
      verror ("Unable to allocate memory for image copy.");
    memcpy (*buffer, vips_memory, *buffer_len);
  }

  static VImage fromstring (std::string buffer, int width, int height,
    int bands, TBandFmt format) throw (VError)
  {
    void *vips_memory;
    VImage result;

    /* We have to copy the string, then add a callback to the VImage to free
     * it when we free the VImage. Use frombuffer() / tobuffer () if you want 
     * to avoid the copy and manage memory lifetime yourself.
     */
    if (!(vips_memory = im_malloc (NULL, buffer.length ()))) 
      verror ("Unable to allocate memory for image copy.");

    /* We have to use .c_str () since the string may not be contiguous.
     */
    memcpy (vips_memory, buffer.c_str (), buffer.length ());
    result = VImage (vips_memory, width, height, bands, format);

    if (im_add_close_callback (result.image (), 
      (im_callback_fn) im_free, vips_memory, NULL))
      verror ();

    return result;
  }
}


/* Helper code for vips_init().
 */
%{
/* Turn on to print args.
#define DEBUG
 */

/* Command-line args during parse.
 */
typedef struct _Args {
  /* The n strings we alloc when we get from Python.
   */
  int n;
  char **str;

  /* argc/argv as processed by us.
   */
  int argc;
  char **argv;
} Args;

#ifdef DEBUG
static void
args_print (Args *args)
{
  int i;

  printf ("args_print: argc = %d\n", args->argc);
  // +1 so we print the trailing NULL too
  for (i = 0; i < args->argc + 1; i++)
    printf ("\t%2d)\t%s\n", i, args->argv[i]);
}
#endif /*DEBUG*/

static void
args_free (Args *args)
{
  int i;

  for (i = 0; i < args->n; i++)
    IM_FREE (args->str[i]);
  args->n = 0;
  args->argc = 0;
  IM_FREE (args->str);
  IM_FREE (args->argv);
  IM_FREE (args);
}


static void
vips_fatal (const char *msg)
{
  char buf[256];

  im_snprintf (buf, 256, "%s\n%s", msg, im_error_buffer());
  im_error_clear ();
  Py_FatalError (buf);
}

%}

%init %{
{
  Args *args;
        
/*  args = args_new (); */

#ifdef DEBUG
  printf ("on startup:\n");
  args_print (args);
#endif /*DEBUG*/
        
  if (im_init_world (args->argv[0])) {
     args_free (args);
     vips_fatal ("can't initialise module vips");
  }

  /* Now parse any GOptions. 
   */
  GError *error = NULL;
  GOptionContext *context;

  context = g_option_context_new ("- vips");
  g_option_context_add_group (context, im_get_option_group());

  g_option_context_set_ignore_unknown_options (context, TRUE);
  if (!g_option_context_parse (context, 
    &args->argc, &args->argv, &error)) {
    g_option_context_free (context);
    args_free (args);
    im_error ("vipsmodule", "%s", error->message);
    g_error_free (error);
    vips_fatal ("can't initialise module vips");
  }
  g_option_context_free (context);

#ifdef DEBUG
  printf ("after parse:\n");
  args_print (args);
#endif /*DEBUG*/

  // Write (possibly) modified argc/argv back again.
  if (args->argv) 
    PySys_SetArgv (args->argc, args->argv);

  args_free (args);
}
%}

