#!/usr/bin/perl
#
# -- Posts a BBS announcement to the desire sub-board

my $BBSSUBJ = "AmigaCity BBS - BBS For The Amiga";
my $BBSOWNER = "AmigaCity Admin";
my @GROUPS = ("DOVE-ADS","AMY-BBSNEWSA","RNRTNBBSAD","USENET_MSC","USENET_INBB");

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/Announce.txt";
use Getopt::Long;

# == No changes below here
my $VERSION = "1.3";
my $USAGE;
my $PASSEDGROUPS = "";

GetOptions ("length=i" => \$length,    # numeric
            "bbssubj=s" => \$BBSSUBJ,      # string
            "bbsowner=s" => \$BBSOWNER,      # string
            "groups=s"  => \$PASSEDGROUPS,      # string
            "msgbody=s" => \$MSGBODYFILE,      # string
            "usage"    => \$USAGE,      # flag
            "verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");

if ($USAGE)
{
        print("Usage:\n\t--bbssubj = BBS Announce Subject\n\t--bbsowner = BBS Announce Owner\n\t--groups = Groups to post announcements to (whitespace seperated)\n\t--msgbody = Message body file\n");
        exit 0;
}

print "Running bbs_announce $VERSION\nUse \"--usage\" to get command options\n";
print "============================\n";

if ($PASSEDGROUPS)
{
	@GROUPS = split(' ', $PASSEDGROUPS);
}
print("Posting to these groups: @GROUPS\n");

my $JSEXEC = "jsexec postmsg.js -i\"$MSGBODYFILE\" -tALL -f\"$BBSOWNER\" -s\"$BBSSUBJ\"";

# Loop for each group
foreach my $curgroup (@GROUPS)
{
	#print "$JSEXEC $curgroup\n";
	print "Sending to $curgroup\n";
	system("$JSEXEC $curgroup");
}

print "*** Please don't run this more than once per day!\n";
exit 0;
