use strict;

my $dbFile = "mud.db";
my $perlMudVersion = 3.0;

#Object types

my $room = 1;
my $player = 2;
my $exit = 3;
my $thing = 4;
my $topic = 5;

#Special IDs

my $none = -1;
my $home = -2;
my $nowhere = -3;

#Can't be seen; or description only, contents invisible
my $dark = 1;

#Gender
my $male = 2;
my $female = 4;
my $herm = 6;

#Name of location visible in who list
my $public = 8;

#Unused flag
my $unusedFlag = 16;
#OK to link to
my $linkok = 32;

#OK to jump to
my $jumpok = 64;

#OK for anyone to build here
my $buildok = 128;

#Claimable by anyone who passes the lock
#(Not yet implemented)
my $claimok = 256;

#Goes home when dropped
my $sticky = 512;

#Part of a puzzle; a teleport or home command
#from this location drops all objects carried.

my $puzzle = 1024;

#If true, this location can be set home (@link)
#for an object by anyone.
my $abode = 2048;

#If true for a room, this location is "grand central station":
#players can see things, hear people speak, etc., but arrivals and
#departures go unnoticed.
my $grand = 4096;

#If true for an object, any person can "sign" the object,
#appending a string of up to 60 characters to its description.
my $book = 8192;

#This player is a wizard. #1 is always a wizard.
my $wizard = 16384;

#This player hates automatic speech and wants more abbreviations.
my $expert = 32768;

#This player wants to know who @emits things.
#Only an issue if $allowEmit is set.
my $spy = 65536;

#This player is allowed to build things. Set for new
#players if $allowBuild is set. Only a wizard can change
#this flag after that.
my $builder = 131072;

#If the book flag is set, and the once flag is also set, then
#any subsequent signature replaces all previous signatures
#by the same individual.
my $once = 262144;

# there is water here
my $water = 524288;

# there is oil here
my $oil = 1048576;

# if a mortal player enters they die
my $death = 2097152;

# objects dropped here add to score by object value
my $sanctuary = 4194304;

# If a player is in here, they cannot be seen from outside by mortals
my $hideaway = 8388608;

# If an object is in here, it cannot be seen by mortal players.
my $hide = 16777216;

# Only one player or mobile can be in this room at a time.
my $small = 33554432;

# This means that the room cannot be looked into from an adjacent room
my $nolook = 67108864;

# If a wiz is in a silent room, then they receives no status messages
my $silent = 134217728;

#For flag setting
my %flags = (
    "dark", $dark,
    "male", $male,
    "female", $female,
    "public", $public,
    "linkok", $linkok,
    "jumpok", $jumpok,
    "buildok", $buildok,
    "claimok", $claimok,
    "link_ok", $linkok,
    "jump_ok", $jumpok,
    "build_ok", $buildok,
    "claim_ok", $claimok,
    "link-ok", $linkok,
    "jump-ok", $jumpok,
    "build-ok", $buildok,
    "claim-ok", $claimok,
    "sticky", $sticky,
    "puzzle", $puzzle,
    "abode", $abode,
    "grand", $grand,
    "book", $book,
    "wizard", $wizard,
    "expert", $expert,
    "spy", $spy,
    "builder", $builder,
    "once", $once,
    "water", $water,
    "oil", $oil,
    "death", $death,
    "sanctuary", $sanctuary,
    "hideaway", $hideaway,
    "hide", $hide,
    "small", $small,
    "no-look", $nolook,
    "silent", $silent
);

my %flagsProper = (
    "dark", $dark,
    "male", $male,
    "female", $female,
    "public", $public,
    "linkok", $linkok,
    "jumpok", $jumpok,
    "buildok", $buildok,
    "claimok", $claimok,
    "sticky", $sticky,
    "puzzle", $puzzle,
    "abode", $abode,
    "grand", $grand,
    "book", $book,
    "wizard", $wizard,
    "expert", $expert,
    "spy", $spy,
    "builder", $builder,
    "once", $once,
    "water", $water,
    "oil", $oil,
    "death", $death,
    "sanctuary", $sanctuary,
    "hideaway", $hideaway,
    "hide", $hide,
    "small", $small,
    "nolook", $nolook,
    "silent", $silent
);

my @flagNames = (
    "dark",
    "male",
    "female",
    "unusedFlag",
    "public",
    "linkok",
    "jumpok",
    "buildok",
    "claimok",
    "sticky",
    "puzzle",
    "abode",
    "grand",
    "book",
    "wizard",
    "expert",
    "spy",
    "builder",
    "once",
    "water",
    "oil",
    "death",
    "sanctuary",
    "hideaway",
    "hide",
    "small",
    "nolook",
    "silent"
);

my @objects; # contains all the objects

my $file = 'MUD.TXT'; # source file
my $line;
my $count = 19; # starting object number

if (restore()) {
    open(DATA, "<$file");
    print "Processing $file \n";

    while ($line = <DATA>) {
        chomp $line;
        if (substr($line,0,6) eq '*rooms') {
            do_rooms();
        }
    }
    
    close DATA;
    print "processing complete.\n";

    &dump;

}


sub restore
{
    my($id, $dbVersion, $dbVersionKnown);
    if (!open(IN, $dbFile)) {
        print "Unable to read from " . $dbFile . ".\n";
        print "Please read the documentation and follow\n";
        print "all of the instructions carefully.\n";
        exit 0;
    }
    $dbVersionKnown = 0;
    while($id = <IN>) {
        if (!$dbVersionKnown) {
            $dbVersionKnown = 1;
            if (!($id =~ /^\d+\.\d+\s*$/)) {
                $dbVersion = 0.0;
            } else {
                $dbVersion = $id;
                if ($dbVersion > $perlMudVersion) {
                    print "This database was written by ",
                    "a newer version of PerlMUD!\n",
                    " You need version ",
                    $dbVersion . " to read it.\n";
                    close(IN);
                    return 0;
                }
                next;
            }
        }
        chomp $id;
        if ($dbVersion >= 2.1) {
            # New style database, hurrah
            while (1) {
                my($attribute, $value, $line);
                $line = <IN>;
                if ($line eq "") {
                    #Uh-oh
                    print "Database is truncated!\n";
                    return 0;
                }
                chomp $line;
                if ($line eq "<END>") {
                    last;
                }
                # Get the attribute and the value
                ($attribute, $value) = split(/ /, $line, 2);
                # Unescape endlines
                $value =~ s/\\n/\r\n/g;
                # But a slash preceding one of those
                # means an escaped LF is truly wanted
                $value =~ s/\\\r\n/\\n/g;
                $objects[$id]{$attribute} = $value;
            }
            $objects[$id]{"id"} = $id;
            if ($id == 1) { # id 1 is always the arch-wizard
                $objects[1]{"flags"} |= $wizard;
            }
            # GOTCHA: $none and 0 are different
            $objects[$id]{"activeFd"} = $none;
        }
    }
    close(IN);
    return 1;
}

sub dump
{
    if (!open(OUT, ">$dbFile.tmp")) {
        print "Unable to write to $dbFile.tmp\n";
        return;
    }
    print "Dumping...\n";
    my($i);
    my($now) = time;
    # The database format changed with version 2.1,
    # not whatever this release may be (I doubt there will be
    # a need for further changes, hurrah -- upwards compatible)
    print OUT "2.1\n";
    # Oh, this is achingly beautiful
    for ($i = 0; ($i <= $#objects); $i++) {
        # Don't save recycled objects
        if ($objects[$i]{"type"} == $none) {
            next;
        }
        print OUT $i, "\n";
        # Now regular data
        my($attribute, $value);
        foreach $attribute (keys %{$objects[$i]}) {
            # Important: filter out any connection
            # dependent attributes here if you don't
            # want them dumped and restored.
            if ($attribute eq "activeFd") {
                # Connection dependent. Don't save it.
                next;
            }
            if ($attribute eq "lastPing") {
                # Connection dependent. Don't save it.
                next;
            }
            if ($attribute eq "brain") {
                # Do not attempt to write out the brain
                next;
            }
            if ($attribute eq "id") {
                # Already written out.
                next;
            }
            $value = $objects[$i]{$attribute};
            $value =~ s/\\n/\\\\n/g;
            $value =~ s/\r\n/\\n/g;
            $value =~ s/\n/\\n/g;
            # Trim out null values at save time.
            if ($value ne "") {
                print OUT $attribute, " ", $value, "\n";
            }
        }
        print OUT "<END>\n";
    }
    if (!close(OUT)) {
        print "Warning: couldn't complete save to $dbFile.tmp!\n";
        # Don't try again right away
        return;
    }
    unlink("$dbFile");
    rename "$dbFile.tmp", "$dbFile";
    print "Dump complete.\n";
}

sub do_rooms
{
    my %roomIds; # maps room identifiers with object ids
    
    my $i=0;
    print "Doing rooms\n";
    while ($line = <DATA>) {
        chomp $line;
#        if (substr($line,0,1) eq '@') { # handle include files somehow
#            $line = <DATA>;
#            chomp $line;
#        }
        if ($line =~ /^(\w+)\s+.*$/) {
            $i=$#objects + 1; # the next object number after all that have been read in from $dbfile
            my @roomargs=split(/\s+/,$line);
            $objects[$i]{"type"}=$room; # its a room
            $objects[$i]{"owner"}=1; # always the arch-wiz owns it
            $objects[$i]{"room"}=$roomargs[0]; # first argument of room is the room identifier
            $roomIds{$roomargs[0]}=$i;
            my $flags=$dark;
            if ($#roomargs>0) {
                for (my $j=1;$j<=$#roomargs;$j++) {
                    if ($roomargs[$j] eq 'light') {
                        $flags=$flags - $dark;
                    } elsif ($roomargs[$j] eq 'dmove') {
                        $j++;
                        $objects[$i]{"dmove"}=$roomargs[$j]; # the argument to dmove is a room id - need to convert to obj id later
                        next;
                    } else {
                        $flags |= $flagsProper{$roomargs[$j]};
                    }
                }
            }
            $objects[$i]{"flags"}=$flags;
            $line = <DATA>;
            chomp $line;
            $line =~ /^\s+(.+)\W$/;
            $objects[$i]{"name"}=$1;
            $objects[$i]{"description"}='';
            print "$i\r";
        }
        elsif ($line =~ /^\s+(.+)\s+$/) {
            $objects[$i]{"description"}=$objects[$i]{"description"} . $1 . " ";
        }
        last if (substr($line,0,7) eq '@txtmap') || (substr($line,0,1) eq '*'); # end rooms if new section
    }
    print "\nResolving room x-refs";
    for ($i=0;$i<=$#objects;$i++) {
        my $n = $objects[$i]{"name"};
        if (substr($n,0,1) eq '%') {
            my $roomid=substr($n,1);
            my $objid=$roomIds{"$roomid"}; # should probably test this is found
            $objects[$i]{"name"}=$objects[$objid]{"name"};
        }
    }
    print "\nDone\n";
}

