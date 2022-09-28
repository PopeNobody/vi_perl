#!/usr/bin/perl perl

use ExtUtils::Embed;

xsinit();
print "CFLAGS:= ",ccflags(),"\n\n";

ldopts();

print "generate.pl:4: hi!\n";



