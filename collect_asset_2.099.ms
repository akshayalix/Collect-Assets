macroScript Collect_asset_2
	Buttontext: "Collect Asset"
	category:"Xiruim"
	toolTip:"Collect Aasset 2"
	Icon:#("CollectAsset",1)
(
	title = "Collect Asset v2.099b"
	--This script created by Morozov Anton
	-- Collect all textures and others external files in one folder.
try (destroyDialog ::Collect_asset) catch()
try (destroyDialog ::match_bmp) catch()
try (destroyDialog ::List_assets) catch()
try (destroyDialog ::logform) catch()
try (destroyDialog ::settings) catch()
global Collect_asset, match_bmp, match_bmp2
local pic_1 = pic_2 = ""
local mb_inst, mb_propName
local errors = copied = 0
local exitt = false
local mb_result = #(0,"",false) -- [1] - 0 - cancel, 1 - leave exist, 2 - replace, 3 - rename [2] - filename [3] - boolean - repeat action
GLOBAL_INI_FILENAME = "collect_asset.ini"
G_INIsettings_FILENAME = "ca_settings.ini"
GLOBAL_INI_FILE_PATH = ((getdir #userScripts) + "\\Collect_asset\\")
INIFilename = pathConfig.appendPath GLOBAL_INI_FILE_PATH GLOBAL_INI_FILENAME
INISettingsFilename = pathConfig.appendPath GLOBAL_INI_FILE_PATH G_INIsettings_FILENAME
GLOBAL_7Z_PATH = (GLOBAL_INI_FILE_PATH + "7z\\")
local logfilepath = GLOBAL_INI_FILE_PATH +"log.txt"
G_IFL_FULLPATH = false
G_DIRSELECT = 2
G_Tooltip_Lang = 1
G_CollectPath = ""

if doesFileExist logfilepath == false do
(
	try logfile = createFile logfilepath catch()
	if logfile != undefined do close logfile
)
try logfile = openfile logfilepath mode:"w" catch()
if logfile != undefined do close logfile

fn printToLogWindow type logtext =
(
	if type == "ERR" do logform.TextBox.SelectionColor = (dotnetclass "System.Drawing.Color").FromArgb 180 0 0
	if type == "DBG" do logform.TextBox.SelectionColor = (dotnetclass "System.Drawing.Color").FromArgb 100 100 0
	if type == "INF" do logform.TextBox.SelectionColor = (dotnetclass "System.Drawing.Color").FromArgb 0 100 0
	logform.TextBox.AppendText(type+"::"+logtext+"\n")
	logform.TextBox.SelectionColor = logform.TextBox.ForeColor
)

fn logging type logtext msg:false =
(
	try logfile = openfile logfilepath mode:"a" encoding:#utf8 catch()
	if logfile != undefined do 
	(
		format "%" localtime to:logfile
		format "|%|%\n" type logtext to:logfile
		close logfile
	)
	try (
		printToLogWindow type logtext
	) catch()
	if msg do messagebox logtext title:type
)

--function to load variable from ini file
fn loadfromINI inifile section_name var_name =
(
	if doesFileExist inifile == false then 
	(
		logging "ERR" ("Do not exist INI file: "+inifile)
		undefined
	) else
	(
		local temp_value = ""
		logging "INF" ("Loading section: "+section_name+", var: "+var_name+", from file: "+inifile)
		temp_value = getINISetting inifile section_name var_name
		logging "DBG" ("Result: "+temp_value)
		if temp_value == "" then undefined else temp_value
	)
)

fn loadVarFromIniFile section_name var_name = 
(
	loadfromINI INIFilename section_name var_name
)

fn loadVarFromSettingsIniFile section_name var_name = 
(
	loadfromINI INISettingsFilename section_name var_name
)

--function write variable to ini file
fn writetoINI inifile section_name var_name var_value = 
(
	if doesFileExist inifile == false do 
		(
			logging "ERR" ("Do not exist INI file "+inifile)
		)
	temp_value = setINISetting inifile section_name var_name (var_value as string)
	if temp_value then logging "INF" ("Write "+var_name+" = "+(var_value as string)+" to INI file "+inifile)
		else logging "ERR" ("Can not write "+var_name+" = "+(var_value as string)+" to INI file "+inifile)
	temp_value
)

fn writeVarToIniFile section_name var_name var_value = 
(
	writetoINI INIFilename section_name var_name var_value
)

fn writeVarToSettingsIniFile section_name var_name var_value = 
(
	writetoINI INISettingsFilename section_name var_name var_value
)

fn Collect_assetOpenUI = (
	-- load settings from ini file
	tmp = (loadVarFromSettingsIniFile "settings" "IFL_FULLPATH")
	if tmp == "true" do G_IFL_FULLPATH = true
	if tmp == "false" do G_IFL_FULLPATH = false
	tmp = (loadVarFromSettingsIniFile "settings" "G_DIRSELECT")
	if tmp != undefined do G_DIRSELECT = tmp as integer
	tmp = (loadVarFromSettingsIniFile "settings" "G_Tooltip_Lang")
	if tmp != undefined do G_Tooltip_Lang = tmp as integer
	local dialogPos = [200,150]
	local temp_value = loadVarFromSettingsIniFile "settings" "dialogPos"
	if temp_value != undefined do dialogPos = execute (temp_value)
	CreateDialog Collect_asset pos:dialogPos
)

FileTypeLights = #(".ies")
FileTypeImg = #(".jpg", ".jpeg", ".bmp", ".tif", ".tiff", ".psd", ".png", ".gif", ".hdr", ".exr",".tga")

fndClasses = #(#(bitmaptex,#filename),
	#(camera_map_per_pixel,#zbuffer),
	#(VRayHDRI,#HDRIMapName),
	#(VRayProxy,#filename),
	#(VRayBmpFilter,#bitmap),
	#(vray_lens_effects,#glareBitmap,#glareObstacleImage),
	#(CoronaProxy,#filename),
	#(CProxy,#filename),
	#(coronaBitmap,#filename),
	#(Alpha_image,#filename),
	#(Greyscale_image,#filename),
	#(IES_Texture,#file),
	#(OctaneProxy,#file),
	#(RGB_image,#filename),
	#(AlembicObject,#source),
	#(point_Cache,#filename),
	#(FStormBitmap,#fileName),
	#(FStormProxy,#File),
	#(proxy,#file),
	#(fR_Proxy,#proxyFile),
	#(fR_Scatter,#proxyFile),
	#(BitmapHDR,#fileName,#fromLUT),
	#(Plant,#lbwfile),
	#(Forest_Pro,#mapname),
	#(Displace,#bitmap),
	#(CoronaCam,#lutFilename),
	#(BipSlave_Control,#filename),
	#(Redshift_Bitmap,#tex0),
	#(Redshift_Camera_Map,#tex0),
	#(Redshift_Environment,#tex0,#tex1,#tex2,#tex3,#tex4),
	#(Redshift_Normal_Map,#tex0),
	#(RS_Bitmap,#tex0),
	#(RS_Camera_Map,#tex0),
	#(RS_Environment,#tex0,#tex1,#tex2,#tex3,#tex4),
	#(RS_Normal_Map,#tex0),
	#(RS_Sprite,#tex0),
	#(proxyGeometry,#file),
	#(VolumeGeometry,#file),
	#(VRayVolumeGrid,#rendinput))

fn getLightsUnique =
(	
	local lightsunique = #()
	local lightinstances = #()
	local instances = #()
	for lightt in lights where (finditem lightinstances lightt) == 0 do
	(
		InstanceMgr.GetInstances lightt &instances
		append lightsunique lightt
		lightinstances += instances
	)
	lightsunique
)

LightListUnique = getLightsUnique()

fn getClassesLight =
(
	local tmp = #()
	local fndlightsprop = #(#ies_file,#webFile,#iesFile,#ies,#profile,#tex0,#tex1,#tex2,#tex3,#tex4,#tex5)
	local fnd = false
	local c
	for c in LightListUnique do
		for lightsprop in fndlightsprop do
			if isProperty c lightsprop do
			(
				cls = Classof c
				for itmtmp in tmp do
					if itmtmp[1] == cls and itmtmp[2] == lightsprop then
					(
						fnd = true
						exit
					) else
						fnd = false
				if not fnd do append tmp #(cls,lightsprop)
			)
	tmp
)

fndClassesLight = getClassesLight()
fndClasses += fndClassesLight
fndassets = #()
assiflFiles = #()
struct asset (inst, propName, filepath, foundpath, status,type)
struct countStat (okk, found, missing, xref)
struct iflFile (filename)
local counts

fn GetStatusFile file = 
(
	local k, nullpath=false, existfile
	local foundfile = mapPaths.getFullFilePath(filenameFromPath(file))
	if getFilenamePath(file) == "" do nullpath = true
	existfile = doesFileExist(file)
	if existfile do
		k = #Ok
	if existfile and nullpath do
		k = #Found
	if existfile == false and foundfile != "" do
		k = #Found
	if existfile == false and foundfile == "" do
		k = #Missing
	k
)

fn prgrbar i all statustext =
(
	Collect_asset.progress_status.text = statustext
	logging "INF" statustext
	if i == 0 do i = 1
	if i > all do i = all
	if all == 0 then precents = 0 else precents = 1000/(all*10 / i)
	if precents > 100 then precents = 100
	Collect_asset.pb1.value = precents
	if (((maxVersion())[1] / 1000) >= 13) do windows.processPostedMessages() 
)

function getprop inst cls =
(
	local prop, err, found
	local err_match1 = "-- Runtime error: Error opening bitmap: "
	try 
		prop = (getproperty inst cls)
	catch
	(
		prop = undefined
		err = getCurrentException()
		--print err
		found = findString err err_match1
		if  found != undefined do
			prop = substring  err (err_match1.count+1) (err.count-err_match1.count+1)
	)
	prop
)

function getFileHash SourceFile =
(
	hMethod = dotNetObject "System.Security.Cryptography.MD5CryptoServiceProvider"
	f = dotNetObject "System.IO.FileStream" SourceFile (dotNetClass "System.IO.FileMode").Open (dotNetClass "System.IO.FileAccess").Read (dotNetClass "System.IO.FileShare").Read 8192
	hMethod.ComputeHash f
	hash = hMethod.Hash
	f.Close()
	buff = dotnetObject "System.Text.StringBuilder"
	byte = dotNetClass "System.Byte"
	SysString = dotNetClass "System.String"
	for hashByte in hash do
	(
		buff.Append (SysString.Format "{0:X2}" hashByte)
	)
	buff.ToString()
)

fn isIdenticalFiles file1 file2 =
(
	local rtrn = false
	if (getFileSize(file1) == getFileSize(file2)) do
		if getFileHash file1 == getFileHash file2 do rtrn = true
	rtrn
)

fn chk_filename filename =
(
	if filename != undefined do
		if (finditem #(@"\",@"/"," ") filename[filename.count]) > 0 do filename = ""
	filename
)

fn getXrefAsset =
(
	statustext = "Get Xref List Asset Files"
	local fndXrefAssets = #()
	local type = "xref"
	for i=1 to xrefs.getXRefFileCount() where xrefs.getXRefFileCount() > 0 do
	(
		fileassets = #()
		tmpXref = xrefs.getXRefFile i
		filename = tmpXref.filename
		status = (GetStatusFile(filename))
		append fndXrefAssets (asset tmpXref #filename filename (mapPaths.getFullFilePath(filenameFromPath(filename))) status type)
		if status != #Missing do
		(
			if status == #Found then filename = mapPaths.getFullFilePath(filenameFromPath(tmpXref.filename))
			fileassets = getMAXFileAssetMetadata (filename)
			if fileassets != undefined do append fndXrefAssets (asset fileassets #filename filename filename #XRefScene type)
		)
		prgrbar i (xrefs.getXRefFileCount()) (statustext + " : get XRef Files - " + filenameFromPath(filename))
	)
	for i=1 to objXRefMgr.recordCount where objXRefMgr.recordCount > 0 do
	(
		fileassets = #()
		tmpXref = objXRefMgr.GetRecord i
		filename = tmpXref.srcFileName
		status = (GetStatusFile(filename))
		append fndXrefAssets (asset tmpXref #srcFileName filename (mapPaths.getFullFilePath(filenameFromPath(filename))) status type)
		if status != #Missing do
		(
			if status == #Found then filename = mapPaths.getFullFilePath(filenameFromPath(filename))
			fileassets = getMAXFileAssetMetadata (filename)
			append fndXrefAssets (asset fileassets #filename filename filename #XRefScene type)
		)
		prgrbar i (objXRefMgr.recordCount) (statustext + " : get XRef objects - " + filenameFromPath(filename))
	)
	prgrbar 0 0 "End Get List Xref Assets"
	fndXrefAssets
)

function getAssetFiles = 
(
	statustext = "Get List Asset Files"
	fndassets = #()
	local tmp = #()
	j = 0
	for fndClass in fndClasses do
	(
		try (tmp = getClassInstances fndClass[1]) catch (tmp = #())
		for inst in tmp do 
		for i=2 to fndClass.count do
		(
			filename = (getprop inst fndClass[i])
			if filename != undefined do
			(
				if (classof filename) == BitMap do filename = (getproperty filename #filename)
				if chk_filename(filename) != "" do
					append fndassets (asset inst fndClass[i] filename (mapPaths.getFullFilePath(filenameFromPath(filename))) (GetStatusFile(filename)) "asset")
			)
		)
		j += 1
		prgrbar j fndClasses.count (statustext + " : get class - " + fndClass as string)
	)
	-- === Add Xref files ===
	join fndassets (getXrefAsset())
	-- === Add V_Ray files ===
	--if matchPattern ((classof renderers.current) as string) pattern:"V_Ray_Adv*" do
	--(
		vrayprop = #(#adv_irradmap_loadFileName, #lightcache_loadFileName, #caustics_loadFileName, #photonMap_loadFileName, #colorMap_lut_path, #gi_uhdCache_file) 
		for prop in vrayprop do
		(
			filename = undefined
			try (filename = (getproperty renderers.current prop)) catch (tmp = #())
			if (chk_filename(filename) != "") and (filename != undefined) do 
				append fndassets (asset renderers.current prop filename (mapPaths.getFullFilePath(filenameFromPath(filename))) (GetStatusFile(filename)) "vray")
		)
	--)
	--=== Add Motion Flow Bip files ===
	try (tmp = getClassInstances Vertical_Horizontal_Turn) catch (tmp = #())
	for inst in tmp do 
	(
		snippets = inst.motionFlow.snippets
		for snip in snippets do
		(
			filename = undefined
			try (filename = snip.filename) catch ()
			if (chk_filename(filename) != "") and (filename != undefined) do 
				append fndassets (asset snip #filename filename (mapPaths.getFullFilePath(filenameFromPath(filename))) (GetStatusFile(filename)) "bip")
		)
	)
	prgrbar 0 0 "End Get List Asset Files"
)

function getAssetFiles_simple =
(
	logging "DBG" "start function getAssetFiles_simple"
	local status
	fndassets_simple = #()
	for ass in fndassets where (findItem #(XRefScene, MixinInterface, Array) (classof ass.inst))==0 do
	(
		filename = (getprop ass.inst ass.propName)
		if filename != undefined do
		(
			if (classof filename) == BitMap do filename = (getproperty filename #filename)
			if ass.status ==  #XRefScene then status = #XRefScene else status = (GetStatusFile(filename))
			if filename != "" do 
			(
				append fndassets_simple (asset ass.inst ass.propName filename (mapPaths.getFullFilePath(filenameFromPath(filename))) status ass.type)
			)
		)
	)
-- === Add Xref files ===
	join fndassets_simple (getXrefAsset())
	fndassets=fndassets_simple
)

fn seek_files seek_path subfolders =
(
	logging "DBG" "start function seek_files"
	dir_array = #(seek_path)
	if subfolders do
	(
		for d in dir_array do
			join dir_array (GetDirectories (d+"/*"))
	)
	for ass in fndassets where ass.status == #Missing do
	(
		filename = ass.filepath
		for d in dir_array do
			if doesFileExist (d+filenameFromPath(filename)) do
			(
				ass.foundpath = d+filenameFromPath(filename)
				ass.status = #Found
				logging "INF" ("Found file: "+ass.foundpath)
				counts.found += 1
				counts.missing -= 1
			)
	)
	Collect_asset.status.caption = "Ok - "+ counts.okk as string +", Found - "+ counts.found as string +", Missing - "+ counts.missing as string
)

function getAssetFilesSelected = 
(
	statustext = "Get List Selected Asset Files"
	fndassetsSel = #()
	local tmp = #()
	j = 0
	for fndClass in fndClasses do
	(
		tmp = #()
		for obj in selection do
			try (tmp += getClassInstances fndClass[1] target:obj) catch ()
		for inst in tmp do 
		for i=2 to fndClass.count do
		(
			if (getproperty inst fndClass[i]) != undefined do
			(
				filename = (getproperty inst fndClass[i])
				if (classof filename) == BitMap do filename = (getproperty filename #filename)
				if filename != "" do
					append fndassetsSel (asset inst fndClass[i] filename (mapPaths.getFullFilePath(filenameFromPath(filename))) (GetStatusFile(filename)) "asset")
			)
		)
		j += 1
		prgrbar j fndClasses.count (statustext + " : get class - " + fndClass as string)
	)
	prgrbar 0 0 "End Get List Selected Asset Files"
	return fndassetsSel
)

function statusrfr simple:false = 
(
	local tmpfln = #()
	if simple then getAssetFiles_simple() else getAssetFiles()
	counts = countStat 0 0 0 0
	for ass in fndassets where (appendifunique tmpfln ass.filepath) or  (ass.status == #XRefScene) do
	(
		if ass.status == #Ok do
			counts.okk += 1
		if ass.status == #Found do
			counts.found += 1
		if ass.status == #Missing do
			counts.missing += 1
		if ass.status == #XRefScene do
		(
			counts.xref += 1
			for assxrf in ass.inst where (appendifunique tmpfln assxrf.filename) do
			(
				if assxrf.filename == "" or assxrf.filename == undefined do
					continue
				status = GetStatusFile(assxrf.filename)
				if status == #Ok do
					counts.okk += 1
				if status == #Found do
					counts.found += 1
				if status == #Missing do
					counts.missing += 1
			)
		)
	)
	Collect_asset.status.caption = "Ok - "+ counts.okk as string +", Found - "+ counts.found as string +", Missing - "+ counts.missing as string
)

fn random_name cnt:12 =
(
	local rndname = "_"
	local symbols = "0123456789qwertyuiopasdfghjklzxcvbnm"
	for i=1 to cnt do rndname += symbols [(random 1 symbols.count)]
	rndname
)

fn xrefupdate =
(
	logging "INF" ("Start xrefupdate")
	for i=1 to xrefs.getXRefFileCount() where xrefs.getXRefFileCount() > 0 do
	(
		tmpXref = xrefs.getXRefFile i
		updateXRef tmpXref
	)
	for i=1 to objXRefMgr.recordCount where objXRefMgr.recordCount > 0 do
	(
		tmpXref = objXRefMgr.GetRecord i
		tmpXref.update()
	)
)

fn relinkfile inst propName newfullpath =
(
	logging "DBG" ("Run fn relinkfile :: " + inst as string + " :: " + propName as string + " :: "+ newfullpath)
	local prop
	prop = getprop inst propName
	if prop != undefined do (
		if (classof prop) == BitMap then 
		(
			oldfullpath = prop.filename
			for i=1 to 3 while toLower(prop.filename) != toLower(newfullpath) do
			(
				setproperty prop #filename newfullpath
				setproperty inst propName prop
				try (prop = getproperty inst propName) catch (errors += 1; logging "ERR" ("NOT getproperty from " + inst as string); exit)
			)
			if toLower(prop.filename) != toLower(newfullpath) then 
			(
				logging "ERR" ("NOT Relink " + oldfullpath as string + " to: " + newfullpath as string)
				errors += 1
			)
			else
				logging "INF" ("Relink " + oldfullpath as string + " to: " + newfullpath as string)
		)
		else (
			oldfullpath = prop
			for i=1 to 3 while (prop != undefined) and (toLower(prop) != toLower(newfullpath)) do
			(
				try (setproperty inst propName newfullpath) catch (errors += 1; logging "ERR" ("NOT Relink " + oldfullpath as string + " to: " + newfullpath as string); exit)
				try (prop = getprop inst propName) catch (exit)
			)
			if (prop != undefined) and (toLower(prop) != toLower(newfullpath)) then
			(
				logging "ERR" ("NOT Relink " + oldfullpath as string + " to: " + newfullpath as string)
				errors += 1
			)
			else
				logging "INF" ("Relink " + oldfullpath as string + " to: " + newfullpath as string)
		)
	)
)

function ResolvePaths = 
(
	local i=0
	for ass in fndassets do
	(
		prgrbar i fndassets.count ("Resolve Paths : "+filenameFromPath(ass.filepath))
		if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
		if ass.status == #Found do relinkfile ass.inst ass.propName ass.foundpath
		if ass.status == #XRefScene do
		(
			upd = false
			for assxrf in ass.inst do
			(
				status = GetStatusFile(assxrf.filename)
				if status == #Found do
				(
					assxrf.filename = mapPaths.getFullFilePath(filenameFromPath(assxrf.filename))
					upd = true	
				)
			)
			if upd do setMAXFileAssetMetadata ass.foundpath ass.inst
		)
		i+=1
	)
	prgrbar 0 0 "End Resolve Paths"
)

function DelMissing = 
(
	local i=0
	local upd = false
	for ass in fndassets do
	(
		if ass.status == #Missing do (
			relinkfile ass.inst ass.propName ""
			i+=1
			prgrbar i counts.missing "Deleting missing paths..."
		)
		if ass.status == #XRefScene do
		(
			upd = false
			for assxrf in ass.inst do
			(
				status = GetStatusFile(assxrf.filename)
				if status == #Missing do
				(
					assxrf.filename = ""
					upd = true
				)
			)
			if upd do 
				setMAXFileAssetMetadata ass.foundpath ass.inst
		)
		if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
	)
	prgrbar 0 0 "Missing paths deleted"
)

function chDir dirpath = (
	if (doesFileExist dirpath) == false then (
		if queryBox("Directory does not exist. Create a Directory?") then
			if (makeDir dirpath all:true) then (
				logging "INF" ("Create Directory: "+dirpath)
				return true
			)
			else logging "ERR" ("Can not create directory "+dirpath) msg:true
	) else (
		local str = dirpath
		if dirpath.count > 1 do if (substring dirpath (dirpath.count - 1) 2) != ":\\" do str = trimRight dirpath "\\\/"
		if isDirectoryWriteable(str) then
			return true
		else logging "ERR" ("Directory not writeable "+dirpath) msg:true
	)
	return false
)

function create_Dir dirpath = (
	local err = true
	if (doesFileExist dirpath) == true then 
		(
			HiddenDOSCommand ("rmdir /S /Q "+dirpath) exitCode:&exitcode
			if exitcode != 0 then ( logging "ERR" ("EROR delete dir " + dirpath); err = false;)
		)
	if (doesFileExist dirpath) == false then 
		if (makeDir dirpath all:true) == false then (logging "ERR" ("EROR create dir " + dirpath); err = false;)
	err
)

fn get_tooltips_lang = 
(
	local lang = ""
	case G_Tooltip_Lang of
	(
		1: lang = "tootlips_EN"
		2: lang = "tootlips_RU"
	)
	lang
)

--load tooltips for controls
function loadTooltips rolloutt:"Collect_asset" = (
	local tooltips_lang = get_tooltips_lang()
	tmp_rollout = execute(rolloutt)
	for c in tmp_rollout.controls do
	(
		tmp_name = rolloutt + "_" + c.name
		if hasINISetting INIFilename tooltips_lang tmp_name do 
			c.tooltip = loadVarFromIniFile tooltips_lang tmp_name
	)
)

function enableCtrl ctrl = (
	if ctrl then 
		for c in Collect_asset.controls where (classof c == ButtonControl) do c.enabled = true
	else
		for c in Collect_asset.controls where (classof c == ButtonControl) do c.enabled = false
)

function dim_x bmpin = (
	if bmpin.width >= bmpin.height then
		330
	else
		330*(bmpin.width*100 / bmpin.height)/100
)
function dim_y bmpin = (
	if bmpin.width <= bmpin.height then
		330
	else
		330*(bmpin.height*100 / bmpin.width)/100
)

function chk_path str = (
	--str = toLower str
	str = trimleft str
	str = trimRight str
	banlet = "?*\"<>|\n"
	for i=1 to banlet.count where str !="" do
	(
		str = substituteString str banlet[i] ""
	)
	str = trimRight str "\\\/"
	str += "\\"
	if str == "\\" do str = ""
	str
)

fn query_match_bmp pc1 pc2 relink =
(
	pic_1 = pc1
	pic_2 = pc2
	mb_result = #(0,"",false) -- [1] - 0 - cancel, 1 - leave exist, 2 - replace, 3 - rename [2] - filename [3] - boolean - repeat action
	if relink then createDialog match_bmp modal:true else createDialog match_bmp2 modal:true
	if mb_result[1] == 3 do (
		if doesFileExist(mb_result[2]) then (
			messagebox "File alrady exist. Try another file name \n mb_result[2]"
			query_match_bmp pic_1 pic_2
		)
	)
	logging "DBG" ("fn query_match_bmp return "+mb_result as string)
	mb_result
)

fn match_bmp_as oldfullpath newfullpath mb_inst mb_propName relink =(
	local errors = copied = i = 0
	if mb_result[3] == false do mb_result = query_match_bmp oldfullpath newfullpath relink
	case mb_result[1] of
	(
		1: (
			if relink do (
				relinkfile mb_inst mb_propName newfullpath
				logging "INF" ("Use file in new path: "+newfullpath)
			)
		)
		2: (
			if (deleteFile newfullpath) and (copyFile oldfullpath newfullpath) then (
				if relink do	relinkfile mb_inst mb_propName newfullpath
				copied = copied+1
				logging "INF" ("Replace file done.")
			)
			else logging "ERR" ("Can not replace the file. Check access "+newfullpath)
		)
		3: (
			if mb_result[3] == false then
				rnmfullpath = mb_result[2]
			else
				do rnmfullpath = getFilenamePath newfullpath + random_name() + getFilenameType newfullpath while doesFileExist(rnmfullpath)
			if doesFileExist(rnmfullpath) == false then (
				if (copyFile oldfullpath rnmfullpath) then (
					relinkfile mb_inst mb_propName rnmfullpath
					copied = copied+1
					logging "INF" ("Rename file to "+rnmfullpath)
				) else logging "ERR" ("Can not save the file. Check access"+rnmfullpath)
			) else (
				logging "ERR" ("File alrady exist: "+rnmfullpath)
			)
		)
	)
	#(copied, errors)
)

fn relink_pointCache filename dirpath =
(
	logging "DBG" ("Run fn relink_pointCache " + filename + " " + dirpath)
	local newPath = dirpath
	local errors = copied = i = 0
	files = getFiles (getFilenamePath filename + getFilenameFile filename + "*.mc")
	if files.count != 0 do (
		mb_result[3] = false
		for oldfullpath in files do
		(
			newfullpath = newPath + filenameFromPath oldfullpath
			if (toLower newfullpath) != (toLower oldfullpath) do
			(
				if doesFileExist(newfullpath) == false then (
					if (copyFile oldfullpath newfullpath) then (
						logging "INF" ("Copy file from "+oldfullpath+" to "+newfullpath)
						copied = copied+1
					) else (errors = errors+1; logging "ERR" ("Can not copy file from "+oldfullpath+" to "+newfullpath))
				)
				else (
					if not isIdenticalFiles oldfullpath newfullpath then (
						logging "INF" ("Found different files: "+oldfullpath+" "+newfullpath)
						if mb_result[3] == false do mb_result = query_match_bmp oldfullpath newfullpath false
						case mb_result[1] of
						(
							1: (
								fileLine.filename = newfullpath
								upd = true
								logging "INF" ("Use file in new path: "+newfullpath)
							)
							2: (
								if (deleteFile newfullpath) and (copyFile oldfullpath newfullpath) then (
									fileLine.filename = newfullpath
									upd = true
									copied = copied+1
									logging "INF" ("Replace file done.")
								)
								else (errors = errors+1; logging "ERR" ("Can not replace the file. Check access "+newfullpath))
							)
						)
					)
				)
			)
		)
		mb_result[3] = false
	)
	#(copied, errors)
)

fn relink_ifl filename dirpath relink fullpath:G_IFL_FULLPATH = 
(
	assiflFiles = #()
	local newPath = dirpath
	local errors = copied = i = 0
	local file = openFile filename mode:"rt"
	if file != undefined then
	(
		while not eof file do (
			append assiflFiles (iflFile (readLine file))
		)
		close file
	--	print assiflFiles
		upd = false
		for fileLine in assiflFiles do (
			if (not matchPattern fileLine.filename pattern:@"*\*") and (doesFileExist(getFilenamePath filename + filenameFromPath fileLine.filename)) then
			(
				oldfullpath = getFilenamePath filename + filenameFromPath fileLine.filename
			)else(
				status = GetStatusFile(fileLine.filename)
				if status == #Missing do continue
				if status == #Found do oldfullpath = mapPaths.getFullFilePath(filenameFromPath(fileLine.filename))
				if status == #Ok do oldfullpath = fileLine.filename
			)
			newfullpath = newPath + filenameFromPath oldfullpath
			if (toLower newfullpath) != (toLower oldfullpath) do
			(
				if doesFileExist(newfullpath) == false then (
					if (copyFile oldfullpath newfullpath) then (
						if relink do (
							fileLine.filename = newfullpath
							upd = true
						)
						logging "INF" ("Copy file from "+oldfullpath+" to "+newfullpath)
						copied = copied+1
						--print newfullpath
					) else errors = errors+1
				)
				else (
					if not isIdenticalFiles oldfullpath newfullpath then (
						logging "INF" ("Found different files: "+oldfullpath+" "+newfullpath)
						if mb_result[3] == false do mb_result = query_match_bmp oldfullpath newfullpath relink
						case mb_result[1] of
						(
							1: (
								fileLine.filename = newfullpath
								upd = true
								logging "INF" ("Use file in new path: "+newfullpath)
							)
							2: (
								if (deleteFile newfullpath) and (copyFile oldfullpath newfullpath) then (
									fileLine.filename = newfullpath
									upd = true
									copied = copied+1
									logging "INF" ("Replace file done.")
								)
								else logging "ERR" ("Can not replace the file. Check access "+newfullpath)
							)
							3: (
								if mb_result[3] == false then
									rnmfullpath = mb_result[2]
								else
									do rnmfullpath = getFilenamePath newfullpath + random_name() + getFilenameType newfullpath while doesFileExist(rnmfullpath)
								if doesFileExist(rnmfullpath) == false then (
									if (copyFile oldfullpath rnmfullpath) then (
										fileLine.filename = rnmfullpath
										upd = true
										copied = copied+1
										logging "INF" ("Rename file to "+rnmfullpath)
									) else logging "ERR" ("Can not save the file. Check access"+rnmfullpath)
								) else (
									logging "ERR" ("File alrady exist: "+rnmfullpath)
								)
							)
						)
					) else (
						if relink do (
							fileLine.filename = newfullpath
							upd = true
						)
					)
				)
			)
		)
		if upd then (
			try file = openFile (dirpath + filenameFromPath filename) mode:"w" catch()
			if file != undefined then
			(
				for fileLine in assiflFiles do (
					if fullpath then 
						format "%\n" fileLine.filename to:file
					else
						format "%\n" (filenameFromPath(fileLine.filename)) to:file
				)
				close file
			) else (
				errors = errors+1
				logging "ERR" ("Error open file to write: "+filename)
			)
		)
	) else (
		errors = errors+1
		logging "ERR" ("Error open file to read: "+filename)
	)
	#(copied, errors)
)

function collect_as dirpath selected relink = 
(
	mb_result = #(0,"",false) -- [1] - 0 - cancel, 1 - leave exist, 2 - replace, 3 - rename [2] - filename [3] - boolean - repeat action
	local prop
	if selected do 
		fndassets = getAssetFilesSelected()
	newPath = dirpath
	errors = copied = i = 0
	for ass in fndassets where (ass.status == #Found or ass.status == #Ok) while not exitt do (
		if Collect_asset.chk_exxref.checked and (ass.type == "xref") do continue
		if ass.status == #Found do oldfullpath = ass.foundpath
		if ass.status == #Ok do oldfullpath = ass.filepath
		if chk_filename(oldfullpath)=="" do continue
		newfullpath = newPath + filenameFromPath oldfullpath
		prgrbar i (counts.okk + counts.found) ("Collect Assets : "+(filenameFromPath newfullpath))
		if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
		--format "oldpath: %\n newpath: %\n" oldfullpath newfullpath
		if (toLower(getFilenameType oldfullpath)) == ".xml" do (
			relink_pointCache oldfullpath dirpath
		)
		if (toLower newfullpath) != (toLower oldfullpath) then
		(
			if doesFileExist(newfullpath) == false then (
				if (copyFile oldfullpath newfullpath) then (
					if relink then
					(
						relinkfile ass.inst ass.propName newfullpath
						logging "INF" ("Copy and Relink file from "+oldfullpath+" to "+newfullpath)
					)
					else
					(
					logging "INF" ("Copy file from "+oldfullpath+" to "+newfullpath)
					)
					copied = copied+1
					--print newfullpath
				) else (errors = errors+1; logging "ERR" ("Can not copy file from "+oldfullpath+"to"+newfullpath) )
			)
			else (
				if not isIdenticalFiles oldfullpath newfullpath then (
					logging "INF" ("Found different files: "+oldfullpath+" "+newfullpath)
					resultfn = match_bmp_as oldfullpath newfullpath ass.inst ass.propName relink
					copied = copied + resultfn[1]
					errors = errors + resultfn[2]
				) else (
					if relink do 
					(
						relinkfile ass.inst ass.propName newfullpath
						logging "INF" ("Relink file from "+oldfullpath+" to "+newfullpath)
					)
				)
			)
		)
		else
		(
			if relink do 
			(
				relinkfile ass.inst ass.propName newfullpath
				logging "INF" ("Relink file from "+oldfullpath+" to "+newfullpath)
			)
		)
		if (toLower(getFilenameType oldfullpath)) == ".ifl" do (
			relink_ifl oldfullpath dirpath relink
		)
		i+=1
	)
	prgrbar 0 0 "End Collect Assets"
	#(copied, errors)
)

fn collect_as_xref dirpath relink = 
(
	logging "DBG" ("start  collect_as_xref")
	newPath = dirpath
	errors = copied = i = 0
	updall = false
	for ass in fndassets where ass.status == #XRefScene while not exitt do
	(
		upd = false
		for assxrf in ass.inst do
		(
			status = GetStatusFile(assxrf.filename)
			if status == #Missing do
				continue
			if status == #Found do oldfullpath = mapPaths.getFullFilePath(filenameFromPath(assxrf.filename))
			if status == #Ok do oldfullpath = assxrf.filename
			newfullpath = newPath + filenameFromPath oldfullpath
			if (toLower newfullpath) != (toLower assxrf.filename) do
			(
				if doesFileExist(newfullpath) == false then (
					if (copyFile oldfullpath newfullpath) then (
						if relink do (
							assxrf.filename = newfullpath
							upd = true
						)
						copied = copied+1
						--print newfullpath
					) else errors = errors+1
				)
				else (
					if not isIdenticalFiles oldfullpath newfullpath then (
						logging "INF" ("Found different files: "+oldfullpath+" "+newfullpath)
						resultfn=match_bmp_as oldfullpath newfullpath assxrf ass.propName relink
						copied += resultfn[1]
						errors += resultfn[2]
					) else (
						if relink do (
							assxrf.filename = newfullpath
							upd = true
						)
					)
				)
			)
			if (toLower(getFilenameType oldfullpath)) == ".ifl" do (
				relink_ifl assxrf.filename dirpath relink
			)
			if (toLower(getFilenameType oldfullpath)) == ".xml" do (
				relink_pointCache assxrf.filename dirpath
			)
		)
		if upd do 
		(
			logging "INF" ("Save Xref file: "+ass.foundpath)
			setMAXFileAssetMetadata ass.foundpath ass.inst
			updall = true
		)
		i+=1
		prgrbar i counts.xref ("Collect Assets Xref files...")
		if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
	)
	if updall do xrefupdate()
	prgrbar 0 0 "End Collect Xref files"
	#(copied, errors)
)

fn fill_table_aseets_li filepath status =
(
	local li
	li = dotNetObject "System.Windows.Forms.ListViewItem" (filenamefrompath filepath)
	li.SubItems.add (getFilenamePath filepath)
	li.SubItems.add (status as string)
	if (finditem FileTypeLights (toLower(getFilenameType filepath))) != 0 do
		li.BackColor = (dotNetClass "System.Drawing.Color").LightYellow
	if (finditem FileTypeImg (toLower(getFilenameType filepath))) != 0 do
		li.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 215 255 207
	if status == #Missing do
		li.ForeColor = (dotNetClass "System.Drawing.Color").Red
	return li
)

fn fill_table_aseets ch =
(
	local theRange = #()
	local tmpar = #()
	local li
	for ass in fndassets do
	(
		if ass.status == #Ok and not ch[1] do 
			continue
		if ass.status == #Found and not ch[2] do 
			continue 
		if ass.status == #Missing and not ch[3] do 
			continue 
		if (findItem tmpar ass.filepath) != 0 and ass.status != #XRefScene do
 			continue
		if ass.status == #XRefScene then
		(
			for assxrf in ass.inst where (findItem tmpar assxrf.filename) == 0 do
			(
				if assxrf.filename == "" or assxrf.filename == undefined do
					continue
				status = GetStatusFile(assxrf.filename)
				if status == #Ok and not ch[1] do 
					continue
				if status == #Found and not ch[2] do 
					continue 
				if status == #Missing and not ch[3] do 
					continue 
				li = fill_table_aseets_li assxrf.filename status
				append theRange li
				append tmpar assxrf.filename
			)
		) else 
		(
			li = fill_table_aseets_li ass.filepath ass.status
			append theRange li
			append tmpar ass.filepath
		)
	)
	free tmpar
	return theRange
)

rollout logform "Log Collect Asset"
(
dotNetControl TextBox "System.Windows.Forms.RichTextBox" pos:[0,0] width:10 height:10

	on logform open do(
		TextBox.width = logform.width
		TextBox.height = logform.height
		TextBox.Visible = true
		TextBox.MultiLine = true
		TextBox.enabled = true
		TextBox.ReadOnly = true
		TextBox.WordWrap = false
		TextBox.ForeColor = (dotnetclass "System.Drawing.Color").FromArgb 20 20 20
		TextBox.BackColor = (dotnetclass "System.Drawing.Color").FromArgb 180 180 180
		TextBox.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
		logfile = openfile logfilepath mode:"r" encoding:#utf8
		if logfile != undefined then
		(
			while not eof logfile do
			(
				rline = readline logfile
				strings = filterString rline "|"
				printToLogWindow strings[2] strings[3]
			)
			close logfile
		)
		else 
		(
			logging "ERR" ("Can not open file " + logfilepath)
		)
	)
	
	on logform resized size do
	(
		TextBox.width = size[1]
		TextBox.height = size[2]
	)
)

local LA_w1 = 800
local LA_h1 = 500
local LA_sizeold = #()
LA_h_footer = 30

rollout textwindow "Text window" width:426 height:310
(
	editText edt1 "" pos:[1,2] width:421 height:303 enabled:true readOnly:true
)

rollout List_assets "List of assets"
(
	label lbl_all "all - 000" pos:[8,9] width:64 height:16
	checkbox chk_ok "ok - 000" pos:[80,8] width:72 height:17 checked:true
	checkbox chk_found "found - 000" pos:[160,8] width:88 height:17 checked:true
	checkbox chk_missing "missing - 000" pos:[256,8] width:96 height:17 checked:true
	button btn_export "Export to text" pos:[352,8] width:88 height:16
	dotNetControl table_aseets "System.Windows.Forms.ListView" pos:[3,28] width:(LA_w1-5) height:(LA_h1-LA_h_footer) align:#center
	
	on List_assets open do
	(
		table_aseets.gridLines = true
		table_aseets.View = (dotNetClass "System.Windows.Forms.View").Details
		table_aseets.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").None
		table_aseets.fullRowSelect = true
		table_aseets.multiSelect = true
		table_aseets.Columns.add "File name" 280
		table_aseets.Columns.add "File path" (LA_w1-370)
		table_aseets.Columns.add "Status" 60
		table_aseets.Items.AddRange (fill_table_aseets(#(chk_ok.checked,chk_found.checked,chk_missing.checked)))
		lbl_all.caption = "all - " + table_aseets.Items.count as string 
		chk_ok.caption = "ok - " + counts.okk as string
		chk_found.caption = "found - " + counts.found as string
		chk_missing.caption = "missing - " + counts.missing as string
	)
	
	on chk_ok changed state do
	(
		table_aseets.Items.clear()
		table_aseets.Items.AddRange (fill_table_aseets(#(chk_ok.checked,chk_found.checked,chk_missing.checked)))
	)
	on chk_found changed state do
	(
		table_aseets.Items.clear()
		table_aseets.Items.AddRange (fill_table_aseets(#(chk_ok.checked,chk_found.checked,chk_missing.checked)))
	)
	on chk_missing changed state do
	(
		table_aseets.Items.clear()
		table_aseets.Items.AddRange (fill_table_aseets(#(chk_ok.checked,chk_found.checked,chk_missing.checked)))
	)
	
	on List_assets resized size do
	(
		if List_assets.width <= 450 then List_assets.width = 450
		else (
			table_aseets.width = List_assets.width - 5
			newwidth = table_aseets.columns.item[1].width + size[1] - LA_sizeold[1]
			if newwidth > 30 do	table_aseets.columns.item[1].width = newwidth
		)
		table_aseets.height = List_assets.height - LA_h_footer
		LA_sizeold = size
		table_aseets.RedrawItems
	)
	
	on table_aseets columnClick columnHeader do 
	(
		table_aseets.ListViewItemSorter = dotnetobject "MXS_dotNet.ListViewItemComparer" columnHeader.column
		table_aseets.ListViewItemSorter = undefined
	)
	
	on btn_export pressed  do
	(
		try destroydialog textwindow catch ()
		createDialog textwindow
		--textwindow.edt1.text = ""
		for i=0 to table_aseets.Items.count-1 do
		(
			local li = table_aseets.Items.item[i]
			textwindow.edt1.text += li.subItems.item[1].text+ li.subItems.item[0].text +"\n"
		)
	)
)

fn cutstring inputstring cutlenght =
(
	if inputstring.count > cutlenght then
	(
		pos1 = cutlenght / 2 - 7
		lencut = inputstring.count - cutlenght
		replace inputstring pos1 lencut " ... "
	) else inputstring
)

--Match bitmaps with relink
rollout match_bmp "Match bitmaps" width:840 height:541
(
	bitmap bmp_1 "Bitmap" pos:[16,32] width:330 height:330
	bitmap bmp_2 "Bitmap" pos:[488,32] width:330 height:330
	label lbl_bmp1 ":" pos:[17,372] width:329 height:107
	label lbl_bmp2 ":" pos:[488,375] width:329 height:104
	label lbl3 "Bitmap Now Assigned" pos:[16,16] width:328 height:16
	label lbl4 "Exist Bitmap In New Path" pos:[488,16] width:328 height:16
	button btn_rplc ">> Replace >>" pos:[355,174] width:123 height:27
	button btn_exist "Use Exist Bitmap >>" pos:[355,217] width:123 height:27
	button btn_rnm "Rename" pos:[480,488] width:123 height:27
	edittext edt_new_name "New Name" pos:[16,494] width:456 height:16
	button btn_nothing "Do Nothing" pos:[696,488] width:123 height:27 toolTip:"leave the current path"
	checkbox chk_forall "Use This Action For All Files" pos:[13,519] width:188 height:14
	
	on match_bmp open do
	(
		loadTooltips rolloutt:"match_bmp"
		if (pic_1 == "") or (pic_2 == "") do 
		(
			logging "ERR" ("pic_1 or pic_2 is emty")
			mb_result[1] = 0
			DestroyDialog match_bmp
		)
		tmp_bmp2 = openBitMap pic_1
		tmp_path = getFilenamePath pic_1
		tmp_filename = filenameFromPath pic_1
		tmp_fulltath = pic_1
		if tmp_bmp2 != undefined then
		(
			tmp_bmp1 = bitmap (dim_x tmp_bmp2) (dim_y tmp_bmp2)
			copy tmp_bmp2 tmp_bmp1
			lbl_bmp1.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\ndimension: " + tmp_bmp2.width as string + "x" + tmp_bmp2.height as string + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			close tmp_bmp2
			bmp_1.bitmap = tmp_bmp1
		) else
		(
			lbl_bmp1.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			bmp_1.filename = (GLOBAL_INI_FILE_PATH+"nopicture.gif")
		)
		tmp_bmp2 = openBitMap pic_2
		tmp_path = getFilenamePath pic_2
		tmp_filename = filenameFromPath pic_2
		tmp_fulltath = pic_2
		if tmp_bmp2 != undefined then
		(
			tmp_bmp1 = bitmap (dim_x tmp_bmp2) (dim_y tmp_bmp2)
			copy tmp_bmp2 tmp_bmp1
			lbl_bmp2.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\ndimension: " + tmp_bmp2.width as string + "x" + tmp_bmp2.height as string + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			close tmp_bmp2
			bmp_2.bitmap = tmp_bmp1
			close tmp_bmp1
		) else
		(
			lbl_bmp2.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			bmp_2.filename = (GLOBAL_INI_FILE_PATH+"nopicture.gif")
		)
		edt_new_name.text = getFilenameFile pic_1 + random_name()
	)
	on match_bmp close do
	(
		if chk_forall.checked do mb_result[3] = true
		bmp_1.bitmap = bmp_2.bitmap = bitmap 1 1 color:gray
	)
	on btn_rplc pressed do
	(
		mb_result[1] = 2
		DestroyDialog match_bmp
	)
	on btn_exist pressed do
	(
		mb_result[1] = 1
		DestroyDialog match_bmp
	)
	on btn_rnm pressed do
	(
		mb_result[1] = 3
		mb_result[2] = getFilenamePath pic_2 + match_bmp.edt_new_name.text + getFilenameType pic_2
		DestroyDialog match_bmp
	)
	on btn_nothing pressed do
	(
		mb_result[1] = 0
		DestroyDialog match_bmp
	)
)

--Match bitmaps without relink
rollout match_bmp2 "Match bitmaps" width:840 height:548
(
	bitmap 'bmp_1' "Bitmap" pos:[14,69] width:330 height:330 align:#left
	bitmap 'bmp_2' "Bitmap" pos:[486,69] width:330 height:330 align:#left
	label 'lbl_bmp1' ":" pos:[15,409] width:329 height:107 align:#left
	label 'lbl_bmp2' ":" pos:[486,412] width:329 height:104 align:#left
	label 'lbl3' "Bitmap Now Assigned" pos:[14,53] width:328 height:16 align:#left
	label 'lbl4' "Exist Bitmap In New Path" pos:[486,53] width:328 height:16 align:#left
	button 'btn_rplc' ">> Replace >>" pos:[353,211] width:123 height:27 align:#left
	button 'btn_exist' "Nothing to do" pos:[353,254] width:123 height:27 align:#left
	checkbox 'chk_forall' "Use This Action For All Files" pos:[11,524] width:188 height:14 align:#left
	label 'lbl5' "WARNING! If you want use \"Rename\" function, please make operation with \"Relink\" checked option" pos:[15,10] width:800 height:34 align:#left
	
	on match_bmp2 open do
	(
		loadTooltips rolloutt:"match_bmp2"
		if (pic_1 == "") or (pic_2 == "") do 
		(
			logging "ERR" ("pic_1 or pic_2 is emty")
			mb_result[1] = 0
			DestroyDialog match_bmp2
		)
		tmp_bmp2 = openBitMap pic_1
		tmp_path = getFilenamePath pic_1
		tmp_filename = filenameFromPath pic_1
		tmp_fulltath = pic_1
		if tmp_bmp2 != undefined then
		(
			tmp_bmp1 = bitmap (dim_x tmp_bmp2) (dim_y tmp_bmp2)
			copy tmp_bmp2 tmp_bmp1
			lbl_bmp1.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\ndimension: " + tmp_bmp2.width as string + "x" + tmp_bmp2.height as string + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			close tmp_bmp2
			bmp_1.bitmap = tmp_bmp1
		) else
		(
			lbl_bmp1.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			bmp_1.filename = (GLOBAL_INI_FILE_PATH+"nopicture.gif")
		)
		tmp_bmp2 = openBitMap pic_2
		tmp_path = getFilenamePath pic_2
		tmp_filename = filenameFromPath pic_2
		tmp_fulltath = pic_2
		if tmp_bmp2 != undefined then
		(
			tmp_bmp1 = bitmap (dim_x tmp_bmp2) (dim_y tmp_bmp2)
			copy tmp_bmp2 tmp_bmp1
			lbl_bmp2.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\ndimension: " + tmp_bmp2.width as string + "x" + tmp_bmp2.height as string + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			close tmp_bmp2
			bmp_2.bitmap = tmp_bmp1
		) else
		(
			lbl_bmp2.caption = "Filename: " + tmp_filename +"\nPath: " + cutstring tmp_path 45 + "\nfile size: " + getFileSize(tmp_fulltath) as string + "\nfile date: " + getFileModDate(tmp_fulltath)
			bmp_2.filename = (GLOBAL_INI_FILE_PATH+"nopicture.gif")
		)
		mb_result[1] = 1
	)
	on match_bmp2 close do
	(
		if chk_forall.checked do mb_result[3] = true
		bmp_1.bitmap = bmp_2.bitmap = bitmap 1 1 color:gray
	)
	on btn_rplc pressed do
	(
		mb_result[1] = 2
		DestroyDialog match_bmp2
	)
	on btn_exist pressed do
	(
		mb_result[1] = 1
		DestroyDialog match_bmp2
	)
)

fn setpath newPath =
(
		i = 0
		for ass in fndassets where (ass.status == #Found or ass.status == #Ok or ass.status == #Missing) while not exitt do 
		(
			if Collect_asset.chk_exxref.checked and (ass.type == "xref") do continue
			newfullpath = newPath + filenameFromPath ass.filepath
			relinkfile ass.inst ass.propName newfullpath
			i+=1
			prgrbar i (counts.okk + counts.found + counts.missing) ("Set Path : "+(filenameFromPath ass.filepath))
			if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
		)
		if (not Collect_asset.chk_exxref.checked) do
		(
			statusrfr simple:true
			for ass in fndassets where ass.status == #XRefScene while not exitt do
			(
				upd = false
				for assxrf in ass.inst do
				(
					newfullpath = newPath + filenameFromPath assxrf.filename
					if (toLower newfullpath) != (toLower assxrf.filename) do
					(
						assxrf.filename = newfullpath
						upd = true
					)
					i+=1
					prgrbar i (counts.okk + counts.found + counts.missing) ("Set Path : "+(filenameFromPath assxrf.filename))
					if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
				)
				if upd do setMAXFileAssetMetadata ass.foundpath ass.inst
			)
			xrefupdate()
		)
		statusrfr simple:true
		prgrbar 0 0 "End Set Path"
)

rollout settings "Settings" width:152 height:184
(
	checkbox 'chk_ifl_fullpath' "full paths in IFL files" pos:[13,9] width:121 height:17 align:#left
	button 'btn_ok' "Ok" pos:[8,144] width:60 height:20 align:#left
	button 'btn_cancel' "Cancel" pos:[80,144] width:60 height:20 align:#left
	dropdownList 'ddl_dirSelect' "Directory selector window" pos:[13,35] width:124 height:40 items:#("standart", "alternative") selection:2 align:#left
	dropdownList 'ddl_Language' "ToolTips Language" pos:[13,86] width:124 height:40 items:#("English", "Russian") selection:1 align:#left
	on settings open do
	(
		chk_ifl_fullpath.checked = G_IFL_FULLPATH
		ddl_dirSelect.selection = G_DIRSELECT
		ddl_Language.selection = G_Tooltip_Lang
	)
	on btn_ok pressed do
	(
		G_IFL_FULLPATH = chk_ifl_fullpath.checked
		writeVarToSettingsIniFile "settings" "IFL_FULLPATH" G_IFL_FULLPATH
		G_DIRSELECT = ddl_dirSelect.selection
		writeVarToSettingsIniFile "settings" "G_DIRSELECT" G_DIRSELECT
		G_Tooltip_Lang = ddl_Language.selection
		writeVarToSettingsIniFile "settings" "G_Tooltip_Lang" G_Tooltip_Lang
		loadtooltips ()
		DestroyDialog settings
	)
	on btn_cancel pressed do
		DestroyDialog settings
)

rollout Collect_asset title width:416 height:592
(
	dotNetControl 'headlink1' "linklabel" pos:[284,23] width:140 height:20 align:#left
	dotNetControl 'headimg' "PictureBox" pos:[0,0] width:420 height:59 align:#left
	
	GroupBox 'grp1' "Assets Status" pos:[14,68] width:392 height:44 align:#left
	label 'status' ":" pos:[24,88] width:200 height:16 align:#left
	button 'btn_stat_refr' "Refresh" pos:[273,84] width:52 height:20 align:#left
	button 'btn_ATopen' "List Assets" pos:[333,84] width:65 height:20 align:#left
	
	GroupBox 'grp2' "Missing Assets" pos:[14,120] width:392 height:103 align:#left
	label 'lbl19' "Path to search missing textures" pos:[24,140] width:170 height:16 align:#left
	edittext 'path_seek' "" pos:[18,158] width:350 align:#left
	button 'btn_path_seek' "..." pos:[374,158] width:24 height:20 align:#left
	checkbox 'chk_inclSubfolders' "Include subfolders" pos:[112,192] width:114 height:15 align:#left
	button 'btn_seek' "SEARCH" pos:[22,185] width:80 height:30 align:#left
	
	GroupBox 'grp5' "Collect Assets" pos:[14,232] width:392 height:192 align:#left
	label 'dir_lbl' "Selected Directory" pos:[24,252] width:145 height:16 align:#left
	edittext 'dir_edt' "" pos:[18,271] width:350 align:#left
	button 'open_btn' "..." pos:[374,271] width:24 height:20 align:#left
	edittext 'edit_subdir' "sub Directory" pos:[152,296] width:216 align:#left
	checkbox 'chk_rlnk' "and relink to selected directory" pos:[23,323] width:170 height:15 checked:true align:#left
	checkbox 'chk_sel' "only from selected objects" pos:[23,341] width:148 height:15 align:#left
	checkbox 'chk_maxfile' "copy .max file" pos:[23,359] width:92 height:15 align:#left
	checkbox 'chk_exxref' "exclude xref" pos:[230,323] width:91 height:18 enabled:true checked:false align:#left
	button 'btn_collect' "COLLECT" pos:[24,384] width:80 height:30 toolTip:"collect all to folder" align:#left
	button 'btn_setPath' "Set path" pos:[112,384] width:80 height:30 toolTip:"Set paths for all assets to selected directory" align:#left
	button 'btn_rnm_russian' "Rename RU" pos:[200,384] width:80 height:30 align:#left
	
	GroupBox 'grp6' "Archive Scene" pos:[14,432] width:392 height:50 align:#left
	button 'btn_archive' "Make archive" pos:[22,452] width:80 height:20 align:#left
	checkbox 'arch_chk_sel' "only selected objects" pos:[112,454] width:124 height:15 align:#left
	
	GroupBox 'grp7' "Utilites" pos:[14,491] width:392 height:50 align:#left
	button 'resolve' "Resolve paths" pos:[24,510] width:80 height:20 align:#left
	button 'btn_del_re_paths' "Del RE paths" pos:[312,510] width:80 height:20 align:#left
	button 'btn_delmissing' "Del missing" pos:[120,510] width:80 height:20 align:#left
	button 'btn_strippath' "Strip paths" pos:[216,510] width:80 height:20 align:#left
	
	label 'progress_status' "dgdfg" pos:[15,567] width:260 height:17 align:#left
	button 'btn_settings' "Settings" pos:[279,564] width:60 height:20 align:#left
	progressBar 'pb1' "ProgressBar" pos:[14,549] width:392 height:8 align:#left
	button 'btn_log' "Log" pos:[346,564] width:60 height:20 align:#left

	on Collect_asset open do
	(
		logging "START" ("Starting script in: "+maxFilePath+maxFileName)
		local ImageClass = dotnetclass "system.drawing.image"
		local ColorClass =dotnetclass "system.drawing.color"
		local Align = dotnetclass "System.Drawing.ContentAlignment"
		local CursorsClass = dotnetclass "System.Windows.Forms.Cursors"
		local LinkBehavior = dotnetclass "System.Windows.Forms.LinkBehavior"
		try (headimg.image = ImageClass.FromFile (GLOBAL_INI_FILE_PATH+"head.gif")) catch
			(logging "ERR" ("Can not read " + (GLOBAL_INI_FILE_PATH+"head.png") as string)
				headimg.width=0
				headimg.height=0
			)
		headlink1.LinkColor = ColorClass.FromArgb 116 200 110
		headlink1.VisitedLinkColor = ColorClass.FromArgb 116 200 110
		headlink1.ActiveLinkColor = ColorClass.FromArgb 101 167 96
		headlink1.ForeColor = ColorClass.FromArgb 116 200 110
		headlink1.BackColor = ColorClass.FromArgb 56 56 56
		headlink1.font = dotNetObject "System.Drawing.Font" "Tahoma" 8.25
		headlink1.LinkBehavior  = LinkBehavior.NeverUnderline
		headlink1.Text = "Updates     Render Farm"
		headlink1.links.add 0 8 "http://www.scriptspot.com/3ds-max/scripts/collect-asset"
		headlink1.links.add 10 23 "http://xiruim-farm.net"
	
		--loading tooltips for buttons
		loadTooltips()
			
		--link01.Cursor = CursorsClass.Hand
		enableCtrl false
		Collect_asset.dir_edt.text = chk_path maxFilePath
		Collect_asset.path_seek.text = ""
		try edit_subdir.text = loadVarFromSettingsIniFile "settings" "subdir" catch()
		edit_subdir.text = chk_path edit_subdir.text
		G_CollectPath = Collect_asset.dir_edt.text + edit_subdir.text
		statusrfr()
		enableCtrl true
	)
	on Collect_asset close do
	(
		exitt = true
		try (headimg.image.Dispose()) catch()
		free fndassets
		try (destroyDialog ::match_bmp) catch()
		try (destroyDialog ::List_assets) catch()
		try (destroyDialog ::logform) catch()
		writeVarToSettingsIniFile "settings" "dialogPos" (getDialogPos Collect_asset)
		writeVarToSettingsIniFile "settings" "subdir" (edit_subdir.text)
	)
	on headlink1 LinkClicked s e do
	(
		s.links.item[s.links.IndexOf e.link].Visited = on
		(dotnetclass "System.Diagnostics.Process").Start e.link.LinkData 
	)
	on btn_stat_refr pressed do
	(
		statusrfr()
	)
	on btn_ATopen pressed do
	(
		createDialog List_assets  width:LA_w1 height:LA_h1 style:#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu) lockHeight:false lockWidth:false
		LA_sizeold = #(List_assets.width, List_assets.height)
	)
	on path_seek entered txt do
		path_seek.text = chk_path path_seek.text
	on btn_path_seek pressed do
	(
		if G_DIRSELECT == 1 do
		(
			s = getSavePath caption:"Select Dir" initialDir:Collect_asset.path_seek.text
			if s != undefined then path_seek.text = chk_path s
		)
		if G_DIRSELECT == 2 do
		(
			theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
			theDialog.ValidateNames = false
			theDialog.CheckFileExists = false
			theDialog.CheckPathExists  = false
			theDialog.AddExtension = false
			theDialog.Multiselect = false
			theDialog.title = "Select Folder"
			theDialog.InitialDirectory = path_seek.text
			theDialog.FileName = "select_folder"
			theDialog.Filter = "select folder|select_folder.select_folder"
			result = theDialog.showDialog()
			result.ToString()
			if result.ToString() == "OK" do
				path_seek.text = chk_path (getFilenamePath theDialog.FileName)
		)
	)
	on btn_seek pressed do
	(
		if pathConfig.isLegalPath path_seek.text do
			seek_files path_seek.text chk_inclSubfolders.checked
	)
	
	on dir_edt entered txt do
	(
		dir_edt.text = chk_path txt
		G_CollectPath = dir_edt.text + edit_subdir.text
	)
	
	on edit_subdir entered txt do
	(
		edit_subdir.text = chk_path txt
		G_CollectPath = dir_edt.text + edit_subdir.text
	)
	
	on open_btn pressed do
	(
		if G_DIRSELECT == 1 do
		(
			s = getSavePath caption:"Select Dir" initialDir:Collect_asset.dir_edt.text
			if s != undefined then dir_edt.text = chk_path s
		)
		if G_DIRSELECT == 2 do
		(
			theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
			theDialog.ValidateNames = false
			theDialog.CheckFileExists = false
			theDialog.CheckPathExists  = false
			theDialog.AddExtension = false
			theDialog.Multiselect = false
			theDialog.title = "Select Folder"
			theDialog.InitialDirectory = Collect_asset.dir_edt.text
			theDialog.FileName = "select_folder"
			theDialog.Filter = "select folder|select_folder.select_folder"
			result = theDialog.showDialog()
			result.ToString()
			if result.ToString() == "OK" do
				dir_edt.text = chk_path (getFilenamePath theDialog.FileName)
		)
		G_CollectPath = dir_edt.text + edit_subdir.text
	)
	on btn_collect pressed do
	(
		exitt = false
		enableCtrl false
		local tmp = tmp2 = #(0,0)
		local copied = errors = 0
		if chDir(G_CollectPath) do
		(
			tmp = collect_as G_CollectPath chk_sel.checked chk_rlnk.checked
			if (counts.xref > 0) and (not chk_sel.checked) and (not chk_exxref.checked) do
			(
				statusrfr simple:true
				tmp2 = collect_as_xref G_CollectPath chk_rlnk.checked
			)
			if chk_maxfile.checked do
			(
				if chk_sel.checked do
				(
					filename = getSaveFileName caption:"save selected objects" types:"Max Files (*.max)|*.max|" filename:G_CollectPath
					if filename != undefined do 
					(
						saveNodes selection filename
						copied += 1
					)
				)
				if not chk_sel.checked do
				(
					filename = G_CollectPath + maxFileName
					if chk_rlnk.checked then
						if saveMaxFile filename useNewFile:true then
							copied += 1
						else
							errors += 1
					else
						if saveMaxFile filename useNewFile:false then
							copied += 1
						else
							errors += 1
				)
			)
			copied += tmp[1]+tmp2[1]
			errors += tmp[2]+tmp2[2]
			messagebox ("Copied "+copied as string + " files. Errors " + errors as string)
			statusrfr simple:true
		)
		enableCtrl true
		if chk_rlnk.checked do setSaveRequired true
	)
	on btn_setPath pressed do
	(
		exitt = false
		enableCtrl false
		setpath G_CollectPath
		enableCtrl true
		setSaveRequired true
	)
	on btn_rnm_russian pressed do
	(
		logging "INF" ("Start Rename Russian symbols")
		local f = k = i = 0
		exitt = false
		enableCtrl false
		if chDir(G_CollectPath) then (
				russ = ""
				if  (temp_state = loadVarFromIniFile "symbols" "russ") != undefined then
				(
					russ = temp_state as string
				)
				else
				(
					messagebox ("Error load variable russ")
					return()
				)
				enn = ""
				if  (temp_state = loadVarFromIniFile "symbols" "enn") != undefined then
				(
					enn = temp_state as string
				)
				else
				(
					messagebox ("Error load variable enn")
					return()
				)
				newPath = G_CollectPath
				ennsmb = filterString enn ","
				russsmb = filterString russ ","
				saver = false
				for ass in fndassets do
				(
					if Collect_asset.chk_exxref.checked and (ass.type == "xref") do continue
					namefile = getFilenameFile ass.filepath
					rusfnd = false
					rename = ""
					fnd = 0
					if  (ass.status == #ok) or (ass.status == #found) do 
					(
						for j = 1 to namefile.count do (
							fnd = findItem russsmb namefile[j]
							if fnd > 0 then (
								append rename ennsmb[fnd]
								rusfnd = true
							)
							else append rename namefile[j]
						)
					)
					if rusfnd do
					(
						saver = true
						newfullpath = undefined
						newfullpath = newPath + rename + getFilenameType ass.filepath
						oldfullpath = ass.foundpath
						if newfullpath != undefined do 
						(
							if isIdenticalFiles oldfullpath newfullpath then
							(
								logging "INF" ("Relink file: "+oldfullpath+" to: "+newfullpath)
								relinkfile ass.inst ass.propName newfullpath
							)
							else
							(
								while doesFileExist(newfullpath) do 
									newfullpath = getFilenamePath (newfullpath) + getFilenameFile (newfullpath) + "1" + getFilenameType (newfullpath)
								if (copyFile oldfullpath newfullpath) then
								(
									logging "INF" ("Relink file: "+oldfullpath+" to: "+newfullpath)
									relinkfile ass.inst ass.propName newfullpath
									k = k+1
									--print newfullpath
								) else f = f+1
							)
						)
					)
					i+=1
					if newfullpath != undefined then 
						prgrbar i (counts.okk+counts.found) ("Rename Russian : "+(getFilenameFile (newfullpath)))
					else
						prgrbar i (counts.okk+counts.found) ("Rename Russian : ...")
					if  (keyboard.EscPressed) and (queryBox "you want to abort operation?") then return ()
				)
				prgrbar 0 0 "End Rename Russian symbols"
				messagebox ("Copied "+k as string + " files. Errors " + f as string)
			)
		statusrfr simple:true
		enableCtrl true
		if saver do setSaveRequired true
		logging "INF" ("End Rename Russian symbols")
	)
	on btn_archive pressed do
	(
		exitt = false
		if arch_chk_sel.checked and selection.count == 0 then (
			messagebox "nothing is selected" title:"Error"
			return()
		)
		enableCtrl false
		local err = false
		tmp = tmp2 = #(0,0)
		TEMP_DIR = sysInfo.tempdir + "collect_asset_tmp\\"
		ASSETS_DIR = TEMP_DIR+"maps\\"
		if not (create_Dir TEMP_DIR) then err = true
		if not (create_Dir ASSETS_DIR) then err = true
		if maxFileName != "" then scenename = maxFileName else scenename = "scene.max"
		tmp = collect_as ASSETS_DIR arch_chk_sel.checked false
		if (counts.xref > 0) and (not arch_chk_sel.checked) do
				tmp2 = collect_as_xref ASSETS_DIR false
		if exitt do err = true
		if tmp[2] != 0 or tmp2[2] != 0 then err = true
		if arch_chk_sel.checked then (
			scenename = getSaveFileName caption:"Enter name of max file" \
			filename:(maxFilePath) \
			types:"3ds max (*.max)|*.max"
			if scenename != undefined then (
				scenename = filenameFromPath scenename
				if (saveNodes selection (TEMP_DIR+scenename)) == false then err = true
			) else ( messagebox "Operation Aborted" title:"Error"; err = true)
		) else if (saveMaxFile (TEMP_DIR+scenename) clearNeedSaveFlag:false useNewFile:false) == false then err = true
		if err do logging "ERR" ("Abort prepare to archive")
		if not err then (
			archive_file = getSaveFileName caption:"Select name of archive" \
			filename:(maxFilePath + (getFilenameFile scenename)) \
			types:"7-zip (*.7z)|*.7z|Zip (*.zip)|*.zip"
			if archive_file != undefined then (
				if (doesFileExist archive_file) == true then deleteFile archive_file
				if getFilenameType(archive_file) == ".7z" do HiddenDOSCommand ("7zG.exe a \""+archive_file+"\" -r \""+TEMP_DIR+"*\" -m0=LZMA2 -ssw") startpath:GLOBAL_7Z_PATH
				if getFilenameType(archive_file) == ".zip" do HiddenDOSCommand ("7zG.exe a \""+archive_file+"\" -r \""+TEMP_DIR+"*\" -ssw") startpath:GLOBAL_7Z_PATH
			) else messagebox "Operation Aborted" title:"Error"
		) else messagebox "Error save to Temp folder" title:"Error"
		HiddenDOSCommand ("rmdir /S /Q "+TEMP_DIR)
		if not err then messagebox "Creating an archive completed" title:"Completed"
		enableCtrl true
	)
	on resolve pressed do
	(
		exitt = false
		enableCtrl false
		ResolvePaths ()
		statusrfr simple:true
		enableCtrl true
		setSaveRequired true
	)
	on btn_del_re_paths pressed do
	(
		re = maxOps.GetCurRenderElementMgr()
		recount = re.numrenderelements()
		for n=0 to recount-1 do
		(
			re.SetRenderElementFilename n ""
		)
	)
	on btn_delmissing pressed do
	(
		exitt = false
		enableCtrl false
		if queryBox "Are you sure you want to delete missing paths?" do DelMissing()
		statusrfr()
		enableCtrl true
		setSaveRequired true
	)
	on btn_strippath pressed do
	(
		exitt = false
		enableCtrl false
		setpath ""		
		enableCtrl true
		setSaveRequired true
	)
	on btn_settings pressed do
	(
		createDialog settings modal:true
	)
	on btn_log pressed do
	(
		createDialog logform width:500 height:300 style:#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu, #style_minimizebox, #style_maximizebox) lockHeight:false lockWidth:false
	)
)
Collect_assetOpenUI()
)

