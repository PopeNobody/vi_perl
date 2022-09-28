#!/usr/bin/perl

use strict;
use warnings;
use autodie qw(:all);
use autodie qw(fork);
use File::stat;
use Data::Dumper;
BEGIN {
  $Data::Dumper::Useqq=1;
  $Data::Dumper::Deparse=1;
  $Data::Dumper::Sortkeys=1;
};
$|++;
$\="\n";

sub main(@);
exit(main(@ARGV));

use IO::Pipe;
sub run_perl($$$@);
sub run_filt($$$@);

my $realscript;
sub main(@)
{
print Dumper(\@_);
  my ($script);
  if(!@_) {
    die "usage: $0 [script and args ...] ...\n...";
  };
  $script=$realscript=shift;

  if( $realscript ne "-e" ) {
    if( ! -f $realscript ) {
      s{^sudo:}{} for $realscript;
    };
    if( ! -f $realscript ) {
      my @path;
      @path = split(/:/, $ENV{PATH});
      $_=join('/',$_,$realscript) for @path;
      @path = grep { -e } @path;
      $realscript=shift @path;
    };
    if( ! -f $realscript ) {
      undef $script;
    };
  };
  die "no script found" unless defined $script;

  my ($pipe1,$pipe2);
  $pipe1=new IO::Pipe;
  $pipe2=new IO::Pipe;
  my ($perl_pid, $filt_pid);
  my ($perl_res, $filt_res);
  my ($perl_sig, $filt_sig);
  if(($perl_pid=fork)==0) {
    return(run_perl($pipe1,$pipe2,$realscript,@_));
  } elsif(($filt_pid=fork)==0) {
    return(run_filt($pipe1,$pipe2,$script,@_));
  } else {
    my $pid;
    close($pipe1->writer);
    close($pipe2->writer);
    while(($pid=wait)!=-1)
    {
      if( $pid == $perl_pid ) {
        $perl_res=$?/256;
        $perl_sig=$?%256;
        warn "perl done, res=$perl_res, sig=$perl_sig\n" if ($perl_res||$perl_sig);
      } elsif( $pid == $filt_pid ) {
        $filt_res=$?/256;
        $filt_sig=$?%256;
        warn "perl done, res=$filt_res, sig=$filt_sig\n" if ($filt_res||$filt_sig);
      } else {
        die "unknown pid: $pid (\$?=$?)\n";
      };
    };
    if($perl_sig||$filt_sig){
      return(255);
    } else {
      return($perl_res|$filt_res);
    };
  };
  die "wtf?";

};

my ($out,$err);
sub run_perl($$$@) {
  for(sort keys %SIG){
    $SIG{$_}='IGNORE';
  };
  my ($out,$err,$script,@args) = splice(@_);
  open(STDOUT,">&".fileno($out->writer)) or die;
  close($out);
  open(STDERR,">&".fileno($err->writer)) or die;
  close($err);
  exec "perl", $script, @args;
  die "failed!";
};
sub run_filt($$$@)
{
  my ($out,$err,$script,@args) = splice(@_);
  open(STDIN,"</dev/null");
  use IO::Select;
  my $sel = new IO::Select;
  my $out_buf="";
  my $err_buf="";
  $sel->add( [ $out->reader(), \$out_buf, 0 ] );
  $sel->add( [ $err->reader(), \$err_buf, 1 ] );
  while($sel->handles){
    my @can=$sel->can_read;
    for(@can)
    {
      my ($pipe,$ref,$stream);
      ( $pipe, $ref, $stream ) = @$_;
      local (*_)=$ref;
      my $res=sysread($pipe,$_,1,length);
      if(!defined($res)) {
        die "sysread:$!";
      } elsif ( !$res ) {
        $sel->remove($pipe);
        close($pipe) or die "close:$!";
        $_="$_\n" if length($$ref);
      };
      next unless chomp;
      if($stream && s{ at (\S+) line (\d+)\.*}{})
      {
        my ($file,$line) = ($1,$2);
        s{^\t(.*)called\s*$}{called from $1};
        print STDERR "$file:$line: msg $_";
      } else {
        print STDOUT "$_";
      };
      $_="";
    };
  };
  return 0;
};
