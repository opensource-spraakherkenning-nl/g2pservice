# script to create a user-defined lexicon

# CLST, RU, Nijmegen
# Louis ten Bosch
# License GPLv3


# arg 1: a lexicon (2 tab-separated columns: word and pronunciation), typically from phonetisaurus, may contain multiples
# STDIN: a word list, user defined
# STDOUT: a dictionary (two tab-separated columns) respecting the structure in STDIN

# the match between input and first column in arg 1 takes place after lowercasing (case ignorant)

open(LEX, "<" . $ARGV[0]);
while (<LEX>)
  {
  chomp;
  @tok = split(/\t/);
  $word = $tok[0];
  $word =~ s/^\s+//;
  $word =~ s/\s+$//;
  push(@{$W2P{lc($word)}}, $tok[1]);
  }

while (<STDIN>)
  {
  chomp;
  $word = $_;
  $word =~ s/^\s+//;
  $word =~ s/\s+$//;
  if (defined($W2P{lc($word)}))
    {
    foreach $key ( @{$W2P{lc($word)}} )
      {
      printf("%s\t%s\n", $word, $key);
      }
    }
  elsif ($word =~ m/^\s*$/)
    {
    printf("%s\t%s\n", "", "");
    }
  else
    {
    printf("%s\t%s\n", $word, "PRONUNCIATION_NOT_FOUND");
    }

  }

