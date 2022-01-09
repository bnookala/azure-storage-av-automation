FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

WORKDIR C:/ScanServer
COPY ./build  C:/ScanServer
COPY runLoop.ps1 C:/

ENTRYPOINT [ "powershell.exe", "C:/runLoop.ps1" ]
