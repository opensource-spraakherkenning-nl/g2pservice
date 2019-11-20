# script to create a user-defined lexicon

# CLST, RU, Nijmegen
# Louis ten Bosch
# License GPLv3


# arg 1: a lexicon (2 tab-separated columns: word and pronunciation), typically from phonetisaurus, may contain multiples
# STDIN: a two column file (user word - tab - flattened word for phonetisaurus)
# STDOUT: a dictionary (two tab-separated columns) respecting the structure in STDIN

# the match between input and first column in arg 1 takes place after lowercasing (case ignorant)

use open qw(:std :utf8);
use utf8;

open(LEX, "<" . $ARGV[0]);
while (<LEX>)
  {
  chomp;
  @tok = split(/\t/);
  $word = $tok[0];
  $word =~ s/^\s+//;
  $word =~ s/\s+$//;
  push(@{$W2P{$word}}, $tok[1]);
  }

while (<STDIN>)
  {
  chomp;
  @tok = split(/\t/);
  $orig = $tok[0];
  $flattened = $tok[1];
  if (defined($W2P{$flattened}))
    {
    foreach $key ( @{$W2P{$flattened}} )
      {
      printf("%s\t%s\n", $orig, $key);
      }
    }
  elsif ($orig =~ m/^\s*$/)
    {
    printf("%s\t%s\n", "", "");
    }
  else
    {
    printf("%s\t%s\n", $orig, "PRONUNCIATION_NOT_FOUND");
    }

  }

