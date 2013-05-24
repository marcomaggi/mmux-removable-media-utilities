# configure.sh --
#
# Run this to configure.

set -xe

prefix=/usr/local

../configure \
    --config-cache                              \
    --cache-file=../config.cache                \
    --prefix="${prefix}"                        \
    --sysconfdir=/etc                           \
    "$@"

### end of file
