package county;
use strict;
use warnings;

my $bar='{&bar; 1;}';

{
	my $stated=0;

	sub counter
	{
		($stated)=@_;
		while ($stated>0) {
			print "$stated\n";
			$stated++;
			eval $bar if ($stated>3);
		}
		print "wend $stated\n";
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
