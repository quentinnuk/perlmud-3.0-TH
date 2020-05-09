use strict;
use Scalar::Util qw(looks_like_number);

use warnings;

my $instruction = 'if ( mud_ifdumb($me,$arg,$arg1,$arg2,\'null\',\'1\') ) {&flush($me,$arg,$arg1,$arg2); &tellPlayer($me,$objects[0]{"msg1"}); 1; }';
my @objects;
my ($me,$arg,$arg1,$arg2) = qw (0 123 1 2);

$objects[0]{"msg1"}="test message";
$objects[0]{"msg2"}="test message 2";

print "eval instruction\n";
my $a = eval $instruction;
print "returned $a \n";
print "eval complete\n";
#print "inline\n";
#if ( mud_testsmall($me,$arg,$arg1,$arg2,'null') ) {&tellPlayer($me,$objects[0]{"msg1"}); } else { &tellPlayer($me,$objects[0]{"msg2"}); }
#print "inline complete\n";
    
sub mud_testsmall
{
    my ($me,$arg,$arg1,$arg2,$farg1) = @_;
    print "mud_testsmall\n";
    return 1; # true
}

sub mud_ifblind
{
    my ($me,$arg,$arg1,$arg2,$farg1,$farg2) = @_;
    print "mud_ifblind\n";
    return 0; # false
}

sub mud_ifdumb
{
    my ($me,$arg,$arg1,$arg2,$farg1,$farg2) = @_;
    print "mud_ifdumb\n";
    return 0; # false
}

sub flush
{
    my ($me,$msg) = @_;
    print "flush\n";
}

sub tellPlayer
{
    my ($me,$msg) = @_;
    print "tellPlayer $msg\n";
}

sub tellRoom
{
    my ($me,$msg) = @_;
    print "tellRoom\n";
}
