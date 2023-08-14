#!/usr/bin/perl
#
# -- Posts a BBS announcement to the desire sub-board

my $BBSSUBJ = "Subject Not Set";
my $BBSOWNER = "Owner Not Set";
my $GROUP = "Groups Not Set";

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/Announce.txt";
use Getopt::Long;

# == No changes below here
my $VERSION = "1.4.1";
my $USAGE;
my $CONF_FILE = "/root/.ba_settings";	# Settings to use

GetOptions ("length=i" => \$length,    # numeric
            "bbssubj=s" => \$BBSSUBJ,      # string
            "bbsowner=s" => \$BBSOWNER,      # string
            "groups=s"  => \$GROUP,      # string
            "msgbody=s" => \$MSGBODYFILE,      # string
            "usage"    => \$USAGE,      # flag
            "verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");

if ($USAGE)
{
        print("Usage:\n\t--bbssubj = BBS Announce Subject\n\t--bbsowner = BBS Announce Owner\n\t--groups = Groups to post announcements to (whitespace seperated)\n\t--msgbody = Message body file\n");
        exit 0;
}

# Try and pull in configs
if (-e $CONF_FILE)
{
	open(INPF, "<$CONF_FILE") || die "Unable to open $CONF_FILE for input";

	foreach $line (<INPF>)
	{
		#print $line;
		chop($line);
		if (substr($line, 0, 8) eq "bbssubj=")
		{
			# Saw Subject
			$BBSSUBJ = substr($line, 8);
			#print ("BBS Subject = '$BBSSUBJ'\n");
		}
		if (substr($line, 0, 9) eq "bbsowner=")
		{
			# Saw Owner
			$BBSOWNER = substr($line, 9);
			#print ("BBS Owner = '$BBSOWNER'\n");
		}
		if (substr($line, 0, 6) eq "group=")
		{
			# Saw Group
			$GROUP = substr($line, 6);
			#print ("BBS Group = '$GROUP'\n");
		}
	}
	close(INPF);
}

print "Running bbs_announce $VERSION\nUse \"--usage\" to get command options\n";
print "============================\n";

if ($GROUP)
{
	@GROUPS = split(' ', $GROUP);
}
print("Posting to these groups: $GROUP\n");

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
