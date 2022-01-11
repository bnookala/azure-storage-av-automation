#Init
$ScanHttpServerFolder = "C:\ScanHttpServer\bin"

Start-Transcript -Path C:\VmInit.log

# Start Defender, in background.
# TBD: Defender still doesn't work in windows.
Start-Job -ScriptBlock {Start-Service windefend}

# Expand HTTP Server Bin files
Write-Host Expanding ScanHttpServer
Expand-Archive $ScanHttpServerFolder\ScanHttpServer.zip -DestinationPath $ScanHttpServerFolder\ -Force

cd $ScanHttpServerFolder

Write-Host Creating and adding certificate

$cert = New-SelfSignedCertificate -DnsName ScanServerCert -CertStoreLocation "Cert:\LocalMachine\My"
$thumb = $cert.Thumbprint
$appGuid = '{'+[guid]::NewGuid().ToString()+'}'

Write-Host successfully created new certificate $cert

# note; deleting ssl cert doesn't seem to work
#netsh http delete sslcert ipport=0.0.0.0:443
# note; adding sslcert doesn't seem to work
netsh http add sslcert ipport=0.0.0.0:443 appid=$appGuid certhash="$thumb"

#Write-Host Adding firewall rules
# note; adding these firewall rules doesn't appear to work
New-NetFirewallRule -DisplayName "ServerFunctionComunicationIn" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "ServerFunctionComunicationOut" -Direction Outbound -LocalPort 443 -Protocol TCP -Action Allow

#Updating antivirus Signatures
# note; asking mpcmdrun to update signatures also doesn't appear to work
Write-Host Updating Signatures for the antivirus
& "C:\Program Files\Windows Defender\MpCmdRun.exe" -SignatureUpdate

#Install dotnet sdk
Write-Host Install .net 5 sdk + runtime
if (-Not (Test-Path $ScanHttpServerFolder\dotnet-install.ps1)){
    Write-Host dotnet-install script doesnt exist, Downloading
    Invoke-WebRequest "https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1" -OutFile $ScanHttpServerFolder\dotnet-install.ps1
}

Write-Host Installing dotnet Runtime
.\dotnet-install.ps1 -Channel 5.0 -Runtime dotnet

# Append path
$env:Path += ";C:\Users\ContainerAdministrator\AppData\Local\Microsoft\dotnet\"

# Install script does not modify path so we have to do it ourselves
$DllPath = "$ScanHttpServerFolder\ScanHttpServer.dll"

Write-Host Starting Run-Loop with Process dotnet $DllPath
while ($true) {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "dotnet"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = "$DllPath"
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

    if ($process.ExitCode -ne 0){
        Write-Host Process Exited with errors, please check the logs in $ScanHttpServerFolder\log
    } else {
        Write-Host Proccess Exited with no errors
    }

    Write-Host Restarting Process dotnet $DllPath
}

Stop-Transcript
