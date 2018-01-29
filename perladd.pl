#!/usr/bin/perl
# PerlAdd.pl - Download latest version at https://SynchronetBBS.org

use 5.012;		# so readdir assigns to $_ in a lone while test
use String::Scanf;	# imports sscanf()
use Cwd qw(cwd);	# Load in cwd command
use Storable;		# For loading & saving variables

# Globals
my $ADD_PROG="/sbbs/exec/addfiles";	# The command to add files to BBS file area
my $BBS_DATA="/sbbs/data/dirs";		# The directory the other file dirs live under
my $SEEN_FILE="/root/.fileseen";		# Stores the list of files we have seen already
my $NEWFILES="/root/.newfiles";		# Stores the list of files we have added but not posted about
my $VERSION="1.18";
my $BBS_DESC_LEN=256;

# Init vars - don't change anything below here
my $DEST_DIR="";
my $CUR_FILE="";
my $FIRST_PART="";
my $DEST_TYPE="";
my $BBS_DIR="";
my $DESIRED_ACTION="";
my $NAME_LENGTH="";
my $SOURCE_DIR="";
my %SEEN_HASH=();
my $REQDESC=0;
my $FILEIDFILE="files.bbs";

print("perladd.pl - Version $VERSION\n");
print("Checking for saved files hash\n");

if (-f $SEEN_FILE)
{
	%SEEN_HASH = %{retrieve($SEEN_FILE)};
	print("Read in $SEEN_FILE\n");
}
else
{
	print("$SEEN_FILE not found\n");
	%SEEN_HASH = ();
}

open(OUTF, ">>$NEWFILES") || die "Unable to open output file $NEWFILES";

sub ListDirs
{
        print "Following are the existing <BBSFILEDIR> directories:\n";
        opendir(my $dh, "$BBS_DATA/") || die "Can't open 'BBS_DATA': $!";
	my @dirfiles= readdir $dh;
	closedir $dh;
	#my @sortedfiles = sort(@dirfiles);
	my @sortedfiles = sort{lc($a) cmp lc($b)} @dirfiles;
	foreach(@sortedfiles)
        {       
                if ($_ ne "." && $_ ne ".." && -d "$BBS_DATA/$_")
                {       
                        print "'$_'\n";
                }
        }
}

# Sub to shorten the long file names
sub ShortenName
{
	my $NumInDir=0;
	my $NewName;
	my $NameNumber;
	#print "Length is $NAME_LENGTH: ";
	$NewName = substr($FIRST_PART, 0, 5);
	$NameNumber = "0000" . $NumInDir;
	$NameNumber = substr($NameNumber, -3);
	$NewName .= $NameNumber;
	# Get lowest unused number
	while (-e "$DEST_DIR/$NewName.$DEST_TYPE")
	{
		# Existed, increment number
		$NumInDir += 1;
		$NewName = substr($FIRST_PART, 0, 5);
		$NameNumber = "0000" . $NumInDir;
		$NameNumber = substr($NameNumber, -3);
		$NewName .= $NameNumber;
	}
	#print "NameNumber = $NameNumber\n";
	return "$NewName.$DEST_TYPE";
}

sub CopyFile
{
	my $dest_file;
	my $str;
	my $i = rindex($CUR_FILE, ".");
	$FIRST_PART = substr($CUR_FILE, 0, $i);
	$DEST_TYPE = substr($CUR_FILE, $i+1);
	#print "first_Part: $FIRST_PART\n";
	#print "Extension: $DEST_TYPE\n";
	$NAME_LENGTH = length $FIRST_PART;
	if ($NAME_LENGTH < 9)
	{
		# File does not need to be shortened
		print "Name is short enough: ";
		$dest_file = $CUR_FILE;
	}
	else
	{
		# Name too long
		print "Name is too long, needs to be shortened: ";
		$dest_file = &ShortenName();
	}
	$dest_file =~ s/ /_/g;
	if ($DESIRED_ACTION eq "link")
	{
		my $link_cmd = "ln -fs '$SOURCE_DIR/$CUR_FILE' '$DEST_DIR/$dest_file'";
		print "Linking file $dest_file\n";
		#print "cmd = '$link_cmd'\n";
		# Link the file
		system($link_cmd);
	}
	my $full_dest_file = "$DEST_DIR/$dest_file";
	my $filesize = -s $full_dest_file;
	my $LONG_PLUS_DESC="";
	my $LongFileName=$CUR_FILE;
	if ($REQDESC)
	{
		print "Enter description for $CUR_FILE: ";
		$LONG_PLUS_DESC = <STDIN>;
		chomp $LONG_PLUS_DESC;
		$CUR_FILE = "$CUR_FILE - $LONG_PLUS_DESC";
	}
	my $BBS_DESC = $CUR_FILE;
	if (length($BBS_DESC) > $BBS_DESC_LEN)
	{
		$BBS_DESC = substr($CUR_FILE, 0, $BBS_DESC_LEN - 1);
	}
	open(my  $FILEID, ">", "$DEST_DIR/$FILEIDFILE") or die "Could not open file '$DEST_DIR/$FILEIDFILE' $!";
	#print($FILEID "$dest_file $LongFileName\n              $BBS_DESC\n"); #ZZZ
	print($FILEID "$LongFileName\n              $BBS_DESC\n");
	close($FILEID);
	system("$ADD_PROG $BBS_DIR -i \"+$DEST_DIR/$FILEIDFILE\"");
	print(OUTF "\"$SOURCE_DIR\",\"$CUR_FILE\",\"$DEST_DIR\",\"$dest_file\",\"$filesize\"\n");
	unlink("$DEST_DIR/$FILEIDFILE");
}

# quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "Incorrect number of arguments\n";
    print "Usage: perladd.pl <BBSFILEDIR> [link|long|existing]\n";
    print "\tlong - Prompts for extended file descriptions, otherwise same as link - reccommended as default\n";
    print "\texisting - use existing files\n";
    print "\tlink - links rather than using existing files\n";
    ListDirs();
    close(OUTF);
    exit;
}
if ($ARGV[1] ne "link" && $ARGV[1] ne "long" && $ARGV[1] ne "existing") {
    print "Incorrect action\n";
    print "Usage: perladd.pl <BBSFILEDIR> [link|long|existing]\n";
    print "\texisting - use existing files\n";
    print "\tlink - links rather than using existing files\n";
    print "\tlong - Prompts for extended file descriptions, otherwise same as link - reccommended as default\n";
    ListDirs();
    close(OUTF);
    exit;
}
$BBS_DIR=$ARGV[0];
$DESIRED_ACTION=$ARGV[1];
my $target_dir="";
$DEST_DIR="$BBS_DATA/$BBS_DIR";

# Make sure target exists
if (!-d $DEST_DIR)
{
	# No, so list existing directories
	print "Destination directory not found\n";
	ListDirs();
        close(OUTF);
	exit;
}

if ($DESIRED_ACTION eq "long")
{
	$REQDESC=-1;
	$DESIRED_ACTION = "link";
}
if ($DESIRED_ACTION eq "link")
{
	$target_dir = ".";
}
else
{
	$target_dir = "$BBS_DATA/$BBS_DIR";
}

# Loop for each entry in the current directory
if ($DESIRED_ACTION eq "existing")
{
	print "Adding existing files\n";
}
else
{
	print "Linking files before adding\n";
}

$SOURCE_DIR = cwd;

opendir(my $dh, $target_dir) || die "Can't open '$target_dir': $!";
while (readdir $dh) {
	# Work on each file in the directory without index.* files
	if ($_ ne "." && $_ ne ".." && $_ ne "index.html" && $_ ne "index.php" && $_ ne "perladd.pl" && $_ ne "perladd.txt")
	{
		$CUR_FILE = $_;
		# Skip over directories
		if (! -d $CUR_FILE)
		{
			if ($SEEN_HASH{"^$_\$"} eq "seen")
			{
				print("Already added $_ - skipping\n");
			}
			else
			{
				#print("File $_ not seen, adding to hash\n");
				$SEEN_HASH{"^$_\$"} = "seen";
				print "Working on '$CUR_FILE': ";
				&CopyFile();
			} 
		}
	}
}
closedir $dh;

# Save seen file hash
store (\%SEEN_HASH, $SEEN_FILE);
print("Saved seen file hash to $SEEN_FILE\n");

close(OUTF);
exit 0;
