FROM mcr.microsoft.com/windows:1809-amd64

WORKDIR C:/ScanHttpServer/bin
COPY VMInit.ps1 C:/VMInit.ps1
COPY ScanHttpServer.zip C:/ScanHttpServer/bin/

RUN ["powershell", "Set-ExecutionPolicy", "-ExecutionPolicy", "Bypass", "-Scope", "LocalMachine"]

# PS: Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend\" -Name "Start" -Value 3
RUN ["powershell", "Set-ItemProperty", "-Path", "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend\", "-Name", "Start", "-Value", "3"]

# PS: Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend\" -Name "LaunchProtected" -Value 0
RUN ["powershell", "Set-ItemProperty", "-Path", "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend\", "-Name", "LaunchProtected", "-Value", "0"]

ENTRYPOINT [ "powershell.exe", "C:/VMInit.ps1" ]
