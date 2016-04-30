#
#
$source = '\\berilia\f$'
$dstvol = 'F'
$dstname = 'Raid DS2'
$folders = @('Admin','Anwend','Archiv','Daten_1','Datenaustausch','Forschung','Industrie','Profile','ProfilOrdner','User','WT')
$logpath = "${dstvol}:\logs"

#Abbruch wenn das Volume nicht existiert 
if(-not (Test-Path -Path "${dstvol}:\")) {
	Exit
}
#Abbruch wenn das Volume nicht das richtige ist
if(-not (Get-Volume -FileSystemLabel $dstname ).DriveLetter -eq $dstvol) {
	Exit
}
#Abbruch wenn die Quelle nicht erreichbar ist
if(-not (Test-Path -Path $source)) {
	Exit
}

#Log Verzeichnis erstellen
New-Item -ItemType Directory -Force -Path $logpath | Out-Null

#Robocopy starten...
ForEach ($dir in $folders) {
	$srcpath = "${source}\$dir"
	$dstpath = "${dstvol}:\$dir"
	$options = "/e /b /copyall /r:2 /w:2 /xd DfsrPrivate /DCOPY:T /XJ /MT:64 /MIR /NC /NFL /NS /NDL /NP"
	$log = "-LOG:${logpath}\"+(Get-Date -Format "yyyy_mm_dd_hh-mm")+"_${dir}.log"
	
	"Copy $srcpath --> $dstpath..."
	Invoke-Expression "robocopy $srcpath $dstpath $options $log"
}

#Schattenkopie anlegen
"Schattenkopie auf Zielvolume ${dstvol}:\ ($dstname) erstellen"
(gwmi -list win32_ShadowCopy).Create("${dstvol}:\",'ClientAccessible')
