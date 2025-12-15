# ===================== BANNER =====================
$banner = @"
  ___     ____   ___ ___ ___   ___ _         _         
 | _ \_  |__  | | _ \_ _|_ _| | __(_)_ _  __| |___ _ _ 
 |   / || |/ /  |  _/| | | |  | _|| | ' \/ _` / -_) '_|
 |_|_\\_,_/_/   |_| |___|___| |_| |_|_||_\__,_\___|_|  
"@

$colors = @("Cyan","Green","Yellow","Magenta","White")
$i = 0
$banner -split "`n" | ForEach-Object {
    Write-Host $_ -ForegroundColor $colors[$i % $colors.Count]
    $i++
}

Write-Host "`nPII Scanner Initializing..." -ForegroundColor Green
Write-Host "--------------------------------------------`n" -ForegroundColor DarkGray
# =================================================

# ===================== Code Starts here (Compatible with PS5) =====================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ---------- Tokenization ----------
$Tokenize = (Read-Host "Tokenize PII values? (Y/N)").ToUpper() -eq 'Y'
function Mask-PII($s) {
    if (-not $Tokenize -or $s.Length -lt 6) { return $s }
    $m = [Math]::Floor($s.Length * 0.2)
    $p = [Math]::Floor(($s.Length - $m) / 2)
    return $s.Substring(0,$p) + ('*' * $m) + $s.Substring($p + $m)
}

# ---------- Folder ----------
try {
    $fb = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne 'OK') { throw }
    $Root = $fb.SelectedPath
} catch {
    $Root = Read-Host "Enter folder path"
}

# ---------- CSV ----------
try {
    $sd = New-Object System.Windows.Forms.SaveFileDialog
    $sd.Filter = "CSV (*.csv)|*.csv"
    if ($sd.ShowDialog() -ne 'OK') { throw }
    $CsvPath = $sd.FileName
} catch {
    $CsvPath = Read-Host "Enter CSV path"
}

"FilePath,PII_Type,PII_Value,Created,Modified,Owner,ScanSeconds,Error" |
    Out-File $CsvPath -Encoding UTF8

# ---------- Regex (primary) ----------
$reEmail   = '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b'
$rePhone   = '(?<!\d)(?:\+91[\s-]?)?[6-9]\d{9}(?!\d)'
$rePAN     = '\b[A-Z]{5}\d{4}[A-Z]\b'
$reAadhaar = '(?<!\d)[2-9]\d{11}(?!\d)'

# ---------- Regex (normalized / spaced) ----------
$rePAN_N   = '\b[A-Z]{5}\s*\d{4}\s*[A-Z]\b'
$reAad_N   = '\b[2-9]\d{3}\s*\d{4}\s*\d{4}\b'

# ---------- Verhoeff ----------
$D = @(
 @(0,1,2,3,4,5,6,7,8,9),@(1,2,3,4,0,6,7,8,9,5),
 @(2,3,4,0,1,7,8,9,5,6),@(3,4,0,1,2,8,9,5,6,7),
 @(4,0,1,2,3,9,5,6,7,8),@(5,9,8,7,6,0,4,3,2,1),
 @(6,5,9,8,7,1,0,4,3,2),@(7,6,5,9,8,2,1,0,4,3),
 @(8,7,6,5,9,3,2,1,0,4),@(9,8,7,6,5,4,3,2,1,0)
)
$P = @(
 @(0,1,2,3,4,5,6,7,8,9),@(1,5,7,6,2,8,3,0,9,4),
 @(5,8,0,3,7,9,6,1,4,2),@(8,9,1,6,0,4,3,5,2,7),
 @(9,4,5,3,1,2,6,8,7,0),@(4,2,8,6,5,7,3,9,0,1),
 @(2,7,9,3,8,0,6,4,1,5),@(7,0,4,6,9,1,3,2,5,8)
)
function Test-Aadhaar($n) {
    $n = $n -replace '\D',''
    if ($n.Length -ne 12) { return $false }
    $c = 0; $a = $n.ToCharArray(); [array]::Reverse($a)
    for ($i=0;$i -lt $a.Length;$i++) {
        $c = $D[$c][$P[$i % 8][([int]$a[$i]-48)]]
    }
    return $c -eq 0
}

# ---------- Files ----------
$Files = Get-ChildItem $Root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Extension -match '\.(txt|csv|xml|json|docx|xlsx|pptx)$' -and
        -not $_.Name.StartsWith('~$')
    }

$Total = $Files.Count
$AllSW = [Diagnostics.Stopwatch]::StartNew()
$i = 0

foreach ($f in $Files) {
    $i++
    $FileSW = [Diagnostics.Stopwatch]::StartNew()
    $eta = if ($i -gt 1) {
        [TimeSpan]::FromSeconds(($AllSW.Elapsed.TotalSeconds/($i-1))*($Total-$i))
    } else { "Calculating..." }

    Write-Progress -Activity "Scanning ($i/$Total)" `
        -Status "ETA: $eta | $($f.FullName)" `
        -PercentComplete ($i*100/$Total)

    $created=$f.CreationTime; $modified=$f.LastWriteTime
    try{$owner=(Get-Acl $f.FullName).Owner}catch{$owner="Unknown"}

    try {
        $text=""
        if ($f.Extension -in '.docx','.xlsx','.pptx') {
            $zip=[IO.Compression.ZipFile]::OpenRead($f.FullName)
            foreach($e in $zip.Entries){
                if($e.FullName -like "*.xml"){
                    $sr=New-Object IO.StreamReader($e.Open())
                    $text+=$sr.ReadToEnd()+" "
                    $sr.Close()
                }
            }
            $zip.Dispose()
        } else {
            $text = Get-Content $f.FullName -Raw
        }

        $norm = ($text.ToUpper() -replace '[^A-Z0-9]',' ')

        foreach ($m in [regex]::Matches($text,$reEmail,'IgnoreCase')) {
            "$($f.FullName),Email,$(Mask-PII $m.Value),$created,$modified,$owner,$($FileSW.Elapsed.TotalSeconds)," |
                Add-Content $CsvPath
        }
        foreach ($m in [regex]::Matches($norm,$rePAN_N)) {
            "$($f.FullName),PAN,$(Mask-PII ($m.Value -replace '\s','')),$created,$modified,$owner,$($FileSW.Elapsed.TotalSeconds)," |
                Add-Content $CsvPath
        }
        foreach ($m in [regex]::Matches($norm,$reAad_N)) {
            if (Test-Aadhaar $m.Value) {
                "$($f.FullName),Aadhaar,$(Mask-PII ($m.Value -replace '\s','')),$created,$modified,$owner,$($FileSW.Elapsed.TotalSeconds)," |
                    Add-Content $CsvPath
            }
        }

    } catch {
        "$($f.FullName),,,,,,$($FileSW.Elapsed.TotalSeconds),$($_.Exception.Message)" |
            Add-Content $CsvPath
    }
}

Write-Host "`nScan complete → $CsvPath" -ForegroundColor Green
