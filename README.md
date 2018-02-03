# BBS Utilities (1.10)
Command-line utilities for the SBBS software
Official support sites: [Official Github Repo](https://github.com/fstltna/bbs_utils) - [Official Forum](https://synchronetbbs.org/index.php/forum/bbs-utils-suite-support) 
![Synchronet Logo](https://SynchronetBBS.org/SynchronetLogo.png) 

Included Utilities:
==
- **bbs_announce** (1.2) - This posts a text file to the desired groups. It posts as content, not a attachment! The settings are in the file at the top. Especially note that you need to copy (and edit unless you want to promote my BBS 😄) the Announce.txt to /sbbs/exec. Now allows command-line overrides of the default settings.
- **perladd.pl** (1.18) - Scans the current folder for new files and adds them to your BBS's file area. Now has a option to enable you to add descriptions to your files at add-time.
- **file_announce** (1.3) - This posts a list of files that you have added using perladd.pl to the message base of your choice. It posts as content, not a attachment! The settings are in the file at the top. Especially note that you need to copy (and edit unless you want to promote my BBS 😄) the FilePost.txt & FilePostBottom.txt to /sbbs/exec. This version now handles long descriptions in the file list columns. Now allows command-line overrides of the default settings.
- **file_remove** (1.0) - This removes a file from your processed list so it can be imported with perladd.pl again.
- **updseen.pl** - Updates the perladd.pl /root/.seen file to fix issues - Not usually needed...

Basic Workflow
==
**cd /source_dir**
**perladd.pl file_dir long**    <- this will prompt for file descriptions
**_repeat for each file to be added_**
**file_announce.pl**   <- this will post all the entries for the previous files to your message base
