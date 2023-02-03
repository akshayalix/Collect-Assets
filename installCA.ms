-- installer for collect aseet script

tempdirCA = getdir(#temp)+"\\CA_install_temp\\"
tmpbatpath = tempdirCA+"installCA.tmp"
installbatpath = tempdirCA+"installCA.bat"
try (close installbat) catch()
deleteFile installbatpath
if not copyFile tmpbatpath installbatpath then 
	messageBox "do not create intstallCA.bat file" title:"Error"
else 
(
	installbat = openfile installbatpath mode:"a" encoding:#utf8
	format "%\n" ("xcopy /Y /S /R \""+tempdirCA+"Icons\" \""+getdir(#ui_ln)+"Icons\"") to:installbat
	format "%\n" ("xcopy /Y /S /R \""+tempdirCA+"IconsDark\" \""+getdir(#ui_ln)+"IconsDark\"") to:installbat
	format "%\n" ("xcopy /Y /S /R \""+tempdirCA+"Collect_asset\" \""+getdir(#userScripts)+"\\Collect_asset\\\"") to:installbat
	close installbat
	DOSCommand ("\""+installbatpath+"\"")
)

fileIn "collect_asset_2.099.ms"
messageBox "Collect Asset is now installed!\n\nTo run it goto:\n   Customize -> Customize User Interface -> Toolbars\nCategory: \"ModX\" and drag \"Collect Asset\" to a toolbar.\n\nClick the toolbar icon to run it!" title:"Collect Asset Installed"
colorMan.reinitIcons() -- update icons

--delete old version
usericonspath = getdir(#userIcons)
deleteFile (usericonspath+"\\CollectAsset_16i.bmp")
deleteFile (usericonspath+"\\CollectAsset_24i.bmp")
deleteFile (getdir(#userMacros)+"\\_ Scripts-Collect_asset_2.mcr")


fn CAdeltmp =
(
 	HiddenDOSCommand ("rmdir /S /Q \""+tempdirCA+"\"")
)
callbacks.addScript #preSystemShutdown "CAdeltmp()" id:#CAdeltmp --delete temp folder on 3ds max exit