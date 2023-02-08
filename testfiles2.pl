my $memfile;
#$memfile->{db}=();
#$memfile->{pf}=();
print "db exists\n" if (exists $memfile->{mud}->{db});
my $filename1=\$memfile->{mud}->{db};
my $filename2=\$memfile->{mud}->{pf};

open (OUT, ">", $filename1);
for my $i (1..200) {
    print OUT "some data $i\n";
}
close (OUT);

print $memfile->{mud}->{db} . "\n";
print "db exists\n" if (exists $memfile->{mud}->{db});

open (OUT, ">", $filename2);
for my $i (1..20) {
    print OUT "other data $i\n";
}
close (OUT);

open (IN, "<", $filename2);
while (my $in=<IN>)
{
    chomp $in;
    print "$in\n";
}
close (IN);
