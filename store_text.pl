#!/usr/bin/perl
use strict;
use warnings;
use autodie qw(:all);


die "usage; $0 <outfile> <infiles>\n" unless @ARGV>1;

my $out;
open($out,">".shift);

