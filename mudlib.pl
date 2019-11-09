#IMPORTANT: change these configuration settings to suit your site.
#You may want to be much more careful about what players can do!

#This file can be reloaded in response to the @reload command
#(wizard only of course). Code accordingly: don't assume that
#lists will be empty, etc. in any initialization you do here.

#Port number to listen for tiny line protocol connections on 
$tinypPort = 4096;
#$tinypPort = 4096;

#Port number to listen for HTTP connections on
$httpPort = 4196;
#$httpPort = 80;

#IP address to listen on. If this is set to 0.0.0.0, then
#PerlMUD will answer on all interfaces. If it is set to a
#specific IP address, PerlMUD will only answer on that
#interface. If you can set up virtual interfaces to give
#your machine several IP addresses, then you can take
#advantage of this to have a PerlMUD server that answers
#HTTP requests on port 80 without interfering
#with your regular WWW server.

#$ipAddress = "206.125.69.87";
$ipAddress = "0.0.0.0";
$httpIpAddress = $ipAddress;
#$httpIpAddress = "206.125.69.84";

#What do you want to call your server? The public sees this name
#in the title of various web pages.

$serverName = "Nerdsholm";

#What is the complete ** Internet host name ** of your server?
#This goes out with the instructions that are sent to
#MUD users that get their accounts via email. Examples:
#www.boutell.com, mud.myschool.edu, et cetera. This must
#be a REAL host name for the server -- just putting
#something here won't magically add a new name to your DNS!

$hostName = "nerdsholm.boutell.com";

#Should users be allowed to create objects and rooms by default?
#Set this to 0 if you prefer not.

$allowBuild = 1;

#Should users be allowed to @emit things without their
#name prefixed? Set this to zero if you prefer not.

$allowEmit = 1;

#Location of sendmail on your system. This will usually be correct.
#This is only important if you are accepting account applications from 
#the public.

$sendmail = "/usr/sbin/sendmail";

#File locations for the database, the login screen banner,
#the Message of the Day, and the help file. 

$dbFile = "mud.db";
$welcomeFile = "welcome.txt";
$motdFile = "motd.txt";
$helpFile = "help.txt";
$emailFile = "mail.txt";
$homePageFile = "home.html";
$applicationFile = "application.html";
$acceptedFile = "accepted.html";
$mailAliasesFile = "aliases.txt";
$apachePasswordsFile = "apache.passwords.txt";
$updateMailAliasesCommand = "./updatealiases";
#If you uncomment this, set a password
#$newsPassword = "";
$newsPassword = "a8b7";

#Idle timeout. This hangs up on users if they do not
#enter at least one command in the time interval
#(specified in seconds; 3600 is an hour).
 
$idleTimeout = 86400;

#Idle timeout for HTTP connections, in seconds. This is
#different: if the server doesn't at least hear from 
#the user's web browser, requesting more mud output,
#in this interval, the user is disconnected.
#
#Since users frequently do not formally log out and there is 
#no real "connection," this timeout should be fairly short (10 minutes).

$httpIdleTimeout = 600;

#Time to wait between (brief) attempts at closing
#sockets we don't need anymore. The longer this is,
#the fewer pauses the mud will experience.

$fdClosureInterval = 30;

#Rows of text to keep from one http update to the next.

$httpRows = 40;

#Columns of text, with auto word wrap inside a <PRE> tag.
$httpCols = 70;

#Seconds between HTTP client pulls (in browsers that support pull).
$httpRefreshTime = 30;

#Interval between automatic backups of the database, in seconds (1 hour).
#Note: stale topics are also sent home during this pass.
$dumpinterval = 3600;
#Seconds until a topic is considered stale.
$topicStaleTime = 3000;

#Version of PerlMUD.
$perlMudVersion = 3.0;

#Max size of output buffer before flushing takes place
$flushOutput = 32768;

#If the client sends the 'smartclient' command prior to sending the
#connect command, then this prefix is sent in front of each line of 
#topic-specific output for the life of the connection. The @emit command
#cannot spoof this.  

$topicPrefix = "[{}]";

#Nothing below here should require changes to set up the mud
	
#Protocols 

$tinyp = 0;
$http = 1;

#Protocol states
$httpReadingHeaders = 0;
$httpReadingBody = 1;
$httpWriting = 2;

#Object types

$room = 1;
$player = 2;
$exit = 3;
$thing = 4;
$topic = 5;

#Special IDs

$none = -1;
$home = -2;
$nowhere = -3;

#Flag values

#Can't be seen; or description only, contents invisible
$dark = 1;

#Gender
$male = 2;
$female = 4;
$herm = 6;

#Name of location visible in who list
$public = 8;

#Unused flag
$unusedFlag = 16;
#OK to link to
$linkok = 32;

#OK to jump to
$jumpok = 64;

#OK for anyone to build here
$buildok = 128;

#Claimable by anyone who passes the lock
#(Not yet implemented)
$claimok = 256;

#Goes home when dropped
$sticky = 512;

#Part of a puzzle; a teleport or home command
#from this location drops all objects carried.

$puzzle = 1024;

#If true, this location can be set home (@link)
#for an object by anyone.
$abode = 2048;

#If true for a room, this location is "grand central station":
#players can see things, hear people speak, etc., but arrivals and 
#departures go unnoticed. 
$grand = 4096;

#If true for an object, any person can "sign" the object,
#appending a string of up to 60 characters to its description.
$book = 8192;

#This player is a wizard. #1 is always a wizard.
$wizard = 16384;

#This player hates automatic speech and wants more abbreviations.
$expert = 32768;

#This player wants to know who @emits things.
#Only an issue if $allowEmit is set.
$spy = 65536;

#This player is allowed to build things. Set for new
#players if $allowBuild is set. Only a wizard can change 
#this flag after that.
$builder = 131072;

#If the book flag is set, and the once flag is also set, then
#any subsequent signature replaces all previous signatures
#by the same individual. 
$once = 262144;

#For flag setting
%flags = (
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
	"once", $once
);

%flagsProper = (
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
	"once", $once
);

@flagNames = (
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
	"once"
);

#Set these up in a particular order so that we can
#say that, for instance, abbreviations of 'whisper'
#should beat abbreviations of 'who'.

@commandsProperOrder = (
	"\@wall", \&wall,
	"say", \&say,
	"emote", \&emote,
	"\@dig", \&dig,
	"\@doing", \&doing,
	"\@create", \&create,
	"\@stats", \&stats,
	"\@rooms", \&rooms,
	"\@gag", \&gag,
	"\@ungag", \&ungag,
	"look", \&look,
	"read", \&look,
	"examine", \&examine,
	"inventory", \&inventory,
	"drop", \&drop,
	"get", \&get,
	"take", \&get,
	"home", \&home,
	"whisper", \&whisper,
	"who", \&who,
	"sign", \&sign,
	"write", \&sign,
	"unsign", \&unsign,
	"help", \&help,
	"motd", \&motd,
	"welcome", \&welcome,
	"\@set", \&set,
	"\@describe", \&setDescription,
	"page", \&page,
	"\@name", \&name,
	"\@chown", \&chown,
	"\@pcreate", \&pcreate,
	"\@password", \&password,
	"\@teleport", \&teleport,
	"\@link", \&link,
	"\@open", \&open,
	"\@fail", \&setFail,
	"\@ofail", \&setOfail,	
	"\@success", \&setSuccess,
	"\@osuccess", \&setOsuccess,
	"\@odrop", \&setOdrop,	
	"\@lock", \&setLock,
	"\@boot", \&boot,
	"\@clean", \&clean,
	"\@find", \&find,
	"\@rows", \&setRows,
	"\@emit", \&emit,
	"\@email", \&setEmail,
	"\@topic", \&createTopic,
	"\@join", \&joinTopic,
	"\@leave", \&leaveTopic,
	"last", \&last,
	"\@tz", \&tz,
	"\@24", \&twentyfour,
	"\@12", \&twelve
);

my($i);
for ($i = 0; ($i < int(@commandsProperOrder)); $i += 2) {
	$commandsProper{$commandsProperOrder[$i]} =
		$commandsProperOrder[$i + 1];
}

#Data for base64 decoder

$base64alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
                  'abcdefghijklmnopqrstuvwxyz'.
                  '0123456789+/';

$base64pad = '=';

$base64initialized = 0;

#Set the SIGPIPE handler (grrr)

&plumber;

#Set up commands table (now in order of precedence) 

#3.0: make sure to empty it again if we're reloading
%commandsTable = ( );

for ($i = 0; ($i < int(@commandsProperOrder)); $i += 2) {
	my($key) = $commandsProperOrder[$i];
	my($val) = $commandsProperOrder[$i + 1];
	my($j);
	for ($j = 1; ($j <= length($key)); $j++) {
		my($s) = substr($key, 0, $j);
		if ($s eq "@") {
			next;
		}
		if (!exists($commandsTable{$s})) {
			$commandsTable{$s} = $val;
		}
	}
}

#Marker for new material in frames
$httpNewMarker = "<a name=\"newest\">#</a>";	

#(re)initialization code ends here

sub selectPass
{
	my($rfds, $wfds, $i);
	$rfds = "";
	$wfds = "";		
	for ($i = 0; ($i <= $#activeFds); $i++) {
		if ($activeFds[$i]{"fd"} ne $none) {
			if ($activeFds[$i]{"protocol"} == $tinyp) {
				my($fd) = $activeFds[$i]{"fd"};
				vec($rfds, fileno($fd), 1) = 1;
				if (length($activeFds[$i]{"outbuf"})) {
					vec($wfds, fileno($fd), 1) = 1;
				}	
			} elsif ($activeFds[$i]{"protocol"} == $http) {
				my($fd) = $activeFds[$i]{"fd"};
				if (($activeFds[$i]{"state"} == 
					$httpReadingHeaders) || 
					($activeFds[$i]{"state"} == 
					$httpReadingBody)) 
				{
					vec($rfds, fileno($fd), 1) = 1;
				} elsif ($activeFds[$i]{"state"} == $httpWriting) {
					vec($wfds, fileno($fd), 1) = 1;
				}
			}	
		} 
	}
	vec($rfds, fileno(TINYP_LISTENER), 1) = 1;
	vec($rfds, fileno(HTTP_LISTENER), 1) = 1;
	my($timeout);
	my($before);
	$before = time;
	# The longest timeout would be between dump intervals
	$timeout = $dumpinterval - ($now - $lastdump);
	# Second longest, probably, between fd closure intervals
	if ($fdClosureNew) {
		# Try it right away	
		$timeout = 0;
	} else {
		my($fdTimeout);
		$fdTimeout = $lastFdClosure + $fdClosureInterval - $now;
		if ($fdTimeout < $timeout) {
			$timeout = $fdTimeout;
		}
	}
	if ($timeout < 0) {
		# Reasonable timeouts only
		$timeout = 0;
	}
	select($rfds, $wfds, undef, $timeout);
	$now = time;
	if ($now - $lastdump >= $dumpinterval) {
		&dump($none, "", "", "");
	}
	if ($fdClosureNew || ($now - $lastFdClosure >= $fdClosureInterval)) 
	{
		$fdClosureNew = 0;
		# Try to close some file descriptors we're
		# done with. This can take a while if they have 
		# not flushed completely yet, so we make three-second
		# attempts to close them, every n seconds.
		# This is a workaround for the SO_LINGER problem.
		$SIG{ALRM} = \&fdClosureTimeout;
		$fdClosureTimedOut = 0;
		alarm(3);
		while (int(@fdClosureList)) {
			close($fdClosureList[0]);
			if ($fdClosureTimedOut) {
				# Try again later
				last;
			}
			# It worked
			shift @fdClosureList;
		}			
		# No more need for the alarm timer
		alarm(0);
		$SIG{ALRM} = undef;	
		$lastFdClosure = time;
	}
	for ($i = 0; ($i <= $#activeFds); $i++) {
		if ($activeFds[$i]{"fd"} ne $none) {
			my($fd) = $activeFds[$i]{"fd"};
			if (vec($rfds, fileno($fd), 1)) {
				&readData($i, $fd);
			}
			# Watch out for a close detected on the read
			if ($activeFds[$i]{"fd"} ne $none) {
				if (vec($wfds, fileno($fd), 1)) {
					&writeData($i, $fd);
				}
			}
		}
	}
	if (vec($rfds, fileno(TINYP_LISTENER), 1)) {
		&acceptTinyp;
	}
	if (vec($rfds, fileno(HTTP_LISTENER), 1)) {
		&acceptHttp;
	}
	# Idle Timeouts
	for ($i = 0; ($i <= $#activeFds); $i++) {
		$e = $activeFds[$i]{"id"};
		if ($e != $none) {
			if ($objects[$e]{"httpRecent"}) {
				next;
			}
			$idlesecs = $now - $objects[$e]{"last"};
			if ($idlesecs > $idleTimeout) {
				&closePlayer($e, 1);
			}
		}
	}	
	for ($i = 0; ($i <= $#httpActiveIds); $i++) {
		if ($httpActiveIds[$i] != $none) {
			if (($now - $objects[$httpActiveIds[$i]]{"lastPing"}) >
				$httpIdleTimeout) 
			{
				&closePlayer($httpActiveIds[$i], 1);
			} elsif (($now - $objects[$httpActiveIds[$i]]{"last"}) >
				$idleTimeout) 
			{
				&closePlayer($httpActiveIds[$i], 1);
			}
		}
	}
}

sub closeActiveFd
{
	my($i) = @_;
	if ($activeFds[$i]{"id"} != $none) {
		if (!$objects[$activeFds[$i]{"id"}]{"httpRecent"}) {
			&closePlayer($activeFds[$i]{"id"}, 1);
			return;
		} else {
			$objects[$activeFds[$i]{"id"}]{"activeFd"} = $none;
		}
		$activeFds[$i]{"id"} = $none;
	}
	my($fd);
	$fd = $activeFds[$i]{"fd"};
	if ($fd ne $none) {
		push @fdClosureList, $fd;
		$fdClosureNew = 1;
	}
	# Make sure the next person doesn't get old buffer data!
	$activeFds[$i] = { };
	$activeFds[$i]{"fd"} = $none;
	$activeFds[$i]{"id"} = $none;
	$activeFds[$i]{"smartclient"} = 0;
}

sub input
{
	my($aindex, $input) = @_;
	$input =~ tr/\x00-\x1F//d;
	if ($activeFds[$aindex]{"id"} ne $none) {
		&command($activeFds[$aindex]{"id"}, $input);
	} else {
		$input =~ s/\s+/ /g;
		$input =~ s/^ //g;
		$input =~ s/ $//g;
		my($verb, $object, $pwd) = split(/ /, $input);	
		if ($verb eq "") {
			return;
		}
		if (($verb eq "quit") || ($verb eq "QUIT")) {
			closeActiveFd($aindex);
			return;
		}
		if ($verb eq "news") {
			if ($newsPassword ne "") {
				if ($input =~ 
					/news\s+$newsPassword\s+\#(\d+)\s+(.*)/)
				{		
					my($to, $what) = ($1, $2);
					if ($objects[$to]{"type"} eq $player) {
						&tellPlayer($to, $what);
					} else {	
						&tellRoom($to, undef, $what, undef);
					}
					closeActiveFd($aindex);
					return;
				}
			} else {
				&tellActiveFd($aindex, "Bad syntax or bad password.");
				closeActiveFd($aindex);
				return;
			}
		}
		if ($verb eq "connect") {
			my($id, $n);
			$n = $object;
			$n =~ tr/A-Z/a-z/;
			if (!exists($playerIds{$n})) {
				&tellActiveFd($aindex, "Login Failed");
				&tellActiveFd($aindex,
					"That player does not exist, or has a different password.");
				return;
			} else {
				$id = $playerIds{$n};
				if ($pwd ne $objects[$id]{"password"}) {
					&tellActiveFd($aindex, "Login Failed");
					&tellActiveFd($aindex,
						"That player does not exist, or has a different password.");
					return;
				}
				&tellActiveFd($aindex, "Login Succeeded");
				if (($objects[$id]{"activeFd"} != $none) ||
					$objects[$id]{"httpRecent"}) 
				{
					closePlayer($id, 0);
				}
				$activeFds[$aindex]{"id"} = $id;
				&login($id, $aindex);
			}
			return;
		}
		if ($verb eq "smartclient") {
			$activeFds[$aindex]{"smartclient"} = 1;
			return;
		} 
		&tellActiveFd($aindex,
			"Try: connect name password (or quit)");
	}
}

sub closePlayer
{
	my($id, $gohome) = @_;
	my($i);
	if ($objects[$id]{"httpRecent"}) {
		$objects[$id]{"httpRecent"} = 0;
		$objects[$id]{"httpOutput"} = "";
		for ($i = 0; ($i <= $#httpActiveIds); $i++) {
			if ($httpActiveIds[$i] == $id) {
				$httpActiveIds[$i] = $none;
				last;
			}
		}
	}
	for ($i = 0; ($i <= $#activeFds); $i++) {
		if (($activeFds[$i]{"fd"} ne $none) &&
			($activeFds[$i]{"id"} == $id)) 
		{
			$activeFds[$i]{"id"} = $none;
			&closeActiveFd($i);
			last;
		}
	}
	$objects[$id]{"activeFd"} = $none;
	if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand)) {
		&tellRoom($objects[$id]{"location"}, $none, $objects[$id]{"name"} . 
			" has disconnected.");
	}
	if ($gohome) {
		&sendHome($id);
	}
	$objects[$id]{"off"} = $now;
}

sub acceptTinyp 
{
	my($fd) = $fdBase . $fdNum;
	$fdNum++;
	if (accept($fd, TINYP_LISTENER)) {
		my($i, $found);
		$found = 0;
		for ($i = 0; ($i <= $#activeFds); $i++) {
			if ($activeFds[$i]{"fd"} eq $none) {
				$activeFds[$i]{"protocol"} = $tinyp;
				$activeFds[$i]{"fd"} = $fd;
				$activeFds[$i]{"id"} = $none;
				&sendActiveFdFile($i, $welcomeFile);
				$found = 1;
				last;
			}
		}
		if (!$found) {
			my($aindex) = $#activeFds + 1;
			$activeFds[$aindex]{"protocol"} = $tinyp;
			$activeFds[$aindex]{"fd"} = $fd;
			$activeFds[$aindex]{"id"} = $none;
			&sendActiveFdFile($aindex, $welcomeFile);
		}
		# Stop (ma)lingering behavior
		setsockopt($fd, SOL_SOCKET, SO_LINGER, 0);
		# Set non-blocking I/O 
		fcntl($fd, F_SETFL, O_NONBLOCK);
	}
}

sub acceptHttp
{
	my($fd) = $fdBase . $fdNum;
	$fdNum++;
	if (accept($fd, HTTP_LISTENER)) {
		my($i, $found);
		$found = 0;
		for ($i = 0; ($i <= $#activeFds); $i++) {
			if ($activeFds[$i]{"fd"} eq $none) {
				$activeFds[$i]{"protocol"} = $http;
				$activeFds[$i]{"state"} = $httpReadingHeaders;
				$activeFds[$i]{"fd"} = $fd;
				$activeFds[$i]{"id"} = $none;
				$found = 1;
				last;
			}
		}
		if (!$found) {
			my($aindex) = $#activeFds + 1;
			$activeFds[$aindex]{"protocol"} = $http;
			$activeFds[$aindex]{"state"} = $httpReadingHeaders;
			$activeFds[$aindex]{"fd"} = $fd;
			$activeFds[$aindex]{"id"} = $none;
		}
		# Lingering is important for HTTP (2.11)
		setsockopt($fd, SOL_SOCKET, SO_LINGER, 1);
		# Set non-blocking I/O (restored, 2.11)
		fcntl($fd, F_SETFL, O_NONBLOCK);
	}
}

sub command
{
	my($me, $text) = @_;	
	my($id);
	$objects[$me]{"lastPing"} = $now;
	$_ = $text;
	# Don't let the user embed commands. Could do nasty, nasty things.
	s/\x01/\./g;
	s/\x02/\./g;
	# Clean up whitespace. 
	s/\s/ /g;
	s/^ //g;
	s/ $//g;
	$text = $_;
	if ($text eq "") {
		return;
	}
	if ($text eq "quit") {
		&closePlayer($me, 1);
		return;
	}
	$objects[$me]{"last"} = $now;
	if ($commandLogging) {
		print CLOG $me, ":", $text, "\n";
		&flush(CLOG);
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
	if (substr($text, 0, 2) eq "..") {
		&tellPlayer($me, "Sorry, support for .. has been removed. Please use ' instead of .. as this makes the .name whisper shortcut safe to use.");
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

	#
	# Consider exits from this room.
	#

	if (substr($text, 0, 1) ne "@") {
		$id = &findContents($objects[$me]{"location"}, $text);
		if ($id != $none) {
			if ($objects[$id]{"type"} != $exit) {
				&fail($me, $id, "You can't go that way.", "");
				return;
			}	
			if (!&testLock($me, $id)) {
				&fail($me, $id, "You can't go that way.", "");
				return;
			}
			if ($objects[$id]{"action"} == $nowhere) {
				&success($me, $id, "",
					$objects[$me]{"name"} . " has left.");
				return;
			}
			&removeContents($objects[$me]{"location"}, $me);
			if (!($objects[$objects[$me]{"location"}]{"flags"} & $grand)) {
				&success($me, $id, "",
					$objects[$me]{"name"} . " has left.");
			}
			if ($objects[$id]{"action"}	== $home) {
				&sendHome($me);
				return;
			}		
			if (!($objects[$objects[$id]{"action"}]{"flags"} & $grand)) {
				if ($objects[$id]{"odrop"} ne "") {
					&tellRoom($objects[$id]{"action"}, $none,
						$objects[$me]{"name"} . " " .
						&substitute($me, 
							$objects[$id]{"odrop"}));
				} else {
					&tellRoom($objects[$id]{"action"}, $none,
						$objects[$me]{"name"} . " has arrived.");
				}
			}
			&addContents($objects[$id]{"action"}, $me);
			&describe($me, $objects[$me]{"location"}, 0);	
			return;
		}
	}	

	#Split into command and argument. 

	my($c, $arg) = split(/ /, $text, 2);
	
	$arg = &canonicalizeWord($me, $arg);

	# Now commands with an = sign.
	
	# Common parsing

	my($arg1, $arg2) = split(/=/, $arg, 2);
	$arg1 = &canonicalizeWord($me, $arg1);
	$arg2 = &canonicalizeWord($me, $arg2);

	# Commands that are not in the normal table

	$c =~ tr/A-Z/a-z/;

	if ($c eq "\@recycle") {
		&recycle($me, $arg, $arg1, $arg2);
		return;
	}
	if ($c eq "\@purge") {
		&purge($me, $arg, $arg1, $arg2);
		return;
	}
	if ($c eq "\@toad") {
		&toad($me, $arg, $arg1, $arg2);
		return;
	}
	if ($c eq "\@shutdown") {
		&shutdown($me, $arg, $arg1, $arg2);
		return;
	}
	if ($c eq "\@reload") {
		&reload($me, $arg, $arg1, $arg2);
		return;
	}
	if ($c eq "\@dump") {
		&dump($me, $arg, $arg1, $arg2);
		return;
	}

	# If there is an =, then look for an abbreviated command
	if (!($objects[$me]{"flags"} & $expert)) {
		if ($arg2 ne "") {
			if (exists($commandsTable{$c})) {
				&{$commandsTable{$c}}($me, $arg, $arg1, $arg2);		
				return;
			}
		} else {
			# if there is no =, then require an exact command
			if (exists($commandsProper{$c})) {
				&{$commandsTable{$c}}($me, $arg, $arg1, $arg2);		
				return;
			}
		}
		# Okay, it is (apparently) not a command, so just say it. 
		&say($me, $text, "", "");
	} else {
		if (exists($commandsTable{$c})) {
			&{$commandsTable{$c}}($me, $arg, $arg1, $arg2);		
			return;
		}
		&tellPlayer($me, "Not a valid command. Try typing help.");
	}	
}

sub dig
{
	my($me, $arg, $arg1, $arg2) = @_;
	if (!&builderTest($me)) {
		&tellPlayer($me, "Sorry, only an authorized builder can do that.");
		return;
	}	
	&addObject($me, $arg, $room);
}

sub doing
{
	my($me, $arg, $arg1, $arg2) = @_;
	$objects[$me]{"doing"} = $arg;
	&tellPlayer($me, "Doing doing doing!");
}

sub twentyfour
{
	my($me, $arg, $arg1, $arg2) = @_;
	$objects[$me]{"24hour"} = 1;
	&tellPlayer($me, "24-hour time display set.");
}

sub twelve
{
	my($me, $arg, $arg1, $arg2) = @_;
	$objects[$me]{"24hour"} = 0;
	&tellPlayer($me, "12-hour time display set.");
}

sub reload
{
	my($me, $arg, $arg1, $arg2) = @_;
	if ($me != $none) {
		if (!&wizardTest($me)) {
			&tellPlayer($me, "Sorry, only a wizard can do that.");
			return;
		}
	}
	&dump($me, $arg, $arg1, $arg2);
	$reloadFlag = 1;
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

sub setEmail
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($id);
	if ($mailAliasesFile eq "") {
		&tellPlayer($me, "This system does not " .
			"have a mail aliases file.");
		return;
	}
	if ($arg =~ /=/) {
		$id = &setField($me, $arg, $arg1, $arg2, 
			"email", "Email address");
		if ($id ne $none) {
			if (!&updateMailAliases) {
				&tellPlayer($me, "NOTE: there may be " .
					"a short delay before your " .
					"new alias is valid.");
			}
		}
	} else {
		$objects[$me]{"email"} = $arg;
		&tellPlayer($me, "Email address set.");
		if (!&updateMailAliases) {
			&tellPlayer($me, "NOTE: there may be " . 
				"a short delay before your " .
				"new alias is valid.");
		}
	}		
}

sub create
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($id);
	if (!&builderTest($me)) {
		&tellPlayer($me, "Sorry, only an authorized builder can do that.");
		return;
	}	
	if ($arg =~ /^\s*$/) {
		&tellPlayer($me, "Syntax: \@create nameofthing");
		return;
	}
	$id = &addObject($me, $arg, $thing); 
	&addContents($me, $id);
	$objects[$id]{"home"} = $objects[$me]{"home"};
}

sub createTopic
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($id);
	if (!&builderTest($me)) {
		&tellPlayer($me, 
			"Sorry, only an authorized builder can do that.");
		return;
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
		&tellPlayer($objects[$id]{"name"} . " dropped.");
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
			&tellPlayer($objects[$id]{"name"} . " dropped.");
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
	&lookBody($me, $arg, $arg1, $arg2, 0);
}

sub examine
{
	my($me, $arg, $arg1, $arg2) = @_;
	&lookBody($me, $arg, $arg1, $arg2, 1);
}

sub find
{
	my($me, $arg, $arg1, $arg2, $details) = @_;
	my($i, $id, $len1, $len2, $w, $found, $name);
	if ($arg eq "") {
		&tellPlayer($me, "Syntax: \@find name");
		return;
	}
	$arg =~ tr/A-Z/a-z/;
	$found = 0;
	$len1 = length($arg);
	$w = &wizardTest($me);
	for ($i = 0; ($i <= $#objects); $i++) {
		if ($w || ($objects[$i]{"owner"} == $me)) {
			($name = $objects[$i]{"name"}) =~ tr/A-Z/a-z/; 
			$len2 = length($name);
			if ($len1 <= $len2) {
				if (substr($name, 0, $len1) eq $arg) {
					&tellPlayer($me, "#" . $i . ": " . 
						$objects[$i]{"name"});
					$found = 1;
				}
			}
		}
	}
	if (!$found) {
		&tellPlayer($me, "Not found.");
	}
}

sub stats
{
	my($me, $arg, $arg1, $arg2, $details) = @_;
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
		&tellPlayer($me, "Statistics for " . $objects[$owner]{"name"});
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
		&tellPlayer($me, "Only a wizard can list rooms belonging " .
			"to other players.");
		return;
	}	
	$total = 0;
	for ($i = 0; ($i <= $#objects); $i++) {
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

sub lookBody
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

sub toad
{
	my($me, $arg, $arg1, $arg2) = @_;
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

	if (($objects[$id]{"activeFd"} != $none) || ($objects[$id]{"httpRecent"})) {
		&closePlayer($id, 0);
	}
	my($name) = $objects[$id]{"name"};
	$name =~ tr/A-Z/a-z/;
	undef($playerIds{$name});

	$objects[$id]{"name"} = "A slimy toad named " . $objects[$id]{"name"};	
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
	&updateApachePasswords;
}

sub recycle
{
	my($me, $arg, $arg1, $arg2) = @_;
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

	@list = split(/,/, $objects[$id]{"contents"});
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

sub inventory
{
	my($me, $arg, $arg1, $arg2) = @_;
	&describe($me, $me, 1);
}

sub drop
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($id);
	if ($arg eq "all") {
		&dropAll($me);
		return;
	}
	$id = &findContents($me, $arg);
	if ($id == $none) {
		&tellPlayer($me, "You are not carrying that.");
	} else {
		if ($objects[$id]{"type"} == $topic) {
			&createTopic($me, $arg, $arg1, $arg2);
			return;
		}
		&removeContents($me, $id);
		&tellPlayer($me, "You dropped " . $objects[$id]{"name"} . ".");
		if ($objects[$id]{"flags"} & $sticky) {
			&addContents($objects[$id]{"home"}, $id);
		} else {
			&addContents($objects[$me]{"location"}, $id);
		}
		if ($objects[$id]{"odrop"} ne "") {
			&tellRoom($objects[$me]{"location"}, $me,
				$objects[$me]{"name"} . " " .
				&substitute($me, $objects[$id]{"odrop"}));
		} else {
			&tellRoom($objects[$me]{"location"}, $me,
				$objects[$me]{"name"} . " dropped " .
				$objects[$id]{"name"} . "."); 
		}
	}
}

sub get
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($id);
	if ($arg eq "") {
		&tellPlayer($me, "Syntax: get thing");
		return;
	}
	if ($arg eq "me") {
		$id = $me;
	} else {
		$id = &findContents($objects[$me]{"location"}, $arg);
	}
	if ($id == $none) {
		&tellPlayer($me, "I don't see that here.");
		return;
	} else {
		if ($id == $me) {
			&tellPlayer($me, "How autoerotic.");
			return;
		}
		if ((!&testLock($me, $id)) ||
			(($objects[$id]{"type"} != $thing) &&
			($objects[$id]{"type"} != $topic) &&
			($objects[$id]{"type"} != $exit))) 
		{
			&fail($me, $id, "You can't pick that up!", "");
			return;
		}
		if ($objects[$id]{"type"} == $exit) {
			if ((!&wizardTest($me)) && 
				($objects[$id]{"owner"} != $me)) 
			{
				&tellPlayer($me, "You don't own that.");
				return;
			}
		}
		&removeContents($objects[$me]{"location"}, $id);
		&addContents($me, $id);
		&tellRoom($objects[$me]{"location"}, $me,
			$objects[$me]{"name"} . " got " .
			$objects[$id]{"name"} . "."); 
		&success($me, $id, 
			"You picked up " . $objects[$id]{"name"} . ".", "");
	}
}

sub home
{
	my($me, $arg, $arg1, $arg2) = @_;
	&sendHome($me);
}

sub tellWizards
{
	my($msg) = @_;
	my($i);
	for ($i = 0; ($i <= $#activeFds); $i++) {
		my($e) = $activeFds[$i]{"id"};
		if ($e != $none) {
			if ($objects[$e]{"httpRecent"}) {
				next;
			}
			if (&wizardTest($e)) {
				&tellPlayer($e, $msg);
			}
		}
	}	
	foreach $e (@httpActiveIds) {
		if ($e != $none) {
			if (&wizardTest($e)) {
				&tellPlayer($e, $msg);
			}
		}
	}		
}

sub who
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($e, $hash, $i);
	&tellPlayer($me, 
		sprintf("%-12.12s%-8.8s%-8.8s%-48s", 
			"User", "On", "Idle", "Doing"));
	my($idlesecs, $idle, $onsecs, $on, $whostr);
	for ($i = 0; ($i <= $#activeFds); $i++) {
		$e = $activeFds[$i]{"id"};
		if ($e != $none) {
			if ($objects[$e]{"httpRecent"}) {
				next;
			}
			$idlesecs = $now - $objects[$e]{"last"};
			$idle = &timeFormat($idlesecs);
			$onsecs = $now - $objects[$e]{"on"};
			$on = &timeFormat($onsecs);
			my($name);
			$name = sprintf("%-12.12s", $objects[$e]{"name"});
			$name = "\x01" . $name . ",look " . $objects[$e]{"name"} . "\x02";
			&tellPlayer($me, 
				sprintf("%s%-8.8s%-8.8s%-48s", 
					$name, $on, 
					$idle, $objects[$e]{"doing"}));
		}
	}	
	foreach $e (@httpActiveIds) {
		if ($e != $none) {
			$idlesecs = $now - $objects[$e]{"last"};
			$idle = &timeFormat($idlesecs);
			$onsecs = $now - $objects[$e]{"on"};
			$on = &timeFormat($onsecs);
			&tellPlayer($me, 
				sprintf("%-12.12s%-8.8s%-8.8s%-48s", 
					$objects[$e]{"name"}, $on, 
					$idle, $objects[$e]{"doing"}));
		}
	}		
	&tellPlayer($me, "Uptime: " . &timeFormat($now - $initialized));
	&tellPlayer($me, "End of List.");
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
		&tellPlayer($me, $objects[$id]{"name"} . 
			" has never logged in.");
		return;
	}
	my($msg) = $objects[$id]{"name"} . " last logged in: " . 
		&timeAndDateFormat($me, $objects[$id]{"on"});
	&tellPlayer($me, $msg);
	if (($objects[$id]{"activeFd"} != $none) ||
		($objects[$id]{"httpRecent"}))
	{
		&tellPlayer($me, $objects[$id]{"name"} . 
			" is still logged in.");
	} elsif ($off eq "") {
		return;
	} elsif ($off > $on) {
		&tellPlayer($me, $objects[$id]{"name"} . 
			" last logged out: " . 
			&timeAndDateFormat($me, $objects[$id]{"off"}));
	} else {
		# If $on is less than $off, the mud was stopped
		# before they logged off, so logoff time is indeterminate.
	}
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

sub shutdown
{
	my($me, $arg, $arg1, $arg2) = @_;
	if (!&wizardTest($me)) {
		&tellPlayer($me, "Sorry, only a wizard can do that.");
		return;
	}
	&dump($me, $arg, $arg1, $arg2);
	my($i);
	close(LISTENER);
	for ($i = 0; ($i <= $#activeFds); $i++) {
		if ($activeFds[$i]{"id"} != $none) {
			&sendHome($activeFds[$i]{"id"});
		}
		&closeActiveFd($i);
	}
	if ($commandLogging) {
		close(CLOG);
	}
	exit 0;
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
	if (!open(OUT, ">$dbFile.tmp")) {
		if ($me != $none) {
			&tellPlayer($me, 
				"Unable to write to $dbFile.tmp\n");
		} 
		return;
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
			if ($attribute eq "httpRecent") {
				# Connection dependent. Don't save it.
				next;
			}
			if ($attribute eq "lastPing") {
				# Connection dependent. Don't save it.
				next;
			}
			if ($attribute eq "httpOutput") {
				# Connection dependent. Don't save it.
				next;
			}
			if ($attribute eq "httpNewBatch") {
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
		&wall(1, "Warning: couldn't complete save to $dbfile.tmp!");
		# Don't try again right away
		$lastdump = $now;
		return;
	}
	unlink("$dbFile");
	rename "$dbFile.tmp", "$dbFile";	
	if ($me != $none) {
		&tellPlayer($me, "Dump complete.");
	}
	$lastdump = $now;
}

sub help
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($found);
	if ($arg eq "") {
		$arg = "index";
	}
	$arg = "*" . $arg;
	if (!open(IN, $helpFile)) {
		&tellActiveFd($i, "ERROR: the file " . $fname .
			" is missing.");
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
}

sub motd
{
	my($me, $arg, $arg1, $arg2) = @_;
	&sendFile($me, $motdFile);	
}

sub welcome
{
	my($me, $arg, $arg1, $arg2) = @_;
	&sendFile($me, $welcomeFile);	
}

sub set
{
	my($me, $arg, $arg1, $arg2) = @_;
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
				&tellPlayer($me, "Player #1 is always a wizard.");
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
				&tellPlayer($me, "Player #1 is always a wizard.");
				return;
			}
		}
		$objects[$id]{"flags"} |= $flag;
		&tellPlayer($me, "Flag set.");
	}	
}

sub whisper
{
	my($me, $arg, $arg1, $arg2) = @_;

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
	for ($i = 0; ($i < int(@ids)); $i++) {
		if ($i > 0) {
			if ($i == (int(@ids) - 1)) {
				$names .= " and ";
			} else {
				$names .= ", ";
			}
		}
		$names .= $objects[$ids[$i]]{"name"};
	}
	$names .= ".";
	my(%ids);
	for $id (@ids) {	
		if (exists($ids{$id})) {
			next;
		}
		$ids{$id} = 1;
		my($n) = $objects[$id]{"name"};
		$lnames = $names;
		$lnames =~ s/ $n([,\.\ ])/ you$1/;
		&tellPlayer($id, $objects[$me]{"name"} . " whispers, \"" .
			$arg2 . "\" to$lnames");
	}	
	&tellPlayer($me, "You whisper \"" . $arg2 . "\" to$names");
}

sub getIdsSpokenTo
{
	my($me, $arg1) = @_;
	my(@refs) = split(/,/, $arg1);
	my(@ids);
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
		if (($objects[$id]{"activeFd"} == $none) &&
			(!$objects[$id]{"httpRecent"}))
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
		my($output) = "You say$to, \"" . $arg2 . "\" $tn";
		my($prefix) = &getTopicPrefix($me);
		$output = "$prefix$output";
		&tellPlayer($me, $output);
		&tellRoom($objects[$me]{"location"}, $me, 
			$objects[$me]{"name"} . " says, \"" . $arg2 . "\" $tn",
			$objects[$me]{"name"}, $objects[$id]{"name"});
	} else {
		my($s);
		if (!($arg2 =~ /^[,']/)) {
			$s = " ";
		}
		&tellRoom($objects[$me]{"location"}, "", 
			$objects[$me]{"name"} . $s . $arg2 . " $tn",
			$objects[$me]{"name"}, $objects[$id]{"name"});
	}
	$objects[$id]{"lastuse"} = time;
}

sub setDescription
{
	my($me, $arg, $arg1, $arg2) = @_;
	&setField($me, $arg, $arg1, $arg2, 
		"description", "Description");
}

sub setFail
{
	my($me, $arg, $arg1, $arg2) = @_;
	&setField($me, $arg, $arg1, $arg2, 
		"fail", "Fail");
}

sub setOfail
{
	my($me, $arg, $arg1, $arg2) = @_;
	&setField($me, $arg, $arg1, $arg2, 
		"ofail", "Ofail");
}

sub updateMailAliases
{
	my($key, $val);
	if (!open(OUT, ">$mailAliasesFile")) {
		print STDERR "PerlMUD: Write to $mailAliasesFile failed.\n";
		return;
	}
	while (($key, $val) = each (%playerIds)) {
		my($name) = $objects[$val]{"name"};
		my($email) = $objects[$val]{"email"};
		if ($email eq "") {
			next;
		}
		$name =~ s/[^\w\@\.\!\-]//g;
		$email =~ s/[^\w\@\.\!\-]//g;
		print OUT "$name:\t$email\n";
	}	
	close(OUT);
	if ($updateMailAliasesCommand ne "") {
		system($updateMailAliasesCommand);
		return 1;
	} else {
		return 0;
	}
}

sub updateApachePasswords
{
	my($key, $val);
	if (!open(OUT, ">$apachePasswordsFile")) {
		print STDERR "PerlMUD: Write to $apachePasswordsFile filed.\n";
		return;
	}
	while (($key, $val) = each (%playerIds)) {
		my($password) = $objects[$val]{"password"};
		my($enc) = crypt($password,
			pack("CC", 
			ord('a') + rand(26), 
			ord('a') + rand(26)));
		my($name) = $objects[$val]{"name"};
		print OUT "$name:$enc\n";
	}	
	close(OUT);
}

sub setOdrop
{
	my($me, $arg, $arg1, $arg2) = @_;
	&setField($me, $arg, $arg1, $arg2, 
		"odrop", "Odrop");
}

sub setSuccess
{
	my($me, $arg, $arg1, $arg2) = @_;
	&setField($me, $arg, $arg1, $arg2, 
		"success", "Success");
}

sub setOsuccess
{
	my($me, $arg, $arg1, $arg2) = @_;
	&setField($me, $arg, $arg1, $arg2, 
		"osuccess", "Osuccess");
}

sub setRows
{
	my($me, $arg, $arg1, $arg2) = @_;
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
		return $none;
	} else {
		if (($objects[$id]{"owner"} != $me) && (!&wizardTest($me))) {
			&tellPlayer($me, "That doesn't belong to you!");
			return $none;
		} else {
			if ($objects[$id]{"type"} != $player) {
				&tellPlayer($me, "That is not a player!");
				return $none;
			}	
			if (($arg2 < 5) || ($arg2 > 200)) {
				&tellPlayer($me, 
					"Rows must be set to a value between 5 and 200.");
				return $none;
			}
			if ($arg2 eq "") {
				$objects[$id]{"httpRows"} = $httpRows;
				&tellPlayer($me, "Rows reset to " . 
				$httpRows . ".");
			} else {
				$objects[$id]{"httpRows"} = $arg2;
				&tellPlayer($me, "Rows set.");
			}
		}
	}
	return $id;
}

sub setLock
{
	my($me, $arg, $arg1, $arg2) = @_;
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
}

sub sign
{
	my($me, $arg, $arg1, $arg2) = @_;
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
		$objects[$me]{"name"} . 
		" adds a signature to " . $objects[$id]{"name"} . ".");
}

sub unsign
{
	my($me, $arg, $arg1, $arg2) = @_;
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
}

sub visibleCanonicalizeWord
{
	my($me, $word) = @_;
	my($id);
	$word =~ s/\s+$//;
	$word =~ s/^\s+//;
	if ($word eq "") {
		return;
	}
	$word = &canonicalizeWord($me, $word);
	
	# Additional canonicalization
	$id = &findContents($me, $word);
	if ($id != $none) {
		$word = "#" . $id;
	} else {	
		$id = &findContents(
			$objects[$me]{"location"}, $word);
		if ($id != $none) {
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
		&tellPlayer($me, "I don't see that here.");
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
	if (($objects[$id]{"activeFd"} == $none) &&
		(!$objects[$id]{"httpRecent"})) 
	{
		&tellPlayer($me, "That player is not logged in.");
		return;
	}
	if ($arg2 eq "") {
		&tellPlayer($id, $objects[$me]{"name"} . 
			" is looking for you in " . 
			$objects[$objects[$me]{"location"}]{"name"} . ".");
		&tellPlayer($me, "You paged " . $objects[$id]{"name"} . ".");
	} else {		
		&tellPlayer($id, $objects[$me]{"name"} . " pages: " . $arg2);
		&tellPlayer($me, "You paged " . $objects[$id]{"name"} . ": " . $arg2);
	}
}	

sub boot
{
	my($me, $arg, $arg1, $arg2) = @_;
	if (!&wizardTest($me)) {
		&tellPlayer($me, "Only a wizard can do that.");
		return;
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
	&closePlayer($id, 1);
	&tellPlayer($me, "Booted.");
}	

sub name
{
	my($me, $arg, $arg1, $arg2) = @_;
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
					&tellPlayer($me, "Only a wizard can do that.");
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
				undef($playerIds{$n2});
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
			if ($objects[$id]{"type"} == $player) {
				&updateApachePasswords;
				&updateMailAliases;
			}
		}
	}
}

sub chown
{
	my($me, $arg, $arg1, $arg2) = @_;
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
			&tellPlayer($arg2Id, $objects[$me]{"name"} . 
				" has given you #" . $id . " (" .
				$objects[$id]{"name"} . ").");
		}
	}
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
	my($id);
	$id = &addObject($me, $arg1, $player);
	$playerIds{$n} = $id;
	$objects[$id]{"owner"} = $id;
	&addContents(0, $id);
	$objects[$id]{"password"} = $arg2;
	if ($allowBuild) {
		$objects[$id]{"flags"} = $builder;
	} else {
		$objects[$id]{"flags"} = 0;
	}
	&updateApachePasswords;
}

sub gag
{
	my($me, $arg, $arg1, $arg2) = @_;
	if ($arg eq "") {
		&tellPlayer($me, "Syntax: \@gag name");
		return;
	}
	if ($arg =~ / /) {
		&tellPlayer($me, "PerlMUD user names do not contain spaces.");
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
	# Look up the player. Do they exist?
	my($copy) = $arg;
	$copy =~ tr/A-Z/a-z/;
	if (!exists($playerIds{$copy})) {
		# Break the bad news
		&tellPlayer($me, "There is no player by that name.");
		return;
	}
	# Check whether that player is already gagged
	$arg = quotemeta($arg);
	if ($objects[$me]{"gags"} =~ /$arg /i) {
		&tellPlayer($me, "Already gagged.");
		return;
	}
	# Now we're ready to gag! Great!
	# Be sure to use the proper name
	# to get the right case.
	$objects[$me]{"gags"} .= $objects[$playerIds{$copy}]{"name"} . " ";
	&tellPlayer($me, "Gag in place.");
}

sub ungag
{
	my($me, $arg, $arg1, $arg2) = @_;
	if ($arg eq "") {
		&tellPlayer($me, "Syntax: \@ungag name");
		return;
	}
	if ($arg =~ / /) {
		&tellPlayer($me, "PerlMUD user names do not contain spaces.");
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

sub password
{
	my($me, $arg, $arg1, $arg2) = @_;
	if ($arg2 eq "") {
		if ($arg1 eq "") {
			&tellPlayer($me, 
				"Syntax: \@password name = password or \@password mynewpassword");
			return;
		}
		$arg2 = $arg1;
		$arg1 = "#" . $me;
	}
	my($n);
	$n = $arg1;
	$n =~ tr/A-Z/a-z/;
	my($id);
	if (substr($arg1, 0, 1) eq "#") {
		$id = substr($arg1, 1);
		$id = &idBounds($id);
	} else {
		if (!exists($playerIds{$n})) {
			&tellPlayer($me, "There is no such player.");
			return;
		}
		$id = $playerIds{$n};
	}
	if (($id != $me) && (!&wizardTest($me))) {
		&tellPlayer($me, "Sorry, you can't do that.");
		return;
	}
	if ($objects[$id]{"type"} != $player) {
		&tellPlayer($me, "That is not a player!");
		return;
	}
	$objects[$id]{"password"} = $arg2;
	&updateApachePasswords;
	&tellPlayer($me, "Password changed.");			
}

sub clean
{
	my($me, $arg, $arg1, $arg2) = @_;
	if ($arg ne "") {
		&tellPlayer($me, "\@clean takes no arguments.");
		return;
	}	
	my(@list, $e);
	@list = split(/,/, $objects[$objects[$me]{"location"}]{"contents"});
	if (($objects[$objects[$me]{"location"}]{"owner"} != $me) &&
		(!&wizardTest($me))) 
	{
		&tellPlayer($me, "You can only \@clean locations you own.");
		return;
	}		
	foreach $e (@list) {
		if ($objects[$e]{"home"} != $objects[$me]{"location"}) {
			if ($objects[$e]{"activeFd"} != $none)
			{
				# Leave conscious objects alone
				next;
			}
			if ($objects[$e]{"type"} != $exit) {
				&sendHome($e);
			}
		}
	}
}

sub teleport
{
	my($me, $arg, $arg1, $arg2) = @_;
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
	my($id);
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
	my($arg2id) = substr($arg2, 1);
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
	$id = &idBounds($id);
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
	my($oldLocation) = $objects[$id]{"location"};
	&removeContents($objects[$id]{"location"}, $id);
	&tellRoom($objects[$id]{"location"}, $none, $objects[$id]{"name"} .
		" disappears.");
	&tellRoom($arg2id, $none, $objects[$id]{"name"} .
		" materializes.");
	&addContents($arg2id, $id);
	&describe($id, $arg2id, 0);
	if ($me != $id) {
		&tellPlayer($id, $objects[$me]{"name"} . 
			" has teleported you to " . 
			$objects[$arg2id]{"name"} . ".");	
	}
	&tellPlayer($me, "Teleported.");
}

sub link
{
	my($me, $arg, $arg1, $arg2) = @_;
	if (!&builderTest($me)) {
		&tellPlayer($me, "Sorry, only an authorized builder can do that.");
		return;
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
}

sub open
{
	my($me, $arg, $arg1, $arg2) = @_;

	if (!&builderTest($me)) {
		&tellPlayer($me, "Sorry, only an authorized builder can do that.");
		return;
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

sub addContents
{
	my($addto, $add) = @_;

	# Whatever you do, don't let any commas get in here 
	$add =~ s/,//g;

	if (length($objects[$addto]{"contents"}) > 0) {
		$objects[$addto]{"contents"} .= "," . $add;
	} else {
		$objects[$addto]{"contents"} = $add;
	}
	$objects[$add]{"location"} = $addto;
}
	
sub findContents
{			  	
	my($container, $arg, $type) = @_;
	my(@list);
	$arg =~ tr/A-Z/a-z/;
	@list = split(/,/, $objects[$container]{"contents"});
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
		my($name);
		$name = $objects[$e]{"name"};
		$name =~ tr/A-Z/a-z/;
		if ($name eq $arg) {
			if ((!$type) ||
				($objects[$e]{"type"} == $type)) 
			{
				return $e;
			}
		}
		#TinyMUD semicolon stuff
		if ($objects[$e]{"type"} == $exit) {
			my(@elist);
			my(@f);
			@elist = split(/;/, $objects[$e]{"name"});
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
#Okay, now an inexact match
	foreach $e (@list) {
		my($name);
		$name = $objects[$e]{"name"};
		$name =~ tr/A-Z/a-z/;
		if (substr($name, 0, length($arg)) eq $arg) {
			if ((!$type) ||
				($objects[$e]{"type"} == $type))
			{ 
				return $e;
			}
		}
		#TinyMUD semicolon stuff
		if ($objects[$e]{"type"} == $exit) {
			my(@elist);
			my(@f);
			@elist = split(/;/, $objects[$e]{"name"});
			foreach $f (@elist) {
				$f =~ tr/A-Z/a-z/;
				if (substr($f, 0, length($arg)) eq $arg) {
					if ((!$type) ||
						($objects[$e]{"type"} == $type))
					{ 
						return $e;
					}
				}
			}
		}
	}		
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
}

sub describe
{
	my($to, $what, $details) = @_;
	&describeBody(\&tellPlayer, $to, $to, $what, $details, 0);
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
		if ($objects[$what]{"email"} ne "") {
			$line .= " email";
		}
		&{$output}($dest, $line);
		if ($objects[$what]{"type"} == $player) {
			my($tz) = $objects[$what]{"tz"};
			if ($tz eq "") {
				&{$output}($dest, "Time Zone: Not Set");
			} else {	
				my($prefix) = "";
				if ($tz < 0) {
					$tz = -$tz;
					$prefix = "-";
				}
				my($hours, $mins) = 
					(int($tz / 60),
						$tz % 60);
				&{$output}($dest, "Time Zone: " . 
					sprintf("%s%02d:%02d",
						$prefix,
						$hours,
						$mins));
			}
		}
		if (&wizardTest($to) || ($objects[$what]{"owner"} == $to)) {
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
			if ($objects[$what]{"email"} ne "") {
				&{$output}($dest, "Email: " . $objects[$what]{"email"});
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
		if (&wizardTest($to) || ($objects[$what]{"owner"} == $to)) {
			if ($objects[$what]{"type"} == $exit) {
				my($dest);
				$dest = int($objects[$what]{"action"});
				if ($dest == $nowhere) {
					&{$output}($dest, "Destination: nowhere");
				} elsif ($dest == $home) {
					&{$output}($dest, "Destination: home");
				} else {
					&{$output}($dest, "Destination: #" . int($objects[$what]{"action"}));
				}
			}
		}
	} else {
		if ($objects[$what]{"type"} != $exit) {
			&{$output}($dest, $objects[$what]{"name"});
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
			if ($details) {
				$found = 1;
				if ($first) {
					$first = 0;
				} else {
					$desc .= ", ";
				}		
				$desc .= $objects[$e]{"name"} . " #" . $e;
			} else {
				if (($objects[$e]{"type"} == $thing) ||
					($objects[$e]{"type"} == $player)) 
				{
					$found = 1;
					if ($first) {
						$first = 0;
					} else {
						$desc .= ", ";
					}		
					$desc .= "\x01" . $objects[$e]{"name"} . "," .
						"look " . 
						$objects[$e]{"name"} . "\x02";
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
	$first = 1;
	$desc = "";
	$found = 0;
	if (($objects[$what]{"type"} == $room) && (!$details)) {
		foreach $e (@list) {
			$found = 1;
			if (!$details) {
				if (($objects[$e]{"type"} == $exit) &&
					(!($objects[$e]{"flags"} & $dark))) {
					if ($first) {
						$first = 0;
					} else {
						$desc .= ", ";
					}		
					my(@foo) = split(/;/, 
						$objects[$e]{"name"});
					$desc .= "\x01" . $foo[0] . "," .
						$foo[0] . "\x02";
				}
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
	if (!$details) {
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
}

sub tellRoom
{
	my($id, $blind, $what, $from, $topic) = @_;
	my($e, @list);
	my($fromText);
	if ($topic eq "") {
		$fromText = " (from $from)" if ($from ne "");
	}
	@list = split(/,/, $objects[$id]{"contents"});
	foreach $e (@list) {
		if ($objects[$e]{"type"} == $player) {  
			if ($e != $blind) {
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
					&tellPlayer($e, $msg);
				}
			}
		}
	}			
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
	for $t (@topics) {
		my($qm) = quotemeta($topic);
		if ($t =~ /^$qm$/i) {
			return !$default;
		}
	}
	return $default;
}

sub joinTopic
{
	my($me, $arg, $arg1, $arg2) = @_;
	&joinTopicBody($me, $arg, $arg1, $arg2, 1);
}

sub leaveTopic
{
	my($me, $arg, $arg1, $arg2) = @_;
	&joinTopicBody($me, $arg, $arg1, $arg2, 0);
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
	my(%topics);
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
	while (($key, $value) = each(%topics)) {
		if ($value) {
			push @topics, $key;	
		}
	}
	$objects[$me]{"topics"} = join(',', @topics);
	&tellPlayer($me, "Topic list updated.");
}


sub tellPlayer
{
	my($who, $what) = @_;
	$what =~ s/\s+$//;
	# Filter annoyances out (apply gag filters).
	my($name);
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
	if ($objects[$who]{"httpRecent"}) {
		if ($objects[$who]{"httpNewBatch"}) {
			$objects[$who]{"httpOutput"} =~ s/$httpNewMarker//g;
			$objects[$who]{"httpOutput"} .= $httpNewMarker;
			$objects[$who]{"httpNewBatch"} = 0;
		}
		my($at);
		# HTML escapes, plus word wrap (for 70-character <PRE> "window")
		$what =~ s/&/&amp;/g;
		$what =~ s/</&lt;/g;
		$what =~ s/>/&gt;/g;
		my($nwhat);
		while (&plainlength($what) > $httpCols) {
			$at = &plainrindex($what, " ", $httpCols);
			if ($at == -1) {
				last;
			}
			$nwhat .= substr($what, 0, $at) . "\n";
			$what = substr($what, $at + 1);
		}
		$nwhat .= $what;
		$nwhat = &linkUrls($nwhat);
		$nwhat =~ s/\x01([^\,\x02]+)\,([^\,\x02]+)\x02/&linkEmbed($1, $2)/ge;
		$objects[$who]{"httpOutput"} .= $nwhat . "\n";			
	} elsif ($objects[$who]{"activeFd"} ne $none) {
		$what =~ s/\x01([^\,\x02]+)\,([^\,\x02]+)\x02/$1/g;
		&tellActiveFd($objects[$who]{"activeFd"}, $what);
	}
}

sub tellActiveFd
{
	my($active, $what) = @_;
	if ($activeFds[$active]{"protocol"} == $http) {
		$activeFds[$active]{"outbuf"} .= $what . "\n";
	} else {
		$activeFds[$active]{"outbuf"} .= $what . "\r\n";
		while (length($activeFds[$active]{"outbuf"}) > $flushOutput) {
			$activeFds[$active]{"outbuf"} = "*FLUSHED*" . 
				substr($activeFds[$active]{"outbuf"}, $flushOutput / 2);
		}
	}
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
					$dbVersion . " to read it.\n";						close(IN);
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
			if ($id == 1) {
				$objects[1]{"flags"} |= $wizard;
			}
			if ($objects[$id]{"type"} == $player) {
				my($n);
				$n = $objects[$id]{"name"};
				$n =~ tr/A-Z/a-z/;
				$playerIds{$n} = $id;
			}		
			# GOTCHA: $none and 0 are different
			$objects[$id]{"activeFd"} = $none;
		} else {
			$objects[$id]{"flags"} = <IN>;
			chomp $objects[$id]{"flags"};
			$objects[$id]{"activeFd"} = $none;
			if ($id == 1) {
				$objects[1]{"flags"} |= $wizard;
			}
			$objects[$id]{"success"} = <IN>;
			chomp $objects[$id]{"success"};
			$objects[$id]{"osuccess"} = <IN>;
			chomp $objects[$id]{"osuccess"};
			$objects[$id]{"fail"} = <IN>;
			chomp $objects[$id]{"fail"};
			$objects[$id]{"ofail"} = <IN>;
			chomp $objects[$id]{"ofail"};
			$objects[$id]{"dropto"} = <IN>;
			chomp $objects[$id]{"dropto"};
			$objects[$id]{"lock"} = <IN>;
			chomp $objects[$id]{"lock"};
			$objects[$id]{"odrop"} = <IN>;
			chomp $objects[$id]{"odrop"};
			$objects[$id]{"name"} = <IN>;
			chomp $objects[$id]{"name"};
			my($t);
			$t = <IN>;
			chomp $t;
			($objects[$id]{"description"} = $t) =~ s/\\n/\r\n/g;
			$objects[$id]{"type"} = <IN>;
			chomp $objects[$id]{"type"};

			if ($objects[$id]{"type"} == $player) {
				my($n);
				$n = $objects[$id]{"name"};
				$n =~ tr/A-Z/a-z/;
				$playerIds{$n} = $id;
				# Grandfather old builders when upgrading
				# the database, if the $allowBuild 
				# configuration flag has been set. 
				if ($allowBuild) {
					$objects[$id]{"flags"} |= $builder;
				}
			}

			$objects[$id]{"owner"} = <IN>;
			chomp $objects[$id]{"owner"};
			$objects[$id]{"location"} = <IN>;
			chomp $objects[$id]{"location"};
			$objects[$id]{"action"} = <IN>;
			chomp $objects[$id]{"action"};
			$objects[$id]{"contents"} = <IN>;
			chomp $objects[$id]{"contents"};
			$objects[$id]{"password"} = <IN>;
			chomp $objects[$id]{"password"};
			$objects[$id]{"home"} = <IN>;
			chomp $objects[$id]{"home"};
			if ($dbVersion < 1.0) {
				next;
			}
			$objects[$id]{"httpRows"} = <IN>;
			chomp $objects[$id]{"httpRows"};
			if ($dbVersion < 2.0) {
				# Then they almost certainly want this
				$objects[$id]{"httpRows"} = $httpRows;
			}
			# For compatibility with 3.0
			$objects[$id]{"view"} = <IN>;
			chomp $objects[$id]{"view"};
			$objectOrientations = <IN>;
			chomp $objects[$id]{"orientation"};
		}
	}
	close(IN);
	return 1;
}

sub mindb
{
	$objects[0]{"name"} = "Void";
	$objects[0]{"type"} = $room;
	$objects[0]{"contents"} = "1";
	$objects[0]{"owner"} = 1;

	$objects[1]{"name"} = "Admin";
	$objects[1]{"type"} = $player;
	$objects[1]{"location"} = 0;
	$objects[1]{"owner"} = 1;
	$objects[1]{"password"} = "initial";
	$objects[1]{"activeFd"} = $none;
	$objects[1]{"flags"} |= $wizard;
	$playerIds{"admin"} = 1;
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
		&tellActiveFd($i, "ERROR: the file " . $fname .
			" is missing.");
		return;
	}
	while(<IN>) {
		s/\s+$//;	
		&tellActiveFd($i, $_);
	}
	close(IN);
}

sub dropAll
{
	my($container) = @_;
	my(@list);
	@list = split(/,/, $objects[$container]{"contents"});
	my($e);
	foreach $e (@list) {
		&command($container, "drop #" . $e);	
	}
	if (!int(@list)) {
		&tellPlayer($container, "You are not carrying anything.");
	}	
}
 
sub sendHome
{	
	my($me) = @_;
	if ($objects[$objects[$me]{"location"}]{"flags"} & $puzzle) {
		&dropAll($me);
	}
	&removeContents($objects[$me]{"location"}, $me);
	if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand)) {
		&tellRoom($objects[$me]{"location"}, $none,
			$objects[$me]{"name"} . " goes home.");
	}
	&addContents($objects[$me]{"home"}, $me);
	if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand)) {
		&tellRoom($objects[$me]{"location"}, $me,
			$objects[$me]{"name"} . " arrives at home.");
	}
	&tellPlayer($me, "You go home.");
	&look($me, "", "", "");
}

sub timeFormat
{
	my($secs, $output) = @_;
	if ($secs < 60) {
		$output = $secs . "s";
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
	if (!(/^[,']/)) {
		$arg = " " . $arg;
	}
	&tellRoom($objects[$me]{"location"}, $none, $objects[$me]{"name"} . $arg);
}

sub purge
{
	my($me, $arg, $arg1, $arg2) = @_;
	my($count);
	my(%junk);
	if (!&wizardTest($me)) {
		&tellPlayer($me, "Sorry, that command is for wizards only.");
		return;
	}
	# First pass: find junk; flag it as such
	for ($i = 0; ($i <= $#objects); $i++) {
		if ($i < 2) {
			# Objects 0 and 1 are indestructible
			next;
		}
		if (!($i % 100)) {
			print STDERR "Purging: scanned $i of $#objects\n";	
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
			print STDERR "Purging: cleaned $i of $#objects\n";
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
		for $l (@list) {	
			if ($junk{$l}) {
				next;
			}
			push @nlist, $l;
		}
		$objects[$i]{"contents"} = join(",", @nlist);
	}
	&tellPlayer($me, "$count broken objects recycled.");
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
}

sub say 
{
	my($me, $arg, $arg1, $arg2, $to) = @_;
	$arg =~ s/^\s+//;
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
			$names .= $objects[$ids[$i]]{"name"};
		}
		$to = " to $names";
	}
	&tellPlayer($me, "You say$to, \"" . $arg . "\"");
	&tellRoom($objects[$me]{"location"}, $me, $objects[$me]{"name"} . 
		" says$to, \"" . $arg . "\"");
}

sub wall
{
	my($me, $arg, $arg1, $arg2) = @_;
	if (!&wizardTest($me)) {
		&tellRoom($me, "Only a wizard can do that.");
		return;
	}
	$arg =~ s/^\s+//;
	my($o);
	for $o (@objects) {
		if ($o->{"type"} == $player) {
			&tellPlayer($o->{"id"},	
				$objects[$me]{"name"} . " yells, \"" 
				. $arg . "\"");
		}
	}
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
		&tellRoom($objects[$me]{"location"}, $me, $objects[$me]{"name"} . 
			" " . &substitute($me, $objects[$id]{"osuccess"}));
	} else {
		if ($odefault ne "") {
			&tellRoom($objects[$me]{"location"}, $me, $odefault);
		}
	}
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
		&tellRoom($objects[$me]{"location"}, $me, $objects[$me]{"name"} . 
			" " . &substitute($me, $objects[$id]{"ofail"}));
	} else {
		if ($odefault ne "") {
			&tellRoom($objects[$me]{"location"}, $me, $odefault);
		}
	}
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
		$expr .= &lockEvalWord($me, $word);
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
	if ($word eq "me") {
		$word = "#" . $me;
	} elsif ($word eq "here") {	
		$word = "#" . $objects[$me]{"location"};
	} elsif (substr($word, 0, 1) eq "*") {
		my($name);
		($name = substr($word, 1)) =~ tr/A-Z/a-z/;
		if (exists($playerIds{$name})) {
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
	if (&findContents($me, $word) != $none) {
		return 1;
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
		$s = $objects[$me]{"name"};
	} elsif ($objects[$me]{"flags"} & $female) {
		$s = "she";
	} elsif ($objects[$me]{"flags"} & $male) {
		$s = "he";
	} else {
		$s = "it";
	}
	$arg =~ s/\%s/$s/ge;
	$n = $objects[$me]{"name"};
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
		$a = $objects[$me]{"name"} . "'s";
	} elsif ($objects[$me]{"flags"} & $female) {
		$a = "hers";
	} elsif ($objects[$me]{"flags"} & $male) {
		$a = "his";
	} else {
		$a = "its";
	}
	$arg =~ s/\%a/$a/ge;	
	if (($objects[$me]{"flags"} & $herm) == $herm) {
		$o = $objects[$me]{"name"};
	} elsif ($objects[$me]{"flags"} & $female) {
		$o = "her";
	} elsif ($objects[$me]{"flags"} & $male) {
		$o = "him";
	} else {
		$o = "it";
	}
	$arg =~ s/\%o/$o/ge;
	if (($objects[$me]{"flags"} & $herm) == $herm) {
		$r = $objects[$me]{"name"};
	} elsif ($objects[$me]{"flags"} & $female) {
		$r = "herself";
	} elsif ($objects[$me]{"flags"} & $male) {
		$r = "himself";
	} else {
		$r = "itself";
	}
	$arg =~ s/\%r/$r/ge;

	$uname = substr($objects[$me]{"name"}, 0, 1);
	$uname =~ tr/a-z/A-Z/;
	$uname .= substr($objects[$me]{"name"}, 1);
	
	if (($objects[$me]{"flags"} & $herm) == $herm) {
		$s = $uname;
	} elsif ($objects[$me]{"flags"} & $female) {
		$s = "She";
	} elsif ($objects[$me]{"flags"} & $male) {
		$s = "He";
	} else {
		$s = "It";
	}
	$arg =~ s/\%S/$s/ge;
	$n = $uname;
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
		$a = $uname . "'s";
	} elsif ($objects[$me]{"flags"} & $female) {
		$a = "Hers";
	} elsif ($objects[$me]{"flags"} & $male) {
		$a = "His";
	} else {
		$a = "Its";
	}
	$arg =~ s/\%A/$a/ge;	
	if (($objects[$me]{"flags"} & $herm) == $herm) {
		$o = $uname;
	} elsif ($objects[$me]{"flags"} & $female) {
		$o = "Her";
	} elsif ($objects[$me]{"flags"} & $male) {
		$o = "Him";
	} else {
		$o = "It";
	}
	$arg =~ s/\%O/$o/ge;
	if (($objects[$me]{"flags"} & $herm) == $herm) {
		$r = $uname;
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

sub readData
{
	my($i, $fd) = @_;
	my($got, $len);
	# Append to the input buffer
	$len = length($activeFds[$i]{"inbuf"});
	$got = sysread($fd, $activeFds[$i]{"inbuf"}, 4096, $len);
	if (($got == 0) || 
		((!defined($got)) && ($! != EINTR) && ($! != EAGAIN))) {
		&closeActiveFd($i);
		return;
	}
	&examineData($i);
}

sub examineData
{
	my($i) = @_;
	my($where);
	if ($activeFds[$i]{"protocol"} == $http) {
		if ($activeFds[$i]{"state"} == $httpReadingHeaders) {
			# MONDO TEDIUM
			my($breaklength);
			my($where, $whereTry);
			$whereTry = index($activeFds[$i]{"inbuf"}, "\n\n");
			$breaklength = 2;
			$where = $whereTry;
			$whereTry = index($activeFds[$i]{"inbuf"}, "\r\r");
			if (($where == -1) || 
				(($whereTry != -1) && ($whereTry < $where))) {
				$where = $whereTry;
			}	
			$whereTry = index($activeFds[$i]{"inbuf"}, "\n\r\n\r");
			if (($where == -1) || 
				(($whereTry != -1) && ($whereTry < $where))) {
				$breaklength = 4;
				$where = $whereTry;
			}	
			$whereTry = index($activeFds[$i]{"inbuf"}, "\r\n\r\n");
			if (($where == -1) || 
				(($whereTry != -1) && ($whereTry < $where))) {
				$breaklength = 4;
				$where = $whereTry;
			}	
			if ($where == -1) {
				return;
			}
			$activeFds[$i]{"name"} = "";
			$activeFds[$i]{"password"} = "";
			my($request, @headers, $header);
			$request = substr($activeFds[$i]{"inbuf"},
				0, $where);
			$activeFds[$i]{"inbuf"} = substr($activeFds[$i]{"inbuf"},
				$where + $breaklength);
			$request =~ s/\r\n/\n/g;
			$request =~ s/\r/\n/g;
			@headers = split(/\n/, $request);
			foreach $header (@headers) {
				my($attr, $value) = split(/\s*:\s*/, $header); 
				$attr =~ tr/A-Z/a-z/;
				if ($attr eq "content-length") {
					$activeFds[$i]{"length"} = $value;
					$activeFds[$i]{"state"} = $httpReadingBody;
					$activeFds[$i]{"request"} = $request;
				} elsif ($attr eq "content-type") {
					$activeFds[$i]{"type"} = $value;
				} elsif ($attr eq "authorization") {
					my($scheme, $value) = split(/\s+/, 
						$value);		
					$scheme =~ tr/A-Z/a-z/;
					if ($scheme eq "basic") {
						$value = &base64decode($value);
						($activeFds[$i]{"name"}, 	
						$activeFds[$i]{"password"}) = 
							split(/:/, $value);
					}
				}
			}
			# No body in this request
			if ($activeFds[$i]{"state"} == $httpReadingHeaders) {
				&httpHandleRequest($i, $request, "",
					$activeFds[$i]{"name"},
					$activeFds[$i]{"password"});
				return;	
			}
		}
		if ($activeFds[$i]{"state"} == $httpReadingBody) {
			if (length($activeFds[$i]{"inbuf"}) >= 
				$activeFds[$i]{"length"}) 
			{	
				&httpHandleRequest($i, 
					$activeFds[$i]{"request"},
					$activeFds[$i]{"inbuf"},
					$activeFds[$i]{"name"},
					$activeFds[$i]{"password"});
			}
			return;
		}
	}
			
	# Split into commands
	if ($activeFds[$i]{"inbuf"} =~ /\n/) {
		@commands = 
			split(/\n/, 
			$activeFds[$i]{"inbuf"});
		my($e);
		my($end);
		$_ = $activeFds[$i]{"inbuf"};
		if (!(/\n$/)) {
			$end = $#commands - 1;
		} else {
			$end = $#commands;
		}
		for ($e = 0; ($e <= $end); $e++) {
			if (length($commands[$e])) {
				&input($i, 
					$commands[$e]);
			}
		}
		if ($end == ($#commands - 1)) {
			$activeFds[$i]{"inbuf"} = 
				$commands[$#commands];
		} else {
			$activeFds[$i]{"inbuf"} = "";
		}
	}
	if (length($activeFds[$i]{"inbuf"}) >= 4096) {
		&input($i, $activeFds[$i]{"inbuf"});
		$activeFds[$i]{"inbuf"} = "";
	}
}	

sub writeData
{
	my($i, $fd) = @_;
	my($got, $len);

	# Try to send the output buffer
	$len = length($activeFds[$i]{"outbuf"});
	$got = syswrite($fd, $activeFds[$i]{"outbuf"}, 
		$len);
	if  ((!defined($got)) && ($! != EINTR) && ($! != EAGAIN)) {
		&closeActiveFd($i);
		return;
	}
	$activeFds[$i]{"outbuf"} = substr(
		$activeFds[$i]{"outbuf"}, $got);
	if ($activeFds[$i]{"protocol"} == $http) {
		if (!length($activeFds[$i]{"outbuf"})) {
			closeActiveFd($i);
		}			
	}	
}

sub tellActiveFdHtml
{
	my($fd, $arg) = @_;
	&tellActiveFd($fd, $arg);
	&tellActiveFd($fd, "<br>");
}

sub httpHandleRequest
{
	my($i, $request, $body, $name, $password) = @_;
	my(@fields, $method, $rawUrl, $url, 
		$protocol, $id, $key, $val, $query,
		$dummy);
	$activeFds[$i]{"outbuf"} = "";
	$activeFds[$i]{"inbuf"} = "";
	$activeFds[$i]{"state"} = $httpWriting;
	@fields = split(/\n/, $request);
	if ($#fields < 0) {
		# Guh?
		&closeActiveFd($i);
		return;
	}	
	@fields = split(/ /, $fields[0]);
	if ($#fields < 2) {
		# Double guh
		&closeActiveFd($i);		
		return;
	}
	$method = $fields[0];
	$rawUrl = join(" ", @fields[1 .. ($#fields - 1)]);
	$protocol = $fields[$#fields];
	# The next session's unique URL component
	my($sessionId);
	$sessionId = int(rand(20000));
	($dummy, $dummy, $url) = split(/\//, $rawUrl);
	if ($url eq "") {
		$url = $dummy;
	}
	$name =~ tr/A-Z/a-z/; 
	%in = &parseFormSubmission($i, $body);
	if (($name eq "") || ($playerIds{$name} <= 0) ||
		($objects[$playerIds{$name}]{"password"} ne $password)) 
	{
		if (($rawUrl eq "/") || ($rawUrl eq "")) {
			&frontDoor($i);
			return;
		} elsif ($rawUrl eq "/apply") {
			&application($i);
			return;
		} elsif ($rawUrl eq "/completed") {
			&completedApplication($i, $body);
			return;
		}
		&tellActiveFd($i, "HTTP/1.0 401 Unauthorized");
		&tellActiveFd($i, "Server: PerlMUD/" . $perlMudVersion);
		&tellActiveFd($i, "WWW-Authenticate: Basic realm=\"PerlMUD\"");
		&tellActiveFd($i, "Content-type: text/html");
		&tellActiveFd($i, "");
		&tellActiveFd($i, "<HEAD><TITLE>Authorization Required</TITLE></HEAD>");
		&tellActiveFd($i, "<BODY><H1>Login Required</H1>");
		&tellActiveFd($i, $serverName . " could not verify that you");
		&tellActiveFd($i, "are a user of the system. ");
		&tellActiveFd($i, "Either you supplied the wrong");
		&tellActiveFd($i, "credentials (e.g., bad password), or your");
		&tellActiveFd($i, "web browser doesn't understand how to");
		&tellActiveFd($i, "prompt you for the information.<P>");
		&tellActiveFd($i, "</BODY>");
		return;
	}
	$id = $playerIds{$name};
	&tellActiveFd($i, "HTTP/1.0 200 Success");
	&tellActiveFd($i, "Server: PerlMUD/" . $perlMudVersion);
	# For crying out loud, PLEASE DON'T cache this! Thanks! Geez!
	if ($url =~ /^upper/) {
		&tellActiveFd($i, "Pragma: no-cache");
		&tellActiveFd($i, "Expires: Thursday, 2 Jan 97");
		&tellActiveFd($i, "Cache-control: no-store");
	}
	# Top page
	if ($url =~ /^command:(\S+)$/) {
		# An embedded command. Always produces a new frameset.
		my($c) = $1;
		$c =~ s/%(..)/pack("c",hex($1))/ge;
		&command($id, $c);
		$url = "command";
	} else {
		# Execute the command right away to find out if the
		# user's orientation has changed. 
		&command($id, $in{"command"});
	}	
	if ($url eq "upper") {
		my($s);
		$s = "Refresh: " . $httpRefreshTime .
			"; URL=/" . $sessionId . "/upper#newest";
		&tellActiveFd($i, $s);
		&tellActiveFd($i, "Window-target: upper");
	}
	&tellActiveFd($i, "Content-type: text/html");	
	&tellActiveFd($i);
	if ($url eq "lower") {
		&outputCommandForm($i, 1, $sessionId);
		return;
	}
	if ($url ne "upper") {
		&tellActiveFd($i, "<html>");
		&tellActiveFd($i, "<head>");
		&tellActiveFd($i, "<title>" . $serverName . " WWW Client</title>");
		&tellActiveFd($i, "</head>");
		&tellActiveFd($i, "<frameset rows=\"*, 40\"");
		&tellActiveFd($i, "onLoad=\"frames[1].document.commands.command.focus();\">");
#		&tellActiveFd($i, "<frame name=\"view\" ");
#		&tellActiveFd($i, "marginheight=\"1\" ");
#		&tellActiveFd($i, "src=\"/" .  $sessionId . "/view\">");
		&tellActiveFd($i, "<frame name=\"upper\" ");
		&tellActiveFd($i, "marginheight=\"1\" ");
		&tellActiveFd($i, "src=\"/" .  $sessionId . "/upper#newest\">");
		&tellActiveFd($i, "<frame name=\"lower\" ");
		&tellActiveFd($i, "marginheight=\"1\" ");
		&tellActiveFd($i, "src=\"/" .  $sessionId . "/lower\">");
		&tellActiveFd($i, "</frameset>");
		if (($url eq "pureframeset") || ($url eq "upper")) {
			&tellActiveFd($i, "</html>");
			return;
		}
		&tellActiveFd($i, "<noframes>");
	}
	# Okay, it's either the upper (output) frame
	# or a no-frames client.
	if ($objects[$id]{"activeFd"} != $none) {
		closePlayer($id, 0);
	}
	if (!($objects[$id]{"httpRecent"})) {
		my($i, $found);
		$objects[$id]{"httpRecent"} = 1;
		$objects[$id]{"httpNewBatch"} = 1;	
		if (!$objects[$id]{"httpRows"}) {
			$objects[$id]{"httpRows"} = $httpRows;
		}
		if (!($objects[$objects[$id]{"location"}]{"flags"} & 
			$grand)) {
			&tellRoom($objects[$id]{"location"}, $none,
				$objects[$id]{"name"} . 
				" has connected.");
		}
		$found = 0;
		for ($i = 0; ($i <= $#httpActiveIds); $i++) {
			if ($httpActiveIds[$i] == $none) {
				$httpActiveIds[$i] = $id;
				$found = 1;
				last;
			}
		}
		if (!$found) {
			$httpActiveIds[$#httpActiveIds + 1] = 
				$id;
		}
		&login($id, $none);
	}
	$activeFds[$i]{"id"} = $id;
	my(@rows, $extra, $rows);
	$rows = $objects[$id]{"httpRows"};
	@rows = split(/\n/, $objects[$id]{"httpOutput"});
	$extra = ($#rows + 1) - $rows;
	if ($extra > 0) {
		$objects[$id]{"httpOutput"} = join("\n", 
			@rows[$extra .. $#rows]);
		$objects[$id]{"httpOutput"} .= "\n";
	}
	&tellActiveFd($i, "<pre>");
	my($copy);
	$copy = $objects[$id]{"httpOutput"};
	$copy =~ s/\s+$//;
	&tellActiveFd($i, $copy);
	&tellActiveFd($i, "</pre>");
	$objects[$id]{"lastPing"} = $now;
	if ($url ne "upper") {
		&outputCommandForm($i, 0, $sessionId);
		&tellActiveFd($i, "</noframes>");
		&tellActiveFd($i, "</html>");
	} else {
		$objects[$id]{"httpNewBatch"} = 1;	
	}
}

sub login
{
	my($id, $aindex) = @_;
	if (!($objects[$objects[$id]{"location"}]{"flags"} & $grand)) {
		&tellRoom($objects[$id]{"location"}, $none,
			$objects[$id]{"name"} . " has connected.");
	}
	$objects[$id]{"activeFd"} = $aindex;
	$objects[$id]{"on"} = $now;
	$objects[$id]{"last"} = $now;
	$objects[$id]{"lastPing"} = $now;
	&sendFile($id, $motdFile);
	&command($id, "look");
}

sub outputCommandForm
{
	my($i, $frameFlag, $sessionId) = @_;
	if ($frameFlag) {
		&tellActiveFd($i,
			"<form name=\"commands\" " .
			"action=\"/" . $sessionId . "/frameset" . 
			"\" target=\"_top\" method=\"POST\" " .
			"onSubmit=\"queueClear()\">");
	} else {
		&tellActiveFd($i,
			"<form action=\"/" . $sessionId . 
			"/frameset\" method=\"POST\">");
	}
	if ($frameFlag) {
		&tellActiveFd($i, 
			"<input type=\"text\" " .
			"size=\"40\" name=\"command\">");
		&tellActiveFd($i, 
			"<input type=\"submit\" " .
			"value=\"Go\" name=\"update\">");
	} else {
		&tellActiveFd($i, 
			"<input type=\"text\" " .
			"size=\"30\" name=\"command\"> ");
		&tellActiveFd($i, 
		"<input type=\"submit\" name=\"update\" value=\"Go\">");
	}

	if ($frameFlag) {
		&tellActiveFd($i, 
			"</form>");
		&tellActiveFd($i, 
			"<script>");
		&tellActiveFd($i,
			"function queueClear ()  {");
		&tellActiveFd($i,
			"	setTimeout('clearCommand()', 500)");
		&tellActiveFd($i,
			"	return 1");
		&tellActiveFd($i,
			"}");
		&tellActiveFd($i,
			"function clearCommand ()  {");
		&tellActiveFd($i,
			"	document.commands.command.value = \"\"");
		&tellActiveFd($i,
			"}");
		&tellActiveFd($i, 
			"</script>");
	} else {
		&tellActiveFd($i,
			"<br><em><strong>IMPORTANT: </strong> you must click 'Go' in order to see more output. For a better interface that does <strong>not</strong> require this, use <a href=\"http://www.netscape.com/\">Netscape 2.0</a>.</em>");
	}
}

sub encodeInput
{
	my($in) = @_;
	my($key, $val, $s, $first);
	my($i, $l, $ch);
	$first = 1;
	while (($key, $val) = each(%{$in})) {
		if (!$first) {
			$s .= "&";
		} else {
			$first = 0;
		}
		$s .= &encodeUrl($key);	
		$s .= "=";
		$s .= &encodeUrl($val);	
	}
	return $s;
}

sub encodeUrl
{
	my($key) = @_;
	my($l, $i, $ch, $s);
	$s = "";
	$l = length($key);
	for ($i = 0; ($i < $l); $i++) {
		$ch = substr($key, $i, 1);
		if ($ch =~ /[^\w\.\#\:\/\~]/) {
			$s .= sprintf("%%%2x", ord($ch)); 	
		} else {
			$s .= $ch;
		}
	}
	return $s;
}

sub linkUrls
{
	my($l) = @_;
	my(@words, $w, $r);
	@words = split(/(\s+)/, $l);
	$r = "";
	#Surround URLs with equivalent links
	$first = 1;
	foreach $w (@words) {
		if ($w =~ /\s+/) {
			$r .= $w;
		} elsif ($w =~ /(["',]*)([a-zA-Z]+:\/\/[\w:\.%@\-\/~]+[\w~\/])(\S*)/) {
			$r .= $1 . "<a target=\"_new\" href=\"" . 
				&encodeUrl($2) . "\">" . $2 . "</a>" . $3;
		} elsif ($w =~ /(["',]*)([\w\.%\-!]+@[\w\.%\-!]+[\w])(\S*)/) {		
			$r .= $1 . "<a href=\"mailto:" . &encodeUrl($2) . 
				"\">" . $2 . "</a>" . $3;
		} elsif ($w =~ /(["',]*)([\w\.%@\-~\/]+\.[\w:\.%\-~\/]+[\.\/][\w:\.%\-~\/]+[\w~\/])(\S*)/) {		
			$r .= $1 . "<a target=\"_new\" href=\"http://" . 
				&encodeUrl($2) . "\">" . $2 . "</a>" . $3;
		} else {
			$r .= $w;	
		}
	}
	return $r;
}

sub base64setup
{
	my($i);
	for ($i = 0; ($i < 64); $i++) {
		$base64table[ord(substr($base64alphabet, $i, 1))] = $i;
	}	
	$base64initialized = 1;
}

sub base64decode
{
	my($arg) = @_;
	my($i, @group, $j, $output, $l, $pad);
	if (!$base64initialized) {
		&base64setup;
	}
	$l = length($arg);
	for ($i = 0; ($i < $l); $i += 4) 
	{
		for ($j = 0; ($j < 4); $j ++) {
			$group[$j] = 
				$base64table[ord(substr($arg, $i + $j, 1))];
		}
		$output .= sprintf("%c%c%c",
			($group[0] << 2) + ($group[1] >> 4),
			(($group[1] & 15) << 4) + (($group[2] & 60) >> 2),
			(($group[2] & 3) << 6) + $group[3]);
	}
	for ($i = ($l - 1); ($i >= 0); $i--) {
		if (substr($arg, $i, 1) eq "=") {
			$pad++;
		}
	}
	if ($pad == 1) {
		$output = substr($output, 0, length($output) - 1);
	} elsif ($pad == 2) {
		$output = substr($output, 0, length($output) - 2);
	}
	return $output;
}

sub linkEmbed
{
	my($text, $command) = @_;
	my($result);	
	$result = "<a target=\"_top\" href=\"/" .  int(rand(20000)) . 
		"/command:" .  &encodeUrl($command) . "\">" . $text . "</a>";
	return $result;
}

sub plainlength
{
	my($arg) = @_;
	$arg =~ s/\x01([^\,\x02]+)\,([^\,\x02]+)\x02/$1/g;
	return length($arg);	
}

sub plainrindex
{
	my($in, $sub, $last) = @_;
	my($foo) = substr($in, 0, $last);
	my($end, $break, $lat, $gat, $plen);
	$end = 0;
	# Count 'last' non-escaped characters. 
	while (1) {
		$lat = index($in, "\x01", $end);
		if ($lat == -1) {
			$last = $end + ($last - $plen);
			last;
		}
		if (($plen + ($lat - $end)) >= $last) {
			$last = $end + ($last - $plen);
			last;
		}
		$plen += ($lat - $end);
		$gat = index($in, "\x02", $lat + 1);
		if ($gat == -1) {
			# Uh-oh, play dumb
			return -1;
		}			
		my($cat);
		$cat = index($in, ",", $lat + 1);
		if ($cat == -1) {
			# Bad craziness.
			return -1;
		}
		$plen += ($cat - $lat - 1); 
		if ($plen >= $last) {
			$last = $lat;
			last;
		}	
		$end = $gat + 1;
	}
	# Okay, now we know where the real limiting point is...	
	$at = rindex($in, $sub, $last);
	# Hackery to ensure we never break up an embedded link
	while ($at != -1) {
		$gat = index($in, "\x02", $at);
		$lat = index($in, "\x01", $at);
		if ($gat == -1) {
			last;
		}
		if (($lat == -1) || ($gat < $lat)) {
			if ($at != 0) {
				$at = rindex(
					$in, $sub, $at - 1);
			} else {
				$at = -1;
			}
		} else {
			last;
		}
	}	
	return $at;
}
	
sub generateUsemap
{
	my($i, $e) = @_;
	my(@elist);
	my(@f);
	@elist = split(/;/, $objects[$e]{"name"});
	foreach $f (@elist) {
		my($umap);
		$f =~ tr/A-Z/a-z/;
		$umap = $exitUsemaps{$f};
		if ($umap ne "") {
			$umap =~ s/SEED/int(rand(20000))/ge;
			&tellActiveFd($i, "<map name=\"exits\">");
			&tellActiveFd($i, $umap);
			&tellActiveFd($i, "</map>");
			return;
		}
	}	
	&tellActiveFd($i, "<map name=\"#exits\">\n</map>");
}

sub frontDoor
{
	my($i) = @_;
	&tellActiveFd($i, "HTTP/1.0 200 Success");
	&tellActiveFd($i, "Server: PerlMUD/" . $perlMudVersion);
	&tellActiveFd($i, "Content-type: text/html");	
	&tellActiveFd($i);
	&sendActiveFdFile($i, $homePageFile);
	
}

sub application
{
	my($i) = @_;
	&tellActiveFd($i, "HTTP/1.0 200 Success");
	&tellActiveFd($i, "Server: PerlMUD/" . $perlMudVersion);
	&tellActiveFd($i, "Content-type: text/html");	
	&tellActiveFd($i);
	&sendActiveFdFile($i, $applicationFile);
}

sub completedApplication
{
	my($fd, $body) = @_;
	my($name, $password, $i);
	%in = &parseFormSubmission($fd, $body);
	$name = $in{"name"};
	$name =~ s/^\#//g;
	$name =~ s/ //g;
	$email = $in{"email"};
	$email =~ s/ //g;
	&tellActiveFd($fd, "HTTP/1.0 200 Success");
	&tellActiveFd($fd, "Server: PerlMUD/" . $perlMudVersion);
	&tellActiveFd($fd, "Content-type: text/html");	
	&tellActiveFd($fd);
	my($copy) = $name;
	$copy =~ tr/A-Z/a-z/;
	if (exists($playerIds{$copy})) {
		&tellActiveFd($fd, "<title>Application Problem</title>");
		&tellActiveFd($fd, "<h1>Application Problem</h1>");
		&tellActiveFd($fd, "Your application could not be accepted ");
		&tellActiveFd($fd, "because another user has already taken ");
		&tellActiveFd($fd, "the name you requested.");
		&tellActiveFd($fd, "<p>");
		&tellActiveFd($fd, "<strong>");
		&tellActiveFd($fd, "<a href=\"/apply\">Apply Again</a>");
		&tellActiveFd($fd, "</strong>");
		return;
	}	
	# Check allowed-users file first, if it exists
	if (open(ALLOWED, "allowed.txt")) {
		my($reg, $qreg, $allowed);
		$allowed = 0;
		while ($reg = <ALLOWED>) {
			chomp $reg;
			if ($reg =~ /^\s*$/) {
				next;
			}
			$qreg = "\Q$reg";
			if ($email =~ /$qreg$/) {
				$allowed = 1;
			}
		}
		if (!$allowed) {
			&tellActiveFd($fd, "<title>Application Rejected</title>");
			&tellActiveFd($fd, "<h1>Application Rejected</h1>");
			&tellActiveFd($fd, "Sorry, that address is " .
				"not permitted to receive an account.");
			return;
		}
		close(ALLOWED);
	}
	# Check lockouts file second, if it exists
	if (open(LOCKOUTS, "lockouts.txt")) {
		my($reg, $qreg);
		while ($reg = <LOCKOUTS>) {
			chomp $reg;
			if ($reg =~ /^\s*$/) {
				next;
			}
			$qreg = "\Q$reg";
			if ($email =~ /$qreg$/) {
				&tellActiveFd($fd, "<title>Application Rejected</title>");
				&tellActiveFd($fd, "<h1>Application Rejected</h1>");
				&tellActiveFd($fd, "Sorry, that address is " .
					"not permitted to receive an account.");
				return;
			}
		}
		close(LOCKOUTS);
	}
	if ($name eq "") {
		&tellActiveFd($fd, "<title>Application Problem</title>");
		&tellActiveFd($fd, "<h1>Application Problem</h1>");
		&tellActiveFd($fd, "Your application could not be accepted ");
		&tellActiveFd($fd, "because you did not provide a name!");
		&tellActiveFd($fd, "<p>");
		&tellActiveFd($fd, "<strong>");
		&tellActiveFd($fd, "<a href=\"/apply\">Apply Again</a>");
		&tellActiveFd($fd, "</strong>");
		return;
	}
	if ($email eq "") {
		&tellActiveFd($fd, "<title>Application Problem</title>");
		&tellActiveFd($fd, "<h1>Application Problem</h1>");
		&tellActiveFd($fd, "Your application could not be accepted ");
		&tellActiveFd($fd, "because you did not provide a valid ");
		&tellActiveFd($fd, "email address.");
		&tellActiveFd($fd, "<p>");
		&tellActiveFd($fd, "<strong>");
		&tellActiveFd($fd, "<a href=\"/apply\">Apply Again</a>");
		&tellActiveFd($fd, "</strong>");
		return;
	}	
	for ($i = 0; ($i < 6); $i++) {
		$password .= sprintf("%c", int(rand(26)) + ord("a"));
	}
	my($id);
	if (!(open(SENDMAIL, "|" . $sendmail . " -t"))) {
		&tellActiveFd($fd, "<title>System Configuration Error</title>");
		&tellActiveFd($fd, "<h1>System Configuration Error</h1>");
		&tellActiveFd($fd, "This PerlMUD server is misconfigured.");
		&tellActiveFd($fd, "The sendmail program cannot be located.");
		&tellActiveFd($fd, "Please contact the administrator.");
		return;
	}	
	print SENDMAIL "To: " . $in{"email"} . "\n";
	print SENDMAIL "Subject: YOUR " . $serverName . " ACCOUNT IS READY!\n";
	print SENDMAIL "\n";
	print SENDMAIL "Your user name is: " . $name . "\n";
	print SENDMAIL "Your password is: " . $password . "\n\n";
	print SENDMAIL "TO CONNECT, access this URL:\n\n";
	print SENDMAIL "http://" . $hostName . ":" . $httpPort . "/\n\n";
	print SENDMAIL "KEEP YOUR PASSWORD IN A SAFE PLACE. Please do not\n";
	print SENDMAIL "use this password for other purposes.\n\n";
	if (open(MAIL, $emailFile)) {
		while (<MAIL>) {
			print SENDMAIL;
		}
		close(MAIL);
	}
	if (open(ACCOUNTLOG, ">>accounts.log")) {
		print ACCOUNTLOG $name, " ", $email, "\n";
		close(ACCOUNTLOG);
	}
	close(SENDMAIL);	
	$id = &addObject(1, $name, $player);
	$playerIds{$copy} = $id;
	$objects[$id]{"owner"} = $id;
	&addContents(0, $id);
	$objects[$id]{"password"} = $password;
	if ($allowBuild) {
		$objects[$id]{"flags"} = $builder;
	} else {
		$objects[$id]{"flags"} = 0;
	}
	&sendActiveFdFile($fd, $acceptedFile);
}

sub parseFormSubmission
{
	my($i, $arg) = @_;
	if ($activeFds[$i]{"type"} =~ "application/x-www-form-urlencoded") {
		return &parseUrlEncoded($arg);
	} else {
		return &parseFileEncoded($i, $arg);
	}	
}

sub parseUrlEncoded
{
	my($arg) = @_;
	my(%in, @in, $id, $key, $val);
	@in = split(/[&;]/, $arg);
	foreach $id (0 .. $#in) {
		# Remove trailing spaces
		$in[$id] =~ s/\s+$//;
		# Remove leading spaces
		$in[$id] =~ s/^\s+//;
		# Convert pluses to spaces
		$in[$id] =~ s/\+/ /g;

		# Split into key and value.
		($key, $val) = split(/=/, $in[$id], 2); # splits on the first =.

		# Convert %XX from hex numbers to alphanumeric
		$key =~ s/%(..)/pack("c",hex($1))/ge;
		$val =~ s/%(..)/pack("c",hex($1))/ge;
		$in{$key} .= $val;
	}
	return %in;
}

sub parseFileEncoded
{
	#Borrow a bit from cgi-lib
	my($i, $arg) = @_;
	my(%in, @in, $id, $key, $val, $ctype, $boundary);
	$ctype = $activeFds[$i]{"type"};
	if ($ctype =~ /^multipart\/form-data\; boundary\=(.+)$/) {
		$boundary = $1;
	} else {
		# Uh-oh, unparseable.
		return %in;
	}
	my($where);
	my($item);
	my(@items);
	@items = split(/-*$boundary-*/, $arg);
	foreach $item (@items) {
		my($header, $body, @headers, $name);
		($header, $body) = 
			split(/\n\n|\r\r|\r\n\r\n|\n\r\n\r/, $item, 2);
		@headers = split(/[\r\n]/, $header);
		foreach $header (@headers) {
			$header =~ tr/A-Z/a-z/;
			if ($header =~ /^content-disposition\: form\-data\; name=\"(\w+)\"/) {
				#Finally
				$name = $1;
				$in{$1} = $body;
				last;
			}
		}			
	}
	return %in;
}

sub plumber {
	$SIG{'PIPE'} = 'plumber';
}

sub builderTest {
	my($me) = @_;
	if (($objects[$me]{"flags"} & $builder) || 
		($objects[$me]{"flags"} & $wizard))
	{ 
		return 1;
	}
	return 0;
}

sub fdClosureTimeout
{
	$fdClosureTimedOut = 1;
}

1;

