#!/usr/bin/perl
#
# -- Posts a BBS announcement to the desire sub-board

my $BBSSUBJ = "AmigaCity BBS - BBS For The Amiga";
my $BBSOWNER = "AmigaCity Admin";
my @GROUPS = ("DOVE-OPS","AMY-BBSNEWSA","RNRTN-SYNC");

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/Announce.txt";

# == No changes below here
my $JSEXEC = "jsexec postmsg.js -i\"$MSGBODYFILE\" -tALL -f\"$BBSOWNER\" -s\"$BBSSUBJ\"";

# Read in message content
foreach my $curgroup (@GROUPS)
{
	print "$JSEXEC $curgroup\n";
	print "Sending to: $curgroup ";
	#system("$JSEXEC $curgroup");
	print "- DONE\n";
}
exit 0;
