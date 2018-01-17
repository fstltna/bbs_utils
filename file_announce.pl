#!/usr/bin/perl
#
# -- Posts a file announcement to the desired sub-board

use Text::CSV;
use Math::Round;

my $BBSSUBJ = "AmigaCity BBS - New Amiga Files";
my $BBSOWNER = "AmigaCity Admin";
my $GROUP = "AMY-FILEANNO";
my $TempName = "/tmp/fileann.tmp";

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/FilePost.txt";
my $MSGBODYBOTTOMFILE = "/sbbs/exec/FilePostBottom.txt";

# == No changes below here
my $JSEXEC = "jsexec postmsg.js -i\"$TempName\" -tALL -f\"$BBSOWNER\" -s\"$BBSSUBJ\" $GROUP";
my $content = "";
my $contentbottom = "";
my $VERSION = "1.1";
my $NEWFILESFILE="/root/.newfiles";         # Stores the list of files we have added but not posted about

print "Running file_announce $VERSION\n";
print "========================\n";

open(INPF, "<$MSGBODYFILE") || die "Unable to open $MSGBODYFILE for input";
{
        local $/;
        $content = <INPF>;
}
close(INPF);

open(INPF, "<$MSGBODYBOTTOMFILE") || die "Unable to open $MSGBODYBOTTOMFILE for input";
{
        local $/;
        $contentbottom = <INPF>;
}
close(INPF);

open(TEMPFILE, ">$TempName") || die "Unable to create temp file $TempName";

# Post header to the temp file
print (TEMPFILE $content);

# Read the list of files added
open(NEWFILES, "<$NEWFILESFILE") || die "Unable to open $NEWFILESFILE for input";

my $csv = Text::CSV->new();

# Loop for each line in the file
while(<NEWFILES>)
{
	chop;
	my $status = $csv->parse($_);
	($Field1, $LongName, $DestFolder, $ShortName, $FileSize) = $csv->fields();
	$FileSize = round($FileSize / 1024);
	$DestFolder = substr ($DestFolder, 16);
	print "Proccessing file $LongName copied to $DestFolder\n";
	my $OutputStr = substr($LongName . "                                                  ", 0, 25) . " " . substr($ShortName . "             ", 0, 13) . " in \"$DestFolder\" ($FileSize KB)";
	print (TEMPFILE "$OutputStr\n");
}
# Post footer to the temp file
print (TEMPFILE $contentbottom);
close(NEWFILES);
close(TEMPFILE);

# Post the message to the group
system("$JSEXEC");
unlink "$TempName" || die "Unable to delete temp file $TempName";
unlink "$NEWFILESFILE" || die "Unable to delete list of files $NEWFILESFILE";
exit 0;
