# for each word in the input create a 2-column tab separated list with original word and flattened phonetisaurus-eligible input
# spaces can be kept in input
# if $ARGV[0] == 0: produce output only
# if $ARGV[0] == 1: produce input and output, tab separated

use open qw(:std :utf8);
use utf8;

while (<STDIN>)
  {
  chomp;
  s/^\s+//g;
  s/\s+$//g;
  s/\s+/ /g;
  $orig = $_;
  $tmp = lc($orig);
  # keep 's as in foto's but rewrite sms'je into sms-je
  $tmp =~ s/\'je/\-je/;
  # $tmp =~ s/([äëïöü])/\-\1/;
  # $tmp =~ tr/àáâãäåçèééêëìíîïñóôöøûüúù/aaaaaaceeeeeiiiinoooouuuu/;
  $tmp =~ s/á/aa/g;
  $tmp =~ s/ç/c/g;
  $tmp =~ s/é/ee/g;
  $tmp =~ s/ó/oo/g;
  $tmp =~ s/í/ie/g;
  $tmp =~ s/ø/eu/;
  $tmp =~ s/[àáâãäå]/a/g;
  $tmp =~ s/[èééêë]/e/g;
  $tmp =~ s/[ìíîï]/i/g;
  $tmp =~ s/ñ/nj/g;
  $tmp =~ s/[óôö]/o/g;
  $tmp =~ s/[ûüúù]/u/g;

  if ($ARGV[0] == 1) {printf("%s\t%s\n", $orig, $tmp);}
  if ($ARGV[0] == 0) {printf("%s\n", $tmp);}
  }

