package county;
use strict;
use warnings;

{
	my $stated=0;

	sub counter
	{
		for $stated (1..5) {
			print "$stated\n";
			&resetcount if ($stated>3);
		}
	}

	sub resetcount
	{
		$stated=0;
	}
}

sub foo
{
	print "foo\n";
	&resetcount;
}

sub bar
{
	print "bar\n";
	&foo;
}

1;
