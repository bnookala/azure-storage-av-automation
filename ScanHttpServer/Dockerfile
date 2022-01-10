FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

WORKDIR C:/ScanHttpServer/bin
COPY VMInit.ps1 C:/VMInit.ps1
COPY ScanHttpServer.zip C:/ScanHttpServer/bin/

ENTRYPOINT [ "powershell.exe", "C:/VMInit.ps1" ]
