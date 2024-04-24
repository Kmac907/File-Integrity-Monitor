Function Calculate-File-Hash($filepath) {
    try {
        $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
        return $filehash
    } catch {
        Write-Host "Error calculating hash for ${filepath}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Function Erase-Baseline-If-Already-Exists(){
    try {
        $baselineExists = Test-Path -Path .\baseline.txt

        if ($baselineExists) {
            Remove-Item -Path .\baseline.txt
        }
    } catch {
        Write-Host "Failed to erase baseline: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Function Initialize-LogFile {
    try {
        $logFilePath = ".\monitoring_log.txt"
        if (-not (Test-Path $logFilePath)) {
            New-Item -Path $logFilePath -ItemType File | Out-Null
        }
        return $logFilePath
    } catch {
        Write-Host "Failed to initialize log file: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "    A) Collect new Baseline?"
Write-Host "    B) Begin monitoring files with saved Baseline"
Write-Host ""
$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

if ($response -eq "A".ToUpper()) {
    Erase-Baseline-If-Already-Exists

    try {
        $files = Get-ChildItem -Path .\Files

        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName
            if ($hash) {
                "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
            }
        }
        Write-Host "Baseline Collected"
        Write-Host ""
    } catch {
        Write-Host "Failed to collect baseline: $($_.Exception.Message)" -ForegroundColor Red
    }
} elseif ($response -eq "B".ToUpper()) {
    $logFilePath = Initialize-LogFile

    $fileHashDictionary = @{}

    try {
        $filePathsAndHashes = Get-Content -Path .\baseline.txt

        foreach ($f in $filePathsAndHashes) {
            $file, $hash = $f -split '\|'
            $fileHashDictionary[$file] = $hash
        }
    } catch {
        Write-Host "Failed to load baseline: $($_.Exception.Message)" -ForegroundColor Red
    }

    while ($true) {
        Start-Sleep -Seconds 1

        try {
            $currentFiles = Get-ChildItem -Path .\Files | Select-Object -ExpandProperty FullName

            # Check for new files
            $newFiles = $currentFiles | Where-Object { -not $fileHashDictionary.ContainsKey($_) }
            foreach ($newFile in $newFiles) {
                $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $($newFile) has been created!"
                Write-Host $logMessage -ForegroundColor Green
                $logMessage | Out-File -FilePath $logFilePath -Append
                $hash = Calculate-File-Hash $newFile
                $fileHashDictionary[$newFile] = $hash.Hash
            }

            # Check for deleted files
            $deletedFiles = $fileHashDictionary.Keys | Where-Object { -not $currentFiles.Contains($_) }
            foreach ($deletedFile in $deletedFiles) {
                $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $($deletedFile) has been deleted!"
                Write-Host $logMessage -ForegroundColor Red
                $logMessage | Out-File -FilePath $logFilePath -Append
                $fileHashDictionary.Remove($deletedFile)
            }

            # Check for changes in existing files
            foreach ($file in $currentFiles) {
                $hash = Calculate-File-Hash $file
                if ($hash) {
                    $currentHash = $hash.Hash
                    $previousHash = $fileHashDictionary[$file]

                    if ($currentHash -ne $previousHash) {
                        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $($file) has changed!!!"
                        Write-Host $logMessage -ForegroundColor Yellow
                        $logMessage | Out-File -FilePath $logFilePath -Append
                        $fileHashDictionary[$file] = $currentHash
                    }
                } else {
                    Write-Host "Error calculating hash for $($file)" -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "Error monitoring files: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
