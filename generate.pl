#!/usr/bin/perl perl

use strict;
use warnings;
use autodie qw(:all);

use ExtUtils::Embed;

open(STDOUT,">Makefile.embed.new");
print "CFLAGS:= ", ccflags(), "\n";
print "LDFLAGS:= ", ldopts(), "\n";
xsinit();
print "generate.pl:4: hi!\n";
link("Makefile.embed.new", "Makefile.embed");
unlink("Makefile.embed.new");



