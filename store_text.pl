#!/usr/bin/perl
use strict;
use warnings;
use autodie qw(:all);


die "usage; $0 <cfile> <hfile> <ident> <infile>\n" unless @ARGV==4;

my ($cfile,$hfile,$ident,$infile);
my ($cfile_h,$hfile_h);

$cfile=shift;
$hfile=shift;
$ident=shift;


my $sentinal=$hfile;
for($sentinal) {
  s{[.]}{_};
};
sub qquote($) {
  my $text=join("","",map { chomp; $_ } shift);
  $text=join("\\\\",split /\\/, $text);
  $text=join("\\\"", split /"/, $text);
  return join('"', "",$text,"");
};

open($hfile_h,">$hfile");
print $hfile_h "#ifndef ${sentinal}\n";
print $hfile_h "#define ${sentinal} ${sentinal}\n";
print $hfile_h "\n";
print $hfile_h "\n";
print $hfile_h "\n";
print $hfile_h "extern const char *$ident();\n";
print $hfile_h "\n";
print $hfile_h "\n";
print $hfile_h "#endif // ${sentinal}\n";
close($hfile_h);

open($cfile_h,">$cfile");
print $cfile_h "#include \"$hfile\"\n";
print $cfile_h "\n\n";
print $cfile_h "static char text[] = ";
while(<>) {
  print $cfile_h qquote($_), "\n";
}
print $cfile_h ";\n";
print $cfile_h "const char *$ident(){\n";
print $cfile_h "  return text;\n";
print $cfile_h "}\n";
close($cfile_h);





