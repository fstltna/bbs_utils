# file_announce
Submits a list of added downloads to a message base


Install Steps:
==
1. Edit FilePost.txt and FilePostBottom.txt for your desired website to promote. Unless you want to promote mine instead 😉
2. Copy the FilePost.txt, FilePostBottom.txt, and  file_announce.pl files to /sbbs/exec. You can put it anywhere but you must edit the file_announce.pl script to tell it where to look for those text files.
3. Edit the /sbbs/exec/file_announce.pl script for your settings and what message base you want to post in.
4. You will need to have uploaded at least one file with perladd.pl before you can run this script successfuly! If you have, then run this script by entering file_announce.pl

Getting The Message Group ID:
==
1. Run scfg
2. Go to "Message Areas"
3. Choose your message group
4. Select a entry
5. Go to "Message Sub-boards"
6. Choose your board and press [ENTER]
7. Note the entry for "Internal Code" - this is what you need to put in file_announce.pl
8. Exit scfg
9. All done!
