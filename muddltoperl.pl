use strict;
use Scalar::Util qw(looks_like_number);

my $dbFile = "mud.db";
my $perlMudVersion = 3.0;

#Object types

my $room = 1;
my $player = 2;
my $exit = 3;
my $thing = 4;
my $topic = 5;
my $synonym = 6;
my $action = 7;
my $demon = 8;

#Special IDs

my $none = -1;
my $home = -2;
my $nowhere = -3;

# demon flags

my $dEnabled = 1;
my $dGlobal = 2;
my $dAlways = 4;

#Can't be seen; or description only, contents invisible
my $dark = 1;

#Gender
my $male = 2;
my $female = 4;
my $herm = 6;

#Name of location visible in who list
my $public = 8;

#Gives off light
my $bright = 16;

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

# you cannot pick up an object with this flag
my $noget = 268435456;

# you can always see the contents of this object even if not prop 0
my $transparent = 536870912;

# objects can be removed even if not at prop 0
my $opened = 1073741824;

# there will be no indication that this object is a container
my $disguised = 2147483648;

# need a 64bit arch for these flags
# if you carry this object you cannot be summoned
my $nosummon = 4294967296;

# impossible to pick up even for wizards (eg tide or rain)
my $fixed = 8589934592;

# will never be assigned to "it"
my $noit = 17179869184;

# illnesses
my $blind = 34359738368;

my $deaf = 68719476736;

my $dumb = 137438953472;

my $paralysed = 274877906944;

my $asleep = 549755813888;

my $destroyed = 1099511627776;

#For flag setting
my %flags = (
    "dark", $dark,
    "male", $male,
    "female", $female,
    "public", $public,
    "bright", $bright,
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
    "silent", $silent,
    "no-get", $noget,
    "transparent", $transparent,
    "opened", $opened,
    "disguised", $disguised,
    "no-summon", $nosummon,
    "fixed", $fixed,
    "no-it", $noit
);

my %flagsProper = (
    "dark", $dark,
    "male", $male,
    "female", $female,
    "public", $public,
    "bright", $bright,
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
    "silent", $silent,
    "noget", $noget,
    "transparent", $transparent,
    "opened", $opened,
    "disguised", $disguised,
    "no-summon", $nosummon,
    "fixed", $fixed,
    "noit", $noit
);

my @flagNames = (
    "dark",
    "male",
    "female",
    "unusedFlag",
    "public",
    "bright",
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
    "silent",
    "noget",
    "transparent",
    "opened",
    "disguised",
    "no-summon",
    "fixed",
    "noit"
);

my %demonFlagsProper = (
    "enabled", $dEnabled,
    "global", $dGlobal,
    "always", $dAlways
);

my %mudFunctions =
(
 "backrot", 1, # not implemented
 "create", 1, # obj; undestroy (create) object
 "dead", 1, # null; do action and quit
 "dec", 1, # (obj|null); decrements prop>0, null implies command noun1
 "decdestroy", 1, # (obj|null); dec prop of noun1>=0 destroy obj?
 "decifzero", 1, # (obj|null); dec prop if > 0, and call if zero
 "decinc", 1, # (obj|null); dec obj or noun1 and inc obj or noun2
 "delaymove", 3, # null room demon; drop noun1 in room after a delay, queue demon specified in demon, then fire $demon
 "destroy", 1, # (obj|null); destroys obj or command noun1
 "destroycreate", 1, # (obj); destroys command noun1 then creates obj
 "destroydec", 1, # (obj|null); destroy obj or noun1 and dec prop of obj or noun2 and out msg
 "destroydestroy", 1, # (obj|null); looks like it destroys command noun1 and param1 obj
 "destroyinc", 1, # (obj|null); destroy obj or noun1 and inc prop of obj or noun2 and out msg
 "detroyset", 2, # obj value; destroy noun1 and set obj property to value
 "destroytogglesex", 1, # null; destroy noun1 and flip sex of player
 "destroytrans", 2, # null room; destroys noun1 and transports player to room
 "disenable", 2, # null value; terminate demon value and do actions
 "emotion", 2, # (obj|null) value; reduce player score by 2*value and increase target obj or noun1 score by (2*value)/3
 "enable", 2, # null value; enable demon value and do action
 "exp", 2, # (obj|null) value; add value to obj or player score
 "expdestroy", 1, # (obj|null); destroy obj and earn score; null is command noun1
 "expinc", 1, # (obj|null); adds score for obj or noun1 to player and increments prop by one
 "expmove", 2, # (obj|null) room; adds score for obj or noun1 to player and transports obj to room
 "expset", 2, # (obj|null) value; gain the score determined by obj or noun1 score if the scoreprop=prop and then do fn set ??? debug understand code in MUD3 setexp
 "fix", 1, # (obj|null); # sets the fixed flag on obj or noun1
 "flipat", 1, # null; flips noun1 and noun2 around in response to "at" preposition
 "float", 1, # (obj|null); clears the fixed flag on obj or noun1
 "floatdestroy", 1, # obj; # incs prop and clears the fixed flag on noun1, destroys obj
 "flush", 1, # null; flush input buffer and do action
 "forrot", 1,  # not used
 "holdfirst", 1, # null; debug not sure what it does maybe checks player has noun1 in inventory not that its just in room????
 "holdlast", 1, # null; debug not sure what it does maybe checks player has noun2 in inventory not that its just in room????
 "hurt", 2, # (obj|null) value; obj or noun1 is attacked with noun2 and the value is the minimum initial hit bitor with the weapon and determines msg?
 "ifasleep", 2, # null value; if asleep flag is value do actions
 "ifberserk", 1, # null; never gong to be true as we wont support berserkers
 "ifblind", 2, # (obj|null) value; if blind flag is value do action
 "ifdead", 1, # obj; test if obj is dead
 "ifdeaf", 2, # (obj|null) value; if deaf flag is value do action
 "ifdestroyed", 1, # obj; test if obj is destroyed
 "ifdisenable", 2, # null value; if demon value is currently enabled kill it and do actions if could kill
 "ifdumb", 2, # (obj|null) value; if dumb flag is value do action
 "ifenabled", 2, # null value; if demon value is currently enabled do actions
 "iffighting", 1, # (obj|null); if obj or player is fighting do action
 "ifgot", 1, # obj; do if got obj and using it??? debug
 "ifhave", 1, # obj; if carrying obj but not using it do action
 "ifhere", 1, # obj; do if obj is here???
 "ifheretrans", 2, # (obj|null) room; if the obj or noun1 is here, transport player to room
 "ifill", 1, # (obj|null); if obj or player is ill do action
 "ifin", 2, # (obj|null) location; if obj or player in location do action
 "ifinc", 2, # (obj|null) room; if player in room inc the prop of obj or noun1
 "ifinsis", 1, # obj; if instrument (noun2) is obj then do actions
 "ifinvis", 2, # (obj|null) value; if invis flag of player or obj is value do action
 "iflevel", 2, # (obj|null) value; if player or obj level >= value do action
 "iflight", 1, # null; returns true if you can see in current location
 "ifobjcontains", 1, # not used
 "ifobjcount", 3, # null room count; if the number of objects in room is greater or equal to count then true
 "ifobjis", 1, # obj; if noun2 is obj do action
 "ifobjplayer", 1, # (null|obj); if obj or noun1 is a player
 "ifparalysed", 2, # (obj|null) value; if paralysed flag is value do action
 "ifplaying", 1, # (null|player); if obj or noun1 is playing
 "ifprop", 2, # (obj|null) value; tests prop value of obj, null implies command noun1
 "ifpropdec", 2, # (null|obj) value; if the prop of obj noun1 is value, decrement prop and succeed
 "ifpropdestroy", 2, # (obj|null) value; if the prop of obj or noun1 is value, then destroy obj
 "ifpropinc", 2, # (null|obj) value; if the prop of obj noun1 is value, inc prop and succeed
 "ifr", 2, # (obj|null) value; if random(100)<value do action and set IFR why debug???
 "ifrlevel", 2, # (obj|null) value; if (1+player level * value > random(100) or wiz) and (1+level of target obj or noun1 * value < random (100) not wiz) do action
 "ifrprop", 2, # (obj|null) value; if maxprop<0 of obj or noun1 set prop to random(maxprop) and if prop is value do action
 "ifrstas", 1, # null; if random(stamina of player) < random(stamina of mobile) do actions??? - this is a mobile specific function debug
 "ifself", 1, # null; if target is self
 "ifsex", 2, # null value; if sex of player is value (0 male, 1 female)
 "ifsmall", 1, # (obj|null); if obj or room has flag small
 "ifsnooping", 1, # null; if player is snooping do action
 "ifweighs", 2, # (obj|null) value; if obj or noun1 weight >= value do msg
 "ifwiz", 1, # (obj|null); do if obj or command noun1 a wiz
 "ifzero", 1, # (obj|null); test prop is zero, null implies command noun1
 "inc", 1, # (obj|null); inc prop<=maxprop, null implies command noun1
 "incdec", 1, # (obj|null); inc obj or noun1 and dec obj or noun2
 "incdestroy", 1, # (obj|null); inc prop of noun1<=maxprop and destroy obj?
 "incmove", 2, # (obj|null) room; inc prop of obj or noun1<=maxprop and move obj to room
 "incsend", 2, # obj room; increments obj prop, in every room containing obj either destroys things or sends players to room and drops inventory
 "injure", 2, # (obj|null) value; deducts value stamina from obj or command noun1, does not start combat
 "loseexp", 2, # null value; reduce score of player by value
 "losestamina", 2, # (obj|null) value; deduct value stamina from obj or command noun1
 "move", 2, # (obj|null) room; move obj to room, null implies command noun1
 "noifr", 1, # null; clear IFR flag why debug?
 "null", 1, # null; null function?
 "resetdest", 2, # obj value; resets mobile object to home location with stamina of value
 "retal", 2, # null value; retaliates like hurt with a bitor of weapon value and out msg
 "send", 2, # obj room; sends every player co-located with obj to room
 "sendemon", 2, # (obj|null) demon; executes demon passing obj or command noun1 as object
 "sendeffect", 2, # obj msgid; sends msgid to every room that contains obj
 "sendlevel", 2, # (obj|null) value; send a message noun2 to all players of level value-1 and do action
 "sendmess", 2, # null message; sends message text to everyone in the room that $me is in
 "set", 2, # (obj|null) value; sets prop to value, null implies command noun1
 "setdestroy", 2, # (obj|first|second) value; destroys obj (eg door), sets the prop of noun1 (eg cannon) to value
 "setfloat", 2, # obj value; sets the prop of obj to value and clears the fixed flag
 "setsex", 2, # (obj|null) value; set sex of me or obj to value (0 is male, 1 is female)
 "ssendemon", 2, # null value; sends something to demon value and do action?? debug
 "stamina", 2, # (obj|null) value; set stamina of obj or player/mobile to min(current stamina+value,100)
 "staminadestroy", 2, # (obj|null) value; destroy obj or noun1 and set stamina of player to value or maxstamina
 "suspend", 2, # null value; suspend demon value
 "swap", 1, # obj; swap the current prop value of obj with the current prop value of noun1
 "testsex", 1, # (obj|null); if male msg1 else msg2
 "testsmall", 1, # (null); test if location has small flag, output msg1 if true else msg2
 "toggle", 1, # (obj|null); toggles the prop of obj or noun1 between currprop and maxprop-currprop, usually 0 and 1
 "togglesex", 1, # null; toggles my sex
 "trans", 2, # null room; teleports player to room instantly. room may be <room1 room2 roomn> for random room
 "transhere", 1, # obj; move obj to my location if obj is not in a death or hideaway room and is not destroyed
 "transwhere", 1, # obj; moves me to location of object
 "unlessbeserk", 1, # null; unless I am berserk, fail
 "unlessdead", 1, # obj; return true unless obj is dead (destroyed or stamina<=0)
 "unlessdestroyed", 1, # obj; return true unless obj is destroyed (destroyed or stamina<0)
 "unlessdisenable", 2, # null value; unless demon value is enabled, return true, else disable demon, return false
 "unlessenabled", 2, # null value; unless the demon value is enabled, return true
 "unlessfighting", 1, # (obj|null); unless player is fighting do action
 "unlessgot", 1, # obj; dont do if got obj in inventory and using it??? debug?
 "unlesshave", 1, # obj; unless carrying obj and not using it do action
 "unlesshere", 1, # obj; unless obj is here output msg1 else output msg2 (or nothing if 0)
 "unlessill", 1, # null; do action unless deaf, dumb, blind, paralysed - demon action debug ????
 "unlessin", 2, # (ob|null) room; unless obj or player in room do action
 "unlessinc", 2, # (obj|null) room; unless player in room inc the prop of obj or noun1
 "unlessinsis", 1, # obj; do action unless instrument (noun2) is obj
 "unlesslevel", 2, # null value; if level of player < value then do actions
 "unlessobjcontains", 1, # not in use
 "unlessobjis", 1, # obj; do action unless noun1 is obj
 "unlessobjplayer", 1, # (obj|null); do unless obj or player is a persona
 "unlessplaying", 2, # (obj|null) value; unless there is a player of level value playing
 "unlessprop", 2, # (obj|null) value; tests prop value of obj, null implies command noun1
 "unlesspropdestroy", 2, # (obj|null) value; unless prop of obj is value destroy noun1
 "unlessrlevel", 2, # (obj|null) value; do action unless (1+player level * value > random(100) or wiz) and (1+level of target obj or noun1 * value < random (100) not wiz)
 "unlessrstas", 1, # null; if random(stamina of player) < random(stamina of noun1) do actions??? - this is a mobile specific function
 "unlesssmall", 1, # (obj|null); unless obj or room has flag small
 "unlesssnopping", 1, # null; unless I am snooping, succeed
 "unlessweighs", 2, # (obj|null) value; unless weight of obj or noun1 >= value, succeed
 "unlesswiz", 1, # (obj|null); do primitive and messages unless obj or player is a wiz
 "writein", 1, # (obj|null); append the second parameter text into obj or noun1 if null (books etc)
 "zonk", 1 # null; I die. Permanently.
);

my @objects; # contains all the objects

my $file = 'MUD.TXT'; # main source file
my $line;
my %roomIds; # maps room identifiers with object ids
my @files = ();
my $fh;
my %textIds; # maps text numeric ids to strings
my %objIds; # maps thing names to numeric ids
my %classIds; # class exists map
my @vocabobj = (); # allow forward declare of objects in vocab
my $logfile = 'log.txt';

if ($ARGV[0] ne '') { # pass the database in ARGV
    $file = uc($ARGV[0]) . ".TXT";
    $dbFile = lc($ARGV[0]) . ".db";
    $logfile = lc($ARGV[0]) . ".log";
};

open LOG, ">$logfile";

if (restore()) {
    open($fh, '<', $file) || die "Can't open $file\n";
    print "Processing $file \n";

    while ($line=read_line()) {
        chomp $line;
        if ($line =~ /^\*rooms/i ) {
            &do_rooms;
        }
        if ($line =~/^\*maps/i ) {
            # ignore for now
        }
        if ($line =~/^\*vocabulary/i ) {
            &do_vocab;
        }
        if ($line =~/^\*demons/i ) {
            &do_demons;
        }
        if ($line =~/^\*objects/i ) {
            &do_objects;
        }
        if ($line =~/^\*travel/i ) {
            &do_travel;
        }
        if ($line =~/^\*text/i ) {
            &do_texts;
        }
    }
    &do_compile; # resolve outstanding links
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
        next if ($line=~/^\;/); # ignore comment lines
        if ($line =~ /^\w+\s+.*$/) {
            $i=$#objects + 1; # the next object number after all that have been read in from $dbfile
            $line=lc($line);
            my @roomargs=split(/\s+/,$line);
            print LOG "Room object $i: 0=$roomargs[0] all=@roomargs\n";
            $objects[$i]{"type"}=$room; # its a room
            $objects[$i]{"owner"}=1; # always the arch-wiz owns it
            $objects[$i]{"room"}=substr($roomargs[0],0,6); # first argument of room is the room identifier max 6 characters
            $roomIds{substr($roomargs[0],0,6)}=$i;
            my $flags=$dark;
            if ($#roomargs>0) {
                for (my $j=1;$j<=$#roomargs;$j++) {
                    if ($roomargs[$j] eq 'light') {
                        $flags=$flags - $dark;
                    } elsif ($roomargs[$j] eq 'dmove') {
                        $j++;
                        $objects[$i]{"dmove"}=$roomargs[$j]; # the argument to dmove is a room id - need to convert to obj id later
                        next;
                    } elsif ($roomargs[$j] eq 'chain') {
                        $j++;
                        $objects[$i]{"chain"}=$roomargs[$j]; # the mud executable to run
                        $j++;
                        $objects[$i]{"chain"} .= "," . $roomargs[$j]; # the room id to start in
                        next;
                    } else {
                        $flags |= $flagsProper{$roomargs[$j]};
                    }
                }
            }
            $objects[$i]{"flags"}=$flags;
#            $line = read_line();
#            chomp $line;
#            $line =~ /^\s+(.+)\W$/;
#            print LOG "name: $1\n";
#            $objects[$i]{"name"}=$1;
#            $objects[$i]{"description"}='';
        }
        elsif ($line =~ /^\s+(.+)\s+$/) {
            if ($objects[$i]{"name"} eq "") {  # if we dont have the name yet, then its the name
                print LOG "name: $1\n";
                $objects[$i]{"name"}=$1;
                $objects[$i]{"description"}='';
            } else { # else its the description
                print LOG "desc: $1\n";
                $objects[$i]{"description"}=$objects[$i]{"description"} . $1 . " ";
            }
        }
        last if ($line=~/^\*.+$/); # end rooms if new section
    }
    print "Resolving room x-refs\n";
    for ($i=0;$i<=$#objects;$i++) {
        my $n = $objects[$i]{"name"};
        my $dmid=$objects[$i]{"dmove"};
        if ($n =~/^%(\w+).*$/) {
            my $objid=$roomIds{substr($1,0,6)}; # debug should probably test this is found
            print LOG "x-ref: $i $n is $objid " . $objects[$objid]{"name"} . "\n";
            $objects[$i]{"name"}=$objects[$objid]{"name"};
        }
        $objects[$i]{"dmove"}=$roomIds{substr($dmid,0,6)} if (defined $dmid);
    }
    print LOG "end rooms\n";
    print "Done\n";
}

sub do_travel {
    # doors are in the general form:
    # roomname [~][condition] message#|-demon|destination(s) directions
    # coontinued by
    #       [~][condition] message#|-demon|destination(s) directions
    # ~ inverts the condition (logical NOT)
    # if the condition is not met, move goes on to the next matched direction for the room
    # examples to be dealt with:
    #     n    start    [o    n    ne    e]; random direction from o,n,ne,e will take you to start this reset
    #bank5    1003    nw    n ;nw or n from bank5 will trigger message 1003 and fail
    #   1002    ne    e    u ;ne or e from bank4 will trigger message 1002 and fail
    #   n    bank4    se    s    swamp    o    d; se,s,swamp,o,d will take you to bank4
    #track1    n    clifff    s    sw; s or sw from track1 will take you to clifff with no condition
    #    beast    474    jump; if beast is in inventory and prop is 0 when jump trigger message 474
    #    ~parachute    beach    jump; if parachute is NOT in inventory when jump move to beach
    #    -13    jump; jump fires demopn 13
    #    52    w; w from track1 will trigger message 52
    #
    my $i=0;
    my @travelargs;
    my ($objid, $destid);
    print "Doing travel\n";
    print LOG "travel\n";
    while ($line = read_line()) {
        chomp $line;
        next if ($line=~/^\;/); # ignore comment lines
        ($line,my $comment) = split(/;/,$line,2); # seperate out in line comments
        if ($line =~ /^\w+\s+.*$/) { # if (word,whitespace,text) then new room exits
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
            $objid=$roomIds{(shift @travelargs)} or print LOG "lookup roomid $1 failed\n"; # map roomid to object id
        } elsif ($line =~ /^\s+.+\s+$/) { # another direction for the same room as objid
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
        if ($line !~ /^\*.+$/) { # only process arguments if it is not a new section
            # arguments can be as follows:
            # [condition] message|demon|destination(s) direction(s)
            # debug if the destination is 0 then now way out - not quite truel in Essex it outputs an empty message 0
            $objects[$i]{"type"}=$exit; # defining an exit
            $objects[$i]{"location"}=$objid; # where is it located
            my $cond=0;
            while (@travelargs) { # work through arguments
                my $nextarg = shift @travelargs;
                print LOG "$i cond=$cond nextarg=\'$nextarg\'\n";
                if ($nextarg =~ /^[-]?\d+$/) { # message or demon or 0
                    $objects[$i]{"action"}=$nowhere; # if there is a message or demon or 0 then there cant be a destination
                    $objects[$i]{"msgdemon"}=$nextarg; # store the message or demon for later
                    $cond=1; # conditions always come before message or demon
                    print LOG "$i no exit\n";
                } elsif ($nextarg =~ /^[\$\w|]+$/) { # condition, destination or direction
                    if ($nextarg =~ /.*\|.*/) { # multi destination
                        print LOG "$i multi-dest ";
                        my @destinations=split(/\|/,$nextarg);
                        foreach my $destination(@destinations) {
                            $destination=$roomIds{substr($destination,0,6)} or print LOG "lookup destid $destination failed\n";
                        }
                        $destid=join('|',@destinations);
                        $objects[$i]{"action"}=$destid; # sends you to destid object(s) seperated by pipes at random
                        $cond=1; # conditions always come before destination
                        print LOG "action destid=$destid\n";
                    } elsif ($nextarg eq "forced") { # its a forced destination
                        print LOG "$i destination forced ";
                        $nextarg = shift @travelargs; # get the destination
                        $objects[$i]{"action"}=$roomIds{substr($nextarg,0,6)}; # sends you to destid object
                        $cond=1; # conditions always come before destination
                        unshift @travelargs, '$forced'; # put a direction of "$forced" on to the travelargs to be processed as a direction
                        print LOG "action destid=".$objects[$i]{"action"}."\n";
                    } elsif (defined $roomIds{substr($nextarg,0,6)}) { # its a single destination
                        print LOG "$i destination ";
                        $objects[$i]{"action"}=$roomIds{substr($nextarg,0,6)}; # sends you to destid object
                        $cond=1; # conditions always come before destination
                        print LOG "action destid=".$objects[$i]{"action"}."\n";
                    } elsif (($cond==0) && ((defined $objIds{$nextarg}) || (defined $classIds{$nextarg}) || ($nextarg eq "n") || ($nextarg eq "e") || ($nextarg eq "d") || ($nextarg eq "dd"))) { # a valid object or class or special must be a condition
                        print LOG "$i condition $nextarg\n";
                        $objects[$i]{"condition"}=$nextarg if ($nextarg ne 'n'); # no need to keep none condition
                        $cond=1; # dont process conditions again for this line
                    } else { # must be a direction
                        unshift @travelargs,$nextarg; # put the direction back on the arg list
                        foreach my $direction(@travelargs) { # expand directions inc. random options
                            print LOG "direction $direction became ";
                            $direction=~s/(^|\|)n(?=$|\|)/$1north/i;
                            $direction=~s/(^|\|)s(?=$|\|)/$1south/i;
                            $direction=~s/(^|\|)e(?=$|\|)/$1east/i;
                            $direction=~s/(^|\|)w(?=$|\|)/$1west/i;
                            $direction=~s/(^|\|)u(?=$|\|)/$1up/i;
                            $direction=~s/(^|\|)d(?=$|\|)/$1down/i;
                            $direction=~s/(^|\|)ne(?=$|\|)/$1northeast/i;
                            $direction=~s/(^|\|)nw(?=$|\|)/$1northwest/i;
                            $direction=~s/(^|\|)sw(?=$|\|)/$1southwest/i;
                            $direction=~s/(^|\|)se(?=$|\|)/$1southeast/i;
                            $direction=~s/(^|\|)o(?=$|\|)/$1out/i;
                            print LOG "$direction\n";
                        }
                        $objects[$i]{"name"}=join( ';',@travelargs); # put directions in name
                        if (defined $objects[$objid]{"contents"}) { # put the exit in the room as well
                            $objects[$objid]{"contents"}.= ",$i"; # adding contents
                        } else {
                            $objects[$objid]{"contents"}="$i"; # intialising contents
                        }
                        last;
                    }
                }
            }
        }
        last if ($line=~/^\*.+$/); # end travel if new section
    }
    print LOG "end travel\n";
    print "Done\n";
}

sub do_texts { # stores all the texts reponses into a list for lookup later
    my $i=0;
    my @textargs;
    my ($objid);
    print "Doing text\n";
    print LOG "texts\n";
    while ($line = read_line()) {
        chomp $line;
        next if ($line=~/^\;/); # ignore comment lines
        if ($line =~ /^\d+\s+.*$/) {
            my @textargs=split(/\s+/,$line,2);
            $objid=shift @textargs; # first thing should be the id used as key
            $textargs[0]=~/^(.*)\s+$/; # trim the end of line
            $textIds{$objid}=$1;
            $textIds{$objid}=~s/\'/\\'/g; # escape quote marks
            print LOG "text: objid=$objid txt=" . $textIds{$objid} . "\n";
        }
        elsif ($line =~ /^\s+(.+)\s+$/) {
            my $t = $1;
            $t=~s/\'/\\'/g; # escape quote marks
            print LOG "$i:\t$t\n";
            if (substr($textIds{$objid},0,1) eq '*') { # keep line breaks if preformatted
                $textIds{$objid}=$textIds{$objid} . "\n" . $t;
            } else { # wrap this text
                $textIds{$objid}=$textIds{$objid} . " " . $t;
            }
        }
        last if ($line=~/^\*.+$/); # end rooms if new section
    }
    # now have all texts, need to x-ref in door objects and add locks and success/fail
    print "Resolving text x-refs\n";
    my $c;
    my $dm;
    for ($i=0;$i<=$#objects;$i++) { # could use a foreach here but having the index aids debugging
        if ($objects[$i]{"type"}==$exit) {
            $c = $objects[$i]{"condition"};
            if ($c ne "") { # assume its a class or object and is suitable to be a lock condition
                $c="emptylock" if ($c eq "e"); # expand e to empty
                $c="difflock" if ($c eq "d"); # expand d to diff
                $c="dielock" if ($c eq "dd"); # expand dd to (display and) die
                print LOG "c=$c ";
                $c=~s/^~(.*)$/!$1/g; # allow for negated conditions
                print LOG "negated c=$c \n";
                $objects[$i]{"lock"}=$c;
                delete ($objects[$i]{"condition"}); # dont need to keep this now lock set up
                print LOG "x-ref $i cond $c resolved as lock\n";
            }
            if (defined $objects[$i]{"msgdemon"}) { # is it a message or demon to process?
                $dm = $objects[$i]{"msgdemon"}; # get the message or demon
                if ($dm>=0) { # condition is a msg number not a -ve demon number so set success msg for going nowhere
                    $objects[$i]{"success"}=$textIds{$dm} or print LOG "invalid msg $dm in objid $i \n";
                    $objects[$i]{"success"}=~s/\\\'/\'/g; # remove escape of ' as not needed in a string
                    print LOG "x-ref $i msg $dm resolved\n";
                    delete ($objects[$i]{"msgdemon"}); # dont need to keep this now success set up
                } elsif ($dm<0) { # condition is a demon
                    print LOG "x-ref $i identified demon $dm\n";
                    #debug do something with demons - will need to be fired in moveObj is th_mud
                    $objects[$i]{"demon"}=$dm;
                    delete ($objects[$i]{"msgdemon"}); # dont need to keep this now set up
                }
            }
        } elsif ($objects[$i]{"type"}==$action) {
            # x-ref action object msgs debug
            while ($objects[$i]{"action"} =~ /msg(\d+)/i) {
                my $msg = $textIds{$1};
                if ($msg eq "?") { # this is a file of text reference
                    $msg = "?" . $1 . ".txt";
                }
                $objects[$i]{"action"} =~ s/msg$1/$msg/i;
            };

            for my $j (1..3) {
                if (defined $objects[$i]{"msg$j"}) {
                    if ($textIds{$objects[$i]{"msg$j"}} eq "?") { # this is a file of text reference
                        $objects[$i]{"msg$j"} = "?" . $objects[$i]{"msg$j"} . ".txt";
                    } else {
                        $objects[$i]{"msg$j"} = $textIds{$objects[$i]{"msg$j"}};
                    }
                }
            }
            if ($objects[$i]{"action"} =~ /mud_sendeffect/i) { # special handler for messages in sendeffect
                $objects[$i]{"action"} =~ /^(.*\'\,\")(\d+)(\"\,.*$)/i;
                my $msg = $textIds{$2}; # resolves send effect message id
                $objects[$i]{"action"} = $1 . $msg . $3;
            }
        }
    }
    print LOG "end texts\n";
    print "Done\n";
}

sub do_objects {
    # objects are  in the general form:
    # name [speed demon attackdemon] location(s) startprop maxprop score [stamina] [flags]
    # followed by text descriptions for each property value
    # locations will be containers for the object and maybe a room or obj
    my $i=0;
    my @objargs;
    my ($objid, $prop, $desc, $startprop);
    print "Doing objects\n";
    print LOG "objects\n";
    while ($line = read_line()) {
        chomp $line;
        last if ($line=~/^\*.+$/); # end objects if new section
        next if ($line=~/^\;/); # ignore comment lines
        if ($line =~ /^[^\d\s]\w+\s+/) { # if the line doesnt start with a digit or whitespace its a new object
            $objIds{"$objid"} = $i; # remap lookup of previous object name to numeric id to the last occurance of the name now its complete
            delete $objects[$i]{"description0"} if ($objects[$i]{"maxprop"} == 0); # no need to keep alt text of previous objid if there is only prop 0 for it
            $i=$#objects + 1; # the next object number after all that have been read in from $dbfile
            $line=lc($line);
            if ($line =~ /(.+)(<|\[)(.+)(>|\])(.*)\s+/) { # joins multi destination roomlist together (only one multi per line)
                my $destination=join('|',split(/\s+/,$3));
                $line=$1 . "\t" . $destination . "\t" . $5;
                print LOG "multi dest line =$line \n";
            }
            my @objargs=split(/\s+/,$line);
            print LOG "objid $i objargs ";
            foreach my $obj(@objargs) { print LOG "\'$obj\' "; }
            print LOG "\n";
            $objid=shift @objargs; # first thing should be the name used as key
            $objects[$i]{"name"} = $objid;
            $objects[$i]{"owner"} = 1; # always owned by the arch-wiz
            $objIds{$objid} = $i unless (defined $objIds{$objid}); # create a lookup of object name to numeric id but only for the first occurance of the name
            print LOG "objIds{$objid}=" . $objIds{"$objid"} . "\n";
            $objects[$i]{"type"} = $thing;
            my $arg = shift @objargs; # next could be a number (speed) or location
            print LOG "first arg=$arg\n";
            if (looks_like_number($arg)) { # speed demon attackdemon
                $objects[$i]{"speed"}=$arg+1; # minimum speed is 1 in th_mud vs 0 in MUD, both mean one tick.
                $objects[$i]{"demon"}=shift @objargs;
                $objects[$i]{"attack"}=shift @objargs;
                print LOG "objid $i speed " . $objects[$i]{"speed"} . " demon " . $objects[$i]{"demon"} . " attack " . $objects[$i]{"attack"} . "\n";
                $arg=shift @objargs; # next should be a location
            }
            # locations followed by props
            # the initial location is always put in home and location and added to the enclosing object (which could be a previously declared thing or room)
            my $loc = $arg;
            if ($loc =~ /.*\|.*/) { # handle multi random locs by converting to numeric ids
                my @locations=split(/\|/,$loc);
                foreach my $location(@locations) {
                    $location=$roomIds{substr($location,0,6)} or print LOG "objid $i multi-loc lookup location $location failed\n";
                }
                $loc=join('|',@locations);
            } else { # simple location not multi
                print LOG "objid $i simple lookup $loc\n";
                if (defined $roomIds{substr($loc,0,6)}) {
                    $loc=$roomIds{substr($loc,0,6)} or print LOG "objid $i simple lookup roomIds $loc failed\n";
                } else { # its in a room on an object
                    $loc=$objIds{"$loc"} or print LOG "objid $i simple lookup objIds $loc failed\n";
                }
                # simple loc, so add this object to loc
                if (defined $objects[$loc]{"contents"}) { # put the object in the room as well
                    $objects[$loc]{"contents"}.= ",$i" if ($objects[$loc]{"contents"} !~ /\b$i\b/); # adding contents if not already there
                } else {
                    $objects[$loc]{"contents"}="$i"; # intialising contents
                }
            }
            # now we have multi loc or a simple loc
            $objects[$i]{"location"}=$loc; # if multi loc this is resolved by restore
            $objects[$i]{"home"}=$loc; # if multi loc this is resolved by restore
            my $flags=0; # no flags as default
            # are there more locations for this object?
            while ($arg = shift @objargs) {
                last if (looks_like_number($arg));
                print LOG "objid $i extended simple lookup $arg\n";
                if (defined $roomIds{substr($arg,0,6)}) {
                   $arg=$roomIds{substr($arg,0,6)} or
                   print LOG "objid $i simple lookup roomIds $arg failed\n";
                } else { # its in a room or an object
                   $arg=$objIds{"$arg"} or
                   print LOG "objid $i simple lookup objIds $arg failed\n";
                }
                print LOG "objid $i added to loc $arg\n";
                # simple loc, so add this object to arg
                if (defined $objects[$arg]{"contents"}) { # put the obj in the location
                    $objects[$arg]{"contents"}.= ",$i" if ($objects[$arg]{"contents"} !~ /\b$i\b/); # adding contents if not already there
                } else {
                    $objects[$arg]{"contents"}="$i"; # intialising contents
                }
                $flags=$noget; # flags default to noget because it is in more than one place
            }
            # now we are on to props
            $startprop = $arg;
            $objects[$i]{"startprop"} = $startprop;
            $objects[$i]{"maxprop"} = shift @objargs;
            $objects[$i]{"scoreprop"} = shift @objargs; # only has a score when at this prop value
            $objects[$i]{"currprop"} = $startprop; # current prop value
            print LOG "objid $i startprop " . $objects[$i]{"startprop"} . " maxprop " . $objects[$i]{"maxprop"} . " scoreprop " . $objects[$i]{"scoreprop"} . "\n";
            # see if we have stamina or flags
            # there is more...
            while ($arg = shift @objargs) {
                if (looks_like_number($arg)) {
                    $objects[$i]{"stamina"} = $arg;
                    if ($arg < 0) { # starts destroyed
                        $flags |= $destroyed;
                    }
                } elsif ($arg eq "contains") {
                    $objects[$i]{"contains"}=shift @objargs; # max containable weight
                } else {
                    print LOG "objid $i adding flag $arg ";
                    $flags |= $flagsProper{"$arg"};
                    print LOG "flags=$flags \n";
                }
            }
            print LOG "objid $i flags=$flags \n";
            $objects[$i]{"flags"}=$flags;
        } elsif ($line =~ /^(\d+)\s+(.+)\s+$/) { #debug
            # process a text description line in format
            # prop$1 text-description$2
            $prop=$1;
            $desc=$2;
            if ($desc=~/^\%(.+)/) {
                # include description from another object
                if ($objects[$objIds{"$1"}]{"maxprop"}>0) {
                    $desc=$objects[$objIds{"$1"}]{"description$prop"};
                } else {
                    $desc=$objects[$objIds{"$1"}]{"description"};
                }
            }
            print LOG "objid $i desc$prop=$desc\n";
            $objects[$i]{"description$prop"} = $desc;
            $objects[$i]{"description"} = $objects[$i]{"description$startprop"} if (defined $objects[$i]{"description$startprop"});
        } elsif ($line =~ /^\s+(.+)\s+$/) { #debug
            # process a text description line in format
            #        text-description-continues$1
            $desc=$1;
            print LOG "objid $i ext desc$prop=$desc\n";
            $objects[$i]{"description$prop"} .= " " . $desc;
            $objects[$i]{"description"} = $objects[$i]{"description$startprop"} if (defined $objects[$i]{"description$startprop"});
        }
    }
    print LOG "end objects\n";
    print "Done\n";
}

sub do_vocab
{
    # *vocab is made up of several subsections:
    # class contains:
    #   clasname - we will ignore these and make imperative in te obj
    # object contains:
    #   objid classname weight score - assign to the objid
    # syn contains:
    #   synonym real-word - capture and store these, probably as an object type
    # motion contains:
    #   motionword (eg north, south, but also $special)
    # noise contains:
    #   noisewords (words to be barred from use as identities) - ignore these as not needed
    # various single argument subsection for defining pronouns, conjugations, prepositions etc - hard code these
    # action contains:
    #   essentially this is programming for the commands but also declares messages for room, near, and far.
    #
    my $i=0;
    my @vocargs;
    my %vo;
    my ($objid, $prop, $desc, $startprop);
    my $subsection = 'class'; # initialise to class
    print "Doing vocabulary\n";
    print LOG "vocabulary\n";
    while ($line = read_line()) {
        chomp $line;
        last if ($line=~/^\*.+$/); # end vocab if new section
        next if ($line=~/^\;/); # ignore comment lines
        ($line,my $comment) = split(/;/,$line,2); # seperate out in line comments
        $line=lc($line);
        @vocargs = split (/\s+/,$line); # split line into words
        print LOG "vocargs=";
        foreach my $arg (@vocargs) {
            print LOG "\'$arg\' ";
        }
        print LOG "\n";
        my $x = shift @vocargs;
        $subsection = $x unless ($x eq ''); # only change the subsection if there is a value
        # ignore class as we will make it imperative rather than declarative
        if ($subsection eq "class") {
            my $class=shift @vocargs;
            $classIds{$class} = 1; # keep a record of the class
        } elsif ($subsection eq "object") {
            # objid class weight score
            # these may be declared before the objects themselves have been defined in *objects
            # so we put them in a vocab objects array and merge them later
            $i=$#vocabobj + 1; # the next object number
            $vocabobj[$i]{"name"} = shift @vocargs;
            $vocabobj[$i]{"class"} = shift @vocargs;
            $vocabobj[$i]{"weight"} = shift @vocargs;
            $vocabobj[$i]{"score"} = shift @vocargs;
            print LOG "$i vocabobj=" . $vocabobj[$i]{"name"} . " added\n";
        } elsif ($subsection eq "syn") {
            # synonym word
            $i=$#objects + 1; # the next object number
            # record synonym object
            $objects[$i]{"name"}=shift @vocargs;
            $objects[$i]{"action"}=shift @vocargs;
            $objects[$i]{"type"}=$synonym;
        } elsif ($subsection eq "action") {
            # verb [.primitive] noun1 noun2 function param1 [param2] here_msg [near_msg] [far_msg] [-demon]
            my %instruction;
            my $assembly;
            $instruction{"name"}=shift @vocargs; # this is the verb
            my $token = shift @vocargs; # get the first argument
            if (substr($token,0,1) eq ".") { # is there an optional primitive?
                $token=".daytime" if ($token eq ".time"); # special to avoid perl namespace clash
                $instruction{"primitive"} = substr($token,1); # this is mud primitive eg drop, get etc
                $token = shift @vocargs; # get next token
            }
            $instruction{"class"} = $token unless ($token eq "none"); # this is the class it acts on (noun1)
            $token = shift @vocargs;
            $instruction{"lock"} = $token unless ($token eq "none"); # apply a class lock to the action (noun2)
            $token = shift @vocargs;
            if ($token ne "null") {
                $instruction{"action"} = $token ; # this is the function unless "null"
                # now capture one or two arguments depnding on function
                if (defined $mudFunctions{$instruction{"action"}}) {
                    my $numParams = $mudFunctions{$instruction{"action"}};
                    for (my $a=1; $a <= $numParams; $a++) {
                        $token = shift @vocargs;
                        $instruction{"arg$a"} = $token
                    }
                } else {
                    print LOG "invalid vocab action $token\n";
                    next;
                }
            }
            $token = shift @vocargs;
            $token = shift @vocargs if ($token eq "null"); # throw away null argument if it exists
            # the x-ref msgs for here, near, far. there is always here and near.
            $instruction{"msg1"}=$token; # here msg
            $token = shift @vocargs;
            if ($token > 0) { # msg2 is present
                $instruction{"msg2"}=$token; # near msg
                $token = shift @vocargs; # get next token (msg3 or demon)
            }
            if ($token <= 0) { # its either a null msg2 or msg3 (ignore) or a demon
                if ($token < 0) { # its a demon!
                    $instruction{"demon"}=$token; # demon triggered if -ve
                } else { # it is a null msg2 or msg3 so throw away
                    $token = shift @vocargs; # get next token (either msg3, a demon, a undef)
                }
            }
            if ($token>0) { # it is a msg3
                $instruction{"msg3"}=$token; # far msg if present
                $token = shift @vocargs; # if there is one get the demon
                $instruction{"demon"}=$token if ($token < 0); # demon triggered
            } elsif ($token<0) { # its a demon and nothing will follow
                $instruction{"demon"}=$token; # demon triggered if -ve                }
            } elsif ($token ne "") { # or it was a null msg3 ("0") and maybe a demon followed it
                $token = shift @vocargs; # if there is one get the demon
                $instruction{"demon"}=$token if ($token < 0); # demon triggered
            }
            print LOG "vocact ";
            foreach my $attribute (keys %instruction) {
                print LOG "$attribute " . $instruction{$attribute} . " ";
            }
            print LOG "\n";
            # assemble object from instruction
            $i=$#objects + 1; # the next object number
            $objects[$i]{"name"}=$instruction{"name"}; # the verb
            $objects[$i]{"class"}=$instruction{"class"} if (defined $instruction{"class"}); # noun1 must be this class
            $objects[$i]{"lock"}=$instruction{"lock"} if (defined $instruction{"lock"}); # this class must be present
            $objects[$i]{"type"}=$action;
            # in teleMUD $arg1 is noun1, $arg2 is noun2, $arg is all arguments, $me is myself
            # debug need to check class and lock matches for $arg1 and $arg2
            if (defined $instruction{"action"}) {
                # there is an action clause so call the mud_action function
                $assembly = "";
                $assembly='if ( ' if (defined $instruction{"primitive"}); # only need a conditional if a primitive follows
                $assembly .= 'mud_' . $instruction{"action"} . '(';
                # add parameters to the mud_action function if exist
                $assembly .= '$me,$arg,$arg1,$arg2,\'' . $instruction{"arg1"} . '\'';
                if (defined $instruction{"arg2"}) {
                    $assembly .= ',\'' . $instruction{"arg2"} . '\''; # there is a fnArg2
                } else {
                    $assembly .= ',""'; # no fnArg2
                }
                if ((defined $instruction{"msg1"}) && ($instruction{"msg1"} != 0)) {
                    $assembly .= ',\'' . "msg" . $instruction{"msg1"} . '\'';
                } else {
                    $assembly .=',""';
                }
                if ((defined $instruction{"msg2"}) && ($instruction{"msg2"} != 0)) {
                    $assembly .= ',\'' . "msg" . $instruction{"msg2"} . '\'';
                } else {
                    $assembly .=',""';
                }
                if ((defined $instruction{"msg3"}) && ($instruction{"msg3"} != 0)) {
                    $assembly .= ',\'' . "msg" . $instruction{"msg3"} . '\'';
                } else {
                    $assembly .=',\'\'';
                }
                if (defined $instruction{"demon"}) {
                    $assembly .= ',' . $instruction{"demon"} ; # run demon if defined
                } else {
                    $assembly .= ',0'; # no demon
                }
                $assembly .= ',$cid,$oc) '; # pass the command id and original command text
                if (defined $instruction{"primitive"}) {
                    $assembly .= ') { return &' . $instruction{"primitive"} . '($me,$arg,$arg1,$arg2,$cid,$oc); }'; # return the primitive return value which could be death
                } else {
                    $assembly .= ';'; # the function return value is sufficient and could be death
                }
            } else { # no function, but still have messages and some tests
                # debug this should allow for a msg2 if the lock fails but the class passed - not supported in TH MUD at the moment as both are checked before action is called - this could be implemented by making the lock generation conditional on action present above
                $assembly .= '{';
                $assembly .= '&mud_demon($me,' . $instruction{"demon"} . ',$arg,$arg1,$arg2); ' if (defined $instruction{"demon"}); # run demon if defined
                $assembly .= '&tellPlayer($me,"' . "msg" . $instruction{"msg1"} . '"); ' if ($instruction{"msg1"} > 0); # success for command and msg is not zero
                $assembly .= 'return &' . $instruction{"primitive"} . '($me,$arg,$arg1,$arg2,$cid,$oc); ' if (defined $instruction{"primitive"}); # return the prmiative return value which could be death
                $assembly .= '1; }'; # return 1 in case there isnt a primitive
            }
            $objects[$i]{"action"}=$assembly;
            print LOG " id=$i actobj " . $objects[$i]{"name"} . " is " . $objects[$i]{"action"} . "\n";
        }
        # ignore class, motion, singles
    }
    print LOG "end vocabulary\n";
    print "Done\n";
}

sub do_demons # demon declarations
{
    my $i=0;
    print "Doing demons\n";
    print LOG "demons\n";
    while ($line = read_line()) {
        chomp $line;
#        $line=~s/;.*//g; # strip comments
        last if ($line=~/^\*.+$/); # end if new section
        next if ($line=~/^\;/); # ignore comment lines
        $line=lc($line);
        my @demonargs = split (/\s+/,$line);
        print LOG "demonargs=";
        foreach my $arg (@demonargs) {
            print LOG "\'$arg\' ";
        }
        print LOG "\n";
        $i=$#objects + 1; # the next object number after all that have been read in from $dbfile
        $objects[$i]{"type"}=$demon; # its a demon
        my $demonid=shift @demonargs; # demon number
        $objects[$i]{"name"}=int(abs($demonid)); # make sure it is +ve number
        $objects[$i]{"action"}=shift @demonargs; # the demon action this is linked to (aka demon name in MUD)
        $objects[$i]{"class"}=shift @demonargs; # demon arg 1
        $objects[$i]{"lock"}=shift @demonargs; # demon arg 2
        $objects[$i]{"speed"}=shift @demonargs; # demon delay
        my $flags = 0;
        while (my $arg = shift @demonargs) {
            $flags |= $demonFlagsProper{"$arg"};
        }
        print LOG "demon=". $objects[$i]{"name"} ." objid=$i act=" . $objects[$i]{"action"} . " flags=$flags \n";
        $objects[$i]{"flags"}=$flags;
    }
    print LOG "end demons\n";
    print "Done\n";
}

sub do_compile {
    my ($i, $j);
    print "Linking objects\n";
    print LOG "linking objects\n";
    for $i (0..$#vocabobj) {
        my $objname = $vocabobj[$i]{"name"};
        print LOG "$i name=$objname class=" . $vocabobj[$i]{"class"} . " weight=" . $vocabobj[$i]{"weight"} . " score=" . $vocabobj[$i]{"score"} . "\n";
        for $j (0..$#objects) {
            if (($objects[$j]{"name"} eq $objname) && ($objects[$j]{"type"} == $thing)) {
                $objects[$j]{"class"} = $vocabobj[$i]{"class"};
                $objects[$j]{"weight"} = $vocabobj[$i]{"weight"};
                $objects[$j]{"score"} = $vocabobj[$i]{"score"};
            }
        }
    }
    print LOG "objects linked\n";
    print "Done\n";
}
