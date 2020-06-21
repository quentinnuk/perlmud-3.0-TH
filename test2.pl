use strict;
use warnings;

my @queue;

sub somesub
{
    my ($a, $b) = @_;
    print "a=$a b=$b\n";
}

{
    my ($x,$y) = (1,2);
    push @queue,"\&somesub($x,$y)";
    push @queue,"\&somesub(\"c\",\"d\")";
    while (my $i=shift @queue)
    {
        eval $i;
        print "$@\n"
    }

}
