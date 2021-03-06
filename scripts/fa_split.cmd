@perl -Sx %0 %*
@goto :eof
#!perl

use File::Temp qw/ :mktemp  /;

sub usage {

print <<EOM;
Usage: fa_split [OPTIONS] < all.txt > training.txt

This program splits input into training and testing sets. It gets upto N of
random test lines from input.

  --out-test=<filename> - specifies file name for the output data,
    testing.txt - is used by default

  --test-size=N - number of base lines to extract from the input stream,
    100 is used by default
EOM

}


#
# process command line parameters
#

$test_size = 100;
$out_test = "testing.txt";

while (0 < 1 + $#ARGV) {

  if("--help" eq $ARGV [0]) {

      usage ();
      exit (0);

  } elsif ($ARGV [0] =~ /^--out-test=(.+)/) {

      $out_test = $1;

  } elsif ($ARGV [0] =~ /^--test-size=(.+)/) {

      $test_size = 0 + $1;

  } else {

      last;
  }
  shift @ARGV;
}

srand();


($fh, $tmp1) = mkstemp ("fa_split_XXXXXXXX");
close $fh;

#
# copy input into temporary file
#

`cat > $tmp1` ;

#
# count input size
#

$lines = 0;

open INPUT1, "< $tmp1" ;

while (<INPUT1>) {
  $lines++;
}

close INPUT1 ;


#
# select random positions of the test set
#

while((0 + keys(%t)) < $test_size) {

  $pos = int(rand($lines)) ;

  if(!(defined $t{$pos})) {
    $t{$pos} = 1 ;
  }
}


#
# split the input
#

open INPUT2, "< $tmp1" ;
open TEST, "> $out_test" ;

$pos = 0;

while (<INPUT2>) {

  $pos++;

  if(defined $t{$pos}) {

    print TEST $_ ;

  } else {

    print $_ ;
  }
}

close INPUT2 ;
close TEST ;


#
# delete temporary file
#

END {
  if ($tmp1 && -e $tmp1) {
    unlink ($tmp1);
  }
}
