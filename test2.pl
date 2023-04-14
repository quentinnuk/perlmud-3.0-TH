use strict;
use warnings;

{
	my $stated=0;

	sub counter
	{
		my $cnt=$stated+1;
		while ($cnt>0) {
			$stated++;
			print "$stated\n";
			&resetcount if ($stated>3);
			print "$stated\n";
			$cnt=$stated;
		}
	}

	sub resetcount
	{
		$stated=0;
	}
}



counter();
