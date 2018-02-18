# perladd.pl

Adds files in the current directory to your BBS's download directory. It tracks files already added and will not add them again. Also handles converting long file names to 8.3 names automaticly.


Usage:
==

1. Very simple, just put the script into a directory in your path like **/sbbs/exec**
2. cd into the source directory, and run the script like this:


	perladd.pl games long
	
	where "games" is the file dir that the files should be symlinked to. The files are symlinked in to save space and the originals are untouched so you don't lose your long file names. The "long" option prompts for a description for each file, you can enter "link" if you just want to link the files and not supply a description.
	
	If you use the "long" option you can set your default editor by setting the EDITOR environment variable. By default nano is used.
	
	When entering a long description you can leave the default string alone to skip that file or edit the description to "abort" or "quit" to stop processing files.

3. You will need the following perl module installed using CPAN:


	String::Scanf

Credits
==
For more utilities or help with this script visit https://SynchronetBBS.org - looking forward to seeing you there!

* NOTE: If you have previously run this script you need to run the updseen.pl script ONCE. This will update your database so you don't get skipped entries. If you never ran it you can ignore this script.
