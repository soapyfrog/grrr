Grrr

A plaything from http://ps1.soapyfrog.com - doing inappropriate things with PowerShell.

Grrr is a Windows Console-based sprite and animation add on for PowerShell
and includes some samples scripts, like space invaders.


------ original README.txt -----

Grrr is a PowerShell snapin and so must be registered and added to your 
PowerShell session.

There's no installer yet, so just cd to the directory containing the
installgrrr.ps1 script and run:

./installgrrr.ps1 -r

(-r will re-register it if already registered)

Demos are in the demos directory - cd in there and run scripts directly. 

Once regisetered, you just add it in using:


add-pssnapin soapyfrog.grrr


Oh, if you want sound in biginvaders, you need to have DirectSound installed.
Get it from:

http://www.microsoft.com/downloads/details.aspx?FamilyId=2DA43D38-DB71-4C1B-BC6A-9B6652CD92A3&displaylang=en

.. or start biginvaders with the -nosound switch. This has had limited testing
as I don't have any XP machines without it installed :-)

TODO: update this for Vista.

postmaster@soapyfrog.com   /   http://ps1.soapyfrog.com/category/grrr
