#!/usr/bin/perl
#
# -- Posts a file announcement to the desired sub-board

use Text::CSV;
use Math::Round;
use Getopt::Long;
use WebService::Discord::Webhook;

my $BBSSUBJ = "Subject Not Set";
my $BBSOWNER = "Owner Not Set";
my $GROUP = "Groups Not Set";
my $DISCORD_WEBHOOK = "";

# Probably no change for this
my $MSGBODYFILE = "/sbbs/exec/FilePost.txt";
my $MSGBODYBOTTOMFILE = "/sbbs/exec/FilePostBottom.txt";

# == No changes below here
my $content = "";
my $contentbottom = "";
my $VERSION = "1.4";
my $NEWFILESFILE="/root/.newfiles";         # Stores the list of files we have added but not posted about
my $USAGE;
my $discord = "";
my $CONF_FILE = "/root/.fa_settings";	# Settings to use
my $TempName = "/tmp/fileann.tmp";

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
		if (substr($line, 0, 8) eq "webhook=")
		{
			# Saw webhook
			$DISCORD_WEBHOOK = substr($line, 8);
			print ("Webhook = '$DISCORD_WEBHOOK'\n");
		}
	}
	close(INPF);
}

my $JSEXEC = "jsexec postmsg.js -i\"$TempName\" -tALL -f\"$BBSOWNER\" -s\"$BBSSUBJ\" $GROUP";

print "Running file_announce $VERSION\nUse \"--usage\" to get command options\n";
print "============================\n";

GetOptions ("length=i" => \$length,    # numeric
            "bbssubj=s" => \$BBSSUBJ,      # string
            "bbsowner=s" => \$BBSOWNER,      # string
            "group=s"  => \$GROUP,      # string
            "msgbody=s" => \$MSGBODYFILE,      # string
            "msgbodybot=s" => \$MSGBODYBOTTOMFILE,      # string
            "usage"    => \$USAGE,      # flag
            "discord"    => \$discord,      # string
            "verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");

if ($USAGE)
{
	print("Usage:\n\t--bbssubj = BBS Announce Subject\n\t--bbsowner = BBS Announce Owner\n\t--group = Group to post announcement to\n\t--msgbody = Message body file\n\t--msgbodybot = Message body bottom file\n\t--discord = flag to post to Discord\n");
	exit 0;
}

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
my $FilesWorked = 0;

# Loop for each line in the file
while(<NEWFILES>)
{
	chop;
	my $status = $csv->parse($_);
	my $Line2Out = "";
	my $Line3Out = "";
	my $Line4Out = "";
	my $Line5Out = "";
	my $Line6Out = "";
	my $Line7Out = "";
	($Field1, $LongName, $DestFolder, $ShortName, $FileSize) = $csv->fields();
	$FileSize = round($FileSize / 1024);
	$DestFolder = substr ($DestFolder, 16);
	print "Proccessing file $LongName copied to $DestFolder\n";
	my $LongLength= length($LongName);
	if ($LongLength > 25)
	{
		$Line2Out = substr($LongName . "                                                  ", 25, 25) . "|";
		if ($LongLength > 50)
		{
			$Line3Out = substr($LongName . "                                                  ", 50, 25) . "|";
			if ($LongLength > 75)
			{
				$Line4Out = substr($LongName . "                                                  ", 75, 25) . "|";
				if ($LongLength > 100)
				{
					$Line5Out = substr($LongName . "                                                  ", 100, 25) . "|";
					if ($LongLength > 125)
					{
						$Line6Out = substr($LongName . "                                                  ", 125, 25) . "|";
						if ($LongLength > 150)
						{
							$Line7Out = substr($LongName . "                                                  ", 50, 25) . "|";
						}
					}
				}
			}
		}
	}
	my $OutputStr = substr($LongName . "                                                  ", 0, 25) . "|" . substr($ShortName . "             ", 0, 13) . " | in \"$DestFolder\" ($FileSize KB)";
	if ($FilesWorked > 0)
	{
		print (TEMPFILE "---\n");
	}
	$FilesWorked++;
	print (TEMPFILE "$OutputStr\n");
	if ($Line2Out ne "")
	{
		print (TEMPFILE "$Line2Out\n");
	}
	if ($Line3Out ne "")
	{
		print (TEMPFILE "$Line3Out\n");
	}
	if ($Line4Out ne "")
	{
		print (TEMPFILE "$Line4Out\n");
	}
	if ($Line5Out ne "")
	{
		print (TEMPFILE "$Line5Out\n");
	}
	if ($Line6Out ne "")
	{
		print (TEMPFILE "$Line6Out\n");
	}
	if ($Line7Out ne "")
	{
		print (TEMPFILE "$Line7Out\n");
	}
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
