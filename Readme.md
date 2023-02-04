# Collect Assets

- Based on script by @Morozov Anton.
- This script collects textures and other files used in the scene in one folder.

## This script work with:

- standart materials
- Vray Render
- Corona Render
- Octane Renderer
- Redshift Render
- FStorm Render
- Final Render

## Installation :

- Scripting -> Run script
- Select dowloaded file 
- `Inside 3ds Max` Find it in Customize -> Customize user interface -> Toolbars 
- Inside Category: `ModX`.

## Building from source

If you don't want to download built plugin from mirrors above, then you can build the plugin yourself.

- Make sure 7-Zip is installed in your Windows PC. Download [7-Zip](https://www.7-zip.org/) from here
- Clone the repository with [GitHub Desktop](https://desktop.github.com) or using git clone on WSL 2
```bat
:: ONLY RUN THIS IF YOU USE GIT AND HAVE IT INSTALLED
git clone --depth=1 https://github.com/akshayalix/Collect-Assets
```
- Run `build.bat`
- Don't use git in command-line or powershell to clone repo. Some users reported that it's corrupting contents.
- After a second, you will see a **.mzp** file with plugin name in the same folder.


