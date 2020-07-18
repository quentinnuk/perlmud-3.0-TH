use strict;
use Scalar::Util qw(looks_like_number);

use warnings;

sub retarr
{
    my @a = @_;
    if (@a) {
        return @a;
    } else {
        return -1;
    }
}

my @b = (1, 2, 3);

my @c = &retarr(@b);

print "@c \n";

print "\@c[0] = $c[0]\n" if ($c[0]==1);

print "retarr=" . &retarr . "\n";

@c = &retarr;

print "@c \n";

print "$c[0]\n";

print "\@c evals to -1\n" if (@c==-1);
print "...\n";
#print "\@c[0] evals to -1\n" if (@c[0]==-1);

1;
