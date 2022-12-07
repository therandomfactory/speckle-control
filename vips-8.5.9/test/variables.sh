top_srcdir=/home/rfactory/speckle-control-42571afe9e00ab162d9af56ffc528ebd37bf0500/vips-8.5.9
PYTHON=
# we need a different tmp for each script since make can run tests in parallel
tmp=$top_srcdir/test/tmp-$$
test_images=$top_srcdir/test/images
image=$test_images/йцук.jpg
mkdir -p $tmp
vips=$top_srcdir/tools/vips
vipsthumbnail=$top_srcdir/tools/vipsthumbnail
vipsheader=$top_srcdir/tools/vipsheader

# we need bc to use '.' for a decimal separator
export LC_NUMERIC=C
