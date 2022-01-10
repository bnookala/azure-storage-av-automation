FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

WORKDIR C:/ScanHttpServer
COPY ./build  C:/ScanHttpServer
COPY startProcess.ps1 C:/

ENTRYPOINT [ "powershell.exe", "C:/startProcess.ps1" ]
