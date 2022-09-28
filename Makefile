MAKEFLAGS:=-rR

all: prog


CXXFLAGS:=$(shell perl -MExtUtils::Embed -e ccflags)
CFLAGS:=$(CXXFLAGS)
LDFLAGS:=$(shell perl -MExtUtils::Embed -e ldopts )
CPPFLAGS:=$(shell perl -MExtUtils::Embed -e perl_inc)

#$(warning LDFLAGS:=$(LDFLAGS))
#$(warning CPPFLAGS:=$(CPPFLAGS))

prog: vi_perl.o

prog:%:%.o
	g++    -o $@ $^ $(CFLAGS) $(LDFLAGS)

%.o: %.i
	gcc -c -o $@ $< $(CFLAGS)

%.i: %.c
	gcc -E -o $@ $< $(CPPFLAGS)

vi_perl.c vi_perl.h: vi_perl.pl store_text.pl
	vi_perl store_text.pl vi_perl.c vi_perl.h vi_perl vi_perl.pl

xsinit.c: xsinit.gen
	bash xsinit.gen
	
.PRECIOUS: prog prog.o prog.i prog.c xinit.c xinit.o

