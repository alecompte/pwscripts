$basedir = ""
$files = Get-ChildItem -Recurse -Filter *.wav
$files | ForEach-Object -Parallel{
    
    $dir = $_.Directory.Name
    md ($basedir + "/" + $dir)

    $FileBaseName = $_.BaseName

    $FullNewPath = "$basedir/$dir/$FileBaseName.mp3"

    ffmpeg -y -i $_.FullName -vn -ar 44100 -b:a 16k $FullNewPath

} -ThrottleLimit 12

$DirCreated = @()

$Files | ForEach-Object -Parallel {
   $Dir = $_.Directory[0].Name
   Add-PnPFolder -Folder "Documents" -Name $Dir -ErrorAction SilentlyContinue


   Add-PnPFile -Path $_.FullName -Folder "Documents/$Dir" -NewFileName $_.Name.Replace("%3A", "").Replace("%2F", "").Replace("%", "")

} -ThrottleLimit 10
