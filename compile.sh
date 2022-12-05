#!/bin/bash

## Author: Seyyid Hikmet Celik

# CFLAGS="-fno-omit-frame-pointer -rdynamic -pg -O0" ./configure --prefix=/home/guest/poslib/postgres-compiled --enable-debug

## Desired compiler
CC=gcc

## You can add desired compiler flags here
CFLAGS="-fno-omit-frame-pointer -rdynamic -pg -O0"

## Postgres install directory after built, give it full path
PINSTALLDIR="$PWD/build" #"/home/guest/poslib/postgres-compiled"

## Custom c file's name
MAINF="custom"

## You need to change this variable according to your include in custom.c file
## e.g. if you included tuplesort.c in custom.c file give it as tuplesort without .c extension
## If you added more includes from the library to your custom.c, add it manually to "$eachObject ==" if part inside the loop below
EXTRACTF="" #"tuplesort"

OBJECTS=""

CFLAGS="$CFLAGS" ./configure --prefix=$PINSTALLDIR --enable-debug;
make;
make install;

while read eachObject; do
	if [[ $eachObject == */main.o || $eachObject == */${EXTRACTF}.o || $eachObject == */libpqwalreceiver.o || $eachObject == */pgoutput.o || $eachObject == *"utils/mb/conversion_procs"* ]]
	then
		continue
	fi

	OBJECTS+=" ${eachObject} "
done <<< "$(find "$PWD/src/backend" -name "*.o")"

$CC -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wshadow=compatible-local -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g $CFLAGS -I./src -I./src/include  -D_GNU_SOURCE -c -o ${MAINF}.o ${MAINF}.c;

$CC -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wshadow=compatible-local -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g $CFLAGS $OBJECTS ./src/timezone/localtime.o ./src/timezone/pgtz.o ./src/timezone/strftime.o ${MAINF}.o ./src/common/libpgcommon_srv.a ./src/port/libpgport_srv.a -L./src/port -L./src/common -Wl,--as-needed -Wl,-rpath,'${PINSTALLDIR}/lib',--enable-new-dtags -Wl,-E -lz -lpthread -lrt -ldl -lm -o $MAINF;

