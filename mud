#!/usr/bin/perl

#PerlMUD 3.0, by Boutell.Com, Inc.
#
#PERL 5 REQUIRED. Your platform must also support Internet sockets.
#
#SEE CONFIGURATION SETTINGS in mudlib.pl.
#
#RELEASED UNDER THE MIT LICENSE.
#Copyright (c) 2011 Boutell.Com, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a 
#copy of this software and associated documentation files (the "Software"), 
#to deal in the Software without restriction, including without limitation 
#the rights to use, copy, modify, merge, publish, distribute, sublicense, 
#and/or sell copies of the Software, and to permit persons to whom the 
#Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included 
#in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
#OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
#THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
#OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
#OTHER DEALINGS IN THE SOFTWARE.
#
#CONFIGURABLE SETTINGS FOLLOW
#
#The directory where PerlMUD can expect to find all of its data files,
#and the mudlib.pl file. All other settings and all non-initialization
#code are in mudlib.pl. This allows the @reload command to be used to
#install new code on the fly (of course, there is still a good chance
#of crashing the mud if the new code is buggy, but it can sometimes
#avoid the need for a restart).
use strict;
#use warnings;

my $dataDirectory = "/Users/qjn10/dev/perlmud-3.0-TH";

require "$dataDirectory/mudlib.pl";

require 5.001;
use Fcntl;
use Socket;
use POSIX;
use Safe;
require "flush.pl";

if (!chdir($dataDirectory)) {
	print "The MUD server could not change to the \n",
		"working directory: $dataDirectory \n",
		"Please read the documentation and follow\n",
		"all of the instructions carefully.\n";
	exit 0;
}	

#Start time

our $now = time;

srand($now + $$);

our $initialized = $now;
our $lastdump = $now;
our $lastFdClosure = $now;
our $reloadFlag = 0;

#Create initial db (commented out)

#&mindb;

#Load db

if (!&restore) {
	print "Can't start the mud with this database.\n";
	exit 0;
}

#Set up listener socket

my $sockaddr = 'S n a4 x8';
our ($name, $aliases, $proto) = getprotobyname("tcp");
our ($ipAddress, $tinypPort);

our @addr = split(/\./, $ipAddress);
our $this = pack($sockaddr, AF_INET, $tinypPort, pack("CCCC", @addr));

if (!socket(TINYP_LISTENER, AF_INET, SOCK_STREAM, $proto)) {
	print "Couldn't create listener socket.\n";
	print "This Perl implementation probably does not support sockets.\n";
	exit 1;
}

#Make sure we can reuse this quickly after a shutdown
setsockopt(TINYP_LISTENER, SOL_SOCKET, SO_REUSEADDR, $this);

#Always set linger; we'll make many brief attempts to
#close the socket to avoid responsiveness problems
#(version 3.0)

setsockopt(TINYP_LISTENER, SOL_SOCKET, SO_LINGER, 1);

#Get the port

if (!bind(TINYP_LISTENER, $this)) {
	print "Couldn't bind to port ", $tinypPort, ".\n";
	close(TINYP_LISTENER);
	exit 1;
}

fcntl(TINYP_LISTENER, F_SETFL, O_NONBLOCK);

if (!listen(TINYP_LISTENER, 5)) {
	print "Couldn't initiate listening for connections.\n";
	close(TINYP_LISTENER);
	exit 1;
}

while (1) {
	# Select loop
	&selectPass;
	if ($reloadFlag) {
		# 3.0: reload the mud code
		my($file) = "$dataDirectory/mudlib.pl";
		my($return);
		$return = do $file;
		if ($return) {
			&tellWizards("Reloaded $file successfully.");
		} else {
			# Hopefully the programmer didn't break tellWizards!
			&tellWizards("Couldn't parse $file: $@") if $@;
			&tellWizards("Couldn't do $file: $!") unless 
				defined $return;
			&tellWizards("Couldn't run $file") unless $return;
		}
		$reloadFlag = 0;
        }
}

