#!/usr/bin/perl
# updseen.pl - Updates the seen files to fix issue

use 5.012;		# so readdir assigns to $_ in a lone while test
use String::Scanf;	# imports sscanf()
use Cwd qw(cwd);	# Load in cwd command
use Storable;		# For loading & saving variables

# Globals
my $SEEN_FILE="/home/bbsowner/.fileseen";		# Stores the list of files we have seen already

# Init vars - don't change anything below here
my %SEEN_HASH=();
my %NEWSEEN_HASH=();

print("Checking for saved files hash\n");

if (-f $SEEN_FILE)
{
	%SEEN_HASH = %{retrieve($SEEN_FILE)};
	print("Read in $SEEN_FILE\n");
}
else
{
	print("$SEEN_FILE not found\n");
	exit 0;
}

foreach my $key (keys %SEEN_HASH)
{
	print "Saw key $key\n";
	$NEWSEEN_HASH{"^$key\$"} = "seen";
}

# Save seen file hash
store (\%NEWSEEN_HASH, $SEEN_FILE);
print("Saved seen file hash to $SEEN_FILE\n");

exit 0;
