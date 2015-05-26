#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
SRC="$MYDIR/../daemovise"
DST="$MYDIR/daemovise"

mobundle -PB "$SRC" -o "$DST" \
   -m Log::Log4perl::Tiny
chmod +x "$DST"

if [ "$1" == 'commit' ] ; then
   git commit "$DST" -m 'regenerated bundled version'
fi
