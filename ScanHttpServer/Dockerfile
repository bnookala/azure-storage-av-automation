FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

WORKDIR C:/ScanServer
COPY ./build  C:/ScanServer
COPY startProcess.ps1 C:/

ENTRYPOINT [ "powershell.exe", "C:/startProcess.ps1" ]
