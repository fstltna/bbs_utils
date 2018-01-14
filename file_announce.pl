#!/usr/bin/perl
#
# -- Posts a file announcement to the desired sub-board

my $BBSSUBJ = "AmigaCity BBS - BBS For The Amiga";
my $BBSOWNER = "AmigaCity Admin";
my @GROUPS = ("DOVE-OPS");

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/FilePost.txt";

# == No changes below here
my $JSEXEC = "jsexec postmsg.js -i\"$MSGBODYFILE\" -tALL -f\"$BBSOWNER\" -s\"$BBSSUBJ\"";
my $content = "";
my $VERSION = "1.1";

print "Running bbs_announce $VERSION\n";
print "========================\n";

open(INPF, "<$MSGBODYFILE") || die "Unable to open $MSGBODYFILE for input";
{
        local $/;
        $content = <INPF>;
}
close(INPF);

print "$content\n";

# Loop for each group
foreach my $curgroup (@GROUPS)
{
	#print "$JSEXEC $curgroup\n";
	print "Sending to: $curgroup\n";
#	system("$JSEXEC $curgroup");
	print "Sending to $curgroup: DONE\n";
}

print "*** Please don't run this more than once per day!\n";
exit 0;
