#!/usr/bin/perl
#
# -- Posts a file announcement to the desired sub-board

use Text::CSV;

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
my $VERSION = "1.0";
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
print (TEMPFILE $content);

open(NEWFILES, "<$NEWFILESFILE") || die "Unable to open $NEWFILESFILE for input";

my $csv = Text::CSV->new();
#$csv = Text::CSV->setDelimiter(',');

# Loop for each file in the line
while(<NEWFILES>)
{
	chop;
	my $status = $csv->parse($_);
	($Field1, $LongName, $DestFolder, $ShortName) = $csv->fields();
	print "Proccessing file $LongName\n";
	$DestFolder = substr ($DestFolder, 16);
	print (TEMPFILE "$LongName - $ShortName in $DestFolder\n");
}
print (TEMPFILE $contentbottom);
close(NEWFILES);
close(TEMPFILE);

#	system("$JSEXEC");
exit 0;
