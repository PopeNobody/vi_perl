MAKEOPTS:=-rR

all:

ifeq ($(MAKECMDGOALS),)

#EMPTY:=$(warning empty)

else

#EMPTY:=$(warning not empty)

$(MAKECMDGOALS): all
	echo done

endif

all: Makefile
	${MAKE} -f Makefile ${MAKECMDGOALS}


Makefile:
	perl generate.pl

