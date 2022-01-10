$ScanHttpServerFolder = "C:\ScanHttpServer\build"
$ExePath = "$ScanHttpServerFolder\ScanHttpServer.exe"

Start-Transcript -Path runLoopStartup.log

Write-Host Starting Process $ExePath
while($true){
    $process = Start-Process $ExePath -PassThru -Wait

    if($process.ExitCode -ne 0){
        Write-Host Process Exited with errors, please check the logs in $ScanHttpServerFolder\log
    }
    else {
        Write-Host Proccess Exited with no errors
    }

    Write-Host Restarting Process $ExePath
}

Stop-Transcript
