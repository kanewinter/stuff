#!/usr/bin/perl -w

# Created by jplace - Mandiant
# Modified by James Juran to use /usr/share/dict/words rather than wwww.wordswarm.net

use strict;

# Validate arguments
scalar(@ARGV) <= 1 || usage();
my $count;
if (scalar(@ARGV) == 1) {
    $ARGV[0] =~ /^\d+$/ || usage();
    $count = $ARGV[0];
} else {
    $count = 1;
}

my $filename = '/usr/share/dict/words';
open (FILE, $filename) || die "Can't open $filename: $!.  Perhaps you need to install the 'words' package.\n";
my @word_pool=<FILE>;
chomp(@word_pool);
my @symbol_pool = split(" ", '~ ! # $ % ^&  * ( ) + - : ;');
my @number_pool = split(" ", '0 1 2 3 4 5 6 7 8 9');

my $x;
for($x=0; $x < $count; $x++) {
  my $symbol1=$symbol_pool[int(rand($#symbol_pool))];
  my $symbol2=$symbol_pool[int(rand($#symbol_pool))];
  my $num1=$number_pool[int(rand($#number_pool))];
  my $num2=$number_pool[int(rand($#number_pool))];
  my $num3=$number_pool[int(rand($#number_pool))];
  my $word1=lc($word_pool[int(rand($#word_pool))]);
  my $word2=lc($word_pool[int(rand($#word_pool))]);
  my $word3=lc($word_pool[int(rand($#word_pool))]);
  $word1=~ s/[[:punct:]]//g;
  $word2=~ s/[[:punct:]]//g;
  $word3=~ s/[[:punct:]]//g;
  my $pwd1="$word1$num1$num2$symbol1$word2";
  my $pwd2="$word2$num1$num2$symbol1$word1";
  my $pwd3="$word3$symbol2$num3";
  print "$pwd1 $pwd2 $pwd3\n";
}

sub usage {
    print "Usage: pwdgen.sh [count]\n";
    exit(-1);
}
