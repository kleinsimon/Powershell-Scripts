#
#
$dstdir = '\\hyperv-2012r2\d$'
$srcvol = 'G'
$srcname = 'Daten'
$folders = @('Admin','Anwend','Archiv','Daten_1','Datenaustausch','Forschung','Industrie','Profile','ProfilOrdner','User','WT')
$logpath = "${dstdir}\logs"
$tmplink = "${srcvol}:\sctmp"

#Abbruch wenn das Volume nicht existiert 
if(-not (Test-Path -Path "${dstdir}")) {
	Exit
}
#Abbruch wenn das Volume nicht das richtige ist
if(-not (Get-Volume -FileSystemLabel $srcname ).DriveLetter -eq $srcvol) {
	Exit
}
#Abbruch wenn die Quelle nicht erreichbar ist
if(-not (Test-Path -Path "${srcvol}:\")) {
	Exit
}

#Log Verzeichnis erstellen
#New-Item -ItemType Directory -Force -Path $logpath | Out-Null

#Schattenkopie anlegen
"Schattenkopie auf Quell-Volumen ${srcvol}:\ ($srcname) erstellen"
$res = (gwmi -list win32_ShadowCopy).Create("${srcvol}:\", "ClientAccessible")
$sc = gwmi Win32_ShadowCopy | ? {$_.ID -eq $res.ShadowID}
$snapdir = $sc.DeviceObject + "\"
cmd /c mklink /d "$tmplink" "$snapdir"

#Robocopy starten...
ForEach ($dir in $folders) {
	$srcpath = "${tmplink}\$dir"
	$dstpath = "${dstdir}\$dir"
	$options = "/e /b /copyall /r:2 /w:2 /xd DfsrPrivate /DCOPY:T /XJ /MT:64 /MIR /NC /NFL /NS /NDL /NP"
	$log = "-LOG:${logpath}\"+(Get-Date -Format "yyyy_mm_dd_hh-mm")+"_${dir}.log"
	
	"Copy $srcpath --> $dstpath..."
	#Invoke-Expression "robocopy $srcpath $dstpath $options $log"
}

cmd /c rmdir "$tmplink"
$sc.Delete()