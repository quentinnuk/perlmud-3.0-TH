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

my $file = 'VALLEY.TXT'; # main source file
my $line;
my %roomIds; # maps room identifiers with object ids
my @files = ();
my $fh;
my %textIds; # maps text numeric ids to strings

open LOG, ">log.txt";

if (restore()) {
    open($fh, '<', $file) || die "Can't open $file\n";
    print "Processing $file \n";

    while ($line=read_line()) {
        chomp $line;
        if ($line =~ /^\*rooms/i ) {
            do_rooms();
        }
        if ($line =~/^\*maps/i ) {
            # ignore for now
        }
        if ($line =~/^\*vocabulary/i ) {
            # ignore for now
        }
        if ($line =~/^\*demons/i ) {
            # ignore for now
        }
        if ($line =~/^\*objects/i ) {
            # ignore for now
        }
        if ($line =~/^\*travel/i ) {
            do_travel();
        }
        if ($line =~/^\*text/i ) {
            # ignore for now
            do_texts();
        }
    }
    
    close($fh);
    print "processing complete.\n";

    &dump;
}

close LOG;

sub read_line # reads a line from filehandle and includes sub files as neccssary
{
    my $line=<$fh>;
    chomp $line;

    if (!defined($line)) {
        # return EOF if there are no files in the queue
        return $line if ($#files == -1);

        # pull the most recent file off the queue & resume
        $fh = pop(@files);
        print LOG "POP file\n";
        return read_line();
    }
    # check for an include line
    if ($line =~ /^\@(\w+).*$/)
    {
        # get the new file name and append extension
        my $newFile = $1;
        $newFile=$newFile . '.get';

        # push the current file on the queue
        push(@files, $fh);
        $fh = undef;    # keep open from closing our previous handle

        # open the new file or die
        open($fh, '<', $newFile) || die "Can't open include $newFile\n";
        
        print LOG "INCLUDE: $newFile\n";

        # read from the new file
        return read_line();
    }

    # nothing special, just return the line
    return $line;
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
    
    my $i=0;
    print "Doing rooms\n";
    print LOG "rooms\n";
    while ($line = read_line()) {
        chomp $line;
        if ($line =~ /^\w+\s+.*$/) {
            $i=$#objects + 1; # the next object number after all that have been read in from $dbfile
            $line=lc($line);
            my @roomargs=split(/\s+/,$line);
            print LOG "Room object $i: 0=$roomargs[0] all=@roomargs\n";
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
            $line = read_line();
            chomp $line;
            $line =~ /^\s+(.+)\W$/;
            print LOG "name: $1\n";
            $objects[$i]{"name"}=$1;
            $objects[$i]{"description"}='';
        }
        elsif ($line =~ /^\s+(.+)\s+$/) {
            print LOG "desc: $1\n";
            $objects[$i]{"description"}=$objects[$i]{"description"} . $1 . " ";
        }
        last if ($line=~/^\*.+$/); # end rooms if new section
    }
    print "Resolving room x-refs\n";
    for ($i=0;$i<=$#objects;$i++) {
        my $n = $objects[$i]{"name"};
        my $dmid=$objects[$i]{"dmove"};
        if ($n =~/^%(\w+).*$/) {
            my $objid=$roomIds{$1}; # debug should probably test this is found
            print LOG "x-ref: $i $n is $objid " . $objects[$objid]{"name"} . "\n";
            $objects[$i]{"name"}=$objects[$objid]{"name"};
        }
        $objects[$i]{"dmove"}=$roomIds{$dmid} if (defined $dmid);
    }
    print LOG "end rooms\n";
    print "Done\n";
}

sub do_travel() {
    my $i=0;
    my @travelargs;
    my ($objid, $destid);
    print "Doing travel\n";
    print LOG "travel\n";
    while ($line = read_line()) {
        chomp $line;
        if ($line =~ /^\w+\s+.*$/) {
            $line=lc($line);
            $i=$#objects + 1; # the next object number
            if ($line =~ /(.+)(<|\[)(.+)(>|\])(.*)\s+/) { # joins multi destination lines together (only one multi per line)
                my $destination=join('|',split(/\s+/,$3));
                $line=$1 . "\t" . $destination . "\t" . $5;
                print LOG "multi dest line =$line \n";
            }
            @travelargs=split(/\s+/,$line);
            print LOG "door object $i: @travelargs\n";
            # arg[0] is the roomid these directions apply to
            $objid=$roomIds{(shift @travelargs)} or print LOG "lookup objid $1 failed\n"; # map roomid to object id
        }
        elsif ($line =~ /^\s+.+\s+$/) { # another direction for the same room as objid
            $line=lc($line);
            $i=$#objects + 1; # the next object number
            if ($line =~ /(.+)(<|\[)(.+)(>|\])(.*)\s+/) { # joins multi destination lines together
                my $destination=join('|',split(/\s+/,$3));
                $line=$1 . "\t" . $destination . "\t" . $5;
                print LOG "multi dest line =$line \n";
            }
            @travelargs=split(/\s+/,$line);
            print LOG "$i\t@travelargs\n";
            # arg[0] is empty on follow on lines
            shift @travelargs; # throw away empty arg
        }
        if ($line !~ /^\*.+$/) { # only do this if it is not a new section
            # arg[1] is the condition which we store for now
            my $condition=shift @travelargs; # numeric msg or demon for direction, or class or object test
            $objects[$i]{"condition"}=$condition if ($condition ne 'n'); # no need to keep no condition
            if ($condition=~/^[-]?\d+$/) {
                # condition is a msg or demon number so arg[2] is a direction we need to preserve so dont shift
                $destid = '0'; # no exit in muddl
            } else {
                # arg[2] is the destination roomid or a 0 for no exit if condition is satisfied
                $destid=shift @travelargs; # store roomid that it will send you to, unless the condition was a number
            }
            if ($destid eq '0') { # 0 is no exit and usually comes with a condition
                $destid=$nowhere;
                $objects[$i]{"action"}=$destid; # door to nowwhere
                print LOG "no exit\n";
            } elsif ($destid=~/^(\w+)$/) { # room or class reference
                $destid=$roomIds{$1} or print LOG "lookup destid $1 failed\n"; # map roomid to destination object id
                if (defined $destid) { # its a room
                    $objects[$i]{"action"}=$destid; # sends you to destid object
                    print LOG "action destid=$destid\n";
                }
            } elsif ($destid =~ /.*\|.*/) {
                my @destinations=split(/\|/,$destid);
                foreach my $destination(@destinations) {
                    $destination=$roomIds{$destination} or print LOG "lookup destid $destination failed\n";
                }
                $destid=join('|',@destinations);
                $objects[$i]{"action"}=$destid; # sends you to destid object(s) seperated by colons at random
                print LOG "action destid=$destid\n";
            } else { # its not a room, msg or demon reference, its something unexpected
                print LOG "ignored invalid destid $destid\n";
            }
            $objects[$i]{"owner"}=1; # always the arch-wiz
            $objects[$i]{"type"}=$exit; # type is an exit
            $objects[$i]{"location"}=$objid; # is in room objid
            $objects[$i]{"home"}=$objid; # in case the exit is sent home
            $objects[$i]{"name"}=join( ';',@travelargs); # put directions in name
            if (defined $objects[$objid]{"contents"}) { # put the exit in the room as well
                $objects[$objid]{"contents"}.= ",$i"; # adding contents
            } else {
                $objects[$objid]{"contents"}="$i"; # intialising contents
            }
        }
        last if ($line=~/^\*.+$/); # end travel if new section
    }
    print LOG "end travel\n";
    print "Done\n";
}

sub do_texts() { # stores all the texts reponses into a list for lookup later
    my $i=0;
    my @textargs;
    my ($objid);
    print "Doing text\n";
    print LOG "texts\n";
    while ($line = read_line()) {
        chomp $line;
        if ($line =~ /^\d+\s+.*$/) {
            my @textargs=split(/\s+/,$line,2);
            $objid=shift @textargs; # first thing should be the id used as key
            $textargs[0]=~/^(.*)\s+$/; # trim the end of line
            $textIds{$objid}=$1;
            print LOG "text: objid=$objid txt=" . $textIds{$objid} . "\n";
        }
        elsif ($line =~ /^\s+(.+)\s+$/) {
            print LOG "$i:\t$1\n";
            $textIds{$objid}=$textIds{$objid} . $1 . " ";
        }
        last if ($line=~/^\*.+$/); # end rooms if new section
    }
    # now have all texts, need to x-ref in door objects and add locks and success/fail
    print "Resolving text x-refs\n";
    # to do
    for ($i=0;$i<=$#objects;$i++) { # could use a foreach here but having the index aids debugging
        if ($objects[$i]{"type"}==$exit) {
            my $c = $objects[$i]{"condition"};
            if ($c=~/^\d+$/) { # condition is a msg number not a -ve demon number so set success msg for going nowhere
                $objects[$i]{"success"}=$textIds{$c} or print LOG "invalid text condition $c in objid $i \n";
                print LOG "x-ref $i cond $c resolved\n";
                delete ($objects[$i]{"condition"}); # dont need to keep this now success set up
            }
        } # need to resolve other places where text is used
    }
    print LOG "end texts\n";
    print "Done\n";
}

sub do_compile() {
    my $i=0;
    print "Compiling objects\n";
    print LOG "rooms\n";
    print "Done\n";
}
