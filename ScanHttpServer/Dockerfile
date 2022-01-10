FROM mcr.microsoft.com/windows:1809-amd64

WORKDIR C:/ScanHttpServer/bin
COPY VMInit.ps1 C:/VMInit.ps1
COPY ScanHttpServer.zip C:/ScanHttpServer/bin/

RUN ["powershell.exe", "Set-ExecutionPolicy", "-ExecutionPolicy", "Bypass", "-Scope", "LocalMachine"]
ENTRYPOINT [ "powershell.exe", "C:/VMInit.ps1" ]
