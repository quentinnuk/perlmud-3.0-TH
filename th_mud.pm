#!/usr/bin/perl
# -*- mode: perl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
# vim:filetype=perl:et:sw=4:ts=4:sts=4
package th_mud;

use strict;
use Text::Wrap qw(wrap $columns);

use Exporter 'import';
our @EXPORT = qw(do_mud load_mud);

use List::Util 'shuffle';
use parent;

my $maintainer = "jadawin"; # local system user who maintains the MUD

#Should users be allowed to create objects and rooms by default?
#Set this to 0 if you prefer not.

my $allowBuild = 0;

#Should users be allowed to @emit things without their
#name prefixed? Set this to zero if you prefer not.

my $allowEmit = 0;

#File locations for the database, the login screen banner,
#the Message of the Day, and the help file.

my $dbFile = "data/mud/mud.db";
my $personaFile = "data/mud/mud.pf";
my $welcomeFile = "data/mud/welcome.txt";
my $motdFile = "data/mud/motd.txt";
my $helpFile = "data/mud/help.txt";
my $filePrefix = "data/mud/";
#If you uncomment this, set a password
#my $newsPassword = "";
my $newsPassword = "a8b7";

#Idle timeout. This hangs up on users if they do not
#enter at least one command in the time interval
#(specified in seconds; 3600 is an hour).
 
my $idleTimeout = 86400;

#Time to wait between (brief) attempts at closing
#sockets we don't need anymore. The longer this is,
#the fewer pauses the mud will experience.

my $fdClosureInterval = 30;

#Interval between automatic backups of the database, in seconds (1 hour).
#Note: stale topics are also sent home during this pass.
my $dumpinterval = 3600;
#Seconds until a topic is considered stale.
my $topicStaleTime = 3000;

#Version of PerlMUD.
my $perlMudVersion = 3.0;

#Max size of output buffer before flushing takes place
my $flushOutput = 32768;

#If the client sends the 'smartclient' command prior to sending the
#connect command, then this prefix is sent in front of each line of
#topic-specific output for the life of the connection. The @emit command
#cannot spoof this.

my $topicPrefix = "[{}]";

#Nothing below here should require changes to set up the mud

our $mudReloadFlag;
    
#Protocols

my $tinyp = 0;

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

#Flag values

#Can't be seen; or description only, contents invisible
my $dark = 1;

#Gender
my $male = 2;
my $female = 4;
my $herm = 6;

#Name of location visible in who list
my $public = 8;

#Gives off light flag
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

# demon flags

my $dEnabled = 1;
my $dGlobal = 2;
my $dAlways = 4;


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
    "nolook", $nolook,
    "no-look", $nolook,
    "silent", $silent,
    "noget", $noget,
    "no-get", $noget,
    "transparent", $transparent,
    "opened", $opened,
    "disguised", $disguised,
    "no-summon", $nosummon,
    "fixed", $fixed,
    "noit", $noit,
    "no-it", $noit,
    "blind", $blind,
    "deaf", $deaf,
    "dumb", $dumb,
    "paralysed", $paralysed,
    "asleep", $asleep,
    "destroyed", $destroyed
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
    "noit", $noit,
    "blind", $blind,
    "deaf", $deaf,
    "dumb", $dumb,
    "paralysed", $paralysed,
    "asleep", $asleep,
    "destroyed", $destroyed
);

my @flagNames = (
    "dark",
    "male",
    "female",
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
    "noit",
    "blind",
    "deaf",
    "dumb",
    "paralysed",
    "asleep",
    "destroyed"
);

# the levels - must be in order 0 to 10 as below

my %levelNames = (
    "male", ["novice",
             "warrior",
             "hero",
             "champion",
             "superhero",
             "enchanter",
             "sorcerer",
             "necromancer",
             "legend",
             "wizard",
             "arch-wizard"],
      "female", ["novice",
                 "warrior",
                 "heroine",
                 "champion",
                 "superheroine",
                 "enchantress",
                 "sorceress",
                 "necromancess",
                 "legend",
                 "witch",
                 "arch-witch"]
);

#Set these up in a particular order so that we can
#say that, for instance, abbreviations of 'whisper'
#should beat abbreviations of 'who'.

my @commandsProperOrder = (
    "\@wall", \&shout,
    "shout", \&shout,
#    "say", \&say,
    "emote", \&emote,
    "\@dig", \&dig,
#   "\@doing", \&doing,
    "\@create", \&create,
    "\@stats", \&stats,
    "\@rooms", \&rooms,
    "\@gag", \&gag,
    "\@ungag", \&ungag,
#    "l", \&look,
#    "score", \&mud_score,
#    "qs", \&quickScore,
#    "read", \&look,
#    "exits", \&exits,
    "\@examine", \&examine,
#    "i", \&inven,
#    "drop", \&drop,
#    "get", \&get,
#    "home", \&home,
#    "whisper", \&whisper,
#    "tell", \&whisper,
#    "who", \&who,
#    "sign", \&sign,
#    "write", \&sign,
#    "unsign", \&unsign,
    "\@help", \&help,
#    "motd", \&motd,
#    "welcome", \&welcome,
    "\@set", \&setFlag,
    "\@describe", \&setDescription,
#    "page", \&page,
    "\@name", \&name,
    "\@chown", \&chown,
#    "\@pcreate", \&pcreate, #debug not needed on TH
    "\@teleport", \&teleport,
    "\@go", \&teleport,
    "\@link", \&link,
    "\@open", \&open,
    "\@fail", \&setFail,
    "\@ofail", \&setOfail,
    "\@success", \&setSuccess,
    "\@osuccess", \&setOsuccess,
    "\@odrop", \&setOdrop,
    "\@lock", \&setLock,
    "\@boot", \&boot,
    "\@find", \&find,
    "\@emit", \&emit,
    "\@topic", \&createTopic,
    "\@join", \&joinTopic,
    "\@leave", \&leaveTopic,
#    "last", \&last,
#    "\@tz", \&tz, #debug not needed on TH
#    "\@24", \&twentyfour,
#    "\@12", \&twelve,
    "\@prop", \&setProp,
    "\@recycle", \&recycle,
    "\@purge", \&purgeObj,
    "\@toad", \&toad,
    "\@shutdown", \&mud_shutdown,
    "\@reset", \&reload,
    "\@dump", \&dump
);

my @invalidMsgs=(
    "I'm not sure I understand you fully.",
    "What?",
    "I don't understand that.",
    "I don't see what you mean.",
    "It's all double dutch to me mate!");

#Set up commands table (now in order of precedence)

#3.0: make sure to empty it again if we're reloading
our %commandsTable;

our %commandsProper;
# initialise synonym table
our %synonymTable;

our ($lastdump, $lastFdClosure, $now) = (time, time, time);
our $initialized = time;
our (@activeFds);
our ($fdClosureNew, $fdClosureTimedOut, @fdClosureList);
our (@objects, %playerIds, $commandLogging);
our @demonsTable;
our %fightsTable;

our $mudPlayers; # keep a count for scoring

our $mud_closed = 0;
$mudReloadFlag = 1;

our $debugMode = 0;

#debug default to peace for now
our $worldPeace = 1;

sub load_mud
{

    $mud_closed = 1; # in case anything bad happens
    $mudPlayers=0;
    #debug default to peace for now
    $worldPeace = 1;

    my($i);
    # define the core builder commands
    for ($i = 0; ($i < int(@commandsProperOrder)); $i += 2) {
        $commandsProper{$commandsProperOrder[$i]} =
            $commandsProperOrder[$i + 1];
    }
    # kill any residual timers just in case
    &TH::kill_timer(\&mud_housekeeping, 0); # stop the housekeeping
    &TH::kill_timer(\&mud_creature, 0); # stops all creature daemons
    &TH::kill_timer(\&mud_xdemon, 0); # stops all other daemons
    for (my $i = 0; ($i <= $#activeFds); $i++) { # stop autowhos
        next if ($activeFds[$i]{"id"}==$none); # fd not in use
        if (defined $objects[$activeFds[$i]{"id"}]{"autowho"}) {
            delete $objects[$activeFds[$i]{"id"}]{"autowho"};
            &TH::kill_timer(\&mud_autowho, $activeFds[$i]{"fd"}->{"fd"});
        }
    }
    @objects = (); # initialise the objects
    %playerIds = (); # init the player table;
    %synonymTable = (); # init synonyms;
    @demonsTable = (); # init the demons table;
    %fightsTable = {}; # init fightsTable;

    #debug a return of 0 here isnt causing an exception
    if (!&restore()) {
        &TH::xlog('Mud: FATAL: Can\'t start the mud with this database.');
        return 0;
    }
    $TH::data->{mud} = {}; # nobody in mud
    &TH::set_timer(1,\&mud_housekeeping,0,0); # start housekeeping every second
    &TH::xlog("Mud: initialized");
    $mud_closed = 0; # open it up
    #(re)initialization code ends here
}

sub restore
{
    #debug broken databases dont kill the mud
    &TH::xlog('Mud: loading data');
    return 0 unless (restore_db($dbFile)); #debug these arent failing on 0
    return 0 unless (restore_db($personaFile));
    &TH::xlog('Mud: initialising game');
    # process synonyms, actions and mobiles
    for my $id (0..$#objects) {
        if ($objects[$id]{"type"}==$action) { # build commandTable
            my $s = $objects[$id]{"name"};
            if (!exists($commandsTable{$s})) {
                $commandsTable{$s} = "$id";
            } else {
                $commandsTable{$s} .= ",$id";
            }
        }
        if ($objects[$id]{"type"}==$synonym) { # build synonymTable from synonym objects
            my $synonym = $objects[$id]{"name"};
            $synonymTable{"$synonym"} = $objects[$id]{"action"}; # synonym to action map
        }
        if ($objects[$id]{"type"}==$demon) { # build demon table
            my $demonid = int(abs($objects[$id]{"name"})); # must be numeric
            $demonsTable[$demonid]{"id"}=$id; # demon to object map
            $demonsTable[$demonid]{"flags"}=$objects[$id]{"flags"}; # demon run state
            if ($demonsTable[$demonid]{"flags"} & $dEnabled) {
                # launch at load
                &mud_demon(0,$demonid,"","","");
            }
        }
        if (($objects[$id]{"type"}==$thing) && ($objects[$id]{"speed"}>0)) { # add mobile to timers
            &TH::set_timer($objects[$id]{"speed"},\&mud_creature,$id,0);
        }
    }
    return 1;
}

sub restore_db
{
    my ($dbFile) = @_;
    my($id, $dbVersion, $dbVersionKnown);
    if (!open(IN, $dbFile)) {
        &TH::xlog('Mud: FATAL: Unable to read from ' . $dbFile);
        return 0;
        # debug
        # in future this should just flag mud unavailable in TH rather than exit 0
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
                    &TH::xlog ( 'Mud: FATAL: database '. $dbVersion . ' not supported');
                    close(IN);
                    return 0;
                }
                next;
            }
        }
        chomp $id;
        if ($id eq "<END>") { # empty formatted db
            last;
        }
        if ($dbVersion >= 2.1) {
            # New style database, hurrah
            while (1) {
                my($attribute, $value, $line);
                $line = <IN>;
                if ($line eq "") {
                    #Uh-oh
                    &TH::xlog ('Mud: FATAL: Database ' . $dbFile . ' is truncated!');
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
                if ((($attribute eq 'action') || ($attribute eq 'name')) && ($value=~/.+\|.+/)) { # multi value attribute
                    my @vals = split(/\|/,$value);
                    @vals = shuffle(@vals); # randomise order
                    $value = join('|',@vals); # re-assemble
                }
                $objects[$id]{$attribute} = $value;
            }
            if ((exists $objects[$id]{"id"}) && ($id!=1)) { # arch-wiz obj 1 can be duplicated but nothing else
                &TH::xlog('Mud: FATAL: Database ' . $dbFile . ' duplicate object ' . $id. '!');
                return 0;
            }
            $objects[$id]{"id"} = $id;
            if ($id == 1) {
                $objects[1]{"flags"} |= $wizard;
            }
            if ($objects[$id]{"type"} == $player) {
                my($n);
                $n = $objects[$id]{"name"};
                $n =~ tr/A-Z/a-z/;
                $playerIds{$n} = $id;
            }
            if ($objects[$id]{"home"}=~/.+\|.+/) { # multi value attribute
                my @vals = split(/\|/,$objects[$id]{"home"});
                my $loc = $vals[rand @vals]; # pick a random location from possible homes for the current location
                $objects[$id]{"location"}=$loc;
                # now put it in the location
                if (length($objects[$loc]{"contents"}) > 0) {
                    $objects[$loc]{"contents"} .= "," . $id;
                } else {
                    $objects[$loc]{"contents"} = $id;
                }
            }
            # GOTCHA: $none and 0 are different
            $objects[$id]{"activeFd"} = $none;
        } else {
            &TH::xlog('Mud: FATAL: invalid database ' . $dbFile . ', not loaded');
            return 0;
        }
    }
    close(IN);
}

sub do_mud
{
    my ( $conn ) = @_;

    if ($mud_closed) {
        &TH::th_println("Some powerful magic prevents your entering The Land. Try again later, please.");
        return;
    }
    
    $TH::data->{mud} = {} if !defined $TH::data->{mud};

    my $mud = $TH::data->{mud};
    my $user = &TH::get_user($conn);
    my $udata = $conn->{udata};
    
    if ($mud->{users}->{$user} == 1) {
        &TH::th_println("You were already playing MUD and have been kicked out.");
        $user =~ tr/A-Z/a-z/;
        if (exists($playerIds{$user})) {
            my $id = $playerIds{$user};
            forceClosePlayer( $id, 1); # forces exit to shell
        }
        delete $mud->{users}->{$user};
        return;
    }
    
    $mud->{users}->{$user} = 1;

    $conn->{in_mud} = 1;
    $conn->{interrupt_sub} = \& do_mud_quit;
    
    # functional TH equivalent of acceptTinyp in PerlMUD source
    my($aindex, $found);
    $found = 0;
    for ($aindex = 0; ($aindex <= $#activeFds); $aindex++) {
        if ($activeFds[$aindex]{"fd"} eq $none) {
            $activeFds[$aindex]{"protocol"} = $tinyp;
            $activeFds[$aindex]{"fd"} = $conn;
            $activeFds[$aindex]{"id"} = $user; # this is case sensitive in other parts of perlmud
            $found = 1;
            last;
        }
    }
    if (!$found) {
        $aindex = $#activeFds + 1;
        $activeFds[$aindex]{"protocol"} = $tinyp;
        $activeFds[$aindex]{"fd"} = $conn;
        $activeFds[$aindex]{"id"} = $user; # this is case sensitive in other parts of perlmud
    }
    &sendActiveFdFile($aindex, $welcomeFile);
    my($id, $n);
    $n = $user;
    $n =~ tr/A-Z/a-z/; # user is translated into lowercase only - #debug
    &mud_tellActiveFd($aindex, "This mud last reloaded " . &timeFormat(time - $initialized) . ' ago.');
    &TH::th_println();
    if (!exists($playerIds{$n})) {
        # player is new to mud, so create a player record
        $id = pcreate(1,'pcreate',$n,$none); # object 1 is always the arch-wizard so can pcreate
    }
    $id = $playerIds{$n};
    $activeFds[$aindex]{"id"} = $id;
    &mud_login($id, $aindex);

    return \& mud_loop;
}

sub mud_login
{
    my($id, $aindex) = @_;
    $now = time;
    &addContents(int($objects[$id]{"home"}), $id); # put me in my home
    if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand) && !($objects[$id]{"flags"} & $dark)) { # grand or invis
        &tellRoom($objects[$id]{"location"}, $none,
            playerName($id) . " has just arrived.");
    }
    $mudPlayers+=1;
    my $level = $levelNames{(($objects[$id]{"flags"} & $female) ? "female" : "male")}[$objects[$id]{"level"}];
    if ($objects[$id]{"played"}>0) {
        &mud_tellActiveFd($aindex, "Hello again, " . playerName($id) . "!");
        &mud_tellActiveFd($aindex, "Your last game was " . &timeFormat($now - $objects[$id]{"last"}) . " ago.");
        $objects[$id]{"flags"} &= ~$asleep; # invert asleep if set
        $objects[$id]{"flags"} &= ~$deaf; # invert deaf if set
        $objects[$id]{"flags"} &= ~$dumb; # invert dumb if set
        $objects[$id]{"flags"} &= ~$blind; # invert blind if set
        $objects[$id]{"flags"} &= ~$paralysed; # invert paralysed if set
        # new stamina point for every 60 seconds outside game
        my $kips=int((time - $objects[$id]{"last"})/60);
        my $y = $objects[$id]{"stamina"} + $kips;
        $objects[$id]{"stamina"} = ($objects[$id]{"maxstamina"}, $y)[$y<$objects[$id]{"maxstamina"}];
    } else {
        my $msg = "Welcome, " . ucfirst($objects[$id]{"name"}) . "! You are born a bouncing baby " . (($objects[$id]{"flags"} & $female) ? "girl" : "boy") . "!";
        &mud_tellActiveFd($aindex, $msg);
    }
    &tellWizards(playerName($id) . " has entered MUD having played " . $objects[$id]{"played"} . " times before.");
    $objects[$id]{"activeFd"} = $aindex;
    $objects[$id]{"on"} = $now;
    $objects[$id]{"last"} = $now;
    $objects[$id]{"lastPing"} = $now;
    $objects[$id]{"played"}+=1;
    $objects[$id]{"prompt"}="*";
    $objects[$id]{"prompt"}="(*)" if ($objects[$id]{"flags"} & $dark); # invis
    #debug do TH scores for these I think
    &mud_tellActiveFd($aindex, "Well done! You've managed 10 games so far without getting killed!") if ($objects[$id]{"played"}==10);
    &mud_tellActiveFd($aindex, "Congratulations! Your 100th game!") if ($objects[$id]{"played"}==100);
    &mud_tellActiveFd($aindex, "Amazing! This is your 1000th game! What dedication!") if ($objects[$id]{"played"}==1000);
    &mud_tellActiveFd($aindex, "Yes, you DO get a message congratulating you on your 10000th game!") if ($objects[$id]{"played"}==10000);
    &sendFile($id, $motdFile);
    &mud_command($id, "look");
}

sub pcreate
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&wizardTest($me)) {
        &tellPlayer($me, "Sorry, only a wizard can do that.");
        return;
    }
    if (($arg1 eq "") || ($arg2 eq "")) {
        &tellPlayer($me, "Syntax: \@pcreate name = password");
        return;
    }
    if (substr($arg1, 0, 1) eq "#") {
        &tellPlayer($me, "Sorry, names cannot begin with #.");
        return;
    }
    $_ = $arg1;
    if (/\s/) {
        &tellPlayer($me, "Sorry, names cannot contain spaces.");
        return;
    }
    my($n);
    $n = $arg1;
    $n =~ tr/A-Z/a-z/;
    if (exists($playerIds{$n})) {
        &tellPlayer($me, "Sorry, that name is taken.");
        return;
    }
    my $id=$none;
    $id = &addObject($me, $arg1, $player);
    $playerIds{$n} = $id;
    $objects[$id]{"owner"} = $id;
    $objects[$id]{"last"} = time; # set last game to now
    $objects[$id]{"location"} = $nowhere; # create in nowhere
    $objects[$id]{"home"} = 0; # set home to room 0
    $objects[$id]{"score"} = 0;
    $objects[$id]{"played"} = 0;
    $objects[$id]{"maxstamina"} = rollChar();
    $objects[$id]{"strength"} = rollChar();
    $objects[$id]{"dexterity"} = rollChar();
    $objects[$id]{"stamina"} = $objects[$id]{"maxstamina"};
    $objects[$id]{"level"} = 0; # start as a novice
    if ($allowBuild) {
        $objects[$id]{"flags"} = ($builder);
    }
    $objects[$id]{"flags"} |= (int(rand(2))? $male : $female); # pick a random sex
    return $id;
}

sub rollChar
{
    # roll persona value attribute on 5d20
    my $sum=0;
    for (my $i=0; ($i<=4); $i++) {
        $sum+=int(rand(20)+1); # 5d20
    }
    return ($sum > 90 ? 100 : $sum+10); # max 100, min 15
}

sub weighContents
{
    # yield the total weight of all contents of type (usually thing)
    my ($what, $type) = @_;
    my $weight = 0;
    my @list = split(/,/,$objects[$what]{"contents"});
# debug this should explode containers in containers but doesnt
    foreach my $o (@list) {
        if ($objects[$o]{"type"} == $type) {
            $weight += $objects[$o]{"weight"};
        }
    }
    return $weight;
}

sub maxObj
{
    # returns max number of objects $what can contain
    # returns 2 if there is no dexterity
    #debug needs to handle bags etc in future using "extraobj"?
    my ($what) = @_;
    return int($objects[$what]{"dexterity"}/10+2);
}

sub howMany
{
    # retruns how many $type objs $what contains
    my ($what,$type) = @_;
    my @list = split(/,/,$objects[$what]{"contents"});
    my $count=0;
    foreach my $o (@list) {
        if ($objects[$o]{"type"} == $type) {
            $count++;
        }
    }
    return int($count);
}

sub startFight
{
    my($me, $id) = @_;
    # $me starts fight with $id
    $fightsTable{$me}{$id}=$me;
    $fightsTable{$id}{$me}=$me;
    print "startFight [$me] vs [$id]\n" if ($debugMode);
}

sub endFight
{
    my($me, $id) = @_;
    # $me ends fight with $id
    delete $fightsTable{$me}{$id};
    delete $fightsTable{$id}{$me};
    print "endFight [$me] vs [$id]\n" if ($debugMode);
}

sub stopFighting
{
    # stops all fights in progress
    
#debug to be worked out - something should allow for flee
#debug see stop.fighting(fleeing) in MUD4.BCL and K.IFFY in MUD8.BCL
    
    if (keys %fightsTable>0) {
        # handle fights in progress
        foreach my $x (keys %fightsTable) {
            foreach my $y (keys %{$fightsTable{$x}}) {
                # take a fight turn
                my $xname = ($objects[$x]{"type"}==$player) ? &playerName($x) : "The " . $objects[$x]{"name"};
                my $yname = ($objects[$y]{"type"}==$player) ? &playerName($y) : "The " . $objects[$y]{"name"};
                &tellPlayer($y,"You can no longer fight " . $xname . "!") if ($objects[$y]{"type"}==$player);
                #debug drop everything for player $y
                &tellPlayer($x,"You can no longer fight " . $yname . "!") if ($objects[$x]{"type"}==$player);
                #debug drop everything for player $x
                &endFight($x,$y);
            }
        }
    }
}

sub fightCheck
{
    my ($me,$id) = @_;
    return $none if !(defined $fightsTable{$me}); # no fight in me
    if (defined $id) {
        if (defined $fightsTable{$me}{$id}) {
            return $fightsTable{$me}{$id}; # return the fight initiator
        } else {
            return $none;
        }
    }
    my @combat = ();
    foreach my $f (keys %{$fightsTable{$me}}) { # fight check
        push (@combat,$f);
    }
    return \@combat; # return an array of who is being fought
}

sub addContents
{
    my($addto, $add) = @_;
    # adds item id $add to container $addto
    # Whatever you do, don't let any commas get in here
    $add =~ s/,//g;

    if (length($objects[$addto]{"contents"}) > 0) {
        $objects[$addto]{"contents"} .= "," . $add;
    } else {
        $objects[$addto]{"contents"} = $add;
    }
    $objects[$add]{"location"} = $addto;
}

sub addObject
{
    my($maker, $name, $type) = @_;
    my($id);
    my($found);
    $found = 0;
    for ($id = 0; ($id <= $#objects); $id++) {
        if ($objects[$id]{"type"} == $none) {
            $found = 1;
            last;
        }
    }
    if (!$found) {
        $id = $#objects + 1;
    }
    $objects[$id]{"name"} = $name;
    $objects[$id]{"type"} = $type;
    $objects[$id]{"activeFd"} = $none;
    $objects[$id]{"owner"} = $maker;
    &tellPlayer($maker, $objects[$id]{"name"} .
        " has been created as #" .  $id . ".");
    return $id;
}


sub sendFile
{
    my($id, $fname) = @_;
    if ($objects[$id]{"activeFd"} ne $none) {
        &sendActiveFdFile($objects[$id]{"activeFd"}, $fname);
    }
}

sub sendActiveFdFile
{
    my($i, $fname) = @_;
    if (!open(IN, $fname)) {
        &mud_tellActiveFd($i, "ERROR: the file " . $fname .
            " is missing.");
        return;
    }
    while(<IN>) {
        s/\s+$//;
        &mud_tellActiveFd($i, "*" . $_);
    }
    close(IN);
}

sub mud_tellActiveFd
{
    my($active, $what, $noRepaint) = @_;
    my $conn = $activeFds[$active]{"fd"}; # the "fd" key contains the $conn hash.
    if (substr($what,0,1) eq "?") { # a ? at the beginning indicates a filename follows
        &sendActiveFdFile($active,$filePrefix . substr($what,1));
        return;
    }
    my $saveCols=$columns; # save the $columns global
    $columns=$conn->{cols} || 80;
    if (substr($what,0,1) eq "*") { # dont wrap if preformatted
        $what=substr($what,1);
    } else {
        $what = wrap('','',$what) ;
    }
    $columns=$saveCols; # restore the $columns global
    &TH::output( $conn->{fd}, "\r" . &TH::scr_clear_eol($conn). $what . "\n", 1 );
    &TH::readline_repaint( $conn ) unless $noRepaint;
}

sub mud_loop
{
    my ( $conn ) = @_;

    delete $conn->{grep};

    if ( defined $conn->{spoof_fd} )
    {
        delete $conn->{spoof_fd};
    }

    if ( defined $conn->{spoof_real_user} )
    {
        $conn->{user}     = $conn->{spoof_real_user};
        $conn->{realuser} = $conn->{spoof_real_user};
        $conn->{udata}    = $TH::data->{users}->{ $conn->{spoof_real_user} };

        delete $conn->{spoof_real_user};
    }

    $conn->{interrupt_sub} = \& do_mud_quit;
    $now = time;
    if ($now - $lastdump >= $dumpinterval) {
        &dump($none, "", "", "");
    }
    my $i;
    my $id=$none;
    # get activeFd and also do some housekeeping
    for ($i = 0; ($i <= $#activeFds); $i++) {
        next if ($activeFds[$i]{"id"} == $none);
        if ($activeFds[$i]{"fd"} eq $conn) { # find the index of this fd ($conn)
            $id=$activeFds[$i]{"id"}; # save the current id for conn
        }
        if ($objects[$activeFds[$i]{"id"}]{"flags"} & $asleep) {
            # see if people should wake up
            my $me = $activeFds[$i]{"id"};
            my $kips=int(($now - $objects[$me]{"bedtime"})/10);
            if ($kips > 0) { # can wake
                my $y = $objects[$me]{"stamina"} + $kips;
                if ($y > $objects[$me]{"maxstamina"}) {
                    &tellPlayer($me,"You are too alert to sleep any more!");
                    &wake($me,"","","",1);
                }
            }
        }
    }
    
    # set prompt for current conn
    
    my $prompt = "*";
    $prompt=$objects[$id]{"prompt"};
    &TH::th_println();
    my $line = &TH::th_readline( $prompt );

    return sub
    {
        my $msg = $$line;

        $msg = &TH::clean_string2($msg);

        $conn->{interrupt_sub} = \& do_mud_quit;

        my $user = $conn->{realuser};

        if ( $msg ne '' && ! &TH::is_robot($conn) )
        {
            $user = uc $user if $conn->{tty};
            return do_mud_command( $msg, $conn );
            $conn->{udata}->{last_mud} = time;
        }

        return \&mud_loop;

    }
    
}

sub do_mud_command
{
    my ( $cmd, $conn ) = @_;

    my $mud = $TH::data->{mud};
    my $user = &TH::get_user($conn);

    return if !defined $mud->{users};
    for (my $i = 0; ($i <= $#activeFds); $i++) {
        if ($activeFds[$i]{"fd"} eq $conn) { # find the index of this fd ($conn)
            my $x = &mud_input($i, $cmd); # $x=$death if dead exit
            #debug test
            # return &do_mud_quit( $conn ) if (uc($cmd) eq 'QUIT');
#            return if ((uc($cmd) eq 'QUIT') || ($x == $death)); # exit mud
            return if ($x == $death); # exit mud
            last;
        }
    }

    return \& mud_loop;
}

sub mud_closeActiveFd
{
    my($i) = @_;
    if ($activeFds[$i]{"id"} != $none) {
        $objects[$activeFds[$i]{"id"}]{"activeFd"} = $none;
        $activeFds[$i]{"id"} = $none;
    }
    my($fd);
    $fd = $activeFds[$i]{"fd"};
    # Make sure the next person doesn't get old buffer data!
    $activeFds[$i] = { };
    $activeFds[$i]{"fd"} = $none;
    $activeFds[$i]{"id"} = $none;
    $activeFds[$i]{"smartclient"} = 0;
    $mudPlayers -= 1; # reduce number of players by 1
}

sub mud_input
{
    my($aindex, $input) = @_;
    $input =~ tr/\x00-\x1F//d;
    my $conn = $activeFds[$aindex]{"fd"};
    if ($activeFds[$aindex]{"id"} ne $none) {
        return (mud_command($activeFds[$aindex]{"id"}, $input)); #debug this is a fudge to pass death all the way up
    } else { #debug you should never get to this bit as everyone in TH automagically gets logged in
        &TH::xlog ('Mud: ERROR: an activeFd was not logged in');
        mud_closeActiveFd($aindex);
        #do_mud_quit( $activeFds[$aindex]{"fd"} );
        return; #debug this probably does not really eject the user but should
    }
}

sub mud_command
{
    my($me, $text, $demon) = @_; # user name is passed in $me
    my($id);
    $objects[$me]{"lastPing"} = $now;
    $_ = $text;
    # Don't let the user embed commands. Could do nasty, nasty things.
    s/\x01/\./g;
    s/\x02/\./g;
    s/^\?//g; # mud_tellActiveFd interprets these at start of line
    s/^\*//g; # mud_tellActiveFd interprets these at start of line
#debug need to remove the comment below when demons are working properly
#    s/^\$//g; # dont accept demon actions from the user
    # Clean up whitespace.
    s/\s/ /g;
    s/^ //g;
    s/ $//g;
    $text = $_;
    if ($objects[$me]{"prompt"} eq "\"") { # just chatting
        if ($text eq "*") {
            $objects[$me]{"prompt"} = "*";
            &flush($me); # flush input
            return 1;
        }
        $text = "\"" . $text;
    }
    if ($text eq "") {
        return;
    }
        
    #Split into command and argument.

    my($c, $arg) = split(/ /, $text, 2);
    
    $c =~ tr/A-Z/a-z/;

    ($c, $arg) = split(/ /, $arg, 2) if ($c eq "go"); # throwaway go as noise

    $c = $synonymTable{"$c"} unless ($synonymTable{"$c"} eq "");
        
    $text = "." . $text if ($playerIds{$c}); # if it returns true, we are whispering to a player

    $arg = &canonicalizeWord($me, $arg);
    
    $objects[$me]{"last"} = $now;

    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to do something
        # wake me if possible but report success if not so that no more commands are tried. its a kludge but it works.
        return if (!(&wake($me,"","",""))); # return if cant wake
    }

    if ($c eq "quit") { #debug this should not be hardcoded
        return &closePlayer($me, 1); # im amazed this works at all
    }

    if (substr($text, 0, 1) eq "\"") {
        &say($me, substr($text, 1), "", "");
        return;
    }
    if (substr($text, 0, 1) eq ":") {
        &emote($me, substr($text, 1), "", "");
        return;
    }
    if (substr($text, 0, 1) eq "'") {
        $text =~ s/^\'(\S+)\s*//;
        &say($me, $text, "", "", $1);
        return;
    }
    if (substr($text, 0, 1) eq ".") {
        $text =~ s/^\.(\S+)\s+//;
        &whisper($me, "", $1, $text);
        return;
    }
    if ($text =~ /^,(\S+)\s+(.*)$/) {
        &topic($me, "", $1, $2, 0);
        return;
    }
    if ($text =~ /^;(\S+)\s+(.*)$/) {
        &topic($me, "", $1, $2, 1);
        return;
    }

#debug this is causing problems elsewhere (eg force, bug, that take text string args) so disable conjugations for now.
#    if ($text =~ /.*\b\./) { # test to see if this is a string of commands using . as conjungation
#        my $x=0;
#        my @commands=split(/\.|$/,$text);
#        foreach my $com (@commands) {
#            $x=&mud_command($me, $com);
#            last if (($x==$death) || ($x==0)); # no more if dead or failed
#        }
#        return $x;
#    }
    
    #
    # Consider exits from this room.
    #

    if (substr($text, 0, 1) ne "@") {
        my $x = moveObject($me, $c, $arg); # try a move
        #debug this may need further refinement as it is a bit ugly
        if ($x==$death) { # death due to destination flag
            &closePlayer($me, 1, 1); #debug really this should close as part of the quit but its tricky quietly
        }
        if ($x) {
            &unfollow($objects[$me]{"following"},$me) if (exists $objects[$me]{"following"}); # if I moved myself or died I cant be following anyone
            return $x ; # either success or death
        }
    }

    # Now commands with an = sign.
    
    # Common parsing
    # this allows for various preposition to seperate arg1 and arg2
    my($arg1, $arg2);
    # this allows =, in, at, to, with, from as argument seperators. with and from can be abbreviated to w and fr. $arg retains the whole argument string.
    if ($arg =~ /^(\S+)\s*(=|\bin\b|\bat\b|\bto\b|\bw\w*\b|\bfr\w*\b)\s*(.+)$/i ) {
        # shoot door with cannon; put thing in container
        $arg1 = $1;
        $arg2 = $3;
        if ($2 =~ /\bat\b/i) { # ensure instrument always in arg2
            # shoot cannon at door - at always flips the nouns
#debug
            print "at detected\n" if ($debugMode);
            
            my $t=$arg1;
            $arg1 = $arg2;
            $arg2 = $t
        }
    } else {
        $arg1 = $arg;
    }
    $arg1 = &canonicalizeWord($me, $arg1);
    $arg2 = &canonicalizeWord($me, $arg2);
    # resolve synonyms for nouns1
    $arg1 = $synonymTable{"$arg1"} unless ($synonymTable{"$arg1"} eq "");
    $arg2 = $synonymTable{"$arg2"} unless ($synonymTable{"$arg2"} eq "");

    # Wiz and special Commands that are not in the database table
    if (exists $commandsProper{$c}) {
        return &{$commandsProper{$c}}($me, $arg, $arg1, $arg2);
    }
    
    # none of the above, so must be a database command or crap
    #debug global find is a fudge around containers. Need to look in room, me, things I am carrying
    my $id1=$none;
    my $id2=$none;
    
    if ($arg2 ne "") { # identify instrument (arg2) if exists
        $id2 = &findContents($me, $arg2); # am I carrying arg2?
        if ($id2==$none) { # somewhere in room?
            $id2 = &findContents($objects[$me]{"location"}, $arg2);
        }
        $id2=&targetPlayer($me,$arg2) if ($id2==$none); # try active player
        if (($objects[$id2]{"flags"} & $dark) || ($objects[$id2]{"flags"} & $destroyed)) {
            $id2=$none unless (&builderTest($me)); # target is invis or destroyed and you are not a wiz
        }
    } else {
        $id2=$none;
    }
    if ($arg1 ne "") { # identify object (arg1) if exists
        $id1 = &findContents($me, $arg1);
        if ($id1==$none) {
            $id1 = &findContents($objects[$me]{"location"}, $arg1);
            if ($id1==$none) {
                if ($arg =~ /^\S+\s*\bfr\w*\b\s*.+$/i) { # is there a "from" clause?
                    if ($id2!=$none) {
                        $id1 = &findContents($id2, $arg1); # look for arg1 in arg2
                        if (($objects[$id1]{"flags"} & $dark) || ($objects[$id1]{"flags"} & $destroyed)) {
                            $id1=$none unless (&builderTest($me)); # obj is invis or destroyed and you are not a wiz
                        }

                    }
                }
            }
            $id1=&targetPlayer($me,$arg1) if ($id1==$none); # try a global player
        }
    } else {
        $id1=$none;
    }
    if (exists($commandsTable{$c})) { # valid command
        if (($id2==$none) && ($arg2 ne "")) { # nothing near called arg2
            &tellPlayer($me,"I see no " . $arg2 . ".");
            return 0;
        }
        my $state=0;
        my @commands = split(/,/,$commandsTable{$c}); # allow multiple object defs for command
        foreach my $cid (@commands) { # try each command def
#debug
            print "c=$c cid=$cid arg=$arg arg1=$arg1\n" if ($debugMode);
            
            if (exists $objects[$cid]{"class"}) { # check arg1 for class match if there is an arg1
                # test something, anything, person
                my $objClass = "";
                my $objType=$none;
                $objClass = $objects[$id1]{"class"} unless ($id1==$none);
                $objType=$objects[$id1]{"type"} unless ($id1==$none); # $none can match "anything" though
                my $classmatch = ((($objects[$cid]{"class"} eq "something") && ($objType==$thing)) || (($objects[$cid]{"class"} eq "anything") && (($objType==$thing) || ($objType==$player) || ($id1==$none))) || (($objects[$cid]{"class"} eq "person") && ($objType==$player)) || ($objects[$cid]{"class"} eq $objClass));

#debug
                print "id1=$id1 c=$c cid class=" . $objects[$cid]{"class"} . " lock=" . $objects[$cid]{"lock"} . " objclass=$objClass  type=$objType  cmatch=$classmatch\n" if ($debugMode);

                next unless ($classmatch);
            }
            if (exists $objects[$cid]{"lock"}) { # check arg2 for class match if there is an arg2. A numeric lock is a word count of command
                next if ($arg2 eq ""); # no arg2 to pass lock
                my $classmatch = ( ($objects[$cid]{"lock"} eq (1 + $text =~ tr/ //)) || (($objects[$cid]{"lock"} eq "something") && ($objects[$id2]{"type"}==$thing)) || (($objects[$cid]{"lock"} eq "anything") && (($objects[$id2]{"type"}==$thing) || ($objects[$id2]{"type"}==$player))) || (($objects[$cid]{"lock"} eq "person") && ($objects[$id2]{"type"}==$player)) || ($objects[$id2]{"class"} eq $objects[$cid]{"lock"}));
#debug
                print "id2=$id2 c=$c cid lock=" . $objects[$cid]{"lock"} . " target lock=" . $objects[$id2]{"lock"}. " classmatch=$classmatch\n" if ($debugMode);

                next unless ($classmatch);
            }
            #debug the eval should return 1 if the function was a sucess or 0 if it wasnt
#debug
            print "evaluating " . $objects[$cid]{"action"}. "\n" if ($debugMode);
            
            $state=eval $objects[$cid]{"action"}; # should return 0 if fail or 1 if success
            print "eval err $@\n" if ($debugMode && ($state==undef));
#debug
            print " state=$state\n" if ($debugMode);
            
            last if ($state); # try the command or go to next if fails
        }
#debug this needs to only display if the verb is valid but couldnt operate becuase of privs required
#        if ($state==0) { # debug this needs to be smarter
#            &tellPlayer($me,$invalidMsgs[int(rand(5))]);
#        }
        if (($id1==$none) && ($arg1 ne "") && ($state==0)) {
            &tellPlayer($me,"I see no " . $arg1 . ".");
        }
        return $state;
    }
    &tellPlayer($me, "You'll have to try something else, I don't understand the first word (which should be an action).");
    return 0;
}

sub moveObject
{
    # attempts to move an object $me and returns 1 if success or 0 if fail outputting appropriate messages
    my($me, $c, $arg, $arg1, $arg2) = @_;
    # now need to iterate through room contents checking each exit for success
    # If an exit name doesnt match $c or fails move on to next
    my $id=$none;
    my $loc = $objects[$me]{"location"};
    my $after="";
    my $found = 0;
    my $msg;
    $id=findContents($loc,$c,$exit); # first look
    while ($id!=$none) {
        $found = 1; # we have found at least one matching exit
        #debug there appears to be a difference between what the manual says and what VALLEY does IRL
        # this is where we detecting a sleeping person
        if ($objects[$me]{"flags"} & $asleep) { # asleep trying to move
            # wake me if possible but report move success if not so that no more commands are tried. its a kludge but it works.
            return 1 if (!(&wake($me,"","","")));
        }
        if ($objects[$me]{"flags"} & $paralysed) { # asleep trying to move
            # cant move but report move success so that no more commands are tried. its a kludge but it works.
            &tellPlayer($me,"You're crippled, you can't go anywhere.");
            return 1; # pretend move worked
        }
        if (&testLock($me, $id)) {
            if ($objects[$id]{"action"} != $nowhere) {
                &removeContents($loc, $me);
                if (!($objects[$loc]{"flags"} & $grand) && !($objects[$me]{"flags"} & $dark)) {
                    # dont announce if grand or me is invisible
                    if ($objects[$me]{"type"}==$player) {
                        $msg = playerName($me) . " has just left.";
                    } else {
                        $msg = "The " . $objects[$me]{"name"} . " has just left.";
                    }
                    &success($me, $id, "",$msg);
                }
                if ($objects[$id]{"action"} == $home) {
                    &sendHome($me);
                    return 1; # gone home
                }
                my $destid=$objects[$id]{"action"};
                if ($destid=~/(.+?)\|.+/) { # multi destination exit
                    $destid=$1; # pick the first destination the loader randomised
                }
                if (!($objects[$destid]{"flags"} & $grand) && !($objects[$me]{"flags"} & $dark)) {
                    # dont announce if grand or me is invisible
                    if ($objects[$id]{"odrop"} ne "") {
                        # this seems to allow the odrop message of an exit to be used for arrival of a person object at destination
                        if ($objects[$me]{"type"}==$player) {
                            $msg = playerName($me) . &substitute($me,$objects[$id]{"odrop"});
                        } else {
                            $msg = "The " . $objects[$me]{"name"} . &substitute($me,$objects[$id]{"odrop"});
                        }
                        &tellRoom($destid, $none, $msg);
                    } else {
                        if ($objects[$me]{"type"}==$player) {
                            $msg = playerName($me) . " has just arrived.";
                        } else {
                            $msg = $objects[$me]{"description"};
                        }
                        &tellRoom($destid, $none, $msg);
                    }
                }
                addContents($destid, $me);
                look($me, "", "", "");
                # dont follow someone to your death
                if (($objects[$me]{"leading"} ne "") && (($objects[$destid]{"flags"} & $death) || $objects[$me]{"flags"} & $dark)) {
                    # me is dead or me was invis
                    &unfollow($me);
                }
                if (($objects[$destid]{"flags"} & $death) && !(builderTest($me))) { # you dont die if you are a wiz/builder
                    #debug this is an ugly way to make it quit all the way up
                    removeContents($destid, $me);
                    addContents($loc, $me); # make sure my death is in the last place I was alive
                    return $death;
                }
                if ($objects[$me]{"leading"} ne "") { #debug need to unfollow if small or dark and no bright object
                    my @followers=split(/,/,$objects[$me]{"leading"});
                    foreach my $f (@followers) {
                        my $name = ($objects[$me]{"type"}==$player) ? &playerName($me) : "the " . $objects[$me]{"name"};
                        &tellPlayer($f,"You follow " . $name . "...");
                        if ((!(&moveObject($f,$c,$arg, $arg1, $arg2))) || (!(isBright($objects[$f]{"locaton"})))) {
                            # move failed for some reason (a lock, dark or too small)?
                            #debug returns success even when a lock stops it
                            &tellPlayer($f,"You can follow " . $name . " no more.");
                            &unfollow($me,$f);
                        }
                    }
                }
                return 1; # success!
            } else { # nowhere man
                &fail($me, $id, "You can't go that way.", "");
                return 1; # not an valid exit but the conditon passed
            }
        } else {
            $after = $id; # match but could not use, try another one
            $id=findContents($loc,$c,$exit,$after); # look again
        }
    }
    if ($found) { # we found exits that matched but couldnt take any of them
        &fail($me, $id, "You can't go that way.", "");
        return 1; # valid choice but couldnt exit and dont try doing anything else in mud_command
        #debug this needs to signal fail to mud_creature but also signal dont do any more to mud_command
    }
    # if you get here it didnt match any exits
    return 0;
}

sub isBright
{
    my ($loc) = @_;
    # checks if you can see in the loc
    return 1 if ((!($objects[$loc]{"flags"} & $dark)) || ($objects[$loc]{"flags"} & $bright)); # not dark in the first place
    my @list = split(/,/, $objects[$loc]{"contents"});
    my $lit=0;
    foreach my $o (@list) {
        $lit=1 if (($objects[$o]{"flags"} & $bright) && ($objects[$o]{"currprop"}==0));
        if (length($objects[$o]{"contents"})>0) { # carrying things
            my @inv = split(/,/, $objects[$o]{"contents"});
            foreach my $p (@inv) {
                $lit=1 if (($objects[$p]{"flags"} & $bright) && ($objects[$p]{"currprop"}==0));
            }
        }
    }
    return $lit;
}

sub isTreasure
{
    my ($i) = @_;
    return (($objects[$i]{"score"}>0) && ($objects[$i]{"speed"}<1) && ($objects[$i]{"scoreprop"}==$objects[$i]{"currprop"}));
}

sub builderTest
{
    my($me) = @_;
    if (($objects[$me]{"flags"} & $builder) ||
        ($objects[$me]{"flags"} & $wizard))
    {
        return 1;
    }
    return 0;
}

sub targetPlayer
{
    # returns the id of a player name in arg1 if currently playing
    my ($me, $arg1) = @_;
    my $id=$none;
    $id = $playerIds{$arg1} if (defined $playerIds{$arg1}); # is it a player?
    $id = $me if ($arg1 eq ""); # target me if none specified
    if ($id!=$none) {
        $id = &idBounds($id);
        my $found=0;
        for (my $i = 0; ($i <= $#activeFds); $i++) { # are they playing?
            if ($activeFds[$i]{"id"} == $id) {
                $found=1;
            }
        }
        $id = $none unless ($found);
    }
    return $id;
}

sub mud_creature
{
    my($conn, $me) = @_; # me is the creature object id
    my ($id, $success);
#debug need to do a fight check before trying to move
    if (($objects[$me]{"currprop"}==0) && ($objects[$me]{"contents"} eq "") && !($objects[$me]{"flags"} & $destroyed) &&
        !($objects[$objects[$me]{"location"}]{"flags"} & $death)) { # only move a creature if prop is 0 and empty, not destroyed and not a death room
        my @directions = ("north","south","east","west","northeast", "northwest","southeast","southwest","up","down");
        my $desc="";
        my $loc = $objects[$me]{"location"};
        @directions = shuffle(@directions); # randomize directions
        foreach my $dir (@directions) {
            $success = 0;
            $success=moveObject($me,$dir); # try and move
            if ($success==$death) { # mobiles go home if they die from moving
                #debug or could just set success to 0 and try another direction
                sendHome($me,1);
            }
            last if ($success); # moved so stop trying
        }
    }
    &TH::set_timer( $objects[$me]{"speed"}, \&mud_creature, $me, 0 ); # start timer again once it has moved
}

sub mud_hitMob
{
}

sub mud_missMob
{
}

sub mud_hitPlayer
{
}

sub mud_missPlayer
{
}

# below are MUD internal functions

sub mud_xdemon # execute demon
{
    my ($conn, $demon) = @_; # demon is the demon id
    if (!($demonsTable[$demon]{"flags"} & $dEnabled)) {
        return 0; # demon is not enabled
    }
    # retrieve parameters
    my $id = $demonsTable[$demon]{"id"};
    my $me = $demonsTable[$demon]{"me"};
    my $arg = $demonsTable[$demon]{"arg"};
    my $arg1 = $demonsTable[$demon]{"arg1"};
    my $arg2 = $demonsTable[$demon]{"arg2"};

    # resolve synonyms for args
    $arg1 = $synonymTable{"$arg1"} unless ($synonymTable{"$arg1"} eq "");
    $arg2 = $synonymTable{"$arg2"} unless ($synonymTable{"$arg2"} eq "");
    
    my $id1 = findObject($arg1); # global
    my $id2 = findObject($arg2); # global

#debug
    print "xdemon demon=$demon objid=$id me=$me arg=$arg arg1=$arg1 id1=$id1 arg2=$arg2 id2=$id2\n" if ($debugMode);

    # check this demon matches the class & lock clauses for noun1 and noun2 if supplied
    if ($objects[$id]{"class"} ne "none") { # check id1 for class match if there is an arg1
        # test something, anything, person
        my $objClass = "";
        my $objType=$none;
        $objClass = $objects[$id1]{"class"} unless ($id1==$none);
        $objType=$objects[$id1]{"type"} unless ($id1==$none);
        my $classmatch = (($objects[$id]{"class"} eq "whichever") || (($objects[$id]{"class"} eq "something") && ($objType==$thing)) || (($objects[$id]{"class"} eq "anything") && (($objType==$thing) || ($objType==$player))) || (($objects[$id]{"class"} eq "person") && ($objType==$player)) || ($objects[$id]{"class"} eq $objClass));
#debug
        print "xdemon demon=$demon classmatch=$classmatch \n" if ($debugMode);

        return 0 unless ($classmatch);
    }
    # I dont think this is ever used in MUD/VALLEY
#    if ($objects[$id]{"lock"} ne "none") { # check id2 for class match if there is an arg2. A numeric lock is a word count of command
#        my $classmatch = (($objects[$id]{"lock"} eq "whichever") || (($objects[$id]{"lock"} eq "something") && ($objects[$id2]{"type"}==$thing)) || (($objects[$id]{"lock"} eq "anything") && (($objects[$id2]{"type"}==$thing) || ($objects[$id2]{"type"}==$player))) || (($objects[$id]{"lock"} eq "person") && ($objects[$id2]{"type"}==$player)) || ($objects[$id2]{"class"} eq $objects[$id]{"lock"}));
#        return 0 unless ($classmatch);
#    }
    my $state=0;
    my $c=$objects[$id]{"action"};
    if (exists($commandsTable{$c})) {
        my @commands = split(/,/,$commandsTable{$c}); # allow multiple object defs for command
        foreach my $cid (@commands) { # try each command def
#debug
            print "xdemon c=$c cid=$cid " if ($debugMode);
            
            $state=eval $objects[$cid]{"action"}; # should return 0 if fail or 1 if success
#debug
            print "state=$state \n" if ($debugMode);
            
            last if ($state); # go to next if fails
        }
    }
    # disenable demon after exec unless always
    if ($demonsTable[$demon]{"flags"} & $dAlways) { # persistent demon
        if ($objects[$id]{"speed"} >= 0) { # demon has a timer
            my $timer=$objects[$id]{"speed"};
            if ($timer=~/(\d+)-(\d+)/) { # there is a range
                $timer=int(rand($2-$1+1))+$1; # rand between $1 and $2 inc
            }
            &TH::set_timer( $timer, \&mud_xdemon, $demon, 0 ); # start timer
        }
    } else { # not persistent
        $demonsTable[$demon]{"flags"} &= ~$dEnabled;
    }
    return $state;
}

sub mud_demon # init demon
{
    my ($me,$demon,$arg,$arg1,$arg2) = @_;
    my $timer = -1;
    #debug need to get $conn as first arg if called from TH?
    $demon=int(abs($demon)); # only use +ve numbers;
    my $id=$demonsTable[$demon]{"id"};
    $demonsTable[$demon]{"flags"} |= $dEnabled; # mark as enabled
    $demonsTable[$demon]{"me"} = $me; # store executor
    $demonsTable[$demon]{"arg"} = $arg; # store values for run
    $demonsTable[$demon]{"arg1"} = $arg1;
    $demonsTable[$demon]{"arg2"} = $arg2;
#debug
    print "demon $demon arg=$arg arg1=$arg1 arg2=$arg2 flags=" .$demonsTable[$demon]{"flags"} . "\n" if ($debugMode);
    
    if ($objects[$id]{"speed"} >= 0) # demon has a timer before launch
    {
        $timer=$objects[$id]{"speed"};
        if ($timer=~/(\d+)-(\d+)/) { # there is a range
            $timer=int(rand($2-$1+1))+$1; # rand between $1 and $2 inc
        }
        &TH::set_timer( $timer, \&mud_xdemon, $demon, 0 ); # start timer
    } else {
        # instant execute
        return &mud_xdemon(0,$demon);
    }
    return 1;
}

sub mud_autowho # autowho timer handler
{
    my ($conn,$me) = @_;
    return if ($objects[$me]{"autowho"}==0);
    &who($me) if (!($objects[$me]{"flags"} & $asleep)); # dont wake but dont tell if asleep
    &TH::set_timer( $objects[$me]{"autowho"}, \&mud_autowho, $me, $activeFds[$objects[$me]{"activeFd"}]{"fd"}->{"fd"} ); # start timer again once it has displayed
}

sub mud_housekeeping
{
    # some housekeeping that it is useful to do from time to time. Similar to check.stuff in MUD1
    $now = time;
    for (my $i = 0; ($i <= $#activeFds); $i++) {
        next if ($activeFds[$i]{"id"} == $none);
        if ($objects[$activeFds[$i]{"id"}]{"flags"} & $asleep) {
            # see if people should wake up
            my $me = $activeFds[$i]{"id"};
            my $kips=int(($now - $objects[$me]{"bedtime"})/10);
            if ($kips > 0) { # can wake
                my $y = $objects[$me]{"stamina"} + $kips;
                if ($y > $objects[$me]{"maxstamina"}) {
                    &tellPlayer($me,"You are too alert to sleep any more!");
                    &wake($me,"","","",1);
                }
            }
        }
    }
    if (keys %fightsTable>0) {
        # handle fights in progress - assumes the tick is governed by the housekeeping timer
        foreach my $x (keys %fightsTable) {
            foreach my $y (keys %{$fightsTable{$x}}) {
                # take a fight turn
                my $xname = ($objects[$x]{"type"}==$player) ? &playerName($x) : "The " . $objects[$x]{"name"};
                my $yname = ($objects[$y]{"type"}==$player) ? &playerName($y) : "The " . $objects[$y]{"name"};
                #debug temp messages
                if ($objects[$y]{"type"}==$player) {
                    &tellPlayer($y,$xname . " hits you!")
                    &tellPlayer($y,"You hit ". $xname . "!")
                }
                if ($objects[$x]{"type"}==$player) {
                    &tellPlayer($x,"You hit " . $yname . "!")
                    &tellPlayer($x,$yname . " hits you!")
                }
            }
        }
    }
    &TH::set_timer(1,\&mud_housekeeping,0,0); # housekeeping every second
}

sub actionHandler # genric handler for messages and demon actions
{
    my ($me,$here,$there,$everywhere,$demon,$arg,$arg1,$arg2) = @_;
    $here="" unless (defined $here);
    $there="" unless (defined $there);
    $everywhere="" unless (defined $everywhere);
    $demon=0 unless (defined $demon);
    &tellPlayer($me,$here) unless ($here eq "");
    &tellPlayer($me,$there) unless ($there eq "");
    &tellElsewhere($me,$everywhere) unless ($everywhere eq "");
    &mud_demon($me,$demon,$arg,$arg1,$arg2) unless ($demon==0);
}

sub mud_dead # null; do action and quit as if dead
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug dont think this will work - needs checking
#    $(    let nam=PNAME of profile
#        for i=0 to 35 if fight!i /\ i ne player.no
#        $(    let block=getmblock()
#            block!3_!nam
#            block!4_1!nam
#            send(i,block,K.IHD,(player.level()+1)*DEADPTS/2)
#            fight!i_false
#        $)
#    $)
#    stop.fighting()
#    longdescribe(sms)
#    unless WIZARD of profile ne 0 test spectacular then
#    $(    drop.everything()
#        STAMINA of profile_STAMINA of profile<20 -> 10, (STAMINA of profile)-10
#    $) or
#    $(    if sms<0 longdescribe(-sms)
#        quit()
#    $)
#    endcase
#
    return $death;
}

sub mud_dec # (obj|null); decrements prop>0, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=targetObject($me, $arg1, $arg2, $fnArg1, $fnArg2);
    return 0 if ($id==$none); # didnt find anything
    my $p = $objects[$id]{"currprop"} - 1;
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2) if ($p < 0);
    &setPropDesc($id,$p);
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_decdestroy # (obj|first|second|null); dec prop of noun1>=0 and destroy obj?
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    &mud_dec($me, $arg, $arg1, $arg2, "null", $fnArg2, $here, $there, $everywhere, $demon); # dec prop noun1 & fire messages & demon
    if ($fnArg1 eq "first") { # destroy noun1
        &mud_destroy($me, $arg, $arg1, $arg2, "null", $fnArg2);
    } elsif ($fnArg1 eq "second") { # destroy noun2
        &mud_destroy($me, $arg, $arg2, $arg2, "null", $fnArg2);
    } else { # destroy obj or noun1
        &mud_destroy($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2);
    }
    return 1;
}

sub mud_destroy # (obj|null); destroys obj or command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=targetObject($me, $arg1, $arg2, $fnArg1, $fnArg2);
    return 0 if ($id==$none); # didnt find anything
    if (!($objects[$id]{"flags"} & $destroyed)) { # only success if not already destroyed
        $objects[$id]{"stamina"} = -1; # in mud this is how it was
        $objects[$id]{"flags"} |= $destroyed; # mark object as destroyed
        my $loc = $objects[$id]{"location"};
        while ($objects[$loc]{"type"}!=$room) { # iterate up to the room
            $loc = $objects[$loc]{"location"};
            if ($loc eq "") { # something went wrong
                $loc=int($objects[$id]{"home"}); # in case of error
                last;
            }
        }
        if ($loc != $objects[$id]{"location"}) { # put destroyed item in nearest room
            &removeContents($objects[$id]{"location"}, $id);
            &addContents($loc, $id);
        }
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_destroydec # (obj|null); destroy obj or noun1 and dec prop of obj or noun2 and out msg
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if ($fnArg1 eq "first") { # destroy noun1
        &mud_destroy($me, $arg, $arg1, $arg2, "null", $fnArg2);
    } elsif ($fnArg1 eq "second") { # destroy noun2
        &mud_destroy($me, $arg, $arg2, "", "null", $fnArg2);
    } else { # destroy obj or noun1
        &mud_destroy($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2);
    }
    &mud_dec($me, $arg, $arg2, "", "null", $fnArg2, $here, $there, $everywhere, $demon); # dec prop noun2 & fire messages & demon
    return 1;
}

sub mud_destroydestroy # (obj|first|second|null); looks like it destroys command noun1 and noun2 or obj
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if ($fnArg1 eq "first") { # destroy noun1
        &mud_destroy($me, $arg, $arg1, $arg2, "null", $fnArg2);
    } elsif ($fnArg1 eq "second") { # destroy noun2
        &mud_destroy($me, $arg, $arg2, "", "null", $fnArg2);
    } else { # destroy obj or noun1
        &mud_destroy($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2);
    }
    &mud_destroy($me, $arg, $arg1, "", "null", $fnArg2, $here, $there, $everywhere, $demon); # destroy noun1 & fire messages & demon
    return 1;
}

sub mud_destroyinc # (obj|null); destroy obj or noun1 and inc prop of obj or noun2 and out msg
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if ($fnArg1 eq "first") { # destroy noun1
        &mud_destroy($me, $arg, $arg1, $arg2, "null", $fnArg2);
    } elsif ($fnArg1 eq "second") { # destroy noun2
        &mud_destroy($me, $arg, $arg2, "", "null", $fnArg2);
    } else { # destroy obj or noun1
        &mud_destroy($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2);
    }
    &mud_inc($me, $arg, $arg2, "", "null", $fnArg2, $here, $there, $everywhere, $demon); # inc prop noun2 & fire messages & demon
    return 1;
}

sub mud_disenable # null value; terminate demon value and do actions
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug needs finishing
    return 0;
}

sub mud_emotion # (obj|null) value; reduce player score by value and increase target obj or noun1 score by (2*value)/3
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,1) eq $me) {
        &tellPlayer($me,"Narcissism gets you nowhere these days, flower.");
        return 0;
    }
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        my $givevalue = int((2*$fnArg2)/3);
        my $takevalue = -($fnArg2);
#debug this is a bit of kludge and needs kiss to be the actual verb
        if ($objects[$id]{"flags"} & $asleep) {
            &wake($id,"","","",1);
        }
        &addExp($me,$takevalue);
        &tellPlayer($id,playerName($me) . " has given you a nice kiss."); # debug this should be the verb used
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        &addExp($id,$givevalue);
        return $id;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_enable # null value; enable demon value and do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return &mud_demon($me,$fnArg2,$arg,$arg1,$arg2);
}

sub mud_exp # (obj|null) value; add value to obj or player score
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        &addExp($me, $id);
        return $id;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_expdestroy # (obj|null); destroy obj and earn score; null is command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me, $arg1, $arg2, $fnArg1, $fnArg2);
    return 0 if ($id==$none); # didnt find anything
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    &addExp($me, $id); # gain exp from noun1 or obj
    return (&mud_destroy($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2));
}

sub mud_expset # (obj|null) value; gain the score determined by obj or noun1 score if the scoreprop=prop and then set prop to value debug understand code in MUD3 setexp
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me, $arg1, $arg2, $fnArg1, $fnArg2);
    return 0 if ($id==$none); # didnt find anything
    my $currvalue=0;
    # more complex score calculation as per MUD3 setexp
    if (($objects[$id]{"currprop"}==$objects[$id]{"scoreprop"}) || ($objects[$id]{"maxprop"}<0)) {
        # prop is score prop or this is a random prop object
        #debug  what is P1 of obj=1 in MUD3?
        my $res = $objects[$id]{"score"};
        $res=($objects[$id]{"currprop"}+1) * $res if ($objects[$id]{"maxprop"}<0); # score based on currprop * value if the prop is a random
        $currvalue = int(3*$res-((4*$res)/($mudPlayers+1))); # only add 1 because we start from 1 unlike MUD.
        &addExp($me,$currvalue); # add to score
    }
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    &setPropDesc($id,$fnArg2); # set prop of object to value
    return 1;
}

sub mud_flipat # null; flips noun1 and noun2 around when at is used as a preposition but is handled in mud_command
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    # not needed in TH mud
    return 0;
}

sub mud_flush # null; flush input buffer and do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $conn=$activeFds[$objects[$me]{"activeFd"}]{"fd"};
    &TH::read_flush($conn->{fd});
    &TH::clear_readline($conn);
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_holdfirst # null; sets flag to check inventory before location
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

sub mud_holdlast # null; sets a flag to check location before inventory
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

sub mud_hurt # (obj|null) value; obj or noun1 is attacked with noun2 and the value is the minimum initial hit bitor with the weapon and determines msg?
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_ifasleep # null value; if asleep flag is value do actions
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
    }
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return (!!($objects[$id]{"flags"} & $asleep)==$fnArg2);
}

sub mud_ifberserk # null; never gong to be true as we wont support berserkers
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

sub mud_ifblind # (obj|null) value; if blind is value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug should compare against value for true/false testing
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
    }
    my $state=(!!($objects[$id]{"flags"} & $blind)==$fnArg2);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_ifdeaf # (obj|null) value; if deaf flag is value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug should compare against value for true/false testing
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
    }
    my $state=(!!($objects[$id]{"flags"} & $deaf)==$fnArg2);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_ifdisenable # null value; if demon value is currently enabled disable it and do actions if could disable
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $d=int(abs($fnArg2));
    if ($demonsTable[$d]{"flags"} & $dEnabled) {
        # if it was enabled - disable it and return true
        $demonsTable[$d]{"flags"} &= ~$dEnabled;
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifdumb # (obj|null) value; if dumb flag is value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug should compare against value for true/false testing
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
    }
    my $state=(!!($objects[$id]{"flags"} & $dumb)==$fnArg2);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_ifenabled # null value; if demon value is currently enabled do actions
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $d=int(abs($fnArg2));
    my $state=!!($demonsTable[$d]{"flags"} & $dEnabled);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_iffighting # (obj|null); if obj or player is fighting do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

sub mud_ifgot # obj; do if got obj and using it??? debug
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if ($fnArg1 eq "first") { # test noun1
        $arg1=$arg1;
    } elsif ($fnArg1 eq "second") { # test noun2
        $arg1=$arg2;
    } else { # test obj if not null
        $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    }
    if (&findContents($me,$arg1) != $none) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifhave # obj; if carrying obj but not using it do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug how does this differ from ifgot?
    if (&findContents($me,$fnArg1) != $none) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifhere # obj; do if obj is here??? debug
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    # is it visible or not?
    my $state = !!(substr(&visibleCanonicalizeWord($me,$fnArg1),0,1) eq "#");
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return $state;
}

sub mud_ifill # (obj|null); if obj or player is ill do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        if (($objects[$id]{"flags"} & $deaf) || ($objects[$id]{"flags"} & $dumb) || ($objects[$id]{"flags"} & $blind) || ($objects[$id]{"flags"} & $paralysed)) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifin # (obj|null) location; if obj or player in location do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = '#' . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        my $room = lc($objects[$objects[$id]{"location"}]{"room"});
        if ($room eq $fnArg2) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifinsis # obj; if instrument (noun2) is obj then do actions
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $insid = visibleCanonicalizeWord($me, $arg2);
    if (substr($insid,0,1) eq "#") {
        $insid = int(substr($insid,1));
        $insid = &idBounds($insid);
        if (($objects[$insid]{"name"} eq $fnArg1) || ($objects[$insid]{"class"} eq $fnArg1)) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifinvis # null value; if invis flag of player is value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    # should really test for value but it is almost always 1
    my $state = (!!($objects[$me]{"flags"} & $dark)==$fnArg2);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", $demon, $arg, $arg1, $arg2);
    }
    return $state;
}

sub mud_iflevel # (obj|null) value; if player or obj level >= value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        if ($objects[$id]{"level"}>=$fnArg2) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1 ;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifobjis # obj; if noun1 is obj do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $objid = visibleCanonicalizeWord($me, $arg1);
    if (substr($objid,0,1) eq "#") {
        $objid = int(substr($objid,1));
        $objid = &idBounds($objid);
        if (($objects[$objid]{"name"} eq $fnArg1) || ($objects[$objid]{"class"} eq $fnArg1)) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifparalysed # (obj|null) value; if paralysed flag is value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug should compare against value for true/false testing
    $arg1 = "#" . $me;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
    }
    my $state=(!!($objects[$id]{"flags"} & $dumb)==$fnArg2);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_ifprop # (obj|null) value; tests prop value of obj, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = &targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    my $state=!!($objects[$id]{"currprop"} == int($fnArg2));
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_ifr # (obj|null) value; if random(100)<value do action and set IFR why debug???
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $state=(int(rand(100))<$fnArg2);
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    }
    return ($state);
}

sub mud_ifrlevel # (obj|null) value; if (1+player level * value > random(100) or wiz) and (1+level of target obj or noun1 * value < random (100) not wiz) do action and set ifr??? debug
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetPlayer($me, $arg1);
    my $cond1=(int(rand(100)) < (1+$objects[$me]{"level"})*$fnArg2); # % chance to succeed
    my $cond2=(int(rand(100)) < (1+$objects[$id]{"level"})*$fnArg2); # % chance to resist
    
#debug not sure if this gives the right answer
    print "ifrlevel me=$me id=$id cond1=$cond1" if ($debugMode);
    
    if (&builderTest($me) || ($cond1)) { # can you succeed
        if ($me==$id) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1; # i was the target that is sufficient
        }
        
#debug
        print " cond2=$cond2" if ($debugMode);
        
        if (!((&builderTest($id)) || ($cond2))) { # can target resist
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1; #  not resisted
        }
    }
    
#debug
    print "\n" if ($debugMode);
    
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifrprop # (obj|null) value; if maxprop<0 of obj or noun1 set prop to random(maxprop) and if prop is value do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    if ($objects[$id]{"maxprop"}<0) {
        my $prop = int(rand(abs($objects[$id]{"maxprop"})+1));
        &setPropDesc($id,$prop);
        if ($prop==$fnArg2) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", $demon, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifrstas # null; if random(stamina of player) < random(stamina of mobile) do actions??? - this is a mobile specific function debug
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    # mobile object id passed in $arg1 as a #id
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        if (int(rand($objects[$me]{"stamina"})) < int(rand($objects[$id]{"stamina"}))) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifself # null; if target is self
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = visibleCanonicalizeWord($me, $arg1);
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        if ($id == $me) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifsmall # (obj|null); if obj or room has flag small
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = "#" . $objects[$me]{"location"}; # current room default
    if ($fnArg1 ne "null") {
        $arg1 = $fnArg1;  # use function arg1 if set
        $id = visibleCanonicalizeWord($me, $arg1);
    }
    if (substr($id,0,1) eq "#") {
        $id = int(substr($id,1));
        $id = &idBounds($id);
        if ($objects[$id]{"flags"} & $small) {
            &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
            return 1;
        }
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifweighs # (obj|null) value; if obj or noun1 weight >= value do msg
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    if ($objects[$id]{"weight"}>=$fnArg2) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifwiz # (obj|null); do if obj or command noun1 a wiz
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (&builderTest($me)) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_ifzero # (obj|null); test prop is zero, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    if ($objects[$id]{"currprop"}==0) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_inc # (obj|null); inc prop<=maxprop, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    #debug
    my $id=targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    my $p = $objects[$id]{"currprop"} + 1;
    if ($p<=$objects[$id]{"maxprop"}) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        &setPropDesc($id,$objects[$id]{"currprop"} + 1);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_incdestroy # (obj|null); inc prop of noun1<=maxprop and destroy obj or noun2?
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if ($fnArg1 eq "first") { # destroy noun1
        &mud_destroy($me, $arg, $arg1, $arg2, "null", $fnArg2);
    } elsif ($fnArg1 eq "second") { # destroy noun2
        &mud_destroy($me, $arg, $arg2, "", "null", "");
    } else { # destroy obj or noun1
        &mud_destroy($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2);
    }
    &mud_inc($me, $arg, $arg1, "", "null", "", $here, $there, $everywhere, $demon); # inc prop noun1
    return 1;
}

sub mud_injure # (obj|null) value; deducts value stamina from obj or mobile in arg1 and destroys, does not start combat, does not score kill
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    # mobile object id passed in $arg1 as a #id - but no check
    my $id=targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    my $stamina = $objects[$id]{"stamina"} - $fnArg2;
    if ($stamina<=0) {
        $objects[$id]{"flags"} |= $destroyed; # mobile died
        $objects[$id]{"stamina"} = -1;
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        #debug this is not in MUD but play testing shows it is helpful
        &tellPlayer($me,"The " . $objects[$id]{"name"} . " died.");
        &dropAll($id); # drop everything it carried
    } else {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        $objects[$id]{"stamina"} = $stamina;
    }
    return 1;
}

sub mud_loseexp # null value; reduce score of player by value
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    &addExp($me, -$fnArg2);
    return 1;
}

sub mud_losestamina # (obj|null) value; deduct value stamina from obj or command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = &targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1 if &builderTest($me); # dont deduct if a wiz
    my $y = $objects[$id]{"stamina"} - $fnArg2;
    $objects[$id]{"stamina"} = (0, $y)[$y>0];

#debug tell target its died and kill it how??? see checkout in MUD3.BCL which is called from F.LOSESTAMINA in MUD5.BCL. Also the message needs to be displayed before death.
    if ($objects[$id]{"stamina"}<1) {
        &checkout($id); #debug this exits the player as dead with no points awarded to killer
    }
    return 1;
}

sub mud_move # (obj|null) room; move obj to room, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $dest=$none;
    $arg1 = $fnArg1 if ($fnArg1 ne "null"); # use function arg1 if set
    $arg2 = $fnArg1;
    $dest=&findObject($arg2,,$room); # find the MUD room
    return 0 if ($dest==$none); # bad room
    my $id = &targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none); # no object
    &removeContents($objects[$id]{"location"},$id);
    &addContents($dest,$id);
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_noifr # null; clear IFR flag why debug?
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

sub mud_retal # null value; retaliates like hurt with a bitor of weapon value and out msg - why the bitor and how to work this out debug???
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

sub mud_sendemon # (obj|null) demon; starts demon passing obj or command noun1 as object
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = &targetPlayer($me, $arg1);
    # send demon only acts on active players, never objects
    return 0 if ($id==$none); # no person, no object
    if (&builderTest($me)) { # it was a wiz wot dunit
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return (&mud_demon($id,$fnArg2,$arg,$arg1,$arg2)); #debug might need to send arg2 as arg1
    }
    return 0 if (($objects[$id]{"flags"} & $dark) || ($objects[$id]{"flags"} & $destroyed)); # not if target is invis or destroyed
    # start demon as if run by $id not $me
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return (&mud_demon($id,$fnArg2,$arg,$arg1,$arg2)); #debug might need to send arg2 as arg1
}

sub mud_sendeffect # obj msgid; sends msgid to every room that contains obj
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    # fnArg2 contains the message to send to all rooms
    my $id=&findObject($fnArg1);
    if ($id!=$none) {
        for (my $i = 0; ($i <= $#objects); $i++) {
            if ($objects[$i]{"type"}==$room) { # check contents
                if ($objects[$i]{"contents"} =~ /\b$id\b/ ) {
                    &tellRoom($i,$none,$fnArg2); # send message to room
                }
            }
        }
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2); # still triggers actions
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_sendlevel # null value; send a message noun2 to all players of level value-1 and do action
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0 if ($objects[$me]{"level"}==0);
    if (!($objects[$me]{"flags"} & $dumb)) {
        for (my $i = 0; ($i <= $#activeFds); $i++) {
            if ($activeFds[$i]{"id"} != $none) {
                my $id = $activeFds[$i]{"id"};
                if ($objects[$id]{"level"} >= $fnArg2 - 1 ) {
                    # novices cant do this
                        &tellPlayer($id,playerName($me) . " (wish) " . $arg); # send message to player
                }
            }
        }
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &tellPlayer($me, "You can't do that, you're dumb");
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_set # (obj|null) value; sets obj prop to value, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none);
    &setPropDesc($id,int($fnArg2));
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_ssendemon # null value; super (as if you are a wiz) send demon value to act on the arg1 target and do action against arg1 as if arg1 had entered the command
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = &targetPlayer($me, $arg1);
    # send demon only acts on active players, never objects
    return 0 if ($id==$none); # no person, no object
    # start demon as if run by $id not $me
    &mud_demon($id,$fnArg2,$arg,$arg1,$arg2); #debug might need to send arg2 as arg1
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_stamina # (obj|null) value; set stamina of obj or player/mobile to min(current stamina+value,maxstamina)
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none);
    my $y = $objects[$id]{"stamina"} + int($fnArg2);
    $objects[$id]{"stamina"} = ($objects[$id]{"maxstamina"}, $y)[$y<$objects[$id]{"maxstamina"}];
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_testsex # (obj|null); if male msg1 else msg2
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    return 0 if ($id==$none);
    if ($objects[$id]{"flags"} & $male) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_testsmall # (null); test if location has small flag, output msg1 if true else msg2
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id = $objects[$me]{"location"}; # current room
    if ($objects[$id]{"flags"} & $small) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlessgot # obj; dont do if got obj in inventory and using it??? debug?
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (!(&mud_ifgot($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2))) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlesshere # obj; unless obj is here output msg1 else output msg2 (or nothing if 0)
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (!(&mud_ifhere($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2))) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlessill # null; do action unless deaf, dumb, blind, paralysed - demon action debug ????
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (!(&mud_ifill($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2))) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlessinsis # obj; do action unless instrument (noun2) is obj
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (!(&mud_ifinsis($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2))) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlesslevel # null value; if level of player < value then do actions
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (!(&mud_iflevel($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2))) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlessobjis # obj; do action unless noun1 is obj
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    if (!(&mud_ifobjis($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2))) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlessobjplayer # (obj|null); do unless noun1 is a player
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetPlayer($me, $arg1); # returns me if arg1 is null
    $id = $none if ($id==$me); # reject if me
    if (($id != $none) && ($objects[$id]{"type"} == $player)) {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
        return 0;
    }
    # obj noun1 wasnt a player or was me so throw away
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, "", $arg2);
    return 1;
}

sub mud_unlessplaying # null value; unless there is a player of level value playing
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $found=0;
    for (my $i = 0; ($i <= $#activeFds); $i++) {
        if ($activeFds[$i]{"id"} != $none) {
            my $id = $activeFds[$i]{"id"};
            $found=1 if ($objects[$id]{"level"} >= $fnArg2);
        }
    }
    if (!$found) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
        return 1;
    }
    &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
    return 0;
}

sub mud_unlessprop # (obj|null) value; tests prop value of obj, null implies command noun1
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $id=&targetObject($me,$arg1,$arg2,$fnArg1,$fnArg2);
    if ($id==$none) { #debug if its not the obj try inst - this is a kludge
        $id=&targetObject($me,$arg2,$arg1,$fnArg1,$fnArg2);
    }
    return 0 if ($id==$none);
    if ($objects[$id]{"currprop"}==$fnArg2) {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
        return 0;
    }
    &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    return 1;
}

sub mud_unlessrlevel # (obj|null) value; do action unless (1+player level * value > random(100) or wiz) and (1+level of target obj or noun1 * value < random (100) not wiz)
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $state=&mud_ifrlevel($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2);
    if ($state) { # ifrlevel sucess, so unlessrlevel failed
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
        return 0;
    } else { # ifrlevel failed, so unlessrlevel success
        &actionHandler($me, $here, "", $everywhere, $demon, "", "", "");
        return 1;
    }
}

sub mud_unlesswiz # (obj|null); do primitive and messages unless obj or player is a wiz
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    my $state = !(&builderTest($me));
    if ($state) {
        &actionHandler($me, $here, "", $everywhere, $demon, $arg, $arg1, $arg2);
    } else {
        &actionHandler($me, "", $there, "", 0, $arg, $arg1, $arg2);
        $state = 0;
    }
    return $state;
}

sub mud_writein # (obj|null); append the second parameter text into obj or noun1 if null (books etc)
{
    my ($me, $arg, $arg1, $arg2, $fnArg1, $fnArg2, $here, $there, $everywhere, $demon) = @_;
    return 0;
}

# here are the MUD primitives

sub assist
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # help someone
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    return 1;
}

sub attach
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # has no meaning on TH
}

sub autowho
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # sets up a timer to send a who to the player ever arg1 seconds
    # may or may not support this on TH -
    # the obvious way is timers but that has issues with the number if timers that may be kicked off
    # how many concurrent users are you really going to have?
    if (int($arg1)>0) {
        $objects[$me]{"autowho"} = $arg1; # store interval for player
        &TH::set_timer( $objects[$me]{"autowho"}, \&mud_autowho, $me, $activeFds[$objects[$me]{"activeFd"}]{"fd"}->{"fd"} ); # start timer for this player
    } elsif (defined $objects[$me]{"autowho"}) {
        delete $objects[$me]{"autowho"};
        &TH::kill_timer(\&mud_autowho, $activeFds[$objects[$me]{"activeFd"}]{"fd"}->{"fd"} )
    }
    return 1;
}

sub back
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # goes back the way you came if you can determine what it was
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    return 1;
}

sub begone
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # no idea what this does
}

sub berserk
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # will never be supported on TH
}

sub blind
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
#debug - in MUD5.BCL this just flips for the profile player (me). Others are flipped using a demon
    my $id=$me;
#    my $id = targetPlayer($me,$arg1);
    if ($id != $none) {
        $objects[$id]{"flags"} |= $blind;
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub brief
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # it would be good to support brief room descriptions in the future
    # both automatic and requested
}

sub bug
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug reports a bug - should make this multi line really rather than just $arg
    my $conn;
    # find my $conn
    for (my $i = 0; ($i <= $#activeFds); $i++) {
        if ($activeFds[$i]{"id"} == $me) {
            $conn = $activeFds[$i]{"fd"};
            last;
        }
    }
    if ((time - $objects[$me]{"bug"} < 60) || ($objects[$me]{"level"} < 1)) { # novices cant report
        &tellPlayer($me,"Sorry, I can't do that now, try again later.");
        $objects[$me]{"bug"}=time; # bug report throttling
        return 0;
    }

    my $to = $maintainer; # well gotta go somewhere
    if ( !defined $TH::data->{users}->{$to} )
    {
        &TH::error( 'MUD maintainer not found' );
        return 0;
    }
    $conn->{mail_to} = $to;

    $conn->{mail_subj} = "MUD bug report";
    $conn->{mail_body} = $arg;

    &TH::mail_send_message($conn);
    
    $objects[$me]{"bug"}=time; # bug reported
    
    &tellPlayer($me,"Your bug has been recorded. Thankyou!");
    return 1;
}

sub bye
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug logs you out on MUD, but just quit here
    return $death;
}

sub change
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    #debug - in MUD5.BCL this just flips for the profile player (me). Others are flipped using a demon
    my $id = &targetPlayer($me,$arg1);
    if ($id != $none) {
        if ($objects[$id]{"flags"} & $female) {
            $objects[$id]{"flags"} &= ~$female;
            $objects[$id]{"flags"} |= $male;
        } else {
            $objects[$id]{"flags"} &= ~$male;
            $objects[$id]{"flags"} |= $female;
        }
        my $sex = ($objects[$id]{"flags"} & $female) ? "female" : "male";
        &tellWizards(ucfirst($objects[$id]{"name"}) . " is now a " . $sex . ".");
        &tellPlayer($id,"Your sex has been magically changed to " . $sex . "!");
        
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub converse
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    # go into chat mode
    if ($objects[$me]{"flags"} & $dumb) { # asleep trying to act
        # wake me if possible but report fail if not.
        &tellPlayer($me, "You won't be able to say anything, you know, you're dumb.");
        return 0;
    }
    $objects[$me]{"prompt"}="\"";
    if ($objects[$me]{"flags"} & $dark) { # invis force vis
        &tellPlayer($me,"You've just become visible!");
        &vis($me,"","","");
    }
    &tellPlayer($me,"To leave converse mode, type '**'");
    return 1;
}

sub crash
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # will not be implemented in TH
}

sub ctrap
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # turn on/off the ctrl-c trap - not currently trapping
}

sub cure
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
#debug - in MUD5.BCL this just flips for the profile player (me). Others are flipped using a demon
    my $id=$me;
#    my $id = &targetPlayer($me,$arg1);
    if ($id != $none) {
        $objects[$id]{"flags"} &= ~$blind;
        $objects[$id]{"flags"} &= ~$deaf;
        $objects[$id]{"flags"} &= ~$dumb;
        $objects[$id]{"flags"} &= ~$paralysed;
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub deafen
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
#debug - in MUD5.BCL this just flips for the profile player (me). Others are flipped using a demon
    my $id=$me;
#    my $id = &targetPlayer($me, $arg1);
    if ($id != $none) {
        $objects[$id]{"flags"} |= $deaf;
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub debug
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # wiz mode by another name - maybe do or not
    if (&wizardTest($me)) {
        $debugMode= !($debugMode);
        $objects[$me]{"prompt"} = ($debugMode)?"----*":"*";
        $objects[$me]{"prompt"} = "(" . $objects[$me]{"prompt"} . ")" if ($objects[$me]{"flags"} & $dark);
    }
    return 1;
}

sub demo
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # will not be implemented in TH
}

sub detach
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # has no meaning in TH
}

sub diagnose
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # get an esitimate of stamina of arg1
}

sub direct
{
    my ($me, $arg, $arg1, $arg2) = @_;
}

sub dumb
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
#debug - in MUD5.BCL this just flips for the profile player (me). Others are flipped using a demon
    my $id=$me;
#    my $id = &targetPlayer($me, $arg1);
    if ($id != $none) {
        $objects[$id]{"flags"} |= $dumb;
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub eat
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # eats an object?
}

sub empty
{
    # empties a visible container (mob or thing)
    my ($me, $arg, $arg1, $arg2) = @_;
    my $id=$none;
    my $word=visibleCanonicalizeWord($me,$arg1);
    if (substr($word,0,1) eq "#") { # found the object and it is here or carried and visible
        $id=substr($word,1);
        &idBounds($id);
        return 0 if ($id==$none);
        if ($objects[$id]{"contains"}<1) {
            &tellPlayer($me,"The " . $objects[$id]{"name"} . " isn't a container.");
        }
        if (length($objects[$id]{"contents"})>0) {
            # empty the container
            my $loc = $objects[$id]{"location"};
            while ($objects[$loc]{"type"}!=$room) { # iterate up to the room
                $loc = $objects[$loc]{"location"};
                if ($loc eq "") { # something went wrong
                    $loc=int($objects[$id]{"home"}); # in case of error
                    last;
                }
            }
            my(@list);
            @list = split(/,/, $objects[$id]{"contents"});
            my($e);
            foreach $e (@list) {
                &removeContents($id,$e);
                &addContents($loc,$e);
                &tellPlayer($me,ucfirst($objects[$e]{"name"}) . " dropped.");
            }
            &tellPlayer($me,"The " . $objects[$id]{"name"} . " now contains nothing.");
        } else {
            &tellPlayer($me,"The " . $objects[$id]{"name"} . " is already empty.");
        }
    }
    return 1;
}

sub enchant
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # no idea what this does
}

sub exorcise # kick player
{
    my ($me, $arg, $arg1, $arg2) = @_;
    &boot($me, $arg, $arg1, $arg2);
    return 1;
}

sub flee
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # run away whilst in a fight
}

sub flush
{
    my ($me, $arg, $arg1, $arg2) = @_;
    my $conn=$activeFds[$objects[$me]{"activeFd"}]{"fd"};
    #debug can this flush history?
    &TH::read_flush($conn->{fd});
    &TH::clear_readline($conn);
    return 1;
}

sub fod
{
    my ($me, $arg, $arg1, $arg2) = @_;
    my $id=&targetPlayer($me,$arg1);
    if ($id != $none) {
        #debug this properly breaks loads of stuff and causes mud to loop after a @purge as recycleById and purge doesnt segregate the players from other objects
#        &toad($me, $arg, $arg1, $arg2);
#        &recycleById($me, $id, 1);
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
}

sub follow
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if ($objects[$me]{"flags"} & $paralysed) { # paralysed
        &tellPlayer($me,"You cant move!");
        return 0;
    }
    # follow a leader
    if ($arg eq "") {
        &tellPlayer($me, "That is not a player.");
        return 0;
    }
    my $name;
    my $id=$none;
    $id=$playerIds{"arg1"} if (exists $playerIds{"arg1"});
    if (substr($arg1,0,1) eq "#") {
        $id = int(substr($arg1,1));
        $id = &idBounds($id);
    } elsif ($id==$none) {
        $id=&findContents($objects[$me]{"location"},$arg1);
        if ($id==$none) {
            $id=targetPlayer($me,$arg1); # any player?
            $id=findObject($arg1,,$thing) if ($id==$none); # any object?
            if ($id==$none) {
                &tellPlayer($me,"I don't know what you mean.");
                return 0;
            } elsif (!&builderTest($me)) {
                $name = ($objects[$id]{"type"}==$player) ? &playerName($id) : "the " . $arg1;

                &tellPlayer($me, ucfirst($name) . " isn't here to follow!");
                return 0;
            }
        }
    }
    if ($me==$id) {
        &tellPlayer($me, "Isn't following yourself rather vain?");
        return 0;
    }
    if ($objects[$me]{"following"}==$id) { # only follow one thing
        $name = ($objects[$id]{"type"}==$player) ? &playerName($id) : "the " . $arg1;
        &tellPlayer($me,"You're already following " . $name . "!");
        return 0;
    }
    if ((int($objects[$id]{"speed"}) < 1) && ($objects[$id]{"type"} != $player)) { # target cant move
        &tellPlayer($me,"It cant move!");
        return 0;
    }

    $objects[$me]{"following"}=$id;
    if (length($objects[$id]{"leading"}) > 0) {
        $objects[$id]{"leading"} .= "," . $me;
    } else {
        $objects[$id]{"leading"} = $me;
    }
    $name = ($objects[$id]{"type"}==$player) ? &playerName($id) : "the " . $arg1;
    &tellPlayer($me,"You have started to follow " . $name . ".\n");
    &tellPlayer($id, playerName($me) . " has started to follow you.\n") if (&builderTest($id));
    return 1;
}

sub freeze
{
    my ($me, $arg, $arg1, $arg2) = @_;
    if (!&wizardTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &TH::kill_timer(\&mud_creature, 0); # stops all creature daemons
    return 1;
}

sub go
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # doesnt really apply in perlMud, stripped out in mud_command
}

sub haste
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not sure what this does
}

sub hours
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # has no meaning in TH
}

sub humble
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not sure what this does
}

sub ignore
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not sure what this does
}

sub insert
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # puts things in a container - needs containers to be supported everywhere
    # put arg1 in arg2 - arg1 can be a class
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my $obj=$none;
    my $bag=$none;
    $obj = &findContents($me,$arg1);
    if ($obj==$none) { # special handling of the recently destroyed
        my $id = &findContents($objects[$me]{"location"},$arg1);
        $obj=$id if ($objects[$id]{"flags"} & $destroyed);
    }
    $bag = &findContents($me,$arg2);
    if ($bag==$none) {
        $bag = &findContents($objects[$me]{"location"},$arg2);
        if ($bag==$none) {
            &tellPlayer($me,"I see no $arg2.");
            return 1;
        }
    }
    if ($obj==$none) {
        &tellPlayer($me,"You have to be carrying the $arg1 to do anything with it.");
        return 1;
    }
    if (($objects[$obj]{"type"}!=$thing) ||  ($objects[$bag]{"type"}!=$thing)) {
        &tellPlayer($me,"You can only insert items into objects, not anything else.");
        return 1;
    }
    if (int($objects[$bag]{"contains"}) == 0 ) {
        &tellPlayer($me,"You can't put it in there!");
        return 1;
    }
    if ($obj==$bag) {
        &tellPlayer($me,"You can't do that to itself!");
        return 1;
    }
    my $wbag=&weighContents($bag,$thing);
    if ($wbag+$objects[$obj]{"weight"}>$objects[$bag]{"contains"}) {
        &tellPlayer($me,"There's not enough room!");
        return 1;
    }
    my $id=$obj;
    while ($id!=$none) {
        &removeContents($objects[$id]{"location"},$id);
        &addContents($bag,$id);
        &tellPlayer($me, ucfirst($objects[$id]{"name"}) . " now inside the $arg2.") unless ($objects[$id]{"flags"} & $destroyed);
        last if ($objects[$id]{"name"} eq $arg1); # only insert the first of its name if its not a class
        $id = &findContents($me,$arg1,$thing,$id); # see if there are any more of the class
    }
    return 1;
    #debug these messages are sent to snoopers of the object/person but testing shows they dont appear or can never appear
    #    case K.IINS:    case K.IREM:
    #        bit_FUNC of block
    #        bit_bit=K.IINS->0,bit=K.IREM->1,bit=K.IGIV->2,3
    #        unless inv out("*C*L(:P has :sthe :p :s some:s)*C*L",
    #            pn,
    #            bit!(table "inserted ","removed ","given ","taken "),
    #            PNAME of INF,
    #            bit!(table "inside","from","to","from"),
    #            bit ge 2->" creature","thing")
    #        endcase
}

sub invis
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # turns $me invisible. dark flag is used on a player.
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (($me != $none) && ($objects[$me]{"type"}==$player)) {
        $objects[$me]{"flags"} |= $dark;
        $objects[$me]{"prompt"} = "(" . $objects[$me]{"prompt"} . ")";
    }
    return 1;
}

sub keep
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # lets things you have got not be dropped by class or all
}

sub kill
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 1 if (!(&wake($me,"","","")));
    }
    my $id=$none;
    my $word=visibleCanonicalizeWord($me,$arg1);
    if (substr($word,0,1) eq "#") { # found the object and it is here or carried and visible
        $id=substr($word,1);
        &idBounds($id);
    } else {
        $id=&targetPlayer($arg1);
        if ($id!=$none) {
            &tellPlayer($me,$arg1 . " isn't here!");
            return 1 ; # player isn't here;
        }
    }
    if ($id==$none) {
        if (defined $playerIds{$arg1}) {
            &tellPlayer($me,ucfirst($arg1) . " is not a player.");
            return 1;
        }
        if ($arg1 eq "") {
            &tellPlayer($me,"That is not a player.");
            return 1;
        }
        #debug need to add a condition thats refuses pronouns
        # unless objct ne fake error("To use the verb :p you have to give someone's name!", verbname)
        &tellPlayer($me,"I see no $arg1.");
        return 1;
    }
    if ($id==$me) {
        &tellPlayer($me,"Committing suicide is too easy a way to get points!");
        return 1;
    }
#    if ((!(defined $objects[$id]{"speed"})) && ($objects[$id]{"type"}==$thing)) {
#debug allows kill to empty things - this is probably not needed
#        &empty($me,$arg,$arg1,$arg2);
#        return 1;
#    }
    if (defined $fightsTable{$me}) { # Ive been in a fight
        if (&fightCheck($me,$id)!=$none) {
            my $name = ($objects[$id]{"type"}==$player) ? &playerName($id) : "the " . $arg1;
            &tellPlayer($me,"You're already fighting " . $name);
            return 1;
        }
        my $targettingThing=($objects[$id]{"type"}==$thing);
        foreach my $f (@{&fightCheck($me)}) { # fight check
            if (($targettingThing) && ($objects[$f]{"type"}==$thing)) {
                &tellPlayer($me,"You can't fight more than one non-player at once!");
                return 1;
            }
        }
    }
    if ($worldPeace) {
        &tellPlayer($me,"Fighting is currently forbidden.");
        return 1;
    }
    if ($objects[$id]{"type"}==$player) {
        # attack a player
        &startFight($me,$id);
        # some magic happens
        
#debug
        &tellPlayer($me,"Fighting is currently forbidden.");
        
        &endFight($me,$id);
    } elsif ($objects[$id]{"type"}==$thing) {
        # attack a thing (could be a thing or class)
        &startFight($me,$id);
        my $msg = playerName($me) . " and the " . $objects[$id]{"name"} . " have started to fight";
        # the fight is afoot!
        &tellRoom($me,$msg . "!");
        &tellWizards($msg . " in #" . $objects[$me]{"location"} . "!", $objects[$me]{"location"});
        #debug stop $me from being able to quit or ctrl-c out
        #debug probably easiest way to do this is to use demons to send hits & misses to opponent from the initiator and trigger opponent reponse
        #debug need to handle retaliate with weapon and attack with weapon
        # some magic happens
        &endFight($me,$id);
    } else {
        # trying to do something stupid like attack a direction
        &tellPlayer($me,"You can't fight that!");
        return 1;
    }
}

sub provoke
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is called when a mob attacks a player $me
    # is $me a sleeping person, the mob gets an advantage
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my $id=$none;
    my $word=visibleCanonicalizeWord($me,$arg1);
    if (substr($word,0,1) eq "#") { # found the object and it is here or carried and visible
        $id=substr($word,1);
        &idBounds($id);
    }
#    } else {
#        $id=&targetPlayer($arg1);
#        if ($id!=$none) {
#            &tellPlayer($me,$arg1 . " isn't here!");
#            return 1 ; # player isn't here;
#        }
#    }
#    if ($id==$none) {
#        if (defined $playerIds{$arg1}) {
#            &tellPlayer($me,ucfirst($arg1) . " is not a player.");
#            return 1;
#        }
#        if ($arg1 eq "") {
#            &tellPlayer($me,"That is not a player.");
#            return 1;
#        }
        #debug need to add a condition thats refuses pronouns
        # unless objct ne fake error("To use the verb :p you have to give someone's name!", verbname)
#        &tellPlayer($me,"I see no $arg1.");
#        return 1;
#    }
#    if ($id==$me) {
#        &tellPlayer($me,"Committing suicide is too easy a way to get points!");
#        return 1;
#    }
#    if ((!(defined $objects[$id]{"speed"})) && ($objects[$id]{"type"}==$thing)) {
#debug allows kill to empty things - this is probably not needed
#        &empty($me,$arg,$arg1,$arg2);
#        return 1;
#    }
    if (defined $fightsTable{$me}) { # Ive been in a fight
        if (&fightsCheck($me,$id)!=$none) {
            my $name = ($objects[$id]{"type"}==$player) ? &playerName($id) : "the " . $arg1;
            &tellPlayer($me,"You're already fighting " . $name);
            return 1;
        }
        my $targettingThing=($objects[$id]{"type"}==$thing);
        foreach my $f (@{&fightsCheck($me)}) { # fight check
            if (($targettingThing) && ($objects[$f]{"type"}==$thing)) {
                &tellPlayer($me,"You can't fight more than one non-player at once!");
                return 1;
            }
        }
    }
    if ($worldPeace) {
        &tellPlayer($me,"Fighting is currently forbidden.");
        return 1;
    }
    if ($objects[$id]{"type"}==$player) {
        # attack a player
        &startFight($me,$id);
        # some magic happens
        
#debug
        &tellPlayer($me,"Fighting is currently forbidden.");
        
        &endFight($me,$id);
    } elsif ($objects[$id]{"type"}==$thing) {
        # attack a thing (could be a thing or class)
        &startFight($me,$id);
        # the fight is afoot!
        my $msg = playerName($me) . " has been attacked by the " . $objects[$id]{"name"};
        &tellRoom($me, $msg . "!");
        &tellWizards($msg . " in #" . $objects[$me]{"location"} . "!",$objects[$me]{"location"});
        #debug stop $me from being able to quit or ctrl-c out
        #debug probably easiest way to do this is to use demons to send hits & misses to opponent from the initiator and trigger opponent reponse
        #debug need to handle retaliate with weapon and attack with weapon
        # some magic happens
        &endFight($me,$id);
    } else {
        # trying to do something stupid like attack a direction
        &tellPlayer($me,"You can't fight that!");
        return 1;
    }
}

sub laugh
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # chuckle
}

sub log
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # will not supprt on TH
}

sub lose
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    # shakes off a follower
    my $id=&targetPlayer($me,$arg1);
    if ($id==$me) {
        &tellPlayer($me,"If you want to lose yourself shut your eyes and hit the keyboard at random...");
        return 0;
    }
    if ($id != $none) {
        if (&unfollow($me,$id)) {
            &tellPlayer($me,"You have lost " . playerName($id) . ".");
        } else {
            &tellPlayer($me, playerName($id) . " isn't following you.");
        }
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub make
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 1 if (!(&wake($me,"","","")));
    }
    # forces a player arg1 to do everything that follows it
    print "make me=$me arg=$arg arg1=$arg1 arg2=$arg2\n" if ($debugMode);
    my $fcommand;
    ($arg1,$fcommand) = split(/ /, $arg, 2); # split arg into target in arg1 and commands in fcommand
    my $id=&targetPlayer($me,$arg1);
    print "make id=$id fcommand=$fcommand\n" if ($debugMode);
    # check not being forced to force
    #debug how?
    # check not forcing self
    if ($me==$id) {
        &tellPlayer($me,"You honestly thought I'd allow that?!");
        return 1;
    }
    if ((&builderTest($id)) && !(&builderTest($me))) {
        &tellPlayer($me,"You can't do that to a wizard or witch unless you are one!");
        return 1;
    }
    if ($fcommand eq "") {
        &tellPlayer($me,"Say it again, and this time mention what you want to force " . &playerName($id) . " to do.");
        return 1;
    }
    if (&builderTest($id)) {
        &tellPlayer($id,playerName($me) . " forces you to " . $fcommand);
    } else {
        &tellPlayer($id,"You are forced to " . $fcommand );
    }
    my $x=0;
    #debug some commands shouldnt be forceable - like force or talking
    if ($fcommand =~ /.*\b\./) { # test to see if this is a string of commands using . as conjungation
        my @commands=split(/\.|$/,$fcommand);
        foreach my $com (@commands) {
            $x=&mud_command($id, $com);
            last if (($x==$death) || ($x==0)); # no more if dead or failed
        }
    } else {
        $x=&mud_command($id, $fcommand);
    }
    # notifications to wizzes
    #debug :p has forced someone to :s*C*L see K.SHBF in MUD8
    &tellPlayer($me,playerName($id) . " has been forced.");
    return $x;
}

sub map
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # will not be supported on TH
}

sub mobile
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # prints list of mobiles for wizzes
}

sub newhours
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not supported on TH
}

sub p
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not supported on TH
}

sub paralyse
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
#debug - in MUD5.BCL this just flips for the profile player (me). Others are flipped using a demon
    my $id=$me;
#    my $id = &targetPlayer($me, $arg1);
    if ($id != $none) {
        $objects[$id]{"flags"} |= $paralysed;
    } else {
        &tellPlayer($me, $arg1 . " is not a player.");
    }
    return 1;
}

sub password
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not supported on TH
}

sub peace
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # stops fighting
    if (builderTest($me)) {
        &stopFighting();
        $worldPeace=1;
    } else {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
    }
    return 1;
}

sub police
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # police reports are unlikely to be supported on TH
}

sub pronouns
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # prints values of him, her, it, etc
}

sub proof
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # sends player arg1 a fake game message in the rest of arg
    my $id=&targetPlayer($me,$arg1);
    if ($me==$id) {
        &tellPlayer($me,"You honestly thought I'd allow that?!");
        return 0;
    }
    if ((&builderTest($id)) && !(&builderTest($me))) {
        &tellPlayer($me,"You can't do that to a wizard or witch unless you are one!");
        return 0;
    }
    if ($arg2 eq "") {
        &tellPlayer($me,"Say it again, and this time mention what you want to appear to " . &playerName($id) . ".");
        return 0;
    }
    my (undef,$fcommand) = split(/ /, $arg, 2); # keep everything after arg1
    if (&builderTest($id)) {
        &tellPlayer($id, $fcommand);
    } else {
        &tellPlayer($id, $fcommand );
    }
    # notifications to wizzes
    #debug :p has forced someone to :s*C*L see K.SHBF in MUD8
    &tellPlayer($me,playerName($id) . " has been proofed.");
    return 1;
}

sub purge
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # ??? maybe calls purgeObj
}

sub quickwho
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my($e, $i);
    my($sex, $level);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        $e = $activeFds[$i]{"id"};
        if ($e != $none) {
            my($name);
            $name = playerName($e);
            if (builderTest($me)) {
                $name = "($name)" if ($objects[$e]{"flags"} & $dark);
                &tellPlayer($me,$name);
            } else {
                $name = "Someone" if ($objects[$me]{"flags"} & $blind);
                next if ($objects[$e]{"flags"} & $dark);
                &tellPlayer($me,$name);
            }
        }
    }
    return 1;
}

sub quit
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug needs to handle limbo
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    return $death;
}

sub refuse
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # refuse help
}

sub remove
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # take arg1 from arg2 - arg1 can be a class arg2 an object (or player?)
    #debug this may also be used for steal/take from player and needs to be adpated
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my $obj=$none;
    my $bag=$none;
    $bag = &findContents($me,$arg2);
    if ($bag==$none) {
        $bag = &findContents($objects[$me]{"location"},$arg2);
        if ($bag==$none) {
            &tellPlayer($me,"I see no $arg2.");
            return 1;
        }
    }
    if (int($objects[$bag]{"contains"}) == 0 ) {
        &tellPlayer($me,"You can't have it in there!");
        return 1;
    }
    if ($objects[$bag]{"contents"} eq "") {
        &tellPlayer($me,"The $arg2 doesn't contain anything!");
        return 1;
    }
    $obj = &findContents($bag,$arg1);
    if ($obj==$none) {
        if ($objects[$bag]{"speed"}>0) {
            &tellPlayer($me,"The $arg2 isn't carrying the $arg1.");
        } else {
            &tellPlayer($me,"The $arg2 doesn't contain $arg1.");
        }
        return 1;
    }
    if (($objects[$obj]{"type"}!=$thing) ||  ($objects[$bag]{"type"}!=$thing)) {
        &tellPlayer($me,"You can only remove items from objects, not anything else.");
        return 1;
    }
    # test for weight and object limits in me
    my $id=$obj;
    while ($id!=$none) {
        if (&canContain($me,$id)) {
            &removeContents($objects[$id]{"location"},$id);
            &addContents($me,$id);
            tellPlayer($me, ucfirst($objects[$id]{"name"}). " removed from $arg2.");
            last if ($objects[$id]{"name"} eq $arg1); # only insert the first of its name if its not a class
            $id = &findContents($me,$arg1,$thing,$id); # see if there are any more of the class
        } else {
            # test for object count
            &tellPlayer($me,"You can't carry more than" . &maxObj($me) . "discrete objects.") if (maxObj($me) < howMany($me,$thing)+1);
            # test for weight
            &tellPlayer($me,"it is too much extra weight.") if (($objects[$me]{"strength"}*1000 >= weighContents($me,$thing)+$objects[$id]{"weight"}) && (!builderTest($me)));
            last; # remove no more
        }
    }
    return 1;
}

sub reset
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
#    &reload($me, $arg, $arg1, $arg2); # this doesnt work when called from here
    &tellPlayer($me,"This is not the reset you were looking for.");
    return 1;
}

sub resurrect
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # undestroy a thing and restore stamina to $arg1
}

sub save
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # meaningless on TH
}

sub score
{
    my ($me, $arg, $arg1, $arg2) = @_;
    &mud_score($me, $arg, $arg1, $arg2);
    return 1;
}

sub set
{
    my ($me, $arg, $arg1, $arg2) = @_;
    if (&builderTest($me)) {
        &setProp($me, $arg, $arg1, $arg2);
        return 1;
    }
    &tellPlayer($me,$invalidMsgs[int(rand(5))]);
    return 0;
}

sub sget
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # gets an item from a remote location if not carried
    &tellPlayer($me,$invalidMsgs[int(rand(5))]);
    return 0;
}

sub sgo
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this will not be implemenetd in TH - used to jump between MUD/VALLEY
}

sub shelve
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this will not be supported on TH
}

sub sleep
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug this gets called as a primitive from sleep and wish
    #debug from wish it takes an argument that it should ignore
    #debug from sleep it takes an argument that should be a player to sleep or none
    #debug but we dont know the caller so "wish name" does cause name to try a sleep
    #debug MUD5.BCL just sets the flag for profile (me)
    #debug ssenddemon is used to apply to others
    my $id=$none;
    if ($arg eq "") {
        $arg1="#" . $me;
    }
    my $word=visibleCanonicalizeWord($me,$arg1);
    if (substr($word,0,1) eq "#") {
        $id=substr($word,1);
    }
    if (($id==$none) && (&builderTest($me))) {
        $id=&targetPlayer($me, $arg1); # only a wiz can target anyone
    }
    if (($id==$none) || ($objects[$id]{"type"}!=$player)) { # you can only sleep a player
        $id=$me;
    }
    return 0 if ($id==$none); # could not find that player;
    if (&builderTest($id) && ($id!=$me) && (&builderTest($me))) { # is the target a wiz and im a wiz?
        my $level = $objects[$id]{"level"};
        my $sex = ($objects[$id]{"flags"} & $female) ? "female" : "male";
        $level = $levelNames{$sex}[$level];
        &tellPlayer($me,"Not to a $level you dont!");
        &tellPlayer($id,&playerName($me) . " has tried to put you to sleep!"); #debug "unless inv" in MUD8.BCL???
        return 0; # cant cast sleep on a witch/wiz
    }
    if ($objects[$id]{"flags"} & $asleep) {
        if ($id==$me) {
            tellPlayer($me,"You're already asleep!");
        } elsif ($objects[$id]{"type"}==$player) {
            tellPlayer($me,"They're already asleep!");
        }
        return 1;
    }
    if ($objects[$objects[$id]{"location"}]{"flags"} & $small) {
        if ($id==$me) {
            tellPlayer($me,"You can't get to sleep in this small place.");
        } elsif ($objects[$id]{"type"}==$player) {
            tellPlayer($me,"They can't get to sleep in such a small place.");
        }
        return 1;
    }
    #debug handle if in the middle of a fight "is in the middle of a fight!"
    if ($objects[$id]{"type"}==$player) {
        $objects[$id]{"flags"} |= $asleep; # flag asleep
        #debug this now needs handling throughout the game in terms of unconsiouness
        # action should set a wake demon
        &tellPlayer($id, &playerName($me) . " has put you to sleep!") if ($id!=$me);
        &tellRoom($objects[$id]{"location"}, $id, playerName($id) . " has fallen asleep.") unless ($objects[$id]{"flags"} & $dark); # tell room unless you are invis
        $objects[$id]{"bedtime"}=time;
        return 1;
    }
    return 0; # you cant sleep anything that isnt a player
}

sub snoop
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # spy on player - add to snooper list
}

sub spectacular
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not supported on TH
}

sub stamina
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # displays details of mobiles or objects:
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 1 if (!(&wake($me,"","","")));
    }
    if (builderTest($me)) {
        my $word=visibleCanonicalizeWord($me,$arg1);
        my $currvalue=0;
        if (substr($word,0,1) eq "#") {
            my $id=substr($word,1);
            $id=idBounds($id);
            my $res = $objects[$id]{"score"};
            $res=($objects[$id]{"currprop"}+1) * $res if ($objects[$id]{"maxprop"}<0); # score based on currprop * value if the prop is a random
            $currvalue = int(3*$res-((4*$res)/($mudPlayers+1))); # only add 1 because we start from 1 unlike MUD.
            &tellPlayer($me,"Name\t" . $objects[$id]{"name"});
            if ($objects[$id]{"speed"}>0) {
                &tellPlayer($me,"Room\t" . $objects[$id]{"location"} . " " . $objects[$objects[$id]{"location"}]{"name"});
                &tellPlayer($me,"Move every\t" . $objects[$id]{"speed"});
            }
            if ($objects[$id]{"contains"}>0) {
                &expandContainer($me,$me,$id,0);
                &tellPlayer($me,"max. contents\t" . $objects[$id]{"contains"} . "g\t contents used\t" . weighContents($id, $thing) . "g")
            }
            &tellPlayer($me,"base value\t" . $objects[$id]{"score"} . "\tcurrent value\t" . $currvalue . "\tweight\t" . $objects[$id]{"weight"} . "g");
            &tellPlayer($me,"prop\t" . $objects[$id]{"currprop"} . "\tscoreprop\t" . $objects[$id]{"scoreprop"});
            &tellPlayer($me,"stamina\t" . $objects[$id]{"stamina"});
        } else {
            &tellPlayer($me,"I see no $arg1!");
        }
    } else {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
    }
    return 1;
}

sub summon
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # summon arg1 to location of $me subject to wiz/magic
}

sub tell
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 1 if (!(&wake($me,"","","")));
    }
    my ($to, $what) = split(/ /,$arg,2);
    # debug tells in the third person when using tell rather than name
    &say($me, $what, $arg1, $arg2, $to);
    return 1;
}

sub daytime
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #tell the time in a meanigful way - note namespace crash with builtin time
}

sub unfollow
{
    my ($me, $id, $quiet) = @_;
    # removes followers from $me
    if ($objects[$me]{"leading"} ne "") {
        my @followers=split(/,/,$objects[$me]{"leading"});
        if (defined $id) { # just silently remove id from followers
            delete $objects[$me]{"leading"};
            delete $objects[$id]{"following"};
            foreach my $e (@followers) { # remove $id from followers
                if ($e ne $id) {
                    if (length($objects[$me]{"leading"}) > 0) {
                        $objects[$me]{"leading"} .= "," . $e;
                    } else {
                        $objects[$me]{"leading"} = $e;
                    }
                }
            }
        } else { # remove all followers with announcements
            foreach my $f (@followers) {
                my $name = ($objects[$me]{"type"}==$player) ? &playerName($me) : "the " . $objects[$me]{"name"};
                    &tellPlayer($f,"You can follow " . $name . " no more.") unless ($quiet);
                &tellPlayer($me, &playerName($f) . " has stopped following you.") if (&builderTest($me));
                delete $objects[$f]{"following"}; # you can only follow one at a time so now you are following no-one
            }
            delete $objects[$me]{"leading"}; # not leading anyone now
        }
    } else {
        return 0; # no followers
    }
    return 1;
}

sub unfreeze
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # make mobs move
    if (!&wizardTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    # kill them just in case there were any residuals
    &TH::kill_timer(\&mud_creature, 0); # stops all creature daemons
    # now restart them
    for my $id (0..$#objects) {
        if (($objects[$id]{"type"}==$thing) && ($objects[$id]{"speed"}>0)) { # add mobile to timers
            &TH::set_timer($objects[$id]{"speed"},\&mud_creature,$id,0);
        }
    }
    return 1;
}

sub unkeep
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # lets things that you have kept be dropped by class or all
}

sub unshelve
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # not supported in TH
}

sub unsnoop
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # stop spying on player
}

sub unveil
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # no idea
}

sub value
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # diaplays the current value of the arg1
    my $id=visibleCanonicalizeWord($me,$arg1);
    my $currvalue=0;
    if (substr($id,0,1) eq "#") {
        $id=substr($id,1);
        $id=idBounds($id);
        # more complex score calculation as per MUD3 setexp
        if ($objects[$id]{"type"}==$thing) { # you can only value things
            if (($objects[$id]{"speed"}>0) && (!builderTest($me))) {
                &tellPlayer($me, "You can't value that!");
                return 1;
            }
            if (($objects[$id]{"currprop"}==$objects[$id]{"scoreprop"}) || ($objects[$id]{"maxprop"}<0)) {
                # prop is score prop or this is a random prop object
                #debug  what is P1 of obj=1 in MUD3?
                my $res = $objects[$id]{"score"};
                $res=($objects[$id]{"currprop"}+1) * $res if ($objects[$id]{"maxprop"}<0); # score based on currprop * value if the prop is a random
                $currvalue = int(3*$res-((4*$res)/($mudPlayers+1))); # only add 1 because we start from 1 unlike MUD.
            }
            &tellPlayer($me,"The base value of the $arg1 is " . $objects[$id]{"score"} . " and the current value is " . $currvalue . ".");
        } else {
            &tellPlayer($me, "You can only value objects, not anything else.");
        }
    } else {
        if (($arg1 ne "all") && ($arg1 ne "")) {
            &tellPlayer($me, "I see no $arg1!");
        } else {
            &tellPlayer($me, "You can only value objects, not anything else.");
        }
    }
    return 1;
}

sub verbose
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug currently always verbose anyway
}

sub vis
{
    my ($me, $arg, $arg1, $arg2) = @_;
    # turns $me visible. dark flag is used on a person.
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (($me != $none) && ($objects[$me]{"type"}==$player)) {
        $objects[$me]{"flags"} &= ~$dark;
        $objects[$me]{"prompt"} =~ s/\((.*)\)/$1/i;
    }
    return 1;
}

sub wake
{
    my ($me, $arg, $arg1, $arg2, $quiet) = @_;
    # lots of things that happen wake you up - shout, kill, wake, all sorts
    my $id=$none;
    if ($arg eq "") {
        $arg1="#" . $me;
    }
    my $word=visibleCanonicalizeWord($me,$arg1);
    if (substr($word,0,1) eq "#") {
        $id=substr($word,1);
    } else {
        $id=$none;
    }
    if (($id==$none) && (builderTest($me))) {
        $id=$playerIds{$arg1};
    }
    if ($id==$none) {
        &tellPlayer($me,$arg1 . " isn't here to wake.");
        return 0 ; # could not find that player;
    }
    if (!($objects[$id]{"flags"} & $asleep)) {
        if ($id==$me) {
            tellPlayer($me,"You are already awake!") unless ($quiet);
        } elsif ($objects[$id]{"type"}==$player) {
            tellPlayer($me, &playerName($id) . " is already awake.") unless (defined $quiet);
        }
        return 0;
    }
    if ($objects[$id]{"type"}==$player) {
        #debug this now needs handling throughout the game as well as waking up and stamina points accrural which happens in wake
        my $kips=int((time - $objects[$id]{"bedtime"})/10);
        if ($id!=$me) {
            &tellPlayer($me,"You wake " . &playerName($id)) unless (defined $quiet);
            &tellPlayer($id,&playerName($me) . " has started to wake you up.") unless (defined $quiet);
        }
        # cant wake up if $kips is zero
        if ($kips<1) {
            tellPlayer($id,"You can't wake up yet!") unless (defined $quiet);
            return 0;
        }
        &tellPlayer($id,"You wake up.");
        &tellRoom($objects[$id]{"location"}, $id, playerName($id) . " has woken up.") unless ($objects[$id]{"flags"} & $dark); # dont tell room if invis
        $objects[$id]{"flags"} &= ~$asleep; # invert asleep
        # new stamina point for every 10 secnds of sleep
        my $y = $objects[$id]{"stamina"} + $kips;
        $objects[$id]{"stamina"} = ($objects[$id]{"maxstamina"}, $y)[$y<$objects[$id]{"maxstamina"}];
        &tellPlayer($id,"Your stamina is now " . $objects[$id]{"stamina"} . ".");
        return 1;
    }
    return 0;
}

sub war
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug TBD
    if (builderTest($me)) {
        $worldPeace=0;
    } else {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
    }
    return 1;
}

sub weigh
{
    my ($me, $arg, $arg1, $arg2) = @_;
    my $id=visibleCanonicalizeWord($me,$arg1);
    if (substr($id,0,1) eq "#") {
        $id=substr($id,1);
        $id=idBounds($id);
        if ($objects[$id]{"type"}==$thing) { # you can only weigh things
            if (($objects[$id]{"speed"}>0) && (!builderTest($me))) {
                &tellPlayer($me,"You can't weigh that!");
            } else {
                my $totweight=$objects[$id]{"weight"} + weighContents($id,$thing);
                &tellPlayer($me,"The weight of the " . $arg1 . " is " . $totweight . "g.");
            }
        } else {
            &tellPlayer($me, "You can only weigh objects, not anything else.");
        }
    } else {
        &tellPlayer($me,"I see no $arg1!");
    }
    return 1;
}

sub where
{
    my ($me, $arg, $arg1, $arg2) = @_;
    #debug this is a spell that has a likelyhood based on level
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (substr($arg,0,1) eq "#") {
        $arg=substr($arg,1);
        $arg=idBounds($arg);
        $arg=$objects[$arg]{"name"};
    } # expand id to name for flexibility on class tests
    $arg =~ tr/A-Z/a-z/;
    $arg = $synonymTable{"$arg"} unless ($synonymTable{"$arg"} eq "");
    my %discoveries; # holds key=obj location, value=count
    my $found = 0;
    my $w = &builderTest($me);
    for (my $i = 0; ($i <= $#objects); $i++) {
        next unless (($objects[$i]{"type"}==$player) ||
                    ($objects[$i]{"type"}==$thing) ||
                    ($objects[$i]{"type"}==$topic));
        if ((!$w) & (($objects[$objects[$i]{"location"}]{"flags"} & $hideaway) || ($objects[$objects[$i]{"location"}]{"flags"} & $death) || ($objects[$i]{"flags"} & $destroyed) || ($objects[$i]{"flags"} & $dark) || ($objects[$i]{"location"}<0))) {
            # loc is a hideaway or death, or obj is nowhere, destroyed or invis
            next;
        }
        (my $name = $objects[$i]{"name"}) =~ tr/A-Z/a-z/;
        if (($name eq $arg)) {
            $found = 1;
            if ($objects[$i]{"type"}==$player) {
                my $desc = $objects[$objects[$i]{"location"}]{"name"};
                &tellPlayer($me,$desc);
                last;
            }
            my $loc=$objects[$i]{"location"};
            $discoveries{"$loc"}+=1;
            next; # only report by name or class not both
        }
        (my $class = $objects[$i]{"class"}) =~ tr/A-Z/a-z/;
        if (($class eq $arg)  && ($objects[$i]{"type"}==$thing)) {
            my $loc=$objects[$i]{"location"};
            $discoveries{"$loc"}+=1;
            $found = 1;
        }
    }
    if ($found) {
        KEY: foreach my $k (keys %discoveries) {
            my $desc = $discoveries{"$k"}; # qty at location $k
            my $loc=$k;
            while ($objects[$loc]{"type"}==$thing) {
                # explode the location up to room or person
                if ((!$w) & (($objects[$loc]{"flags"} & $hideaway) || ($objects[$loc]{"flags"} & $death) ||  ($objects[$loc]{"location"}<0))) {
                    # loc is a hideaway or death, or obj is nowhere, destroyed or invis
                    next KEY; # dont explode this any more
                }
                $desc = " inside the " . $objects[$loc]{"name"};
                $loc = $objects[$objects[$loc]{"location"}]{"location"};
                next;
            }
            if ($objects[$loc]{"type"}==$room) {
                $desc .= " in the room described as " . $objects[$loc]{"name"};
            } else {
                $desc .= " carried by " . &playerName($loc);
                $desc .= " in the room described as " . $objects[$objects[$loc]{"location"}]{"name"};
            }
            &tellPlayer($me,$desc)
        }
    } else {
        &tellPlayer($me, "You can only ask where an item or person is, not anything else.");
        return 0;
    }
    return 1;
}

# here are some MUD1 utility routines

sub checkout
{
    
#debug this probably needs further work
    
    my ($me,$killer) = @_;
    # this is supposed to kill a player at the end of a fight or if stamina reaches zero
    # award a score to the killer based on me score
    my $points=$objects[$me]{"score"};
    $points=($points>102400)? 102400 : $points;
    $points=int(75+$points/12);
    if (defined $killer) { # send the points to the killer
        &addExp($killer,$points);
    }
    &forceClosePlayer($me,1); #debug no idea if this will work
    # debug nuke player if perma death (rather than deleting)
    if (&builderTest($me)) { # you are a wiz, you cant really die
        $objects[$me]{"stamina"}=$objects[$me]{"maxstamina"};
    } else { # mere mortals die
        $objects[$me]{"score"} = 0;
        $objects[$me]{"played"} = 0;
        $objects[$me]{"maxstamina"} = &rollChar();
        $objects[$me]{"strength"} = &rollChar();
        $objects[$me]{"dexterity"} = &rollChar();
        $objects[$me]{"stamina"} = $objects[$me]{"maxstamina"};
        $objects[$me]{"level"} = 0; # start as a novice
        $objects[$me]{"prompt"} = "*"; # re-initialise prompt
        $objects[$me]{"flags"} &= ~$dark; # reset visible
        $objects[$me]{"flags"} &= ~$asleep; # reset sleep
    }

}

# below are perlMud orginals

sub dig
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    &addObject($me, $arg, $room);
}

sub doing
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    $objects[$me]{"doing"} = $arg;
    &tellPlayer($me, "Doing doing doing!");
    #debug dispense with this as doing isnt used
}

sub twentyfour
{
    my($me, $arg, $arg1, $arg2) = @_;
    #debug dispense with this I think
    $objects[$me]{"24hour"} = 1;
    &tellPlayer($me, "24-hour time display set.");
}

sub twelve
{
    my($me, $arg, $arg1, $arg2) = @_;
    #debug dispense with this I think
    $objects[$me]{"24hour"} = 0;
    &tellPlayer($me, "12-hour time display set.");
}

sub create
{
    my($me, $arg, $arg1, $arg2) = @_;
    my($id);
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    if ($arg =~ /^\s*$/) {
        &tellPlayer($me, "Syntax: \@create nameofthing");
        return 1;
    }
    $id = &addObject($me, $arg, $thing);
    &addContents($me, $id);
    $objects[$id]{"home"} = $objects[$me]{"home"};
    return 1;
}

sub createTopic
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my($id);
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    if ($arg =~ /^\s*$/) {
        &tellPlayer($me, "Syntax: \@topic topicname " .
            "(no commas or spaces allowed)");
        return;
    }
    if (length($arg2)) {
        &tellPlayer($me, "Syntax: \@topic topicname " .
            "(no commas or spaces allowed)");
        return;
    }
    if ($arg =~ /[ ,]/) {
        &tellPlayer($me, "Syntax: \@topic topicname " .
            "(no commas or spaces allowed)");
        return;
    }
    $id = &findTopic($me, $arg, 1);
    &tellPlayer($me, "Topic $arg raised. Type ,$arg blah blah... " .
        "to talk about it. You can 'get' the topic if you want " .
        "to carry it off and discuss it elsewhere.");
    $objects[$id]{"lastuse"} = time;
    &topic($me, "", $objects[$id]{"name"}, $objects[$id]{"me"} .
        "brings up the topic", 1);
}

sub findTopic
{
    my($me, $arg, $exact) = @_;
    my($id);
    #1. Exact match for the topic, present in the room already.
    $id = &findContents($objects[$me]{"location"}, $arg, $topic);
    my($pat) = quotemeta($arg);
    if (($id != $none) && ($objects[$id]{"name"} =~ /^$pat$/i)) {
        return $id;
    }
    #2. Exact match for the topic, present in the user's inventory.
    $id = &findContents($me, $arg, $topic);
    if (($id != $none) && ($objects[$id]{"name"} =~ /^$pat$/i)) {
        &removeContents($me, $id);
        $objects[$id]{"location"} = $objects[$me]{"location"};
        &addContents($objects[$me]{"location"}, $id);
        &tellPlayer($me,$objects[$id]{"name"} . " dropped.");
        return $id;
    }
    if (!$exact) {
        #3. Inexact match for the topic, present in the room already.
        $id = &findContents($me, $arg, $topic);
        if ($id != $none) {
            return $id;
        }
        #4. Inexact match for the topic, present in the user's inventory.
        $id = &findContents($me, $arg, $topic);
        if ($id != $none) {
            &removeContents($me, $id);
            $objects[$id]{"location"} = $objects[$me]{"location"};
            &addContents($objects[$me]{"location"}, $id);
            &tellPlayer($me,$objects[$id]{"name"} . " dropped.");
            return $id;
        }
    }
    #5. Must be created.
    $id = &addObject($me, $arg, $topic);
    &addContents($objects[$me]{"location"}, $id);
    $objects[$id]{"home"} = $me;
    # By default, it is locked to its creator.
    $objects[$id]{"lock"} = "#$me";
    return $id;
}

sub look
{
    my($me, $arg, $arg1, $arg2) = @_;
    if ($objects[$me]{"flags"} & $blind) {
        &tellPlayer($me,"You can't see anything, you're blind.");
    } else {
        &lookBody($me, $arg, $arg1, $arg2, 0);
    }
    return 1;
}

sub examine
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (builderTest($me)) {
        &lookBody($me, $arg, $arg1, $arg2, 1);
    } else {
        &tellPlayer($me,"You can examine things 'til your hearts content, you wont find anything special. Heavens, if I let folk go around examining things they'd spend the whole game doing it.");
        return 0;
    }
    return 1;
}

sub exits
{
    my($me, $arg, $arg1, $arg2) = @_;
    my $what = $objects[$me]{"location"};
    my $found=0;
    my $first = 1;
    my $desc = "";
    if ($objects[$what]{"type"} == $room) {
        my @list = split(/,/, $objects[$what]{"contents"});
        foreach my $e (@list) {
            if (($objects[$e]{"type"} == $exit) &&
                (!($objects[$e]{"flags"} & $dark)) &&
                ($objects[$e]{"lock"} eq "")) { # dont show dark exits or with lock conditions
                $found = 1;
                if ($first) {
                    $first = 0;
                } else {
                    $desc .= ", ";
                }
                my(@foo) = split(/(;|\|)/,
                    $objects[$e]{"name"});
                    $desc .= $foo[0];
            }
        }
        if (!$found) {
            &tellPlayer($me, "Obvious Exits: None");
        } else {
            &tellPlayer($me, "Obvious Exits: $desc");
        }
    }
    return 1;
}

sub find
{
    my($me, $arg, $arg1, $arg2, $details) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me, "Only a wizard can do that.");
        return 1;
    }
    my($i, $id, $len1, $len2, $w, $found, $name, $class);
    if ($arg eq "") {
        &tellPlayer($me, "Syntax: \@find name");
        return;
    }
    $arg =~ tr/A-Z/a-z/;
    $found = 0;
    $len1 = length($arg);
    $w = &wizardTest($me);
    for ($i = 0; ($i <= $#objects); $i++) {
        next if (($objects[$i]{"type"}==$synonym) || ($objects[$i]{"type"}==$action)); # dont report synonym definitions or actions
        if ($w || ($objects[$i]{"owner"} == $me)) {
            ($name = $objects[$i]{"name"}) =~ tr/A-Z/a-z/;
            $len2 = length($name);
            if ($len1 <= $len2) {
                if (substr($name, 0, $len1) eq $arg) {
                    &tellPlayer($me, "#" . $i . ": " .
                        $objects[$i]{"name"} . " is in object #" .
                    int($objects[$i]{"location"}) . " " . $objects[$objects[$i]{"location"}]{"name"});
                    $found = 1;
                    next; # only report by name or class not both
                }
            }
            ($class = $objects[$i]{"class"}) =~ tr/A-Z/a-z/;
            $len2 = length($class);
            if ($len1 <= $len2) {
                if (substr($class, 0, $len1) eq $arg) {
                    &tellPlayer($me, "#" . $i . ": " .
                        $objects[$i]{"name"} . " is in object #" .
                    int($objects[$i]{"location"}) . " " . $objects[$objects[$i]{"location"}]{"name"});
                    $found = 1;
                }
            }
            if (defined $objects[$i]{"room"}) { # find mud1 room identifiers
                ($name = $objects[$i]{"room"}) =~ tr/A-Z/a-z/;
                $len2 = length($name);
                if ($len1 <= $len2) {
                    if (substr($name, 0, $len1) eq $arg) {
                        &tellPlayer($me, "#" . $i . ": " .
                            $objects[$i]{"room"} . " " . $objects[$i]{"name"});
                        $found = 1;
                    }
                }
            }
        }
    }
    if (!$found) {
        &tellPlayer($me, "Not found.");
    }
    return 1;
}

sub findObject
{
    my($what, $continue, $type) = @_;
    # finds object id for item "$what" starting at id $continue matching $type
    my($name, $class, $room);
    $continue=0 unless defined $continue;
    if ($what eq "") {
        return $none;
    }
    $continue=&idBounds($continue);
    $what =~ tr/A-Z/a-z/;
    for (my $i = $continue; ($i <= $#objects); $i++) {
        if (($objects[$i]{"type"}==$synonym) || ($objects[$i]{"type"}==$action) || ($objects[$i]{"type"}==$exit)) { # dont return these
            next
        }
        if (defined $type) { # type filter
            next unless $objects[$i]{"type"}==$type; # this is not the type you were looking for
        }
        ($name = $objects[$i]{"name"}) =~ tr/A-Z/a-z/;
        ($class = $objects[$i]{"class"}) =~ tr/A-Z/a-z/;
        ($room = $objects[$i]{"room"}) =~ tr/A-Z/a-z/;
        if (($name eq $what) || ($class eq $what) || ($room eq $what) || (($what eq "treasure") && &isTreasure($i))) {
                return $i;
        }
    }
    return $none;
}

sub stats
{
    my($me, $arg, $arg1, $arg2, $details) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    my($i, $j, @typeCounts, @flagCounts, $open, $owner, $total);
    $owner = $none;
    if ($arg ne "") {
        if (substr($arg, 0, 1) ne "#") {
            my($n);
            $n = $arg1;
            $n =~ tr/A-Z/a-z/;
            if (!exists($playerIds{$n})) {
                &tellPlayer($me, "There is no such player.");
                return;
            }
            $owner = $playerIds{$n};
        } else {
            $owner = substr($arg, 1);
            $owner = &idBounds($owner);
        }
        if ($owner == $none) {
            &tellPlayer($me, "That is not a valid player.");
            return;
        }
        if ($objects[$owner]{"type"} != $player) {
            &tellPlayer($me, "That is not a valid player.");
            return;
        }
    }
    for ($i = 0; ($i <= $#objects); $i++) {
        if ($owner != $none) {
            if ($objects[$i]{"owner"} != $owner) {
                next;
            }
        }
        if ($objects[$i]{"type"} == $none) {
            $open++;
        } else {
            $typeCounts[$objects[$i]{"type"}]++;
        }
        for ($j = 0; ($j <= $#flagNames); $j++) {
            if ($objects[$i]{"flags"} & (1 << $j)) {
                $flagCounts[$j]++;
            }
        }
        $total++;
    }
    if ($owner == $none) {
        &tellPlayer($me, "Overall Statistics");
    } else {
        &tellPlayer($me, "Statistics for " . playerName($owner));
    }
    &tellPlayer($me, "Total objects:           " . int($total));
    &tellPlayer($me, "Total things:            " .
        int($typeCounts[$thing]));
    &tellPlayer($me, "Total exits:             " .
        int($typeCounts[$exit]));
    &tellPlayer($me, "Total rooms:             " .
        int($typeCounts[$room]));
    &tellPlayer($me, "Total players:           " .
        int($typeCounts[$player]));
    &tellPlayer($me, "Total topics:            " .
        int($typeCounts[$topic]));
    if ($owner == $none) {
        &tellPlayer($me, "Total unused objects:    " . $open);
    }
    for ($i = 0; ($i <= $#flagNames); $i++) {
        if ($flagCounts[$i]) {
            &tellPlayer($me, sprintf("%-25.25s%d", "Total " .
                $flagNames[$i] . " objects:",
                $flagCounts[$i]));
        }
    }
}

sub rooms
{
    my($me, $arg, $arg1, $arg2, $details) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    my($owner, $total, $rooms);
    $owner = $none;
    if ($arg ne "") {
        if (substr($arg, 0, 1) ne "#") {
            my($n);
            $n = $arg1;
            $n =~ tr/A-Z/a-z/;
            if (!exists($playerIds{$n})) {
                &tellPlayer($me, "There is no such player.");
                return;
            }
            $owner = $playerIds{$n};
        } else {
            $owner = substr($arg, 1);
            $owner = &idBounds($owner);
        }
        if ($owner == $none) {
            &tellPlayer($me, "That is not a valid player.");
            return;
        }
        if ($objects[$owner]{"type"} != $player) {
            &tellPlayer($me, "That is not a valid player.");
            return;
        }
    }
    if (($owner == $none) && (!&wizardTest($me))) {
        $owner = $me;
    }
    if (($owner != $me) && (!&wizardTest($me))) {
        &tellPlayer($me, "Only a arch-wizard can list rooms belonging to other players.");
        return;
    }
    $total = 0;
    for (my $i = 0; ($i <= $#objects); $i++) {
        if ($owner != $none) {
            if ($objects[$i]{"owner"} != $owner) {
                next;
            }
        }
        if ($objects[$i]{"type"} == $room) {
            if ($rooms ne "") {
                $rooms .= ", ";
            }
            $rooms .= "#" . $i;
            $total++;
            if (!($total % 100)) {
                # Flush for extreme cases
                &tellPlayer($me, $rooms);
                $rooms = "";
            }
        }
    }
    if ($total % 100) {
        &tellPlayer($me, $rooms);
    }
    if ($owner == $none) {
        &tellPlayer($me, "Total rooms: ". $total);
    } else {
        &tellPlayer($me, "Rooms belonging to " .
            $objects[$owner]{"name"} . ": " . $total);
    }
}

sub gag
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    if ($arg eq "") {
        &tellPlayer($me, "Syntax: \@gag name");
        return;
    }
    if ($arg =~ / /) {
        &tellPlayer($me, "MUD player names do not contain spaces.");
        return 1;
    }
    # Allow big-geek syntax
    if ($arg =~ /^#(\d+)$/) {
        if (!defined($objects[$1])) {
            &tellPlayer($me, "That player does not exist.");
        }
        if ($objects[$1]{"type"} != $player) {
            &tellPlayer($me, "Only players can be gagged.");
        }
        # Okay, now we can accept it.
        $arg = $objects[$1]{"name"};
    }
    # Strip a leading *, the global player reference thingie,
    # not required here but allowed.
    if ($arg =~ /^\*(\w+)$/) {
        $arg = $1;
    }
    # Look up the player. Do they exist?
    my($copy) = $arg;
    $copy =~ tr/A-Z/a-z/;
    if (!exists($playerIds{$copy})) {
        # Break the bad news
        &tellPlayer($me, "There is no player by that name.");
        return 1;
    }
    # Check whether that player is already gagged
    $arg = quotemeta($arg);
    if ($objects[$me]{"gags"} =~ /$arg /i) {
        &tellPlayer($me, "Already gagged.");
        return 1;
    }
    # Now we're ready to gag! Great!
    # Be sure to use the proper name
    # to get the right case.
    $objects[$me]{"gags"} .= $objects[$playerIds{$copy}]{"name"} . " ";
    &tellPlayer($me, "Gag in place.");
    return 1;
}

sub ungag
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    if ($arg eq "") {
        &tellPlayer($me, "Syntax: \@ungag name");
        return;
    }
    if ($arg =~ / /) {
        &tellPlayer($me, "MUD player names do not contain spaces.");
        return;
    }
    # Allow big-geek syntax
    if ($arg =~ /^#(\d+)$/) {
        if (!defined($objects[$1])) {
            &tellPlayer($me, "That player does not exist.");
        }
        if ($objects[$1]{"type"} != $player) {
            &tellPlayer($me, "Only players can be gagged.");
        }
        # Okay, now we can accept it.
        $arg = $objects[$1]{"name"};
    }
    # Strip a leading *, the global player reference thingie,
    # not required here but allowed.
    if ($arg =~ /^\*(\w+)$/) {
        $arg = $1;
    }

    # We don't care whther the player exists -- removing
    # a gag for a now-nonexistent player is pretty common!

    # Check whether that player is gagged.
    $arg = quotemeta($arg);
    if ($objects[$me]{"gags"} =~ /$arg /i) {
        # Remove the gag of that player.
        $objects[$me]{"gags"} =~ s/$arg //i;
        &tellPlayer($me, "Gag removed.");
        return;
    }
    # No such gag.
    &tellPlayer($me,
        "That player is not gagged, or you mistyped their name.");
}

sub inven
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my @list = split(/,/, $objects[$me]{"contents"});
    # sort contents into numerical order so low numbered things always precede high number things
    @list = sort {$a <=> $b} @list;
    my $desc = "";
    my $first = 1;
    my $found = 0;
    my @containers=();
    foreach my $f (@list) {
        $found = 1;
        if ($first) {
            $first = 0;
        } else {
            $desc .= ", ";
        }
        $desc .= $objects[$f]{"name"};
        push (@containers, $f) if ($objects[$f]{"contains"} > 0);
    }
    if (!$found) {
        $desc = "You aren\'t carrying anything!";
    } else {
        &tellPlayer($me, "You are currently holding the following:");
        $desc .= ".";
    }
    &tellPlayer($me, $desc);
    # now explode containers the player is carrying
    #debug to be developed
    # now explode containers the player is carrying
    foreach my $o (@containers) {
        &expandContainer($me,$me,$o,1); # exapnd containers on player
    }
    return 1;
}

sub drop
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 1 if (!(&wake($me,"","","")));
    }
    my $id=$none;
    my $id2=$none;

    if ($arg eq "all") {
        &dropAll($me);
        return 1;
    }
    # support for giving
    if ($arg =~ /^(.*)(\bat\b|\bto\b)\s*(.+)$/i ) {
        # giving something to someone
        $arg=$1; # the list of things
        $arg2=$3; # who to give them to
        my $word=visibleCanonicalizeWord($me,$arg2);
        if (substr($word,0,1) eq "#") {
            $id2=substr($word,1);
            $id2=&idBounds($id2);
            if ($objects[$id2]{"type"} != $player) { #debug you can only really give to a player?
                $id2=$none; # this will make it drop
            }
        }
        if (($id2==$none) && exists($playerIds{$arg2})) {
            &tellPlayer($me, ucfirst($arg2) . " isn't here to give anything to.");
            return 1;
        }
        if ($me==$id2) {
            &tellPlayer($me,"Giving to yourself is silly!");
            return 1;
        }
    }
    # support for multiple objects and synonyms
    $arg =~ s/\s+//; # strip out whitespace in arguments
    my @args=split(/,/,$arg); # allow multiple objects to be got seperated by commas
    foreach my $arg (@args) { # process arguments
        $arg =~ s/\s+//; # strip out whitespace in arguments
        $arg = $synonymTable{"$arg"} unless ($synonymTable{"$arg"} eq ""); # resolve synonyms for objects
        my $found=0;
        while (1) { # keep dropping objects that match arg until no more
            $id = &findContents($me, $arg); # handles classes
            last if (($objects[$id]{"name"} eq $arg) && ($found)); # only drop the first of its name
            my $loc = $objects[$me]{"location"}; # note my location
            $loc = $id2 if ($id2 != $none); # giving to id2
            if ($id == $none) {
                &tellPlayer($me, "You are not carrying that.") if (!$found); # only out message if no object arg was found on me
                last;
            } else { #debug this looks wrong
                if ($objects[$id]{"type"} == $topic) {
                    &createTopic($me, $arg, $arg1, $arg2);
                    return 1;
                }
                $found = 1;
                &removeContents($me, $id);
                if ($id2 != $none) {
                    &tellPlayer($me, ucfirst($objects[$id]{"name"}) . " given to ". playerName($id2). ".");
                } else {
                    &tellPlayer($me, ucfirst($objects[$id]{"name"}) . " dropped.") if ($id2 == $none);
                }
                &addScore($me, $id, $loc) if ($objects[$loc]{"flags"} & $sanctuary); # add to score if in sanctuary
                if ($objects[$id]{"flags"} & $sticky) {
                    $loc=$objects[$id]{"home"}; # send home if sticky
                }
                $loc = $objects[$loc]{"dmove"} unless ($objects[$loc]{"dmove"} eq ""); # move if dmove present
                &addContents($loc, $id); # put the obj in loc
            }
            if ($objects[$id]{"odrop"} ne "") {
                &tellRoom($loc, $me,
                    ucfirst($objects[$me]{"name"}) . " " .
                    &substitute($me, $objects[$id]{"odrop"}));
            } else {
                if ($id2==$none) {
                    my $desc = playerName($me) . " dropped the " .
                    $objects[$id]{"name"} . ".";
                    if ($objects[$id]{"description"} ne "") {
                        $desc = $objects[$id]{"description"};
                    }
                    &tellRoom($loc, $me, $desc) if ($id2==$none);
                } else {
                    my $desc = playerName($me) . " has given you the " .
                    $objects[$id]{"name"} . ".";
                    &tellPlayer($id2, $desc);
                }
            }
        }
    }
    return 1;
}

sub dropAll
{
    my($container) = @_;
    my(@list);
    @list = split(/,/, $objects[$container]{"contents"});
    my($e);
    foreach $e (@list) {
        &mud_command($container, "drop #" . $e);
    }
    if (!int(@list)) {
        &tellPlayer($container, "You aren't carrying anything!");
    }
    return 1;
}

sub mud_score
{
    my ($me, $arg, $arg1, $arg2) = @_;
    &tellScore($me, $me, 1);
    return 1;
}

sub quickScore
{
    my ($me, $arg, $arg1, $arg2) = @_;
    &tellScore($me, $me, 0);
    return 1;
}


sub addScore
{
    # adds score to player based on objId and optional location
    my ($me, $objId, $locId) = @_;
    #debug simple scoring for now
    my $currvalue=0;
    if (($objects[$objId]{"currprop"}==$objects[$objId]{"scoreprop"}) || ($objects[$objId]{"maxprop"}<0)) {
        # prop is score prop or this is a random prop object
        #debug  what is P1 of obj=1 in MUD3?
        my $res = $objects[$objId]{"score"};
        $res=($objects[$objId]{"currprop"}+1) * $res if ($objects[$objId]{"maxprop"}<0); # score based on currprop * value if the prop is a random
        $currvalue = int(3*$res-((4*$res)/($mudPlayers+1))); # only add 1 because we start from 1 unlike MUD.
#        $currvalue = 0 if &builderTest($me); # wizzes dont score points
        $currvalue = 0 if (($objects[$me]{"flags"} & $dark) && ($currvalue>0)); # you can loose pts if invis but not gain them
    }
    &addExp($me,$currvalue);
    return 1;
}

sub addExp
{
    # adds experience points to score
    my ($me, $value) = @_;
    return if (($objects[$me]{"flags"} & $dark) && ($value>0)); # cant score points if invisible
    $objects[$me]{"score"} += $value;
    $objects[$me]{"score"} = 0 if ($objects[$me]{"score"}<0); # never lower than zero
    &tellPlayer($me, '[' . $objects[$me]{"score"} . ']');
    my $lev = whatLevel($me);
    if ($lev != $objects[$me]{"level"}) {
        my $oldLevel = $levelNames{(($objects[$me]{"flags"} & $female) ? "female" : "male")}[$objects[$me]{"level"}];
        my $level = $levelNames{(($objects[$me]{"flags"} & $female) ? "female" : "male")}[$lev];
        &tellPlayer($me,"Your level of experience is now $level.") ;
        &tellWizards(ucfirst($objects[$me]{"name"}) . " has changed experience level from $oldLevel to $level.");
        if ($lev > $objects[$me]{"level"}) { # level increased max 100
            $objects[$me]{"stamina"} = ($objects[$me]{"stamina"} > 90 ? 100 : $objects[$me]{"stamina"}+10);
            $objects[$me]{"maxstamina"} = ($objects[$me]{"maxstamina"} > 90 ? 100 : $objects[$me]{"maxstamina"}+10);
            $objects[$me]{"strength"} = ($objects[$me]{"strength"} > 90 ? 100 : $objects[$me]{"strength"}+10);
            $objects[$me]{"dexterity"} = ($objects[$me]{"dexterity"} > 90 ? 100 : $objects[$me]{"dexterity"}+10);
        } else { # level decreased min 20
            $objects[$me]{"stamina"} = ($objects[$me]{"stamina"} < 30 ? 20 : $objects[$me]{"stamina"}-10);
            $objects[$me]{"maxstamina"} = ($objects[$me]{"maxstamina"} < 30 ? 20 : $objects[$me]{"maxstamina"}-10);
            $objects[$me]{"strength"} = ($objects[$me]{"strength"} < 30 ? 20 : $objects[$me]{"strength"}-10);
            $objects[$me]{"dexterity"} = ($objects[$me]{"dexterity"} < 30 ? 20 : $objects[$me]{"dexterity"}-10);
        }
        $objects[$me]{"level"} = $lev;
    }
    return 1;
}

sub tellScore
{
    my ($me, $what, $details) = @_;
    # displays score for what to me, usually what = me
    my $outp = "";
    my $sex = "";
    if ($details) {
        if ($objects[$what]{"type"}==$player) {
            &tellPlayer($me,"Score to date: " . int($objects[$what]{"score"}));
            my $level = $objects[$what]{"level"};
            $sex = ($objects[$what]{"flags"} & $female) ? "female" : "male";
            $level = $levelNames{$sex}[$level];
            &tellPlayer($me,"Level of experience: ". ucfirst($level));
        }
        $outp .= "Strength: " . $objects[$what]{"strength"} . "\t" if ($objects[$what]{"strength"} ne "");
        $outp .= "Stamina: " . $objects[$what]{"stamina"} . "\t" if ($objects[$what]{"stamina"} ne "");
        $outp .= "Dexterity: " . $objects[$what]{"dexterity"} . "\t" if ($objects[$what]{"dexterity"} ne "");
        $outp .= "Sex: $sex" if ($sex ne "");
        &tellPlayer($me,$outp) if ($outp ne "");
        $outp = "";
        $outp = "Maximum stamina: " . $objects[$what]{"maxstamina"} if ($objects[$what]{"maxstamina"} ne "");
        &tellPlayer($me, $outp) if ($outp ne "");
        my $maxweight = 1000 * $objects[$what]{"strength"};
        my $weight = weighContents($what, $thing);
        $outp = "Weight carried: " . $weight . "g (max. weight: " . $maxweight . "g)";
        &tellPlayer($me, $outp) if ($outp ne "");
        my $maxobjs = maxObj($what);
        my $objs = howMany($what, $thing);
        $outp = "Objects carried: $objs (max. objects: $maxobjs)";
        &tellPlayer($me, $outp) if ($outp ne "");
        $outp = "Games played to date: " . $objects[$what]{"played"} if ($objects[$what]{"played"} ne "");
        &tellPlayer($me, $outp) if ($outp ne "");
    } else {
        $outp = "Score: " . $objects[$what]{"score"} . ", sta: " . $objects[$what]{"stamina"} . "/" . $objects[$what]{"maxstamina"} . ", str: " . $objects[$what]{"strength"} . ", dex: " . $objects[$what]{"dexterity"};
        &tellPlayer($me, $outp);
    }
    return 1;
}

sub whatLevel
{
    # levels are 0 to 9 with 400*2^n between each level
    my ($what) = @_;
    return 10 if ($what==1); # object 1 is always the arch
    my $scr = $objects[$what]{"score"};
    for (my $i=0; ($i<10); $i++) { # levels 0..9
        return $i if ((1<<$i)*400 > $scr);
    }
    return 9; # max mortal level
}

sub playerName
{
    my ($me) = @_;
    if ($objects[$me]{"type"}==$player) { # add honorifics
        my $level = $objects[$me]{"level"};
        my $sex = ($objects[$me]{"flags"} & $female) ? "female" : "male";
        my $lev = $levelNames{"$sex"}[$level];
        return ucfirst($objects[$me]{"name"}) . " the " . $lev if ($objects[$me]{"level"}>0);
    }
    return ucfirst($objects[$me]{"name"}); # not player or a novice
}

sub get
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    # support for stealing
    my $id=$none;
    my $id2=$none;
    if ($arg =~ /^(.*)(\bfr.*\b)\s*(.+)$/i ) {
        # stealing something from someone
        $arg=$1; # the list of things
        $arg2=$3; # who to steal them from
        my $word=visibleCanonicalizeWord($me,$arg2);
        if (substr($word,0,1) eq "#") {
            $id2=substr($word,1);
            $id2=&idBounds($id2);
        }
        if (($id2==$none) || (!(exists($playerIds{$arg2})))) {
            &tellPlayer($me, ucfirst($arg2) . " isn't here to steal anything from.");
            return 1;
        }
        if ($me==$id2) {
            &tellPlayer($me,"Stealing from yourself is silly!");
            return 1;
        }
    }
    if ($arg eq "") {
        &tellPlayer($me, "Syntax: get thing[,thing]");
        return 0;
    }
    if ($arg eq "all") { #debug specify container in future
        &getAll($me,$objects[$me]{"location"});
        return 1;
    }
    # support for multiple objects and synonyms
    my @args=split(/,/,$arg); # allow multiple objects to be got seperated by commas
    foreach $arg (@args) { # process arguments
        $arg1 = $arg;
        $arg1 =~ s/\s+//; # strip out whitespace in arguments
        $arg1 = $synonymTable{"$arg1"} unless ($synonymTable{"$arg1"} eq ""); # resolve synonyms for objects
        if ($arg1 eq "me") {
            $id = $me;
            &tellPlayer($me, "Taking from yourself is silly!.");
            return 0;
        }
        my $found=0;
        while (1) { # keep picking up objects that match arg until there are no more
            my $loc = $objects[$me]{"location"};
            $loc = $id2 if ($id2 != $none);
            $id = &findContents($loc, $arg1, $thing); # this only finds the first thing that matches the arg (class or name)
            while (($id!=$none) && (($objects[$id]{"flags"} & $dark) || ($objects[$id]{"flags"} & $destroyed))) { # target is invis or destroyed and you are not a wiz
                last if (&builderTest($me)); # wiz can get anyway
                $id = &findContents($loc, $arg1, "", $id)
            }
            last if (($objects[$id]{"name"} eq $arg1) && ($found)); # only get the first of its name
            if ($id == $none) {
                #debug it should only say this if the arg exists somehwere but isnt here
                if (findObject($arg,,$thing)==$none) {
                    &tellPlayer($me,"It's all double dutch to me mate!") if (!$found);
                } else {
                    &tellPlayer($me, "I see no $arg.") if (!$found);
                }
                # only out message if no object arg was found in location
                #debug if the arg is not at actual thing it should say: I don't know what arg means
                last;
            }
            $found=1; # found at least one object
            # calculate stealabilty if stealing
            if ($id2!=$none) {
                my $damage=int(rand(100)+1); # 1d100 chance of resist
                # if target is asleep or target a wiz special resist
                $damage=-1 if ($objects[$id2]{"flags"} & $asleep);
                $damage=102 if (builderTest($id2));
                if ($damage>$objects[$me]{"dexterity"}) { # caught!
                        &tellPlayer($id2,"You catch " . playerName($me) . " trying to steal the ". $objects[$id]{"name"} . " from you!");
                        &tellPlayer($me,playerName($id2) . " discovers your attempt to steal the " . $objects[$id]{"name"}. "!");
                        return 1;
                }
                # successful, but did they notice?
                my $weight = $objects[$id]{"weight"};
                my $detected=(int(rand(100-$weight/100))+1 <= $objects[$id2]{"dexterity"});
                if (($detected) && !($objects[$id2]{"flags"} & $asleep)) { # rumbled but still a success!
                    &tellPlayer($id2,playerName($me) . " has stolen the ". $objects[$id]{"name"} . " from you!");
                }
            }
            if ((!&testLock($me, $id)) ||
                (($objects[$id]{"type"} != $thing) &&
                ($objects[$id]{"type"} != $topic) &&
                ($objects[$id]{"type"} != $exit)))
            {
                &fail($me, $id, "You can't pick up the " . $objects[$id]{"name"} . ".", "");
                return 1;
            }
            if (($objects[$id]{"type"} == $exit) ||
                ($objects[$id]{"flags"} & $noget)) {
                if ((!&wizardTest($me)) &&
                    ($objects[$id]{"owner"} != $me))
                {
                    &tellPlayer($me, "Don't be ridiculous!");
                    return 1;
                } else {
                    if ($objects[$id]{"flags"} & $fixed) {
                        &tellPlayer($me,"Can't be done.");
                        return 1;
                    }
                    &tellPlayer($me, "I hope you know what you are doing.");
                }
            }
            if (canContain($me,$id)) {
                # me can carry it
                &removeContents($loc, $id);
                $objects[$id]{"flags"} &= ~$destroyed; # if you can get it it cant be destroyed
                $objects[$id]{"stamina"}=0 if ($objects[$id]{"stamina"}<0);
                &addContents($me, $id);
                &tellRoom($loc, $me, playerName($me) . " picked up the " . $objects[$id]{"name"} . ".") if ($id2==$none);
                &success($me, $id, ucfirst($objects[$id]{"name"}) . " taken.", "");
            } else {
                if (maxObj($me) < howMany($me,$thing)+1) {
                    &fail($me, $id, "You can't carry more than " . maxObj($me) . " objects.");
                    return 0; # the get fails
                } else {
                    &fail($me, $id, "It is too much extra weight.");
                    return 0; # the get fails
                }
            }
        }
    }
    return 1; # success
}

sub getAll
{
    my ($me,$container) = @_;
    my (@list);
    @list = split(/,/, $objects[$container]{"contents"});
    my($e);
    my $found=0;
    foreach $e (@list) {
        if ((testLock($me,$e)) &&
            (!($objects[$e]{"flags"} & $noget)) &&
            ($objects[$e]{"type"}==$thing) && (!($objects[$e]{"flags"} & $dark)) && (!($objects[$e]{"flags"} & $destroyed)))
        {
            last unless (&get($me, "#" . $e, "", ""));
            $found=1;
        }
    }
    if (!$found) {
        &tellPlayer($me, "Nothing taken.");
    }
    return $found;
}
    
sub canContain
{
    my ($who, $what) = @_;
    return 1 if (($objects[$who]{"strength"}*1000 >= weighContents($who,$thing)+$objects[$what]{"weight"}) && (maxObj($who) >= howMany($who,$thing)+1));
    return 0;
}

sub lookBody #debug new look to be more MUD1 like
{
    my($me, $arg, $arg1, $arg2, $details) = @_;
    # the default is to describe the room you are in
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (($arg eq "") || ($arg eq ("#" . $objects[$me]{"location"}))) {
        if (builderTest($me) && $details) {
            &describe($me, $objects[$me]{"location"}, $details);
        } else {
        # describe the current location and summarise contents
        # for each player in location, list what they are carrying
        # and if they carry a container then expand that too unless closed
            my $what = $objects[$me]{"location"};
            if ((!($objects[$what]{"flags"} & $dark)) || &isBright($what)) {
                # there is enough light to see room
                &tellPlayer($me, $objects[$what]{"name"});
                if ($objects[$what]{"description"} eq "") {
                    &tellPlayer($me, "You see nothing special.") unless ($objects[$what]{"type"}=$room); #debug always true
                } else {
                    &tellPlayer($me, $objects[$what]{"description"});
                }
                # now describe contents of room
                my(@list);
                my($desc, $first, $e, $found);
                @list = split(/,/, $objects[$what]{"contents"});
                # sort contents into numerical order so low numbered things always precede high number things
                @list = sort {$a <=> $b} @list;
                $desc = "";
                $first = 1;
                # list room contents starting with non-players
                foreach $e (@list) {
                    if ($objects[$e]{"type"} != $player) {
                        if ($objects[$e]{"maxprop"}<0) { # random prop every look
                            my $p = int(rand(abs($objects[$e]{"maxprop"})+1));
                            $objects[$e]{"currprop"}=$p;
                            $objects[$e]{"description"} = $objects[$e]{"description$p"};
                        }
                        # only describe non-player if it has a current description and is not destroyed
                        #debug need to add build/wiz can see name & id of thing, although examine does that anyway
                        if (($objects[$e]{"description"} ne "") && (!($objects[$e]{"flags"} & $destroyed))) {
                            $desc = $objects[$e]{"description"};
                            &tellPlayer($me, $desc);
                            &expandContainer($me,$what,$e,1); # exapnd if $e is a container
                        }
                    }
                }
                # now list players in room last except me
                foreach $e (@list) {
                    if (($e != $me) && ($objects[$e]{"type"} == $player)) {
                        next if (($objects[$e]{"flags"} & $dark) && !(&builderTest($me))); # cant see if not wiz
                        $desc = playerName($e) . " is here, ";
                        $desc = "(" . playerName($e) . ") is here, " if ($objects[$e]{"flags"} & $dark);
                        $desc .= "asleep, " if ($objects[$e]{"flags"} & $asleep);
                        $desc .= "carrying ";
                        # now list what the player is carrying
                        my @list = split(/,/, $objects[$e]{"contents"});
                        # sort contents into numerical order so low numbered things always precede high number things
                        @list = sort {$a <=> $b} @list;
                        $first = 1;
                        $found = 0;
                        my @containers=();
                        foreach my $f (@list) {
                            if (($objects[$f]{"type"} == $thing) && (!($objects[$f]{"flags"} & $destroyed))) {
                                $found = 1;
                                if ($first) {
                                    $first = 0;
                                } else {
                                    $desc .= ", ";
                                }
                                $desc .= $objects[$f]{"name"};
                                push (@containers, $f) if ($objects[$f]{"contains"} > 0);
                            }
                        }
                        if (!$found) {
                            $desc .= "nothing.";
                        } else {
                            $desc .= ".";
                        }
                        &tellPlayer($me, $desc);
                        # now explode containers the player is carrying
                        foreach my $o (@containers) {
                            &expandContainer($me,$e,$o,1); # exapnd containers on player $e
                        }
                    }
                }
            } else {
                # the dark flag was set
                #debug needs to cope with light sources in future
                &tellPlayer($me, "It is too dark to see.");
            }
        }
    } else {
        # there is an argument that could be a
        # exit, person, place or thing
        # describe the exit, person (present), place (only if wiz),
        # or thing (visible)
        #debug needs work - needs dark detect at least
        my $id = &findContents($objects[$me]{"location"}, $arg1);
        if ($id == $none) {
            $id = &findContents($me, $arg1);
        }
        if ($id == $none) {
            if ($details) {
                if (substr($arg1, 0, 1) eq "#") {
                    $id = int(substr($arg1, 1));
                    $id = &idBounds($id);
                }
            }
        }
        if (($id == $none) || ($objects[$id]{"type"} == $none)) {
            &tellPlayer($me, "I don't see that here.");
            return;
        }
        &describe($me, $id, $details);
    }
    return 1;
}

sub expandContainer
{
    my ($me,$id,$obj,$nest) = @_;
    # who looks, who holds (or $none), container, nesting level
    return 0 if ((int($objects[$obj]{"contains"}) == 0) || (($objects[$obj]{"flags"} & $disguised) && (!(&builderTest($me))))); # its not a container or its digusieed and you are not a wiz
    $nest=1 if !(defined $nest);
    my $found=0;
    my $first=1;
    my @containers=();
    my $desc = "The " . $objects[$obj]{"name"};
    if ($objects[$obj]{"speed"}>0) {
        $desc .= " is carrying "; # its a mobile
    } else {
        $desc .= " contains ";
    }
    if ($objects[$obj]{"contents"} ne "") {
        if (($me!=$id) && (($objects[$obj]{"currprop"} != 0) || (!($objects[$obj]{"flags"} & $opened)))) {
            $desc .= "something.";
        } else {
            my @contents = split(/,/,$objects[$obj]{"contents"});
            foreach my $o (@contents) {
                $found = 1;
            
                if ($first) {
                    $first = 0;
                } else {
                    $desc .= ", ";
                }
                $desc .= $objects[$o]{"name"};
                push(@containers,$o) if ($objects[$o]{"contains"} > 0); # expand containers below
            }
        }
    } else {
        $desc .= "nothing.";
    }
    my $saveCols=$columns; # save the $columns global
    my $activeFd=$objects[$me]{"activeFd"};
    if ($activeFd==$none) {
        $columns=80;
    } else {
        my $conn = $activeFds[$activeFd]{"fd"};
        $columns=$conn->{cols} || 80;
    }
    $desc=wrap("    " x $nest,"    " x $nest,$desc);
    $columns=$saveCols; # restore the $columns global
    &tellPlayer($me,$desc);
    foreach my $o (@containers) {
        &expandContainer($me,$id,$o,$nest+1); # exapnd containers in container
    }
}

sub old_lookBody #debug no longer used, remove
{
    my($me, $arg, $arg1, $arg2, $details) = @_;
    my($id);
    if (($arg eq "") || ($arg eq ("#" . $objects[$me]{"location"}))) {
        &describe($me, $objects[$me]{"location"}, $details);
    } else {
        $id = &findContents($objects[$me]{"location"}, $arg);
        if ($id == $none) {
            $id = &findContents($me, $arg);
        }
        if ($id == $none) {
            if ($details) {
                if (substr($arg, 0, 1) eq "#") {
                    $id = int(substr($arg, 1));
                    $id = &idBounds($id);
                }
            }
        }
        if (($id == $none) || ($objects[$id]{"type"} == $none)) {
            &tellPlayer($me, "I don't see that here.");
            return;
        }
        &describe($me, $id, $details);
    }
}

sub tz
{
    my($me, $arg, $arg1, $arg2) = @_;
    if ($arg eq "") {
        &tellPlayer($me, "Usage: [-]HH:MM (optional minus sign, " .
            "followed by an offset in hours and minutes)");
        return;
    }
    if ($arg =~ /^([-+]?)(\d\d?):(\d\d)$/) {
        my($sign, $hours, $mins) = ($1, $2, $3);
        my($tz) = $hours * 60 + $mins;
        if ($sign eq "-") {
            $tz = -$tz;
        }
        $objects[$me]{"tz"} = $tz;
        &tellPlayer($me, "Time zone updated.");
    } else {
        &tellPlayer($me, "Usage: [-]HH:MM (optional minus sign, " .
            "followed by an offset in hours and minutes)");
    }
}

sub reload
{
    #debug - this resets the mud but this needs further work to stop it doing weired stuff in memory
    my($me, $arg, $arg1, $arg2) = @_;
    if ($me != $none) {
        if (!&builderTest($me)) {
            &tellPlayer($me,$invalidMsgs[int(rand(5))]);
            return 0;
        }
        # this is where we detecting a sleeping person
        if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
            # wake me if possible but report fail if not.
            return 0 if (!(&wake($me,"","","")));
        }
    }
    my($i);
    # eject all players from MUD
    &stopFighting(); # stop all fighting
    $mud_closed = 1;
    &tellElsewhere($me, "There is something magic happening! You feel yourself leaving the land...");
    &tellElsewhere($me,"You can restart in a minute or so.");
    &tellPlayer($me,"There is something magic happening! You feel yourself leaving the land...");
    &TH::kill_timer(\&mud_housekeeping, 0); # stop the housekeeping
    &TH::kill_timer(\&mud_creature, 0); # stops all creature daemons
    &TH::kill_timer(\&mud_xdemon, 0); # stops all other daemons
    for (my $i = 0; ($i <= $#activeFds); $i++) { # stop autowhos
        next if ($activeFds[$i]{"id"}==$none); # fd not in use
        if (defined $objects[$activeFds[$i]{"id"}]{"autowho"}) {
            delete $objects[$activeFds[$i]{"id"}]{"autowho"};
            &TH::kill_timer(\&mud_autowho, $activeFds[$i]{"fd"}->{"fd"});
        }
    }
    # kick players
    for ($i = 0; ($i <= $#activeFds); $i++) {
        if ($activeFds[$i]{"id"} != $none) {
            my $id = $activeFds[$i]{"id"};
            &forceClosePlayer($id,1,1);
        }
    }
    &dump($me, $arg, $arg1, $arg2); # dump pf file
    $mudReloadFlag = 1;
    $mudPlayers = 0;
    #debug default to peace for now
    $worldPeace = 1;
    @objects = (); # initialise the objects
    %playerIds = (); # init the player table;
    %synonymTable = (); # init synonyms;
    @demonsTable = (); # init the demons table;
    %fightsTable = {}; # init fightsTable;
    ($lastdump, $lastFdClosure, $now) = (time, time, time);
    $initialized = time;
    if (!&restore) {
        &TH::xlog('Mud: FATAL: Can\'t restart the mud with this database.');
        return 0;
    }

    $TH::data->{mud} = {}; # nobody in mud
    &TH::set_timer(1,\&mud_housekeeping,0,0); # start housekeeping every second
    $mud_closed = 0; # open up again
    &TH::xlog("Mud: reset");
    #(re)initialization code ends here

    return $death;
}

sub mud_shutdown
{
    # this should only be called by telehack shutdown or reboot
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&wizardTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    $mud_closed = 1;
    # eject all players from MUD

    my($i);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        if ($activeFds[$i]{"id"} != $none) {
            my $id = $activeFds[$i]{"id"};
            &tellPlayer($id,"There is something magic happening! You feel yourself leaving the land...");
            &forceClosePlayer($id,1,1);
        }
    }
    $mudPlayers = 0;

    &TH::kill_timer(\&mud_creature, 0); # stops all creature daemons
    &TH::kill_timer(\&mud_xdemon, 0); # stops all other daemons
    for (my $i = 0; ($i <= $#activeFds); $i++) { # stop autowhos
        if (defined $objects[$activeFds[$i]{"id"}]{"autowho"}) {
            delete $objects[$activeFds[$i]{"id"}]{"autowho"};
            &TH::kill_timer(\&mud_autowho, $activeFds[$i]{"fd"}->{"fd"});
        }
    }
    &dump($me, $arg, $arg1, $arg2);
    &TH::xlog("Mud: Shutdown");
    return $death;
}

sub toad
{
    my($me, $arg, $arg1, $arg2) = @_;
    #debug this is the stand-in for FOD but really need sorting out
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    my($id, $arg2id);
    if ($arg1 eq "") {
        &tellPlayer($me, "Usage: \@toad player");
        return;
    }
    if (substr($arg1, 0, 1) eq "#") {
        $id = int(substr($arg1, 1));
        $id = &idBounds($id);
        if ($id == $none) {
            &tellPlayer($me, "There is no such player.");
            return;
        }
    } else {
        my($n);
        if ($arg1 =~ /^\*(.*)$/) {
            $arg1 = $1;
        }
        $n = $arg1;
        $n =~ tr/A-Z/a-z/;
        if (!exists($playerIds{$n})) {
            &tellPlayer($me, "There is no such player.");
            return;
        }
        $id = $playerIds{$n};
    }
    if ($arg2 eq "") {
        $arg2id = $none;
    } else {
        if (substr($arg2, 0, 1) eq "#") {
            $arg2id = int(substr($arg2, 1));
            $arg2id = &idBounds($arg2id);
            if ($arg2id == $none) {
                &tellPlayer($me, "There is no such player.");
                return;
            }
        } else {
            my($n);
            if ($arg2 =~ /^\*(.*)$/) {
                $arg2 = $1;
            }
            $n = $arg2;
            $n =~ tr/A-Z/a-z/;
            if (!exists($playerIds{$n})) {
                &tellPlayer($me, "There is no such player.");
                return;
            }
            $arg2id = $playerIds{$n};
        }
        if ($arg2id == $none) {
            &tellPlayer($me, "I don't see that here.");
        }
    }
    if ($arg2id != $none) {
        if ($objects[$arg2id]{"type"} != $player) {
            &tellPlayer($me, "#" . $arg2id . " is not a player.");
            return;
        }
    }
    if (!&wizardTest($me)) {
        &tellPlayer($me, "Only a wizard can do that!");
        return;
    }
    if ($objects[$id]{"type"} != $player) {
        &tellPlayer($me, "Not a player. \@toad is used to turn players into slimy toads (objects). \@recycle is used to eliminate objects.");
    }
    if ($id == $arg2id) {
        &tellPlayer($me, "You can't give a toad's possessions to the toad itself.");
        return;
    }
    if (($id == 0) || ($id == 1)) {
        &tellPlayer($me, "Objects #0 and #1 are indestructible.");
        return;
    }

    &dropAll($id);

    if (($objects[$id]{"activeFd"} != $none))
    {
        &closePlayer($id, 0);
    }
    my($name) = $objects[$id]{"name"};
    $name =~ tr/A-Z/a-z/;
    undef($playerIds{$name});

    $objects[$id]{"name"} = "A slimy toad named " . ucfirst($objects[$id]{"name"});
    $objects[$id]{"type"} = $thing;
    #Find objects belonging to this player and give them
    #to the specified player, or recycle them if no
    #player is specified.

    my($i);
    for ($i = 0; ($i <= $#objects); $i++) {
        if (($i != $id) && ($objects[$i]{"owner"} == $id)) {
            if ($arg2id == $none) {
                &recycle($me, "#" . $i, "", "");
            } else {
                $objects[$i]{"owner"} = $arg2id;
            }
        }
    }
    &tellPlayer($me, "Toaded.");
}

sub purgeObj
{
    my($me, $arg, $arg1, $arg2) = @_;
#debug massive issues with this, does not account for seperate player file - seems to bork the whole thing at the moment
    return 0; # DO NOT USE!
    my($count,$i);
    my(%junk);
    if (!&wizardTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    # First pass: find junk; flag it as such
    for ($i = 0; ($i <= $#objects); $i++) {
        if ($i < 2) {
            # Objects 0 and 1 are indestructible
            next;
        }
        if (!($i % 100)) {
            &TH::xlog("Mud: Purging: scanned $i of $#objects"); #debug - this may be too noisy for the console
        }
        if ($objects[$i]{"type"} eq "") {
            $junk{$i} = 1;
            $objects[$i]{"type"} = $none;
            $count++;
        }
    }
    # Second pass: remove from inventories, destinations, etc.
    # in an efficient way
    for ($i = 0; ($i <= $#objects); $i++) {
        if ($junk{$i}) {
            next;
        }
        if (!($i % 100)) {
            &TH::xlog( "Mud: Purging: cleaned $i of $#objects"); #debug - this may be too noisy for the console
        }
        if ($junk{$objects[$i]{"owner"}}) {
            # Give to wizard
            $objects[$i]{"owner"} = 1;
        }
        if ($junk{$objects[$i]{"action"}}) {
            # Unlink exit
            $objects[$i]{"action"} = 0;
        }
        my(@list) = split(/,/, $objects[$i]{"contents"});
        my(@nlist);
        for my $l (@list) {
            if ($junk{$l}) {
                next;
            }
            push @nlist, $l;
        }
        $objects[$i]{"contents"} = join(",", @nlist);
    }
    &tellPlayer($me, "$count broken objects recycled.");
}

sub recycle
{
    my($me, $arg, $arg1, $arg2) = @_;
#debug some possible brokage here too because it doesnt acount for pf file
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    my($id);
    my(@list, $e);
    if ($arg eq "") {
        &tellPlayer($me, "Usage: \@recycle thing");
        return;
    }
    $id = &findContents($objects[$me]{"location"}, $arg);
    if ($id == $none) {
        $id = &findContents($me, $arg);
    }
    if ($id == $none) {
        if (substr($arg, 0, 1) eq "#") {
            $id = int(substr($arg, 1));
            $id = &idBounds($id);
        }
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    }
    &recycleById($me, $id, 0);
}

sub recycleById
{
    my($me, $id, $quiet) = @_;
    if ($objects[$id]{"owner"} != $me) {
        if (!&wizardTest($me)) {
            if (!$quiet) {
                &tellPlayer($me, "You don't own that!");
            }
            return;
        }
    }
    if ($objects[$id]{"type"} == $player)
    {
        if (!$quiet) {
            &tellPlayer($me,
                "You must \@toad players before recycling them.");
        }
        return;
    }
    if (($id == 0) || ($id == 1)) {
        if (!$quiet) {
            &tellPlayer($me, "Objects #0 and #1 are indestructible.");
        }
        return;
    }
    #Remove it from its location
        
    &removeContents($objects[$id]{"location"}, $id);
    #Find all entrances and link them to the void
    my($i);
    for ($i = 0; ($i <= $#objects); $i++) {
        if ($objects[$i]{"action"} == $id) {
            $objects[$i]{"action"} = 0;
        }
    }

    #Reset the flags to keep anything funny like a puzzle
    #flag from interfering with the removal of the contents

    $objects[$id]{"flags"} = 0;

    #Send the contents home. If they live here,
    #recycle them too, unless they are players.
    #If they are players, set their homes to room 0
    #and send them home.
    my $e;
    my @list = split(/,/, $objects[$id]{"contents"});
    foreach $e (@list) {
        if ($objects[$e]{"home"} == $id) {
            if ($objects[$e]{"type"} == $player) {
                $objects[$e]{"home"} = 0;
            } else {
                &recycle($me, "#" . $e, "", "");
                next;
            }
        }
        &sendHome($e);
    }

    if (!$quiet) {
        &tellPlayer($me, $objects[$id]{"name"} . " recycled.");
    }
    #Mark it unused
    $objects[$id] = { };
    # I promise I won't introduce more of this stupidity
    $objects[$id]{"type"} = $none;
    $objects[$id]{"activeFd"} = $none;
}
 
sub sendHome
{
    my($me, $quiet) = @_;
    if ($objects[$objects[$me]{"location"}]{"flags"} & $puzzle) {
        &dropAll($me);
    }
    #debug drop whatever you are carrying if you are sent home
    &dropAll($me);
    &removeContents($objects[$me]{"location"}, $me);
    if (!($objects[$objects[$me]{"location"}]{"flags"} & $grand)) {
        &tellRoom($objects[$me]{"location"}, $none,
            playerName($me) . " goes home.") if !$quiet;
    }
    &addContents(int($objects[$me]{"home"}), $me);
    if (!($objects[$objects[$me]{"location"}]{"flags"} & $grand)) {
        &tellRoom($objects[$me]{"location"}, $me,
            playerName($me) . " arrives at home.") unless $quiet;
    }
    &tellPlayer($me, "You go home.");
    &look($me, "", "", "");
}

sub help
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 1;
    }
    my($found);
    if ($arg eq "") {
        $arg = "index";
    }
    $arg = "*" . $arg;
    if (!open(IN, $helpFile)) {
        &tellPlayer($me, "I\'m sorry, I can\'t help you right now.");
        &TH::xlog('Mud: ERROR: the helpfile ' . $helpFile . ' is missing');
        return;
    }
    &tellPlayer($me, "");
    $found = 0;
    while(<IN>) {
        s/\s+$//;
        if ($arg eq $_) {
            $found = 1;
            last;
        }
    }
    if (!$found) {
        &tellPlayer($me,
            "Sorry, there is no such help topic. Try just typing help.");
        close(IN);
        return;
    }
    while(<IN>) {
        s/\s+$//;
        if (substr($_, 0, 1) eq "*") {
            last;
        }
        &tellPlayer($me, $_);
    }
    close(IN);
    return 1;
}

sub topic
{
    my($me, $arg, $arg1, $arg2, $emote) = @_;
    my($id) = &findContents($objects[$me]{"location"}, $arg1, $topic);
    if ($id == $none) {
        &tellPlayer($me, "There is no topic here called " .
            $arg1 . ". Type \@topic $arg1 to raise a topic.");
        return;
    }
    if (!&filterTopic($me, $objects[$id]{"name"})) {
        &tellPlayer($me, "You are not joined to that topic. " .
            "\@join " . $objects[$id]{"name"} . " first.");
        return;
    }
    my($tn) = "<" . $objects[$id]{"name"} . ">";
    if (!$emote) {
# debug
#        my($output) = "You say$to, \"" . $arg2 . "\" $tn"; # i think this is wrong should be $tn
        my($output) = "You say$tn, \"" . $arg2 . "\" $tn";
        my($prefix) = &getTopicPrefix($me);
        $output = "$prefix$output";
#debug no need to tell player what they said
#        &tellPlayer($me, $output);
        &tellRoom($objects[$me]{"location"}, $me,
            playerName($me) . " says, \"" . $arg2 . "\" $tn",
            $objects[$me]{"name"}, $objects[$id]{"name"});
    } else {
        my($s);
        if (!($arg2 =~ /^[,\']/)) {
            $s = " ";
        }
        &tellRoom($objects[$me]{"location"}, "",
            playerName($me) . $s . $arg2 . " $tn",
            $objects[$me]{"name"}, $objects[$id]{"name"});
    }
    $objects[$id]{"lastuse"} = time;
}

sub motd
{
    my($me, $arg, $arg1, $arg2) = @_;
    &sendFile($me, $motdFile);
    return 1;
}

sub welcome
{
    my($me, $arg, $arg1, $arg2) = @_;
    &sendFile($me, $welcomeFile);
    return 1;
}

sub setFlag
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    my($flag);
    my($id);
    if (($arg1 eq "") || ($arg2 eq "")) {
        &tellPlayer($me, "Syntax: \@set object = flag or !flag");
    }
    if (substr($arg1, 0, 1) eq "#") {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    } else {
        $id = &findContents($objects[$me]{"location"}, $arg1);
        if ($id == $none) {
            $id = &findContents($me, $arg1);
        }
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that object here.");
        return;
    }
    if ((!&wizardTest($me)) && ($objects[$id]{"owner"} != $me)) {
        &tellPlayer($me, "You don't own that.");
        return;
    }
    if (substr($arg2, 0, 1) eq "!") {
        if (!$flags{substr($arg2, 1)}) {
            &tellPlayer($me, "No such flag.");
            return;
        }
        $flag = $flags{substr($arg2, 1)};
        if (($flag == $wizard) || ($flag == $builder)) {
            if (!&wizardTest($me)) {
                &tellPlayer($me, "Only a wizard can do that.");
                return;
            }
            if ($id == 1) {
                &tellPlayer($me, "Player #1 is the arch-wizard.");
                return;
            }
        }
        $objects[$id]{"flags"} &= ~$flag;
        &tellPlayer($me, "Flag cleared.");
    } else {
        if (!$flags{$arg2}) {
            &tellPlayer($me, "No such flag.");
            return;
        }
        $flag = $flags{$arg2};
        if (($flag == $wizard) || ($flag == $builder)) {
            if (!&wizardTest($me)) {
                &tellPlayer($me, "Only a wizard can do that.");
                return;
            }
            if ($id == 1) {
                &tellPlayer($me, "Player #1 is the arch-wizard.");
                return;
            }
        }
        $objects[$id]{"flags"} |= $flag;
        &tellPlayer($me, "Flag set.");
    }
    return 1;
}

sub setDescription
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &setField($me, $arg, $arg1, $arg2,
        "description", "Description");
    return 1;
}

sub setFail
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &setField($me, $arg, $arg1, $arg2,
        "fail", "Fail");
    return 1;
}

sub setOfail
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &setField($me, $arg, $arg1, $arg2,
        "ofail", "Ofail");
    return 1;
}

sub updateMailAliases
{
    my($key, $val);
    #debug should be removed as no meaning in TH
}

sub updateApachePasswords
{
    my($key, $val);
    #debug should be removed as no meaning in TH
}

sub setOdrop
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &setField($me, $arg, $arg1, $arg2,
        "odrop", "Odrop");
    return 1;
}

sub setSuccess
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &setField($me, $arg, $arg1, $arg2,
        "success", "Success");
    return 1;
}

sub setOsuccess
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    &setField($me, $arg, $arg1, $arg2,
        "osuccess", "Osuccess");
    return 1;
}

sub setLock
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    my($id);
    $id = &setField($me, $arg, $arg1, $arg2,
        "lock", "Lock");
    if ($id == $none) {
        return;
    }
    # Canonicalize the lock now, not when the lock is tested
    my($lock, $i, $word, $expr, $len);
    my(@words);
    my($c);
    $lock = $objects[$id]{"lock"};
    $word = "";
    $expr = "";
    $len = length($lock);
    for ($i = 0; ($i < $len); $i++) {
        $_ = $c = substr($lock, $i, 1);
        if (/[\(\)\&\|\!]/) {
            if ($word ne "") {
                $word = &visibleCanonicalizeWord($me, $word);
                $expr .= $word;
            }
            $expr .= $c;
            $word = "";
        } else {
            $word .= $c;
        }
    }
    if ($word ne "") {
        $expr .= &visibleCanonicalizeWord($me, $word);
    }
    $objects[$id]{"lock"} = $expr;
    return 1;
}

sub setProp
{
    my($me, $arg, $arg1, $arg2) = @_;
    # set currprop to 0 or <=maxprop
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    $arg2 = "0" if ($arg2 eq "");
    $arg2 = abs($arg2); # only positive values allowed
    my $id = &setField($me, $arg, $arg1, $arg2,
        "currprop", "Property");
    # ensure currprop is never greater than abs value of maxprop
    my $y = abs($objects[$id]{"maxprop"});
    $arg2 = ($arg2, $y)[$arg2 > $y];
    $objects[$id]{"currprop"}=$arg2;
    # set the property description debug doesnt work for rain
    if ($objects[$id]{"description$arg2"} ne "") {
        $objects[$id]{"description"}=$objects[$id]{"description$arg2"};
    } else { # supports things like rain that have no prop 0 desc
        $objects[$id]{"description"}=""; #debug maybe this sorts out rain
    }
    return 1;
}

sub setPropDesc
{
    my ($id,$prop) = @_;
    $prop = ($prop, 0)[$prop < 0]; # min 0
    my $y = abs($objects[$id]{"maxprop"});
    $prop = ($prop, $y)[$prop > $y]; # max y
    $objects[$id]{"currprop"}=$prop;
    # set the property description debug doesnt work for rain
    if ($objects[$id]{"description$prop"} ne "") {
        $objects[$id]{"description"}=$objects[$id]{"description$prop"};
    } else {
        $objects[$id]{"description"}=""; #debug maybe this sorts out rain
    }
    return 1;
}

sub sign
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my($id);
    if (substr($arg1, 0, 1) ne "#") {
        $id = &findContents($me, $arg1);
        if ($id == $none) {
            $id = &findContents(
                $objects[$me]{"location"}, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    }
    if (length($arg2) > 256) {
        &tellPlayer($me,
            "Signatures are limited to 256 characters apiece. Please sign again (briefly). Sorry for the inconvenience.");
        return;
    }
    if (!(($objects[$id]{"flags"} & $book) &&
        ($objects[$id]{"type"} == $thing))) {
        &tellPlayer($me, "You can't sign that!");
        return $none;
    }
    if ($objects[$id]{"flags"} & $once) {
        #If the once flag is set, remove all
        #previous signatures by this person.
        my($name) = quotemeta($objects[$me]{"name"});
        $objects[$id]{"description"} =~ s/\r\n$name: [^\r\n]*\r\n/\r\n/g;
        $objects[$id]{"description"} =~ s/\r\n$name: [^\r\n]*$//g;
    }
    $objects[$id]{"description"} .= "\r\n" .
        $objects[$me]{"name"} . ": " . $arg2;
    &tellPlayer($me, $objects[$id]{"name"} . " signed.");
    &tellRoom($objects[$me]{"location"}, $me,
        playerName($me) .
        " adds a signature to " . $objects[$id]{"name"} . ".");
    return 1;
}

sub unsign
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my($id);
    if (substr($arg1, 0, 1) ne "#") {
        $id = &findContents($me, $arg1);
        if ($id == $none) {
            $id = &findContents(
                $objects[$me]{"location"}, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    } else {
        if (!(($objects[$id]{"flags"} & $book) &&
            ($objects[$id]{"type"} == $thing))) {
            &tellPlayer($me, "That's not a book!");
            return;
        }
        my($name) = quotemeta($objects[$me]{"name"});
        # No more global unsign -- take off the g
        $objects[$id]{"description"} =~ s/\r\n$name: [^\r\n]*\r\n/\r\n/;
        $objects[$id]{"description"} =~ s/\r\n$name: [^\r\n]*$//;
        &tellPlayer($me, $objects[$id]{"name"} . " unsigned.");
    }
    return 1;
}

sub targetObject
{
    # process arguments in to an id for some mud_functions
    my ($me,$arg1,$arg2,$fnArg1,$fnArg2) = @_;
    my $id=$none;
    my $word;
    if ($fnArg1 eq "first") { # test noun1
        $arg1=$arg1;
    } elsif ($fnArg1 eq "second") { # test noun2
        $arg1=$arg2;
    } elsif ($fnArg1 ne "null") { # test obj if not null
        $arg1 = $fnArg1; # use function arg1 if set
        $id=findObject($arg1,,$thing); # find the object id
    }
    if ($id==$none) {
        $word=visibleCanonicalizeWord($me, $arg1);
    }
    if (substr($word,0,1) eq "#") {
        $id = int(substr($word,1));
        $id = &idBounds($id);
    }
    return $id;
}

sub visibleCanonicalizeWord
{
    my($me, $word) = @_;
    my($id);
    $word =~ s/\s+$//;
    $word =~ s/^\s+//;
    if ($word eq "") {
        return $word;
    }
    $word = &canonicalizeWord($me, $word);
    
    # Additional canonicalization
    $id = &findContents($me, $word);
    if (($id != $none) && (!($objects[$id]{"flags"} & $dark)) && (!($objects[$id]{"flags"} & $destroyed))) {
        $word = "#" . $id;
    } else {
        $id = &findContents(
            $objects[$me]{"location"}, $word);
        # debug if an object is dark or destroyed it is not visible
        if (($id != $none) && (!($objects[$id]{"flags"} & $dark)) && (!($objects[$id]{"flags"} & $destroyed))) {
            $word = "#" . $id;
        }
    }
    return $word;
}
    
sub setField
{
    my($me, $arg, $arg1, $arg2, $field, $name) = @_;
    my($id);
    if (substr($arg1, 0, 1) ne "#") {
        $id = &findContents($me, $arg1);
        if ($id == $none) {
            $id = &findContents(
                $objects[$me]{"location"}, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "You can't see that here.");
        return $none;
    } else {
        if (($objects[$id]{"owner"} != $me) && (!&wizardTest($me))) {
            &tellPlayer($me, "That doesn't belong to you!");
            return $none;
        } else {
            $objects[$id]{$field} = $arg2;
            if ($arg2 eq "") {
                &tellPlayer($me, $name . " cleared.");
            } else {
                &tellPlayer($me, $name . " set.");
            }
        }
    }
    return $id;
}

sub page
{
    my($me, $arg, $arg1, $arg2) = @_;
    my ($id);
    if (substr($arg1, 0, 1) ne "#") {
        my($n);
        $n = $arg1;
        $n =~ tr/A-Z/a-z/;
        if (!exists($playerIds{$n})) {
            &tellPlayer($me, "There is no such player.");
            return;
        }
        $id = $playerIds{$n};
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "That is not a valid player.");
        return;
    }
    if ($objects[$id]{"type"} != $player) {
        &tellPlayer($me, "That is not a valid player.");
        return;
    }
    if (($objects[$id]{"activeFd"} == $none)) {
        &tellPlayer($me, "That player is not logged in.");
        return;
    }
    if ($arg2 eq "") {
        &tellPlayer($id, playerName($me) .
            " is looking for you in " .
            $objects[$objects[$me]{"location"}]{"name"} . ".");
        &tellPlayer($me, "You paged " . $objects[$id]{"name"} . ".");
    } else {
        &tellPlayer($id, playerName($me) . " pages: " . $arg2);
        &tellPlayer($me, "You paged " . playerName($id) . ": " . $arg2);
    }
    return 1;
}

sub boot
{
    my($me, $arg, $arg1, $arg2) = @_;
    my ($id);
    if (!&wizardTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    if (substr($arg, 0, 1) ne "#") {
        my($n);
        $n = $arg;
        $n =~ tr/A-Z/a-z/;
        if (!exists($playerIds{$n})) {
            &tellPlayer($me, "There is no such player.");
            return;
        }
        $id = $playerIds{$n};
    } else {
        $id = substr($arg, 1);
    }
    if ($objects[$id]{"type"} != $player) {
        &tellPlayer($me, "That is not a valid player.");
        return;
    }
    if ($objects[$id]{"activeFd"} == $none) {
        &tellPlayer($me, "That player is not logged in.");
        return;
    }
    
    if ($id == 1) {
        &tellPlayer($me, "Player #1 cannot be booted.");
        return;
    }
    &forceClosePlayer($id, 1);
    &tellPlayer($me, "Booted.");
    return 1;
}

sub name
{
    my($me, $arg, $arg1, $arg2) = @_;
    my ($id);
    if (substr($arg1, 0, 1) ne "#") {
        $id = &findContents($me, $arg1);
        if ($id == $none) {
            $id = &findContents(
                $objects[$me]{"location"}, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    } else {
        if (($objects[$id]{"owner"} != $me) && (!&wizardTest($me))) {
            &tellPlayer($me, "That doesn't belong to you!");
        } else {
            if ($objects[$id]{"type"} == $player) {
                if (!&wizardTest($me)) {
                    &tellPlayer($me, "Only an arch-wizard can do that.");
                    return;
                }
                my($n);
                $n = $arg2;
                $n =~ tr/A-Z/a-z/;
                $n =~ s/\s+//g;
                if (exists($playerIds{$n})) {
                    &tellPlayer($me, "That name is already taken.");
                    return;
                }
                my($n2);
                $n2 = $objects[$id]{"name"};
                $n2 =~ tr/A-Z/a-z/;
                delete $playerIds{$n2};
                $playerIds{$n} = $id;
            }
            if ($objects[$id]{"type"} == $topic) {
                if ($arg2 =~ / ,/) {
                    &tellPlayer($me, "Commas and spaces " .
                        "are not allowed in " .
                        "topic names.");
                    return;
                }
            }
            $objects[$id]{"name"} = $arg2;
            &tellPlayer($me, "Name set.");
        }
    }
    return 1;
}

sub chown
{
    my($me, $arg, $arg1, $arg2) = @_;
    my ($id);
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    if (substr($arg1, 0, 1) ne "#") {
        $id = &findContents($me, $arg1);
        if ($id == $none) {
            $id = &findContents(
                $objects[$me]{"location"}, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    } else {
        if (($objects[$id]{"owner"} != $me) && (!&wizardTest($me))) {
            &tellPlayer($me, "That doesn't belong to you!");
        } else {
            my($arg2Id);
            if (substr($arg2, 0, 1) eq '#') {
                $arg2Id = substr($arg2, 1);
            } else {
                my($n);
                $n = $arg2;
                $n =~ tr/A-Z/a-z/;
                $arg2Id = $playerIds{$n};
            }
            if ($objects[$arg2Id]{"type"} != $player) {
                    &tellPlayer($me, $arg2 . " is not a valid player.");
                    return;
            }
            $objects[$id]{"owner"} = $arg2Id;
            &tellPlayer($me, "Owner set.");
            &tellPlayer($arg2Id, playerName($me) .
                " has given you #" . $id . " (" .
                $objects[$id]{"name"} . ").");
        }
    }
    return 1;
}

sub whisper
{
    my($me, $arg, $arg1, $arg2) = @_;

    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if ($objects[$me]{"flags"} & $dumb) { # cant speak
        &tellPlayer($me, "You can't say anything, you're dumb.");
        return 0;
    }
    $arg2 = TH::urlshort_check( $arg2 );
    if ( $arg2 =~ /\b$TH::RELAY_OFFENSIVE_RE\b/i )
    {
        $arg2='<censored>';
    }
    elsif ( $arg =~ /\b$TH::RELAY_PERSONAL_RE\b/i )
    {
        $arg2='<personal>';
    }

    my($id);
    if (($arg1 eq "") || ($arg2 eq "")) {
        &tellPlayer($me, "Syntax: .person message, .person,person,person message, or whisper person = message");
        return;
    }
    my(@ids) = &getIdsSpokenTo($me, $arg1);
    if (!int(@ids)) {
        # Nobody passed muster
        return;
    }
    my($names, $lnames);
    $names = " ";
    for (my $i = 0; ($i < int(@ids)); $i++) {
        if ($i > 0) {
            if ($i == (int(@ids) - 1)) {
                $names .= " and ";
            } else {
                $names .= ", ";
            }
        }
        $names .= ucfirst($objects[$ids[$i]]{"name"});
    }
    $names .= " ";
    my(%ids);
    for $id (@ids) {
        if (exists($ids{$id})) {
            next;
        }
        $ids{$id} = 1;
        my $n = ucfirst($objects[$id]{"name"});
        $lnames = $names;
        $lnames =~ s/ $n([,\.\ ])/ you /;
        my $speaker = playerName($me);
        $speaker = "Someone" if ($objects[$me]{"flags"} & $dark);
        &tellPlayer($id, $speaker . " tells$lnames\"" . $arg2 . "\"") if (!($objects[$id]{"flags"} & $deaf));
    }
#    &tellPlayer($me, "You whisper \"" . $arg2 . "\" to$names");
    return 1;
}

sub timeFormat
{
    my($secs, $output) = @_;
    if ($secs < 60) {
        $output = int($secs) . "s";
    } elsif ($secs < 3600) {
        $output = int($secs / 60) . "m";
    } elsif ($secs < 86400) {
        $output = int($secs / 3600) . "h";
    } else {
        $output = int($secs / 86400) . "d";
    }
    return $output;
}

sub emote
{
    my($me, $arg, $arg1, $arg2) = @_;
    $arg =~ s/^\s+//;
    $_ = $arg;
    if (!(/^[,\']/)) {
        $arg = " " . $arg;
    }
    my $speaker = playerName($me);
    $speaker = "Someone" if ($objects[$me]{"flags"} & $dark);
    &tellRoom($objects[$me]{"location"}, $none, $speaker . $arg);
    return 1;
}

sub emit
{
    my($me, $arg, $arg1, $arg2) = @_;
    $arg =~ s/^\s+//;
    if (!$allowEmit) {
        &tellPlayer($me, "Sorry, that command is forbidden.");
        return;
    }
    if ($arg eq "") {
        &tellPlayer($me, "Syntax: \@emit message");
    } else {
        # Do not allow anyone to emit the topic prefix.
        if (substr($arg, 0, length($topicPrefix)) eq $topicPrefix) {
            $arg = ">$arg";
        }
        &tellRoom($objects[$me]{"location"}, $none, $arg, $objects[$me]{"name"})
    }
    return 1;
}

sub say
{
    my($me, $arg, $arg1, $arg2, $to) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if ($objects[$me]{"flags"} & $dumb) { # cant speak
        &tellPlayer($me, "You can't say anything, you're dumb.");
        return 0;
    }

    $arg =~ s/^\s+//;
    $arg = TH::urlshort_check( $arg );
    if ( $arg =~ /\b$TH::RELAY_OFFENSIVE_RE\b/i )
    {
        $arg='<censored>';
    }
    elsif ( $arg =~ /\b$TH::RELAY_PERSONAL_RE\b/i )
    {
        $arg='<personal>';
    }

    if ($to ne "") {
        my(@ids) = &getIdsSpokenTo($me, $to);
        if (!int(@ids)) {
            return;
        }
        my($names, $i);
        for ($i = 0; ($i < int(@ids)); $i++) {
            if ($i > 0) {
                if ($i == (int(@ids) - 1)) {
                    $names .= " and ";
                } else {
                    $names .= ", ";
                }
            }
            $names .= ucfirst($objects[$ids[$i]]{"name"});
        }
        $to = " to $names,";
    }
#debug no need to tell player what they said
#    &tellPlayer($me, "You say$to \"" . $arg . "\"");
    if ($objects[$me]{"flags"} & $dark) {
        &tellRoom($objects[$me]{"location"}, $me, "Someone says$to \"" . $arg . "\"");
    } else {
        &tellRoom($objects[$me]{"location"}, $me, playerName($me) .
            " says$to \"" . $arg . "\"");
    }
    return 1;
}

sub getIdsSpokenTo
{
    my($me, $arg1) = @_;
    my(@refs) = split(/,/, $arg1);
    my(@ids,$id);
    my($i);
    for $i (@refs) {
        $i = &canonicalizeWord($me, $i);
        if ($i =~ /^#(.*)/) {
            $id = &idBounds($1);
        } else {
            $i =~ tr/A-Z/a-z/;
            if (!exists($playerIds{$i})) {
                $id = &findContents(
                    $objects[$me]{"location"}, $i, $player);
                if ($id == $none) {
                    &tellPlayer($me, "Sorry, there is no " .
                        "player named $i.\n");
                    next;
                }
            } else {
                $id = $playerIds{$i};
            }
        }
        if (($objects[$id]{"activeFd"} == $none))
        {
            &tellPlayer($me, "$i is not logged in.");
            next;
        }
        if ($objects[$id]{"type"} != $player) {
            &tellPlayer($me, "$i is an inanimate object.");
            next;
        }
        push @ids, $id;
    }
    return @ids;
}

sub success
{
    my($me, $id, $default, $odefault) = @_;
    if ($objects[$id]{"success"} ne "") {
        &tellPlayer($me, &substitute($me, $objects[$id]{"success"}));
    } else {
        if ($default ne "") {
            &tellPlayer($me, $default);
        }
    }
    if ($objects[$id]{"osuccess"} ne "") {
        &tellRoom($objects[$me]{"location"}, $me, playerName($me) .
            " " . &substitute($me, $objects[$id]{"osuccess"}));
    } else {
        if ($odefault ne "") {
            &tellRoom($objects[$me]{"location"}, $me, $odefault);
        }
    }
    return 1;
}

sub fail
{
    my($me, $id, $default, $odefault) = @_;
    if ($objects[$id]{"fail"} ne "") {
        &tellPlayer($me, &substitute($me, $objects[$id]{"fail"}));
    } else {
        if ($default ne "") {
            &tellPlayer($me, $default);
        }
    }
    if ($objects[$id]{"ofail"} ne "") {
        &tellRoom($objects[$me]{"location"}, $me, playerName($me) .
            " " . &substitute($me, $objects[$id]{"ofail"}));
    } else {
        if ($odefault ne "") {
            &tellRoom($objects[$me]{"location"}, $me, $odefault);
        }
    }
    return 1;
}

sub testLock
{
    my($me, $id) = @_;
    my($lock, $i, $word, $expr);
    my(@words);
    $lock = $objects[$id]{"lock"};
    $word = "";
    $expr = "";
    my($len);
    $len = length($lock);
    for ($i = 0; ($i < $len); $i++) {
        my($c);
        $_ = $c = substr($lock, $i, 1);
        if (/[\(\)\&\|\!]/) {
            $word = &canonicalizeWord($me, $word);
            if ($word ne "") {
                $expr .= &lockEvalWord($me, $word);
            }
            $expr .= $c;
            $word = "";
        } else {
            $word .= $c;
        }
    }
    $word = &canonicalizeWord($me, $word);
    if ($word ne "") {
        if ($word eq "empty") {
            # is the player carrying nothing?
            if ($objects[$me]{"contents"} eq "") {
                $expr .= "1"; # empty inventory
            } else {
                $expr .= "0";
            }
        } else {
            $expr .= &lockEvalWord($me, $word);
        }
    }

    # No lock

    if (!length($expr)) {
        return 1;
    }

    # Take advantage of Perl. We know there is nothing
    # here other than (, ), &, |, !, 1, and 0.

    return eval($expr);
}

sub canonicalizeWord
{
    my($me, $word) = @_;
    $word =~ s/^\s+//g;
    $word =~ s/\s+$//g;
    if ($word eq "") {
        return $word; # nothing to do
    } elsif (($word eq "me") || # all refer to me
        ($objects[$me]{"name"} eq $word) ||
        ($objects[$me]{"class"} eq $word)) {
        $word = "#" . $me;
    } elsif ($word eq "here") {
        $word = "#" . $objects[$me]{"location"};
    } elsif (substr($word, 0, 1) eq "*") {
        my($name);
        ($name = substr($word, 1)) =~ tr/A-Z/a-z/;
        if ((&targetPlayer($me, $name) != $none)) {
            $word = "#" . $playerIds{$name};
        }
    }
    return $word;
}

sub lockEvalWord
{
    my($me, $word) = @_;

    $word =~ s/^\s+//g;
    $word =~ s/\s+$//g;

    if ($word eq "") {
        return 1;
    }
    if (("#" . $me) eq $word) {
        return 1;
    }
    my $id = &findContents($me, $word);
    if ($id != $none) { # only prop 0 can unlock
        if (($objects[$id]{"currprop"}==0) ||
            ($objects[$id]{"currprop"} eq "")) {
            return 1;
        }
    }
    return 0;
}

sub substitute
{
    my($me, $arg) = @_;
    my($s, $p, $o, $n, $a, $r, $uname);
    $_ = $arg;
    if (!/%/) {
        return $arg;
    }
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $s = playerName($me);
    } elsif ($objects[$me]{"flags"} & $female) {
        $s = "she";
    } elsif ($objects[$me]{"flags"} & $male) {
        $s = "he";
    } else {
        $s = "it";
    }
    $arg =~ s/\%s/$s/ge;
    $n = playerName($me);
    $arg =~ s/\%n/$n/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $p = $objects[$me]{"name"} . "'s";
    } elsif ($objects[$me]{"flags"} & $female) {
        $p = "her";
    } elsif ($objects[$me]{"flags"} & $male) {
        $p = "his";
    } else {
        $p = "its";
    }
    $arg =~ s/\%p/$p/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $a = playerName($me) . "'s";
    } elsif ($objects[$me]{"flags"} & $female) {
        $a = "hers";
    } elsif ($objects[$me]{"flags"} & $male) {
        $a = "his";
    } else {
        $a = "its";
    }
    $arg =~ s/\%a/$a/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $o = playerName($me);
    } elsif ($objects[$me]{"flags"} & $female) {
        $o = "her";
    } elsif ($objects[$me]{"flags"} & $male) {
        $o = "him";
    } else {
        $o = "it";
    }
    $arg =~ s/\%o/$o/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $r = playerName($me);
    } elsif ($objects[$me]{"flags"} & $female) {
        $r = "herself";
    } elsif ($objects[$me]{"flags"} & $male) {
        $r = "himself";
    } else {
        $r = "itself";
    }
    $arg =~ s/\%r/$r/ge;
    
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $s = playerName($me);
    } elsif ($objects[$me]{"flags"} & $female) {
        $s = "She";
    } elsif ($objects[$me]{"flags"} & $male) {
        $s = "He";
    } else {
        $s = "It";
    }
    $arg =~ s/\%S/$s/ge;
    $n = playerName($me);
    $arg =~ s/\%N/$n/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $s = $uname . "'s";
    } elsif ($objects[$me]{"flags"} & $female) {
        $p = "Her";
    } elsif ($objects[$me]{"flags"} & $male) {
        $p = "His";
    } else {
        $p = "Its";
    }
    $arg =~ s/\%P/$p/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $a = playerName($me) . "'s";
    } elsif ($objects[$me]{"flags"} & $female) {
        $a = "Hers";
    } elsif ($objects[$me]{"flags"} & $male) {
        $a = "His";
    } else {
        $a = "Its";
    }
    $arg =~ s/\%A/$a/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $o = playerName($me);
    } elsif ($objects[$me]{"flags"} & $female) {
        $o = "Her";
    } elsif ($objects[$me]{"flags"} & $male) {
        $o = "Him";
    } else {
        $o = "It";
    }
    $arg =~ s/\%O/$o/ge;
    if (($objects[$me]{"flags"} & $herm) == $herm) {
        $r = playerName($me);
    } elsif ($objects[$me]{"flags"} & $female) {
        $r = "Herself";
    } elsif ($objects[$me]{"flags"} & $male) {
        $r = "Himself";
    } else {
        $r = "Itself";
    }
    $arg =~ s/\%R/$r/ge;

    $arg =~ s/\%\%/\%/g;
    return $arg;
}

sub idBounds
{
    my($id) = @_;
    if ($id > $#objects) {
        $id = $none;
    }
    if ($id < 0) {
        $id = $none;
    }
    return $id;
}
    
sub findContents
{
    my ($container, $arg, $type, $after) = @_;
    $arg =~ tr/A-Z/a-z/;
    return $none if ($arg eq ""); # nothing to find
    my @list = split(/,/, $objects[$container]{"contents"});
    if ($after ne "") { # throw away everything upto and including $after
        while (my $c=shift(@list)) {
            last if ($c eq $after);
        }
    }
    my($e);
    if (substr($arg, 0, 1) eq "#") {
        foreach $e (@list) {
            if (("#" . $e) eq $arg) {
                if ((!$type) ||
                    ($objects[$e]{"type"} == $type))
                {
                    return $e;
                }
            }
        }
        return $none;
    }
#First an exact match
    foreach $e (@list) {
        my($name, $class);
        $name = $objects[$e]{"name"}; # test object name
        $class = $objects[$e]{"class"}; # test object class
        $name =~ tr/A-Z/a-z/;
        $class =~ tr/A-Z/a-z/;
        if (($name eq $arg) || ($class eq $arg) || (($arg eq "treasure") && &isTreasure($e))) { # name or class match arg or special treasure
            if ((!$type) ||
                ($objects[$e]{"type"} == $type))
            {
                return $e;
            }
        }
        #TinyMUD semicolon stuff
        if ($objects[$e]{"type"} == $exit) {
            my(@elist);
            my($f);
            $f = $objects[$e]{"name"};
            $f =~ s/\|.*//; # remove any alternate exits after the first one for randoms
            @elist = split(/;/, $f);
            foreach $f (@elist) {
                $f =~ tr/A-Z/a-z/;
                if ($f eq $arg) {
                    if ((!$type) ||
                        ($objects[$e]{"type"} == $type))
                    {
                        return $e;
                    }
                }
            }
        }
    }
#Okay, now an inexact match - not supported in MUD1 nor here
#    foreach $e (@list) {
#        my($name, $class);
#        next if $objects[$e]{"type"} == $exit; # debug dont do inexact matches on exits
#        $name = $objects[$e]{"name"}; # test object name
#        $class = $objects[$e]{"class"}; # test object class
#        $name =~ tr/A-Z/a-z/;
#        $class =~ tr/A-Z/a-z/;
#        if ((substr($name, 0, length($arg)) eq $arg) ||
#            (substr($class, 0, length($arg)) eq $arg)) {
#            if ((!$type) ||
#                ($objects[$e]{"type"} == $type))
#            {
#                return $e;
#            }
#        }
#        #TinyMUD semicolon stuff
#        #debug remove this as we skip inexact exits above
#        if ($objects[$e]{"type"} == $exit) {
#            my(@elist);
#            my($f);
#            $f = $objects[$e]{"name"};
#            $f =~ s/\|.*//; # remove any alternate exits after the first one for randoms
#            @elist = split(/;/, $f);
#            foreach $f (@elist) {
#                $f =~ tr/A-Z/a-z/;
#                if (substr($f, 0, length($arg)) eq $arg) {
#                    if ((!$type) ||
#                        ($objects[$e]{"type"} == $type))
#                    {
#                        return $e;
#                    }
#                }
#            }
#        }
#    }
    return $none;
}

sub removeContents
{
    my($container, $id) = @_;
    my(@list);
    @list = split(/,/, $objects[$container]{"contents"});
    $objects[$container]{"contents"} = "";
    my($e);
    foreach $e (@list) {
        if ($e ne $id) {
            &addContents($container, $e);
        }
    }
    return 1;
}

sub closePlayer
{
    my($id, $gohome, $quiet) = @_;
    my($i);
    unfollow($id);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        if (($activeFds[$i]{"fd"} ne $none) &&
            ($activeFds[$i]{"id"} == $id))
        {
            my $mud = $TH::data->{mud};
            my $conn = $activeFds[$i]{"fd"};
            my $user = &TH::get_user( $conn );
            &TH::clear_readline($conn);
            if (defined $objects[$id]{"autowho"}) {
                delete $objects[$id]{"autowho"};
                &TH::kill_timer(\&mud_autowho, $conn->{"fd"});
            }
            &mud_tellActiveFd($i,'Goodbye!');
            delete $mud->{users}->{$user};
            delete $conn->{interrupt_sub};
            delete $conn->{in_mud};
            &mud_closeActiveFd($i);
            last;
        }
    }
    $objects[$id]{"activeFd"} = $none;
    if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand)) {
        if ($quiet) {
            &tellWizards( ucfirst($objects[$id]{"name"}) .
                " has just passed on."); # always tell a wiz
        } else {
            &tellRoom($objects[$id]{"location"}, $none, ucfirst($objects[$id]{"name"}) .
                " has just passed on.");
            &tellWizards( ucfirst($objects[$id]{"name"}) .
                " has just passed on.", $objects[$id]{"location"});
        }
    }
    if ($gohome) {
        &sendHome($id,1); # send home quietly
        #debug stop sending player home, exit the game and force drop all items instead
        &removeContents($objects[$id]{"location"}, $id);
        $objects[$id]{"location"}=$nowhere; #debug send the quit player to nowhere
    }
    $objects[$id]{"off"} = $now;
    return $death;
}

sub forceClosePlayer # needed for boot and unintended disconnect
{
    my($id, $gohome, $quiet) = @_;
    my($i);
    unfollow($id);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        if (($activeFds[$i]{"fd"} ne $none) &&
            ($activeFds[$i]{"id"} == $id))
        {
            my $mud = $TH::data->{mud};
            my $conn = $activeFds[$i]{"fd"};
            my $user = &TH::get_user( $conn );
            my $fd = $conn->{fd};
            if (defined $objects[$id]{"autowho"}) {
                delete $objects[$id]{"autowho"};
                &TH::kill_timer(\&mud_autowho, $fd);
            }
            mud_tellActiveFd($i,'Goodbye!',1); # exit and dont repaint prompt
            delete $mud->{users}->{$user};
            delete $conn->{interrupt_sub};
            delete $conn->{in_mud};
            &TH::clear_readline($conn);
            &mud_closeActiveFd($i);
            #debug
            # here on lies some really shitty code that forces a quit copied from th_relay.pm
            # it seems like a kludge to me but I couldnt get it to work any other way easily
            &TH::read_flush($conn->{fd});
            return if !defined $conn->{fd};

            delete $conn->{readline_no_cr};

            &TH::kill_timer( \&TH::print_delay_timer, 0 );
            $conn->{outbuf} = '';
            $conn->{outpos} = 0;
            delete $TH::print_delay_buffer->{ $fd };
            delete $TH::print_delay->{ $fd };

            if ( $conn->{interrupt_sub} )
            {
                delete $conn->{interrupt_sub};
            }
            delete $conn->{resize_hook};

            $conn->{want} = 0;
            delete $conn->{in_readline};
            delete $conn->{readchar_timeout};
            delete $conn->{in_readchar};
            delete $conn->{func_next};
            $conn->{handle_since_input} = 0;
            
                $conn->{func} = \&TH::do_shell;

                foreach my $timer ( @$TH::timerlist )
                {
                    next if ! $timer->{fd};
                    next if $timer->{fd} != $fd;
                    next if $timer->{noctrlc};
                    delete $timer->{fn};
                }
            last;
        }
    }
    $objects[$id]{"activeFd"} = $none;
    if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand)) {
        if ($quiet) {
            &tellWizards( ucfirst($objects[$id]{"name"}) .
                " has just passed on."); # always tell a wiz
        } else {
            &tellRoom($objects[$id]{"location"}, $none, ucfirst($objects[$id]{"name"}) .
                " has just passed on.");
            &tellWizards( ucfirst($objects[$id]{"name"}) .
                " has just passed on.", $objects[$id]{"location"});
        }

    }
    if ($gohome) {
        &sendHome($id, 1); #debug stop sending player home, exit the game and force drop all items instead
        &removeContents($objects[$id]{"location"}, $id);
        $objects[$id]{"location"}=$nowhere; #debug send the quit player to nowhere
    }
    $objects[$id]{"off"} = $now;
    return 1;
}

sub do_mud_quit
{
    my ( $conn ) = @_;
    my ($i, $id);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        if ($activeFds[$i]{"fd"} eq $conn) {
            closePlayer( $activeFds[$i]{"id"},1 );
            last;
        }
    }
    
    return 1;
}

sub dump
{
    my($me, $arg, $arg1, $arg2) = @_;
    
    if ($me != $none) {
        if (!&wizardTest($me)) {
            &tellPlayer($me, "Sorry, only a wizard can do that.");
            return;
        }
    }
    if ($me != $none) {
        &tellPlayer($me, "Dumping the database...");
    }
    if ($arg eq "all") {
        &TH::xlog("Mud: dump all");
        return 0 if !(dump_db($me));
        return 0 if !(dump_pf($me));
    } else {
        &TH::xlog("Mud: dump personas");
        return 0 if !(dump_pf($me));
    }
    $lastdump = $now;
    if ($me != $none) {
        &tellPlayer($me, "Dump complete.");
    }
    &TH::xlog("Mud: dump complete");
    return 1;
}

sub dump_db
{
    my ($me) = @_;
    if (!open(OUT, ">$dbFile.tmp")) {
        if ($me != $none) {
            &tellPlayer($me,
                "Unable to write to $dbFile.tmp\n");
            &TH::xlog("Mud: Unable to write to $dbFile.tmp");
        }
        return 0;
    }
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
        # Send stale topics home, if they aren't already home
        if ($objects[$i]{"type"} == $topic) {
            if ($objects[$i]{"location"} != $objects[$i]{"home"}) {
                if ($now - $objects[$i]{"lastuse"} >
                    $topicStaleTime) {
                    &sendHome($i);
                }
            }
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
        &tellWizards("Warning: couldn't complete save to $dbFile.tmp!");
        &TH::xlog("Mud: couldn't complete save to $dbFile.tmp!");
        # Don't try again right away
        $lastdump = $now;
        return 0;
    }
    unlink("$dbFile");
    rename "$dbFile.tmp", "$dbFile";
    return 1;
}

sub dump_pf
{
    my ($me) = @_;

    my $dbFile = $personaFile;
    if (!open(OUT, ">$dbFile.tmp")) {
        if ($me != $none) {
            &tellPlayer($me,
                "Unable to write to $dbFile.tmp\n");
            &TH::xlog("Mud: Unable to write to $dbFile.tmp");
        }
        return 0;
    }
    my($i);
    my $now = time;
    # The database format changed with version 2.1,
    # not whatever this release may be (I doubt there will be
    # a need for further changes, hurrah -- upwards compatible)
    print OUT "2.1\n";
    # Oh, this is achingly beautiful
    for ($i = 0; ($i <= $#objects); $i++) {
        # Don't save recycled objects
        if ($objects[$i]{"type"} != $player) {
            next; # only dump players to pf
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
            if ($attribute eq "contents") {
                # do not write out inventory.
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
        &tellWizards(0, "Warning: couldn't complete save to $dbFile.tmp!");
        &TH::xlog("Mud: couldn't complete save to $dbFile.tmp!");
        # Don't try again right away
        $lastdump = $now;
        return 0;
    }
    unlink("$dbFile");
    rename "$dbFile.tmp", "$dbFile";
    return 1;
}

sub wizardTest
{
    my($me) = @_;
    # Object #1 is always a wizard
    if ($me == 1) {
        return 1;
    }
    # How about ordinary wizards?
    if ($objects[$me]{"flags"} & $wizard) {
        return 1;
    } else {
        return 0;
    }
}

sub shout
{
    my($me, $arg, $arg1, $arg2) = @_;
#    if (!&wizardTest($me)) {
#        &tellPlayer($me, "Only a wizard can do that.");
#        return;
#    }
    if ($objects[$me]{"flags"} & $dumb) {
        &tellPlayer($me,"You can't, you're dumb!");
        return 1;
    }
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    $arg =~ s/^\s+//;
    my($o);
    foreach $o (@activeFds) {
        if ($o->{"id"}!=$none) {
            next if ($objects[$o->{"id"}]{"flags"} & $deaf); # skip if deaf
            if (($objects[$o->{"id"}]{"location"} eq $objects[$me]{"location"}) || &builderTest($me) || &builderTest($o->{"id"})) {
                if ($objects[$me]{"flags"} & $dark) { # invisible wiz
                    &tellPlayer($o->{"id"},"Someone shouts \"" . $arg . "\"");
                } else {
                    &tellPlayer($o->{"id"},
                        playerName($me) . " shouts \"" . $arg . "\"");
                }
            } else {
                if ($objects[$me]{"flags"} & $dark) { # invisible
                    &tellPlayer($o->{"id"},"Someone shouts \"" . $arg . "\"");
                } else {
                    my $sex = ($objects[$me]{"flags"} & $female) ? "female" : "male";
                    &tellPlayer($o->{"id"}, "A " . $sex . " voice in the distance shouts \"" . $arg . "\"");
                }
            }
        }
    }
    return 1;
}

sub tellElsewhere
{
    my($me, $arg, $arg1, $arg2) = @_;
    # broadcast message to all except orginator
    $arg =~ s/^\s+//;
    my($o);
    foreach $o (@activeFds) {
        if (($o->{"id"} != $none) && ($objects[$o->{"id"}]{"location"} ne $objects[$me]{"location"})) {
                &tellPlayer($o->{"id"},$arg) unless ($o->{"id"}==$me);
        }
    }
    return 1;
}

sub joinTopic
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    &joinTopicBody($me, $arg, $arg1, $arg2, 1);
    return 1;
}

sub leaveTopic
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    &joinTopicBody($me, $arg, $arg1, $arg2, 0);
    return 1;
}

sub joinTopicBody
{
    my($me, $arg, $arg1, $arg2, $join) = @_;
    if ($arg =~ /^all$/i) {
        $objects[$me]{"topicdefault"} = $join;
        $objects[$me]{"topics"} = "";
        if ($join) {
            &tellPlayer($me, "Joining all topics.");
        } else {
            &tellPlayer($me, "Leaving all topics.");
        }
        return;
    }
    my($default);
    if (!exists($objects[$me]{"topicdefault"})) {
        $default = 1;
    } else {
        $default = $objects[$me]{"topicdefault"};
    }
    my(@topics) = split(/[ ,]+/, $arg);
    my($otopics) = $objects[$me]{"topics"};
    my(@otopics) = split(/,/, $otopics);
    my(%topics, $t);
    for $t (@otopics) {
        $topics{$t} = 1;
    }
    for $t (@topics) {
        my($id);
        $id = &findContents($objects[$me]{"location"}, $t, $topic);
        if ($id == -1) {
            $id = &findContents($me, $t, $topic);
            if ($id == -1) {
                &tellPlayer($me, "No topic $t.");
                next;
            }
        }
        my($tname) = $objects[$id]{"name"};
        if ($default == $join) {
            $topics{$tname} = 0;
        } else {
            $topics{$tname} = 1;
        }
    }
    @topics = ( );
    while (my ($key, $value) = each(%topics)) {
        if ($value) {
            push @topics, $key;
        }
    }
    $objects[$me]{"topics"} = join(',', @topics);
    &tellPlayer($me, "Topic list updated.");
    return 1;
}

sub tellPlayer
{
    my($who, $what) = @_;
    $what =~ s/\s+$//;
    # Filter annoyances out (apply gag filters).
    my($name, $gag);
    $name = $objects[$who]{"name"};
    $name = quotemeta($name);
    if (($objects[$who]{"gags"} =~ /^$name[,' ]/i) ||
        ($objects[$who]{"gags"} =~ / $name[,' ]/i))
    {
        # The player is not interested.
        return;
    }
    foreach $gag (split(/ /, $objects[$who]{"gags"})) {
        if ($gag ne "") {
            $gag = quotemeta($gag);
            if ($what =~ /^$gag[,' ]/i) {
                # The player is not interested.
                return;
            }
        }
    }
    if ($objects[$who]{"activeFd"} ne $none) {
        &mud_tellActiveFd($objects[$who]{"activeFd"}, $what);
    }
    return 1;
}

sub describe
{
    my($to, $what, $details) = @_;
    &describeBody(\&tellPlayer, $to, $to, $what, $details, 0);
    return 1;
}

sub describeBody
{
    my($output, $dest, $to, $what, $details) = @_;
    my($found);
    $found = 0;
    if ($details) {
        my($line);
        $line = $objects[$what]{"name"} . " #" . $what .
            " Owner: " .
            $objects[$objects[$what]{"owner"}]{"name"} .
            " Home: #" . int($objects[$what]{"home"});
        my($key, $val);
        while (($key, $val) = each(%flagsProper)) {
            if ($objects[$what]{"flags"} & $val) {
                $line .= " " . $key;
            }
        }
        &{$output}($dest, $line);
        $line="";
        if ($objects[$what]{"type"} == $player) {
            $line = "Score: " . int($objects[$what]{"score"}) . " ";
        }
        if (&builderTest($to) || ($objects[$what]{"owner"} == $to)) {
            if ($objects[$what]{"stamina"} >= 0) {
                $line .= "Stamina: " . $objects[$what]{"stamina"};
            }
            &{$output}($dest, $line) if (length($line)>5);
            $line = "";
            if ($objects[$what]{"currprop"} ne "") {
                $line .= "Currprop: " . $objects[$what]{"currprop"} . " ";
            }
            if ($objects[$what]{"maxprop"} ne "") {
                $line .= "Maxprop: " . $objects[$what]{"maxprop"} . " ";
            }
            &{$output}($dest, $line) if (length($line)>5);
            if ($objects[$what]{"fail"} ne "") {
                &{$output}($dest, "Fail: " . $objects[$what]{"fail"});
            }
            if ($objects[$what]{"ofail"} ne "") {
                &{$output}($dest, "Ofail: " . $objects[$what]{"ofail"});
            }
            if ($objects[$what]{"odrop"} ne "") {
                &{$output}($dest, "Odrop: " . $objects[$what]{"odrop"});
            }
            if ($objects[$what]{"success"} ne "") {
                &{$output}($dest, "Success: " . $objects[$what]{"success"});
            }
            if ($objects[$what]{"osuccess"} ne "") {
                &{$output}($dest, "Osuccess: " . $objects[$what]{"osuccess"});
            }
            if ($objects[$what]{"lock"} ne "") {
                &{$output}($dest, "Lock: " . $objects[$what]{"lock"});
            }
            if ($objects[$what]{"gags"} ne "") {
                &{$output}($dest, "Gags: " . $objects[$what]{"gags"});
            }
            if ($objects[$what]{"type"} == $player) {
                my($top);
                if (($objects[$what]{"topicdefault"}) ||
                    (!exists($objects[$what]
                        {"topicdefault"})))
                {
                    $top = "Topics: ALL, except: ";
                } else {
                    $top = "Topics: ";
                }
                my($tlist) = $objects[$what]{"topics"};
                if (length($tlist)) {
                    $top .= "$tlist";
                }
                &{$output}($dest, $top);
            }
        }
        &{$output}($dest, "Location: #" . int($objects[$what]{"location"}));
        if ((&builderTest($to)) || ($objects[$what]{"owner"} == $to)) {
            if ($objects[$what]{"type"} == $exit) {
                #debug this is never appearing - why?
                my($destination);
                $destination = int($objects[$what]{"action"}); # debug this could have multi choice in it
                if ($destination == $nowhere) {
                    &{$output}($dest, "Destination: nowhere");
                } elsif ($destination == $home) {
                    &{$output}($dest, "Destination: home");
                } else {
                    &{$output}($dest, "Destination: " . "#" . $objects[$what]{"action"});
                }
            }
        }
    } else {
        if ($objects[$what]{"type"} != $exit) {
            &{$output}($dest, playerName($what));
        }
    }
    if ($objects[$what]{"description"} eq "") {
        &{$output}($dest, "You see nothing special.");
    } else {
        &{$output}($dest, $objects[$what]{"description"});
    }
    my(@list);
    my($desc, $first, $e);
    @list = split(/,/, $objects[$what]{"contents"});
    $desc = "";
    $first = 1;
    if ($details || (!($objects[$what]{"flags"} & $dark))) {
        foreach $e (@list) {
            if (($details) && ($objects[$e]{"type"} != $exit)) {
                $found = 1;
                if ($first) {
                    $first = 0;
                } else {
                    $desc .= ", ";
                }
                $desc .= $objects[$e]{"name"} . " #" . $e;
            } else {
                if ($objects[$e]{"type"} == $thing) {
                    $found = 1;
                    if ($first) {
                        $first = 0;
                    } else {
                        $desc .= ", ";
                    }
                    $desc .= $objects[$e]{"name"};
                } elsif ($objects[$e]{"type"} == $player) {
                    &{$output}($dest, $desc) if ($desc);
                    $found = 1;
                    if ($first) {
                        $first = 0;
                    } else {
                        $desc .= ", ";
                    }
                    &{$output}($dest, $desc);
                    $desc="";
                }
            }
        }
    }
    if (!$found) {
        if ($objects[$what]{"type"} == $room) {
            if ($details || (!($objects[$what]{"flags"} & $dark))) {
                &{$output}($dest, "Contents: None");
            }
        }
    } else {
        if ($objects[$what]{"type"} == $player) {
            &{$output}($dest, "Carrying:");
        } else {
            &{$output}($dest, "Contents:");
        }
        &{$output}($dest, $desc);
    }
#debug move into seperate exits command
    $first = 1;
    $desc = "";
    $found = 0;
    if (($objects[$what]{"type"} == $room) && ($details)) {
        foreach $e (@list) {
            $found = 1;
            if (($objects[$e]{"type"} == $exit) &&
                (!($objects[$e]{"flags"} & $dark))) {
                if ($first) {
                    $first = 0;
                } else {
                    $desc .= ", ";
                }
                my(@foo) = split(/(;|\|)/,
                    $objects[$e]{"name"});
                $desc .= $foo[0] . " #$e";
            }
        }
        if (!$found) {
            &{$output}($dest, "Visible Exits: None");
        } else {
            &{$output}($dest, "Visible Exits:");
            &{$output}($dest, $desc);
        }
    }
    $found = 0;
    $first = 1;
    $desc = "";
    if ($details) {
        my($topics);
        foreach $e (@list) {
            $found = 1;
            if (!$details) {
                if (($objects[$e]{"type"} == $topic) &&
                    (!($objects[$e]{"flags"} & $dark))) {
                    if ($first) {
                        $first = 0;
                    } else {
                        $desc .= ", ";
                    }
                    $desc .= $objects[$e]{"name"};
                }
            }
        }
        if ($found) {
            if ($objects[$what]{"type"} == $room) {
                &{$output}($dest, "Active Topics:");
            } else {
                &{$output}($dest, "Topics:");
            }
            &{$output}($dest, $desc);
        }
    }
    return 1;
}

sub teleport
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    if ($arg2 eq "") {
        if ($arg1 ne "") {
            $arg2 = $arg1;
            $arg1 = "#" . $me;
        } else {
            &tellPlayer($me, "Syntax: \@teleport thing = #place");
            return;
        }
    }
    if (substr($arg2, 0, 1) ne "#") {
        &tellPlayer($me,
            "Syntax: \@teleport thing = #place");
        return;
    }
    my $id;
    if (!(substr($arg1, 0, 1) eq "#")) {
        $id = &findContents($objects[$me]{"location"}, $arg1);
        if ($id == $none) {
            $id = &findContents($me, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    }
    my $arg2id = substr($arg2, 1);
    if (($objects[$id]{"type"} != $player) && ($objects[$id]{"type"}
        != $thing) && ($objects[$id]{"type"} != $exit) &&
        ($objects[$id]{"type"} != $topic)) {
        &tellPlayer($me, "You can't teleport that.");
        return;
    }
    if (($objects[$id]{"owner"} != $me) && (!&wizardTest($me))) {
        if (!($objects[$id]{"flags"} & $jumpok)) {
            &tellPlayer($me,
                "That object is not set jumpok.");
            return;

        }
    }
    if ($arg2id == $home) {
        &sendHome($id);
        &tellPlayer($me, "Teleported.");
        return;
    }
    if ($id == $none) {
        &tellPlayer($me, "That destination id is not valid.");
        return;
    }
    if ($objects[$arg2id]{"type"} != $room) {
        &tellPlayer($me, "That is not a valid destination.");
        return;
    }
    if (($objects[$arg2id]{"owner"} != $me) && (!&wizardTest($me))) {
        if (!($objects[$arg2id]{"flags"} & $jumpok)) {
            &tellPlayer($me,
                "That destination is not set jumpok.");
            return;

        }
    }
    if ($objects[$objects[$me]{"location"}]{"flags"} & $puzzle) {
        &dropAll($me);
    }
    my $oldLocation = $objects[$id]{"location"};
    &removeContents($objects[$id]{"location"}, $id);
    &unfollow($id);
    if (builderTest($id)) {
        &tellRoom($objects[$id]{"location"}, $none, playerName($id) .
        " disappears in a puff of smoke.") if !($objects[$id]{"flags"} & $dark);
        &tellRoom($arg2id, $none, playerName($id) .
        " appeared with a crash of thunder.") if !($objects[$id]{"flags"} & $dark);
    } elsif ($objects[$id]{"type"}==$player) {
        &tellRoom($objects[$id]{"location"}, $none, playerName($id) .
        " has just left.") if !($objects[$id]{"flags"} & $dark);
        &tellRoom($arg2id, $none, playerName($id) .
        " has just arrived.") if !($objects[$id]{"flags"} & $dark);
    } else { # exit, topic or thing
        &tellRoom($objects[$id]{"location"}, $none, "The " . $objects[$id]{"name"} .
        " has just dissapeared.") if !($objects[$id]{"flags"} & $dark);
        my $desc = "The " . $objects[$id]{"name"} . " suddenly appeared.";
        if ($objects[$id]{"description"} ne "") {
            $desc = $objects[$id]{"description"};
        }
        &tellRoom($arg2id, $none, $desc) if !($objects[$id]{"flags"} & $dark);
    }
    &addContents($arg2id, $id);
    if ($me != $id) {
        &tellPlayer($id, playerName($me) .
            " has summoned you magically!");
    }
    &look($id, "", "", "");
    &tellPlayer($me, "Teleported.");
    return 1;
}

sub link
{
    my($me, $arg, $arg1, $arg2) = @_;
    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    if ($arg2 eq "") {
        &tellPlayer($me, "Syntax: \@link person/thing = #place");
        return;
    }
    $_ = $arg2;
    my($id);
    if (substr($arg1, 0, 1) ne "#") {
        $id = &findContents($objects[$me]{"location"}, $arg1);
        if ($id == $none) {
            $id = &findContents($me, $arg1);
        }
    } else {
        $id = substr($arg1, 1);
        $id = &idBounds($id);
    }
    if ($id == $none) {
        &tellPlayer($me, "I don't see that here.");
        return;
    }
    if (($objects[$id]{"owner"} != $me) && (!&wizardTest($me))) {
        &tellPlayer($me, "You don't own that.");
        return;
    }
    my($arg2id);
    $arg2id = $none;
    if ($objects[$id]{"type"} == $exit) {
        if (($arg2 eq "nowhere") || ($arg2 eq "NOWHERE")) {
            $arg2id = $nowhere;
        } elsif (($arg2 eq "home") || ($arg2 eq "HOME")) {
            $arg2id = $home;
        }
    }
    if ($arg2id == $none) {
        if (substr($arg2, 0, 1) ne "#") {
            &tellPlayer($me,
                "Syntax: \@link person/thing = #place");
            return;
        }
        $arg2id = substr($arg2, 1);
        $arg2id = &idBounds($arg2id);
    }
    if ($objects[$id]{"type"} == $exit) {
        # Special case for 'nowhere' and 'home'
        if (($arg2id == $nowhere) || ($arg2id == $home)) {
            $objects[$id]{"action"} = $arg2id;
            &tellPlayer($me, "Destination set.");
            return;
        }
    }
    if ($arg2id == $none) {
        &tellPlayer($me, "That destination id is not valid.");
        return;
    }
    if ($objects[$arg2id]{"type"} != $room) {
        &tellPlayer($me, "That is not a valid destination.");
        return;
    }
    if (($objects[$id]{"type"} != $player) && ($objects[$id]{"type"}
        != $thing) && ($objects[$id]{"type"} != $topic)
        && ($objects[$id]{"type"} != $exit))
    {
        &tellPlayer($me, "You can't link that.");
        return;
    }
    if ($objects[$id]{"type"} == $exit) {
        if ((!($objects[$arg2id]{"flags"} & $linkok)) &&
            (!($objects[$arg2id]{"owner"} == $me)) &&
            (!&wizardTest($me)))
        {
            tellPlayer($me,
                "That destination does not have its linkok flag set.");

        } else {
            $objects[$id]{"action"} = $arg2id;
            &tellPlayer($me, "Destination set.");
        }
    } else {
        if ((!($objects[$arg2id]{"flags"} & $abode)) &&
            (!($objects[$arg2id]{"owner"} == $me)) &&
            (!&wizardTest($me)))  {
            &tellPlayer($me,
            "That location does not have its abode flag set.");
        } else {
            $objects[$id]{"home"} = $arg2id;
            &tellPlayer($me, "Home set.");
        }
    }
    return 1;
}

sub open
{
    my($me, $arg, $arg1, $arg2) = @_;

    if (!&builderTest($me)) {
        &tellPlayer($me,$invalidMsgs[int(rand(5))]);
        return 0;
    }
    if (($objects[$objects[$me]{"location"}]{"owner"} != $me) &&
        (!&wizardTest($me)))
    {
        if (!($objects[$objects[$me]{"location"}]{"flags"} & $buildok)) {
            &tellPlayer($me,
                "This location is not set buildok.");
            return;

        }
    }
    $arg1 =~ s/\s+;/;/g;
    $arg1 =~ s/;\s+/;/g;
    if ($arg2 eq "") {
        &tellPlayer($me, "Syntax: \@open direction;synonym = #destid");
    } else {
        $_ = $arg2;
        if ($arg2 eq "nowhere") {
            $arg2 = "#" . $nowhere;
        }
        if ($arg2 eq "home") {
            $arg2 = "#" . $home;
        }
        if (substr($arg2, 0, 1) ne "#") {
            &tellPlayer($me,
                "Syntax: \@open direction;synonym = #destid (note the # sign)");
        } else {
            $arg2 = substr($arg2, 1);
            if (($arg2 == $home) || ($arg2 == $nowhere)) {
                my($id);
                $id = &addObject($me, $arg1, $exit);
                &addContents($objects[$me]{"location"}, $id);
                $objects[$id]{"action"} = $arg2;
                &tellPlayer($me, "Opened.");
                return;
            }
            $arg2 = &idBounds($arg2);
            if (($arg2 == $none) ||
                ($objects[$arg2]{"type"} != $room)) {
                &tellPlayer($me,
                    "That destination id is not valid.");
                return;
            }
            if (($objects[$arg2]{"owner"} != $me) &&
                (!&wizardTest($me))) {
                if (!($objects[$arg2]{"flags"} & $linkok)) {
                    &tellPlayer($me,
                        "That destination does not have its linkok flag set.");
                    return;

                }
            }
            my($id);
            $id = &addObject($me, $arg1, $exit);
            &addContents($objects[$me]{"location"}, $id);
            $objects[$id]{"action"} = $arg2;
            $objects[$id]{"home"} = $objects[$me]{"location"};
            &tellPlayer($me, "Opened.");
        }
    }
    return 1;
}

sub home
{
    my($me, $arg, $arg1, $arg2) = @_;
    &sendHome($me);
    return 1;
}

sub tellWizards
{
    my($msg, $loc) = @_;
    my($i);
    $loc=$nowhere unless (defined $loc);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        my($e) = $activeFds[$i]{"id"};
        if ($e != $none) {
            if (&builderTest($e) && ($objects[$e]{"location"} != $loc) && !($objects[$objects[$e]{"location"}]{"flags"} & $silent)) { # this tells wizards and builders unless they are in loc or a silent room
                &tellPlayer($e, $msg);
            }
        }
    }
    return 1;
}

sub who
{
    my($me, $arg, $arg1, $arg2) = @_;
    # this is where we detecting a sleeping person
    if ($objects[$me]{"flags"} & $asleep) { # asleep trying to act
        # wake me if possible but report fail if not.
        return 0 if (!(&wake($me,"","","")));
    }
    my($e, $i);
    my($sex, $level);
    for ($i = 0; ($i <= $#activeFds); $i++) {
        $e = $activeFds[$i]{"id"};
        if ($e != $none) {
            my($name);
            $name = playerName($e);
            if (builderTest($me)) {
                $name = "($name)" if ($objects[$e]{"flags"} & $dark);
                &tellPlayer($me,$name . ' is playing in room #' . $objects[$e]{"location"});
            } else {
                $name = "Someone" if ($objects[$me]{"flags"} & $blind);
                next if ($objects[$e]{"flags"} & $dark);
                &tellPlayer($me,$name . ' is playing');
            }
        }
    }
    return 1;
}

sub last
{
    my($me, $arg, $arg1, $arg2) = @_;
    my($id);
    if ($arg1 eq "") {
        &tellPlayer($me, "Usage: last player");
        return;
    }
    if (substr($arg1, 0, 1) eq "#") {
        $id = int(substr($arg1, 1));
        $id = &idBounds($id);
        if ($id == $none) {
            &tellPlayer($me, "There is no such player.");
            return;
        }
    } else {
        my($n);
        if ($arg1 =~ /^\*(.*)$/) {
            $arg1 = $1;
        }
        $n = $arg1;
        $n =~ tr/A-Z/a-z/;
        if (!exists($playerIds{$n})) {
            &tellPlayer($me, "There is no such player.");
            return;
        }
        $id = $playerIds{$n};
    }
    if ($objects[$me]{"tz"} eq "") {
        &tellPlayer($me, "You have not set your time zone. " .
            "Assuming GMT. Use \@tz to change this.");
    }
    my($on, $off) = ($objects[$id]{"on"}, $objects[$id]{"off"});
    if ($on eq "") {
        &tellPlayer($me, playerName($id) .
            " has never logged in.");
        return;
    }
    my($msg) = playerName($id) . " last logged in: " .
        &timeAndDateFormat($me, $objects[$id]{"on"});
    &tellPlayer($me, $msg);
    if (($objects[$id]{"activeFd"} != $none))
    {
        &tellPlayer($me, playerName($id) .
            " is still logged in.");
    } elsif ($off eq "") {
        return;
    } elsif ($off > $on) {
        &tellPlayer($me, playerName($id) .
            " last logged out: " .
            &timeAndDateFormat($me, $objects[$id]{"off"}));
    } else {
        # If $on is less than $off, the mud was stopped
        # before they logged off, so logoff time is indeterminate.
    }
    return 1;
}

sub timeAndDateFormat
{
    my($me, $when) = @_;
    my($adj) = $when + $objects[$me]{"tz"} * 60;
    my(@timeFields) = gmtime($adj);
    my($month, $day, $year, $hour, $min, $sec);
    $month = ("Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec") [$timeFields[4]];
    $day = $timeFields[3];
    $year = $timeFields[5] + 1900;
    $hour = $timeFields[2];
    $min = $timeFields[1];
    $sec = $timeFields[0];
    my($suffix);
    if ($objects[$me]{"24hour"}) {
        $suffix = "";
    } else {
        if (($hour == 12) && ($min == 0)) {
            $suffix = " noon";
        } elsif (($hour == 0) && ($min == 0)) {
            $hour = 12;
            $suffix = " midnight";
        } elsif ($hour > 12) {
            $hour -= 12;
            $suffix = " pm";
        } elsif ($hour == 12) {
            $suffix = " pm";
        } elsif ($hour == 0) {
            $hour = 12;
            $suffix = " am";
        } else {
            $suffix = " am";
        }
    }
    if ($objects[$me]{"24hour"}) {
        $hour = sprintf("%02d", $hour);
    } else {
        $hour = sprintf("%2d", $hour);
    }
    return sprintf("%s %02d %04d %02d:%02d:%02d$suffix",
        $month, $day, $year, $hour, $min, $sec);
}

sub tellRoom
{
    my($id, $exclude, $what, $from, $topic) = @_;
    my($e, @list);
    my($fromText);
    $exclude=$none unless (defined $exclude);
    if ($topic eq "") {
        $fromText = " (from $from)" if ($from ne "");
    }
    @list = split(/,/, $objects[$id]{"contents"});
    foreach $e (@list) {
        if (($objects[$e]{"type"} == $player) && (!($objects[$e]{"flags"} & $asleep)) && (!($objects[$e]{"flags"} & $blind)) && (!($objects[$e]{"flags"} & $deaf)) ) { # dont tell deaf and blind or just blind?
            if ($e != $exclude) {
                # Filter annoyances out (apply gag filters).
                if ($from ne "") {
                    my($tgag) = quotemeta($from);
                    if (($objects[$e]{"gags"} =~ /^$tgag /i) ||
                        ($objects[$e]{"gags"} =~ / $tgag /i))
                    {
                        # The player is not interested.
                        next;
                    }
                }
                # Apply topic filters.
                if (!&filterTopic($e, $topic)) {
                    next;
                }
                my($msg) = $what;
                
                # Handle the smartclient prefix for topics.
                if ($topic ne "") {
                    my($prefix) = &getTopicPrefix($e);
                    $msg = "$prefix$msg";
                }
                if ($objects[$e]{"flags"} & $spy) {
                    &tellPlayer($e, $msg . $fromText);
                } else {
                    &tellPlayer($e, $msg)  # if (!($objects[$e]{"flags"} & $deaf)); #debug  audible vs visual how?
                }
            }
        }
    }
    return 1;
}


sub getTopicPrefix
{
    my($me) = @_;
    my($prefix) = "";
    my($fd) = $objects[$me]{"activeFd"};
    if ($fd ne $none) {
        if ($activeFds[$fd]{"smartclient"}) {
            return $topicPrefix;
        }
    }
    return "";
}

sub filterTopic
{
    my($me, $topic) = @_;
    my($topics) = $objects[$me]{"topics"};
    my($default);
    if ($topic eq "") {
        return 1;
    }
    if (!exists($objects[$me]{"topicdefault"})) {
        $default = 1;
    } else {
        $default = $objects[$me]{"topicdefault"};
    }
    my(@topics) = split(/,/, $topics);
    my ($t);
    for $t (@topics) {
        my($qm) = quotemeta($topic);
        if ($t =~ /^$qm$/i) {
            return !$default;
        }
    }
    return $default;
}

1;
