/* load a GIF with giflib
 *
 * 10/2/16
 * 	- from svgload.c
 * 25/4/16
 * 	- add giflib5 support
 * 26/7/16
 * 	- transparency was wrong if there was no EXTENSION_RECORD
 * 	- write 1, 2, 3, or 4 bands depending on file contents
 * 17/8/16
 * 	- support unicode on win
 * 19/8/16
 * 	- better transparency detection, thanks diegocsandrim
 * 25/11/16
 * 	- support @n, page-height
 */

/*

    This file is part of VIPS.
    
    VIPS is free software; you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
    02110-1301  USA

 */

/*

    These files are distributed with VIPS - http://www.vips.ecs.soton.ac.uk

 */

/*
#define VIPS_DEBUG
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif /*HAVE_CONFIG_H*/
#include <vips/intl.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>

#include <vips/vips.h>
#include <vips/buf.h>
#include <vips/internal.h>
#include <vips/debug.h>

#ifdef HAVE_GIFLIB

#include <gif_lib.h>

/* giflib 5 is rather different :-( functions have error returns and there's
 * no LastError().
 *
 * GIFLIB_MAJOR was introduced in 4.1.6. Use it to test for giflib 5.x.
 */
#ifdef GIFLIB_MAJOR
#  if GIFLIB_MAJOR > 4
#    define HAVE_GIFLIB_5
#  endif
#endif

typedef struct _VipsForeignLoadGif {
	VipsForeignLoad parent_object;

	/* Load this page (frame number).
	 */
	int page;

	/* Load this many pages.
	 */
	int n;

	GifFileType *file;

	/* The current read position, in pages.
	 */
	int current_page;

	/* Set for EOF detected.
	 */
	gboolean eof;

	/* As we scan the file, the index of the transparent pixel for this
	 * frame.
	 */
	int transparency;

	/* Decompress lines of the gif file to here.
	 */
	GifPixelType *line;

	/* We decompress the whole thing to a huge RGBA memory image, and
	 * as we render, watch for bands and transparency. At the end of
	 * loading, we copy 1 or 3 bands, with or without transparency to
	 * output.
	 */
	gboolean has_transparency;
	gboolean has_colour;

	/* The FILE* we read from.
	 */
	FILE *fp;

} VipsForeignLoadGif;

typedef VipsForeignLoadClass VipsForeignLoadGifClass;

G_DEFINE_ABSTRACT_TYPE( VipsForeignLoadGif, vips_foreign_load_gif, 
	VIPS_TYPE_FOREIGN_LOAD );

/* From gif2rgb.c ... offsets and jumps for interlaced GIF images.
 */
static int 
	InterlacedOffset[] = { 0, 4, 2, 1 },
	InterlacedJumps[] = { 8, 8, 4, 2 };

/* giflib4 was missing this.
 */
static const char *
vips_foreign_load_gif_errstr( int error_code )
{
#ifdef HAVE_GIFLIB_5
	return( GifErrorString( error_code ) ); 
#else /*!HAVE_GIFLIB_5*/
	switch( error_code ) {
	case D_GIF_ERR_OPEN_FAILED:
		return( _( "Failed to open given file" ) ); 

	case D_GIF_ERR_READ_FAILED:
		return( _( "Failed to read from given file" ) ); 

	case D_GIF_ERR_NOT_GIF_FILE:
		return( _( "Data is not a GIF file" ) ); 

	case D_GIF_ERR_NO_SCRN_DSCR:
		return( _( "No screen descriptor detected" ) ); 

	case D_GIF_ERR_NO_IMAG_DSCR:
		return( _( "No image descriptor detected" ) ); 

	case D_GIF_ERR_NO_COLOR_MAP:
		return( _( "Neither global nor local color map" ) ); 

	case D_GIF_ERR_WRONG_RECORD:
		return( _( "Wrong record type detected" ) ); 

	case D_GIF_ERR_DATA_TOO_BIG:
		return( _( "Number of pixels bigger than width * height" ) ); 

	case D_GIF_ERR_NOT_ENOUGH_MEM:
		return( _( "Failed to allocate required memory" ) ); 

	case D_GIF_ERR_CLOSE_FAILED:
		return( _( "Failed to close given file" ) ); 

	case D_GIF_ERR_NOT_READABLE:
		return( _( "Given file was not opened for read" ) ); 

	case D_GIF_ERR_IMAGE_DEFECT:
		return( _( "Image is defective, decoding aborted" ) ); 

	case D_GIF_ERR_EOF_TOO_SOON:
		return( _( "Image EOF detected, before image complete" ) ); 

	default:
		return( _( "Unknown error" ) ); 
	}
#endif /*HAVE_GIFLIB_5*/
}

static void
vips_foreign_load_gif_error_vips( VipsForeignLoadGif *gif, int error )
{
	VipsObjectClass *class = VIPS_OBJECT_GET_CLASS( gif );

	const char *message;

	if( (message = vips_foreign_load_gif_errstr( error )) )
		vips_error( class->nickname, "%s", message ); 
}

static void
vips_foreign_load_gif_error( VipsForeignLoadGif *gif )
{
	int error;

	error = 0;

#ifdef HAVE_GIFLIB_5
	if( gif->file ) 
		error = gif->file->Error;
#else 
	error = GifLastError(); 
#endif

	if( error ) 
		vips_foreign_load_gif_error_vips( gif, error ); 
}

static void
vips_foreign_load_gif_close( VipsForeignLoadGif *gif )
{
#ifdef HAVE_GIFLIB_5
	if( gif->file ) {
		int error; 

		if( DGifCloseFile( gif->file, &error ) == GIF_ERROR ) 
			vips_foreign_load_gif_error_vips( gif, error );
		gif->file = NULL;
	}
#else 
	if( gif->file ) {
		if( DGifCloseFile( gif->file ) == GIF_ERROR ) 
			vips_foreign_load_gif_error_vips( gif, GifLastError() ); 
		gif->file = NULL;
	}
#endif

	VIPS_FREEF( fclose, gif->fp ); 
}

/* Our input function for file open. We can't use DGifOpenFileName(), since
 * that just calls open() and won't work with unicode on win32. We can't use
 * DGifOpenFileHandle() since that's an fd from open() and you can't pass those
 * acoss DLL boundaries on Windows. 
 */
static int 
vips_giflib_file_read( GifFileType *file, GifByteType *buffer, int n )
{
	FILE *fp = (FILE *) file->UserData;

	return( (int) fread( (void *) buffer, 1, n, fp ) );
}

static int
vips_foreign_load_gif_open( VipsForeignLoadGif *gif, const char *filename )
{
	g_assert( !gif->file ); 
	g_assert( !gif->fp ); 

	if( !(gif->fp = vips__file_open_read( filename, NULL, FALSE )) ) 
		return( -1 ); 

#ifdef HAVE_GIFLIB_5
{
	int error; 

	if( !(gif->file = 
		DGifOpen( gif->fp, vips_giflib_file_read, &error )) ) {
		vips_foreign_load_gif_error_vips( gif, error );
		return( -1 ); 
	}
}
#else 
	if( !(gif->file = DGifOpen( gif->fp, vips_giflib_file_read )) ) { 
		vips_foreign_load_gif_error_vips( gif, GifLastError() ); 
		return( -1 ); 
	}
#endif

	return( 0 ); 
}

static int
vips_foreign_load_gif_open_buffer( VipsForeignLoadGif *gif, InputFunc read_fn )
{
	g_assert( !gif->file ); 

#ifdef HAVE_GIFLIB_5
{
	int error;

	if( !(gif->file = DGifOpen( gif, read_fn, &error )) ) {
		vips_foreign_load_gif_error_vips( gif, error );
		return( -1 ); 
	}
}
#else 
	if( !(gif->file = DGifOpen( gif, read_fn )) ) { 
		vips_foreign_load_gif_error_vips( gif, GifLastError() ); 
		return( -1 ); 
	}
#endif

	return( 0 ); 
}

static void
vips_foreign_load_gif_dispose( GObject *gobject )
{
	VipsForeignLoadGif *gif = (VipsForeignLoadGif *) gobject;

	vips_foreign_load_gif_close( gif ); 

	G_OBJECT_CLASS( vips_foreign_load_gif_parent_class )->
		dispose( gobject );
}

static VipsForeignFlags
vips_foreign_load_gif_get_flags_filename( const char *filename )
{
	/* We can render any part of the image on demand.
	 */
	return( VIPS_FOREIGN_PARTIAL );
}

static VipsForeignFlags
vips_foreign_load_gif_get_flags( VipsForeignLoad *load )
{
	return( VIPS_FOREIGN_PARTIAL );
}

static gboolean
vips_foreign_load_gif_is_a_buffer( const void *buf, size_t len )
{
	const guchar *str = (const guchar *) buf;

	if( len >= 4 &&
		str[0] == 'G' && 
		str[1] == 'I' &&
		str[2] == 'F' &&
		str[3] == '8' )
		return( 1 );

	return( 0 );
}

static gboolean
vips_foreign_load_gif_is_a( const char *filename )
{
	unsigned char buf[4];

	if( vips__get_bytes( filename, buf, 4 ) &&
		vips_foreign_load_gif_is_a_buffer( buf, 4 ) )
		return( 1 );

	return( 0 );
}

static void
vips_foreign_load_gif_render_line( VipsForeignLoadGif *gif,
	int width, VipsPel * restrict q, VipsPel * restrict p )
{
	ColorMapObject *map = gif->file->Image.ColorMap ?
		gif->file->Image.ColorMap : gif->file->SColorMap;

	int x;

	for( x = 0; x < width; x++ ) {
		VipsPel v = p[x];

		if( v >= map->ColorCount ) {
			g_warning( "%s", _( "pixel value out of range" ) );
			continue;
		}

		if( v != gif->transparency ) { 
			q[0] = map->Colors[v].Red;
			q[1] = map->Colors[v].Green;
			q[2] = map->Colors[v].Blue;
			q[3] = 255;
		}
		else {
			q[0] = 0;
			q[1] = 0;
			q[2] = 0;
			q[3] = 0;
		}

		q += 4;
	}
}

/* Render the current gif frame into an RGBA buffer. GIFs 
 * accumulate, so don't clear the buffer first, we need to paint a 
 * series of frames on top of each other. 
 */
static int
vips_foreign_load_gif_render( VipsForeignLoadGif *gif, VipsImage *out ) 
{
	VipsObjectClass *class = VIPS_OBJECT_GET_CLASS( gif );
	GifFileType *file = gif->file;
	ColorMapObject *map = file->Image.ColorMap ?
		file->Image.ColorMap : file->SColorMap;

	/* Check that the frame lies within our image.
	 */
	if( file->Image.Left < 0 ||
		file->Image.Left + file->Image.Width > out->Xsize ||
		file->Image.Top < 0 ||
		file->Image.Top + file->Image.Height > out->Ysize ) {
		vips_error( class->nickname, 
			"%s", _( "frame is outside image area" ) ); 
		return( -1 ); 
	}

	/* Check if we have a non-greyscale colourmap for this frame.
	 */
	if( !gif->has_colour ) {
		int i;

		for( i = 0; i < map->ColorCount; i++ ) 
			if( map->Colors[i].Red != map->Colors[i].Green ||
				map->Colors[i].Green != map->Colors[i].Blue ) {
				VIPS_DEBUG_MSG( "gifload: not mono\n" ); 
				gif->has_colour = TRUE;
				break;
			}
	}

	/* We need a line buffer to decompress to.
	 */
	if( !gif->line ) 
		if( !(gif->line = VIPS_ARRAY( gif, 
			gif->file->SWidth, GifPixelType )) )
			return( -1 ); 

	if( file->Image.Interlace ) {
		int i;

		VIPS_DEBUG_MSG( "gifload: interlaced frame of "
			"%d x %d pixels at %d x %d\n",
			file->Image.Width, file->Image.Height,
			file->Image.Left, file->Image.Top ); 

		for( i = 0; i < 4; i++ ) {
			int y;

			for( y = InterlacedOffset[i]; 
				y < file->Image.Height;
			  	y += InterlacedJumps[i] ) {
				VipsPel *q = VIPS_IMAGE_ADDR( out, 
					file->Image.Left, file->Image.Top + y );

				if( DGifGetLine( gif->file, gif->line, 
					file->Image.Width ) == GIF_ERROR ) {
					vips_foreign_load_gif_error( gif ); 
					return( -1 ); 
				}

				vips_foreign_load_gif_render_line( gif, 
					file->Image.Width, q, gif->line ); 
			}
		}
	}
	else {
		int y;

		VIPS_DEBUG_MSG( "gifload: non-interlaced frame of "
			"%d x %d pixels at %d x %d\n",
			file->Image.Width, file->Image.Height,
			file->Image.Left, file->Image.Top ); 

		for( y = 0; y < file->Image.Height; y++ ) {
			VipsPel *q = VIPS_IMAGE_ADDR( out, 
				file->Image.Left, file->Image.Top + y );

			if( DGifGetLine( gif->file, gif->line, 
				file->Image.Width ) == GIF_ERROR ) {
				vips_foreign_load_gif_error( gif ); 
				return( -1 ); 
			}

			vips_foreign_load_gif_render_line( gif, 
				file->Image.Width, q, gif->line ); 
		}
	}

	return( 0 );
}

/* Write the next page, if there is one, to @page. Set EOF if we hit the end of
 * the file. @page must be a memory image of the right size. 
 */
static int
vips_foreign_load_gif_page( VipsForeignLoadGif *gif, VipsImage *out )
{
	GifRecordType record;
	int n_pages;

	n_pages = 0;

	do { 
		GifByteType *extension;
		int ext_code;

		if( DGifGetRecordType( gif->file, &record ) == GIF_ERROR ) {
			vips_foreign_load_gif_error( gif ); 
			return( -1 ); 
		}

		switch( record ) {
		case IMAGE_DESC_RECORD_TYPE:
			VIPS_DEBUG_MSG( "gifload: IMAGE_DESC_RECORD_TYPE:\n" ); 

			if( DGifGetImageDesc( gif->file ) == GIF_ERROR ) {
				vips_foreign_load_gif_error( gif ); 
				return( -1 ); 
			}

			if( vips_foreign_load_gif_render( gif, out ) )
				return( -1 ); 

			n_pages += 1;

			VIPS_DEBUG_MSG( "gifload: page %d:\n", 
				gif->current_page + n_pages );

			break;

		case EXTENSION_RECORD_TYPE:
			VIPS_DEBUG_MSG( "gifload: EXTENSION_RECORD_TYPE:\n" ); 

			gif->transparency = -1;

			if( DGifGetExtension( gif->file, 
				&ext_code, &extension ) == GIF_ERROR ) {
				vips_foreign_load_gif_error( gif ); 
				return( -1 ); 
			}

			if( ext_code == GRAPHICS_EXT_FUNC_CODE &&
				extension &&
				extension[0] == 4 && 
				(extension[1] & 0x1) ) {
				/* Bytes are 4, 1, delay low, delay high,
				 * transparency. Bit 1 means transparency
				 * is being set.
				 */
				gif->transparency = extension[4];
				gif->has_transparency = TRUE;

				VIPS_DEBUG_MSG( "gifload: "
					"seen transparency %d\n", 
					gif->transparency );
			}

			while( extension != NULL ) {
				if( DGifGetExtensionNext( gif->file, 
					&extension) == GIF_ERROR ) {
					vips_foreign_load_gif_error( gif ); 
					return( -1 ); 
				}

#ifdef VIPS_DEBUG
				if( extension ) 
					VIPS_DEBUG_MSG( "gifload: "
						"EXTENSION_NEXT:\n" ); 
#endif
			}

			break;

		case TERMINATE_RECORD_TYPE:
			VIPS_DEBUG_MSG( "gifload: TERMINATE_RECORD_TYPE:\n" ); 
			gif->eof = TRUE;
			break;

		case SCREEN_DESC_RECORD_TYPE:
			VIPS_DEBUG_MSG( "gifload: SCREEN_DESC_RECORD_TYPE:\n" );
			break;

		case UNDEFINED_RECORD_TYPE:
			VIPS_DEBUG_MSG( "gifload: UNDEFINED_RECORD_TYPE:\n" );
			break;

		default:
			break;
		}
	} while( n_pages < 1 &&
		!gif->eof );

	gif->current_page += n_pages;

	return( 0 );
}

static VipsImage *
vips_foreign_load_gif_new_page( VipsForeignLoadGif *gif )
{
	VipsImage *out;

	out = vips_image_new_memory();

	vips_image_init_fields( out, 
		gif->file->SWidth, gif->file->SHeight, 4, VIPS_FORMAT_UCHAR,
		VIPS_CODING_NONE, VIPS_INTERPRETATION_sRGB, 1.0, 1.0 );

	/* We will have the whole GIF frame in memory, so we can render any 
	 * area.
	 */
        vips_image_pipelinev( out, VIPS_DEMAND_STYLE_ANY, NULL );

	/* Turn out into a memory image which we then render the GIF frames
	 * into.
	 */
	if( vips_image_write_prepare( out ) ) {
		g_object_unref( out ); 
		return( NULL );
	}

	return( out );
}

static void *
unref_object( void *data, void *a, void *b )
{
	g_object_unref( G_OBJECT( data ) );

	return( NULL ); 
}

static void
unref_array( GSList *list )
{
	/* g_slist_free_full() was added in 2.28 and we have to work with 
	 * 2.6 :( 
	 */
	vips_slist_map2( list, unref_object, NULL, NULL ); 
	g_slist_free( list );
}

/* We render each frame to a separate memory image held in a linked
 * list, then assemble to out. We don't know the number of frames in advance,
 * so we can't just allocate a large area.
 */
static int
vips_foreign_load_gif_pages( VipsForeignLoadGif *gif, VipsImage **out )
{
	VipsObjectClass *class = VIPS_OBJECT_GET_CLASS( gif );

	GSList *frames;
	VipsImage *frame;
	VipsImage *previous;
	VipsImage **t;
	int n_frames;
	int i;

	frames = NULL;
	previous = NULL;

	/* Accumulate any start stuff up to the first frame we need.
	 */
	if( !(frame = vips_foreign_load_gif_new_page( gif )) ) 
		return( -1 );
	do { 
		if( vips_foreign_load_gif_page( gif, frame ) ) {
			g_object_unref( frame );
			return( -1 );
		}
	} while( !gif->eof &&
		gif->current_page <= gif->page );

	if( gif->eof ) {
		vips_error( class->nickname, 
			"%s", _( "too few frames in GIF file" ) );
		g_object_unref( frame );
		return( -1 );
	}

	frames = g_slist_append( frames, frame );
	previous = frame;

	while( gif->n == -1 ||
		gif->current_page < gif->page + gif->n ) {
		/* We might need a frame for this read to render to.
		 */
		if( !(frame = vips_foreign_load_gif_new_page( gif )) ) {
			unref_array( frames );
			return( -1 );
		}

		/* And init with the previous frame, if any.
		 */
		if( previous ) 
			memcpy( VIPS_IMAGE_ADDR( frame, 0, 0 ),
				VIPS_IMAGE_ADDR( previous, 0, 0 ),
				VIPS_IMAGE_SIZEOF_IMAGE( frame ) );

		if( vips_foreign_load_gif_page( gif, frame ) ) {
			g_object_unref( frame ); 
			unref_array( frames );
			return( -1 );
		}

		if( gif->eof ) {
			/* Nope, didn't need the new frame.
			 */
			g_object_unref( frame ); 
			break;
		}
		else {
			frames = g_slist_append( frames, frame );
			previous = frame;
		}
	}

	n_frames = g_slist_length( frames ); 

	if( gif->eof &&
		gif->n != -1 &&
		n_frames < gif->n ) {
		unref_array( frames );
		vips_error( class->nickname, 
			"%s", _( "too few frames in GIF file" ) );
		return( -1 );
	}

	/* We've rendered to a set of memory images ... we can shut down the GIF
	 * reader now.
	 */
	vips_foreign_load_gif_close( gif ); 

	if( !(t = VIPS_ARRAY( gif, n_frames, VipsImage * )) ) { 
		unref_array( frames );
		return( -1 );
	}

	for( i = 0; i < n_frames; i++ )
		t[i] = (VipsImage *) g_slist_nth_data( frames, i );

	if( vips_arrayjoin( t, out, n_frames, 
		"across", 1,
		NULL ) ) { 
		unref_array( frames );
		return( -1 );
	}

	unref_array( frames );

	if( n_frames > 1 )
		vips_image_set_int( *out, VIPS_META_PAGE_HEIGHT, frame->Ysize );

	return( 0 );
}

static int
vips_foreign_load_gif_load( VipsForeignLoad *load )
{
	VipsForeignLoadGif *gif = (VipsForeignLoadGif *) load;
	VipsImage **t = (VipsImage **) 
		vips_object_local_array( VIPS_OBJECT( load ), 4 );

	VipsImage *im;

	if( vips_foreign_load_gif_pages( gif, &t[0] ) )
		return( -1 );
	im = t[0];

	/* Depending on what we found, transform and write to load->real.
	 */
	if( gif->has_colour &&
		gif->has_transparency ) {
		/* Nothing to do.
		 */
	}
	else if( gif->has_colour ) { 
		/* RGB.
		 */
		if( vips_extract_band( im, &t[1], 0,
			"n", 3,
			NULL ) )
			return( -1 );
		im = t[1];
	}
	else if( gif->has_transparency ) {
		/* GA. Take BA so we have neighboring channels. 
		 */
		if( vips_extract_band( im, &t[1], 2,
			"n", 2,
			NULL ) )
			return( -1 );
		im = t[1];
		im->Type = VIPS_INTERPRETATION_B_W;
	}
	else {
		/* G.
		 */
		if( vips_extract_band( im, &t[1], 0, NULL ) )
			return( -1 );
		im = t[1];
		im->Type = VIPS_INTERPRETATION_B_W;
	}

	if( vips_image_write( im, load->out ) )
		return( -1 );

	return( 0 );
}

static void
vips_foreign_load_gif_class_init( VipsForeignLoadGifClass *class )
{
	GObjectClass *gobject_class = G_OBJECT_CLASS( class );
	VipsObjectClass *object_class = (VipsObjectClass *) class;
	VipsForeignLoadClass *load_class = (VipsForeignLoadClass *) class;

	gobject_class->dispose = vips_foreign_load_gif_dispose;
	gobject_class->set_property = vips_object_set_property;
	gobject_class->get_property = vips_object_get_property;

	object_class->nickname = "gifload_base";
	object_class->description = _( "load GIF with giflib" );

	load_class->get_flags_filename = 
		vips_foreign_load_gif_get_flags_filename;
	load_class->get_flags = vips_foreign_load_gif_get_flags;

	VIPS_ARG_INT( class, "page", 10,
		_( "Page" ),
		_( "Load this page from the file" ),
		VIPS_ARGUMENT_OPTIONAL_INPUT,
		G_STRUCT_OFFSET( VipsForeignLoadGif, page ),
		0, 100000, 0 );

	VIPS_ARG_INT( class, "n", 6,
		_( "n" ),
		_( "Load this many pages" ),
		VIPS_ARGUMENT_OPTIONAL_INPUT,
		G_STRUCT_OFFSET( VipsForeignLoadGif, n ),
		-1, 100000, 1 );

}

static void
vips_foreign_load_gif_init( VipsForeignLoadGif *gif )
{
	gif->n = 1;
	gif->transparency = -1;
}

typedef struct _VipsForeignLoadGifFile {
	VipsForeignLoadGif parent_object;

	/* Filename for load.
	 */
	char *filename; 

} VipsForeignLoadGifFile;

typedef VipsForeignLoadGifClass VipsForeignLoadGifFileClass;

G_DEFINE_TYPE( VipsForeignLoadGifFile, vips_foreign_load_gif_file, 
	vips_foreign_load_gif_get_type() );

static int
vips_foreign_load_gif_file_header( VipsForeignLoad *load )
{
	VipsForeignLoadGif *gif = (VipsForeignLoadGif *) load;
	VipsForeignLoadGifFile *file = (VipsForeignLoadGifFile *) load;

	if( vips_foreign_load_gif_open( gif, file->filename ) ) 
		return( -1 ); 

	VIPS_SETSTR( load->out->filename, file->filename );

	return( vips_foreign_load_gif_load( load ) );
}

static const char *vips_foreign_gif_suffs[] = {
	".gif",
	NULL
};

static void
vips_foreign_load_gif_file_class_init( 
	VipsForeignLoadGifFileClass *class )
{
	GObjectClass *gobject_class = G_OBJECT_CLASS( class );
	VipsObjectClass *object_class = (VipsObjectClass *) class;
	VipsForeignClass *foreign_class = (VipsForeignClass *) class;
	VipsForeignLoadClass *load_class = (VipsForeignLoadClass *) class;

	gobject_class->set_property = vips_object_set_property;
	gobject_class->get_property = vips_object_get_property;

	object_class->nickname = "gifload";
	object_class->description = _( "load GIF with giflib" );

	foreign_class->suffs = vips_foreign_gif_suffs;

	load_class->is_a = vips_foreign_load_gif_is_a;
	load_class->header = vips_foreign_load_gif_file_header;

	VIPS_ARG_STRING( class, "filename", 1, 
		_( "Filename" ),
		_( "Filename to load from" ),
		VIPS_ARGUMENT_REQUIRED_INPUT, 
		G_STRUCT_OFFSET( VipsForeignLoadGifFile, filename ),
		NULL );

}

static void
vips_foreign_load_gif_file_init( VipsForeignLoadGifFile *file )
{
}

typedef struct _VipsForeignLoadGifBuffer {
	VipsForeignLoadGif parent_object;

	/* Load from a buffer.
	 */
	VipsArea *buf;

	/* Current read point, bytes left in buffer.
	 */
	VipsPel *p;
	size_t bytes_to_go;

} VipsForeignLoadGifBuffer;

typedef VipsForeignLoadGifClass VipsForeignLoadGifBufferClass;

G_DEFINE_TYPE( VipsForeignLoadGifBuffer, vips_foreign_load_gif_buffer, 
	vips_foreign_load_gif_get_type() );

/* Callback from the gif loader.
 *
 * Read up to len bytes into buffer, return number of bytes read, 0 for EOF.
 */
static int
vips_giflib_buffer_read( GifFileType *file, GifByteType *buf, int n )
{
	VipsForeignLoadGifBuffer *buffer = 
		(VipsForeignLoadGifBuffer *) file->UserData;
	size_t will_read = VIPS_MIN( n, buffer->bytes_to_go );

	memcpy( buf, buffer->p, will_read );
	buffer->p += will_read;
	buffer->bytes_to_go -= will_read;

	return( will_read ); 
}

static int
vips_foreign_load_gif_buffer_header( VipsForeignLoad *load )
{
	VipsForeignLoadGif *gif = (VipsForeignLoadGif *) load;
	VipsForeignLoadGifBuffer *buffer = (VipsForeignLoadGifBuffer *) load;

	/* Init the read point.
	 */
	buffer->p = buffer->buf->data;
	buffer->bytes_to_go = buffer->buf->length;

	if( vips_foreign_load_gif_open_buffer( gif, vips_giflib_buffer_read ) ) 
		return( -1 ); 

	return( vips_foreign_load_gif_load( load ) );
}

static void
vips_foreign_load_gif_buffer_class_init( 
	VipsForeignLoadGifBufferClass *class )
{
	GObjectClass *gobject_class = G_OBJECT_CLASS( class );
	VipsObjectClass *object_class = (VipsObjectClass *) class;
	VipsForeignLoadClass *load_class = (VipsForeignLoadClass *) class;

	gobject_class->set_property = vips_object_set_property;
	gobject_class->get_property = vips_object_get_property;

	object_class->nickname = "gifload_buffer";
	object_class->description = _( "load GIF with giflib" );

	load_class->is_a_buffer = vips_foreign_load_gif_is_a_buffer;
	load_class->header = vips_foreign_load_gif_buffer_header;

	VIPS_ARG_BOXED( class, "buffer", 1, 
		_( "Buffer" ),
		_( "Buffer to load from" ),
		VIPS_ARGUMENT_REQUIRED_INPUT, 
		G_STRUCT_OFFSET( VipsForeignLoadGifBuffer, buf ),
		VIPS_TYPE_BLOB );

}

static void
vips_foreign_load_gif_buffer_init( VipsForeignLoadGifBuffer *buffer )
{
}

#endif /*HAVE_GIFLIB*/

/**
 * vips_gifload:
 * @filename: file to load
 * @out: output image
 * @...: %NULL-terminated list of optional named arguments
 *
 * Optional arguments:
 *
 * * @page: %gint, page (frame) to read
 * * @n: %gint, load this many pages
 *
 * Read a GIF file into a VIPS image.  Rendering uses the giflib library.
 *
 * Use @page to select a page to render, numbering from zero.
 *
 * Use @n to select the number of pages to render. The default is 1. Pages are
 * rendered in a vertical column, with each individual page aligned to the
 * left. Set to -1 to mean "until the end of the document". Use vips_grid() 
 * to change page layout.
 *
 * The whole GIF is rendered into memory on header access. The output image
 * will be 1, 2, 3 or 4 bands depending on what the reader finds in the file. 
 *
 * See also: vips_image_new_from_file().
 *
 * Returns: 0 on success, -1 on error.
 */
int
vips_gifload( const char *filename, VipsImage **out, ... )
{
	va_list ap;
	int result;

	va_start( ap, out );
	result = vips_call_split( "gifload", ap, filename, out );
	va_end( ap );

	return( result );
}

/**
 * vips_gifload_buffer:
 * @buf: memory area to load
 * @len: size of memory area
 * @out: image to write
 * @...: %NULL-terminated list of optional named arguments
 *
 * Optional arguments:
 *
 * * @page: %gint, page (frame) to read
 * * @n: %gint, load this many pages
 *
 * Read a GIF-formatted memory block into a VIPS image. Exactly as
 * vips_gifload(), but read from a memory buffer. 
 *
 * You must not free the buffer while @out is active. The 
 * #VipsObject::postclose signal on @out is a good place to free. 
 *
 * See also: vips_gifload().
 *
 * Returns: 0 on success, -1 on error.
 */
int
vips_gifload_buffer( void *buf, size_t len, VipsImage **out, ... )
{
	va_list ap;
	VipsBlob *blob;
	int result;

	/* We don't take a copy of the data or free it.
	 */
	blob = vips_blob_new( NULL, buf, len );

	va_start( ap, out );
	result = vips_call_split( "gifload_buffer", ap, blob, out );
	va_end( ap );

	vips_area_unref( VIPS_AREA( blob ) );

	return( result );
}

