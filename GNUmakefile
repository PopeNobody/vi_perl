MAKEOPTS:=-rR

all:

ifneq ($(MAKECMDGOALS),)
$(MAKECMDGOALS): all
	@echo made $(MAKECMDGOALS)
endif

all: Makefile
	${MAKE} -f Makefile ${MAKECMDGOALS}


Makefile:
	perl generate.pl

