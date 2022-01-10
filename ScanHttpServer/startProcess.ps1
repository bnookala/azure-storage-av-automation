$ScanHttpServerFolder = "C:\ScanHttpServer"
$ExePath = "$ScanHttpServerFolder\ScanHttpServer.dll"

Start-Transcript -Path runLoopStartup.log

Write-Host Install .net 5 sdk + runtime
if (-Not (Test-Path $ScanHttpServerFolder\dotnet-install.ps1)){
    Write-Host dotnet-install script doesnt exist, Downloading
    Invoke-WebRequest "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1" -OutFile $ScanHttpServerFolder\dotnet-install.ps1
}

cd $ScanHttpServerFolder
Write-Host Installing dotnet Runtime
.\dotnet-install.ps1 -Channel 5.0 -Runtime dotnet

Write-Host Starting Process $ExePath
while($true){
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $ExePath
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = "localhost"
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $pinfo
    $process.Start() | Out-Null
    $process.WaitForExit()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    Write-Host "stdout: $stdout"
    Write-Host "stderr: $stderr"
    Write-Host "exit code: " + $process.ExitCode

    #$process = Start-Process $ExePath -PassThru -Wait

    if($process.ExitCode -ne 0){
        Write-Host Process Exited with errors, please check the logs in $ScanHttpServerFolder\log
    }
    else {
        Write-Host Proccess Exited with no errors
    }

    Write-Host Restarting Process $ExePath
}

Stop-Transcript
