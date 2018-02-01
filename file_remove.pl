#!/usr/bin/perl
# file_remove.pl - Download latest version at https://SynchronetBBS.org

use 5.012;		# so readdir assigns to $_ in a lone while test
use String::Scanf;	# imports sscanf()
use Cwd qw(cwd);	# Load in cwd command
use Storable;		# For loading & saving variables

# Globals
my $SEEN_FILE="/root/.fileseen";		# Stores the list of files we have seen already
my $VERSION="1.0";

# Init vars - don't change anything below here
my %SEEN_HASH=();

print("file_remove.pl - Version $VERSION\n");
print("Checking for saved files hash\n");

if (-f $SEEN_FILE)
{
	%SEEN_HASH = %{retrieve($SEEN_FILE)};
	print("Read in $SEEN_FILE\n");
}
else
{
	print("$SEEN_FILE not found\n");
	exit(1);
}

# quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "Incorrect number of arguments\n";
    print "Usage: file_remove.pl <file name>\n";
    exit(1);
}

my $FileToRemove = $ARGV[0];
print "Looking for file '$FileToRemove'\n";
exit 0;

if (! -f $FileToRemove) {
    print "File not found in current directory...\n";
    exit(1);
}


if (! -d $FileToRemove)
{
	if ($SEEN_HASH{"^$FileToRemove\$"} eq "seen")
	{
		print("Found & removed...\n");
		$SEEN_HASH{"^$FileToRemove\$"} = "removed";
	}
	else
	{
		print("File $FileToRemove not found\n");
	} 
}
else
{
	print("Can not remove directories\n");
	exit(1);
}

# Save seen file hash
store (\%SEEN_HASH, $SEEN_FILE);
print("Saved seen file hash to $SEEN_FILE\n");

exit 0;
