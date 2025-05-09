#!/usr/bin/perl
# PerlAdd.pl - Download latest version at https://SynchronetBBS.org

use 5.012;		# so readdir assigns to $_ in a lone while test
use String::Scanf;	# imports sscanf()
use Cwd qw(cwd);	# Load in cwd command
use Storable;		# For loading & saving variables

# Globals
my $ADD_PROG="jsexec /sbbs/exec/addfiles.js";	# The command to add files to BBS file area
#my $ADD_PROG="/sbbs/exec/addfiles";	# The command to add files to BBS file area
my $BBS_DATA="/sbbs/data/dirs";		# The directory the other file dirs live under
my $SEEN_FILE="/home/bbsowner/.fileseen";		# Stores the list of files we have seen already
my $NEWFILES="/home/bbsowner/.newfiles";		# Stores the list of files we have added but not posted about
my $VERSION="1.35";
my $BBS_DESC_LEN=256;

# Init vars - don't change anything below here
my $DEST_DIR="";
my $CUR_FILE="";
my $FIRST_PART="";
my $DEST_TYPE="";
my $BBS_DIR="";
my $DESIRED_ACTION="";
my $SOURCE_DIR="";
my %SEEN_HASH=();
my $REQDESC=0;
my $FILEIDFILE="files.bbs";
my $DEFEDIT="/bin/nano";
my $EDITOR="";
my $Aborted=0;
my $DefaultText = "Replace this with a description for";
my $DefaultLength = length($DefaultText);
my $WARN_ITEMS=10;
my $WC_COMMAND="/usr/bin/wc";

sub QueueItems
{
	my $ItemCount = 0;
	if (!-f $NEWFILES)
	{
		print "No items in the posting queue\n";
		return 0;
	}
	open(INPF, "<$NEWFILES") || die "Unable to open input file $NEWFILES";

	while(<INPF>)
	{
		$ItemCount += 1;
	}
	close(INPF);
	if ($_[0] eq "queueitems")
	{
		print "Currently there are $ItemCount items in the posting queue\n";
	}
	if ($ItemCount > $WARN_ITEMS)
	{
		print "More than $WARN_ITEMS in posting queue. Please run file_announce.pl\n";
	}
}

# Save seen file hash
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

if ($ENV{'EDITOR'})
{
	$EDITOR = $ENV{'EDITOR'};
}
else
{
	$EDITOR = $DEFEDIT;
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

sub CopyFile
{
	my $dest_file;
	my $str;
	my $i = rindex($CUR_FILE, ".");
	$FIRST_PART = substr($CUR_FILE, 0, $i);
	$DEST_TYPE = substr($CUR_FILE, $i+1);
	#print "first_Part: $FIRST_PART\n";
	#print "Extension: $DEST_TYPE\n";
	$dest_file = $CUR_FILE;
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
		my $TMPNAME = "/tmp/addingfile.txt";
		open (TMPFILE, ">$TMPNAME") || die "file '$TMPNAME' could not be opened for writing";
		# Write default text
		print (TMPFILE "$DefaultText $CUR_FILE - leave this text as-is to skip adding this file, or replace with 'quit' or 'abort' to stop");
		close (TMPFILE);
		# Edit the description file
		system("$EDITOR $TMPNAME");
		open (TMPFILE, "<$TMPNAME") || die "file '$TMPNAME' could not be opened for reading";
		# Now read in edited text
		$LONG_PLUS_DESC = <TMPFILE>;
		close(TMPFILE);
		chomp $LONG_PLUS_DESC;
		if (substr($LONG_PLUS_DESC, 0, $DefaultLength) eq $DefaultText)
		{
			# Skip this file
			$Aborted = 1;
			next;
		}
		if ((lc($LONG_PLUS_DESC) eq "quit") || (lc($LONG_PLUS_DESC) eq "abort"))
		{
			# Abort processing
			$Aborted = 2;
			break;
		}
		$CUR_FILE = "$LONG_PLUS_DESC";
	}
	my $BBS_DESC = $CUR_FILE;
	if (length($BBS_DESC) > $BBS_DESC_LEN)
	{
		$BBS_DESC = substr($CUR_FILE, 0, $BBS_DESC_LEN - 1);
	}
	open(my  $FILEID, ">", "$DEST_DIR/$FILEIDFILE") or die "Could not open file '$DEST_DIR/$FILEIDFILE' $!";
	print($FILEID "$dest_file $LongFileName\n              $BBS_DESC\n");
	#print($FILEID "$LongFileName\n              $BBS_DESC\n");
	close($FILEID);
	#system("$ADD_PROG $BBS_DIR -i \"+$DEST_DIR/$FILEIDFILE\"");
	system("$ADD_PROG $BBS_DIR");
	print(OUTF "\"$SOURCE_DIR\",\"$CUR_FILE\",\"$DEST_DIR\",\"$dest_file\",\"$filesize\"\n");
	unlink("$DEST_DIR/$FILEIDFILE");
}

# quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;
if ($num_args == 1) {
	if ($ARGV[0] eq "inqueue")
	{
		QueueItems("queueitems");
		exit 0;
	}
}

if ($num_args != 2) {
    print "Incorrect number of arguments\n";
    print "Usage: perladd.pl <BBSFILEDIR> [long|link|existing]\n";
    print "\tlong - Prompts for extended file descriptions, otherwise same as link - reccommended as default\n";
    print "\texisting - use existing files\n";
    print "\tlink - links rather than using existing files\n";
    print "--or--\n";
    print "Usage: perladd.pl inqueue - lists number of items in the queue to post\n";
    ListDirs();
    close(OUTF);
    exit;
}
if ($ARGV[1] ne "link" && $ARGV[1] ne "long" && $ARGV[1] ne "existing")
{
    print "Incorrect action\n";
    print "Usage: perladd.pl <BBSFILEDIR> [long|link|existing]\n";
    print "\tlong - Prompts for extended file descriptions, otherwise same as link - reccommended as default\n";
    print "\texisting - use existing files\n";
    print "\tlink - links rather than using existing files\n";
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
				print "Working on '$CUR_FILE': ";
				$Aborted = 0;
				if ($DESIRED_ACTION ne "existing")
				{
					&CopyFile();
				}
				#print("File $_ not seen, adding to hash\n");
				if ($Aborted == 0)
				{
					# Didn't abort or skip, so add to seen hash
					$SEEN_HASH{"^$_\$"} = "seen";
					store (\%SEEN_HASH, $SEEN_FILE);
					print("Saved seen file hash to $SEEN_FILE\n");
				}
				if ($Aborted == 2)
				{
					# Did abort, stop processing and exit
					closedir $dh;
					close(OUTF);
					exit 0;
				}
			} 
		}
	}
}
closedir $dh;

# Save seen file hash
store (\%SEEN_HASH, $SEEN_FILE);
print("Saved seen file hash to $SEEN_FILE\n");

close(OUTF);
QueueItems();

exit 0;
