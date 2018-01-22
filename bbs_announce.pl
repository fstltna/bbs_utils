#!/usr/bin/perl
#
# -- Posts a BBS announcement to the desire sub-board

my $BBSSUBJ = "AmigaCity BBS - BBS For The Amiga";
my $BBSOWNER = "AmigaCity Admin";
my @GROUPS = ("DOVE-ADS","AMY-BBSNEWSA","RNRTNBBSAD");

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/Announce.txt";

# == No changes below here
my $JSEXEC = "jsexec postmsg.js -i\"$MSGBODYFILE\" -tALL -f\"$BBSOWNER\" -s\"$BBSSUBJ\"";

my $VERSION = "1.0";

print "Running bbs_announce $VERSION\n";
print "========================\n";

# Loop for each group
foreach my $curgroup (@GROUPS)
{
	#print "$JSEXEC $curgroup\n";
	print "Sending to: $curgroup\n";
	system("$JSEXEC $curgroup");
	print "Sending to $curgroup: DONE\n";
}

print "*** Please don't run this more than once per day!\n";
exit 0;
