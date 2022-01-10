#Init
$ScanHttpServerFolder = "C:\ScanHttpServer\bin"

Start-Transcript -Path C:\VmInit.log

$ScanHttpServerBinZipUrl = "https://github.com/Azure/azure-storage-av-automation/releases/latest/download/ScanHttpServer.zip"

# Download Http Server bin files

Write-Host Expanding ScanHttpServer
Expand-Archive $ScanHttpServerFolder\ScanHttpServer.zip -DestinationPath $ScanHttpServerFolder\ -Force

cd $ScanHttpServerFolder

Write-Host Creating and adding certificate

$cert = New-SelfSignedCertificate -DnsName ScanServerCert -CertStoreLocation "Cert:\LocalMachine\My"
$thumb = $cert.Thumbprint
$appGuid = '{'+[guid]::NewGuid().ToString()+'}'

Write-Host successfully created new certificate $cert

netsh http delete sslcert ipport=0.0.0.0:443
netsh http add sslcert ipport=0.0.0.0:443 appid=$appGuid certhash="$thumb"

Write-Host Adding firewall rules
New-NetFirewallRule -DisplayName "ServerFunctionComunicationIn" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "ServerFunctionComunicationOut" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Allow

#Updating antivirus Signatures
Write-Host Updating Signatures for the antivirus
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -SignatureUpdate
#Running the App
Write-Host Starting Run-Loop

#start-process powershell -verb runas -ArgumentList $runLoopPath

Write-Host Install .net 5 sdk + runtime
if (-Not (Test-Path $ScanHttpServerFolder\dotnet-install.ps1)){
    Write-Host dotnet-install script doesnt exist, Downloading
    Invoke-WebRequest "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1" -OutFile $ScanHttpServerFolder\dotnet-install.ps1
}

Write-Host Installing dotnet Runtime
.\dotnet-install.ps1 -Channel 5.0 -Runtime dotnet


$ExePath = "$ScanHttpServerFolder\ScanHttpServer.dll"
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
