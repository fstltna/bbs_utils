# bbs_announce
Submits a text file to a array of message bases.


Install Steps:
==
1. Edit Announce.txt for your desired website to promote. Unless you want to promote mine instead 😉
2. Copy the Announce.txt & bbs_announce.pl files to /sbbs/exec. You can put it anywhere but you must edit the bbs_announce.pl script to tell it where to look for Announce.txt.
3. Edit the /sbbs/exec/bbs_announce.pl script for your settings and what message bases you want to post in.
4. Do a test run by running bbs_announce.pl
5. If all looks good set up a cron job to run no more often than once per day - please no spam!
Here is a example cronjob entry:

	01 01 * * * /sbbs/exec/bbs_announce.pl

Getting Message Group IDs:
==
1. Run scfg
2. Go to "Message Areas"
3. Choose your message group
4. Select a entry
5. Go to "Message Sub-boards"
6. Choose your board and press [ENTER]
7. Note the entry for "Internal Code" - this is what you need to put in bbs_announce.pl
8. Repeat for any other boards you want to post to.
9. Exit scfg
10. All done!
