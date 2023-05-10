@ECHO OFF
::_____________________________________________________________________________________________________________________________________________________________
:: 관리자 권한 요청

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

IF %errorlevel% neq 0 (
	GOTO UACPrompt
) ELSE (
	GOTO gotAdmin
)

:UACPrompt
	ECHO SET UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
	ECHO UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

	"%temp%\getadmin.vbs"
	EXIT /B

:gotAdmin
	IF EXIST "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
	PUSHD "%CD%"
	CD /D "%~dp0"

::_____________________________________________________________________________________________________________________________________________________________

CHCP 65001 > nul
Title 알약 제거

ECHO 알약 통합에이전트 제거를 위한 작업입니다.
ECHO Uninstall 권한이 없어 프로그램 파일과 레지스트리를 직접 제거합니다.
CHOICE /c 12 /n /t 3 /d 2 /m "제거를 진행하시겠습니까? [1] Yes, [2] No"

IF %errorlevel% equ 1 (
	CLS
) ELSE IF %errorlevel% equ 2 (
	GOTO End
)

ECHO ○ 백그라운드에서 동작 중인 알약 프로세스를 강제로 종료
ECHO.
TASKKILL /im "AYCUpdSrv.ayc" /t /f 2>nul
CLS
ECHO ● 백그라운드에서 동작 중인 알약 프로세스를 강제로 종료

ECHO ○ 디렉토리 제거 시작
ECHO.
RD /s /q "%Program Files%\ESTsoft" 2>nul
RD /s /q "%ProgramData%\ESTsoft" 2>nul
RD /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\이스트소프트"  2>nul
ECHO ● 백그라운드에서 동작 중인 알약 프로세스를 강제로 종료
ECHO ● 디렉토리 제거 시작

ECHO ○ 바로가기 제거 시작
ECHO.
DEL /s /q "%ProgramData%\Microsoft\Windows\Start menu\알약"
DEL /s /q "%UserProfile%\Desktop\알약"
CLS
ECHO ● 백그라운드에서 동작 중인 알약 프로세스를 강제로 종료
ECHO ● 디렉토리 제거 시작
ECHO ● 바로가기 제거 완료

ECHO ○ 레지스트리 제거 시작
ECHO.
REG QUERY "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UFH\SHC" /f "C:\Program Files\ESTsoft\ALYac\AYCLaunch.exe" | FIND /i "C:\Program Files\ESTsoft\ALYac\AYCLaunch.exe" >> "%temp%\ALYacIntegrationAgentRemove.log"
FOR /f "tokens=1" %%a in ('type %temp%\ALYacIntegrationAgentRemove.log') do SET key1=%%a
REG QUERY "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UFH\SHC" /f "C:\Program Files\ESTsoft\ALYac\AYCLaunch.exe" | FIND /i "C:\Program Files\ESTsoft\ALYac\AYCLaunch.exe" >> "%temp%\ALYacIntegrationAgentRemove.log"
FOR /f "tokens=1" %%a in ('type %temp%\ALYacIntegrationAgentRemove.log') do SET key2=%%a
DEL /s /q "%temp%\ALYacIntegrationAgentRemove.log"

REG DELETE "HKCR\*\shellex\ContextMenuHandlers\ALYac" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UFH\SHC" /v "%key1%" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UFH\SHC" /v "%key2%" /f
REG DELETE "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /v "C:\Program Files\ESTsoft\ALYac\AYCLaunch.exe" /f
REG DELETE "HKLM\SOFTWARE\ESTsoft\ALYac" /f
REG DELETE "HKLM\SOFTWARE\ESTsoft\ALYacIntegrationAgent" /f
REG DELETE "HKLM\SOFTWARE\ESTsoft\ASM" /f
REG DELETE "HKLM\SOFTWARE\ESTsoft" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ALYac" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ALYacIntegrationAgent" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ALYac_is1" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ALYacIntegrationAgent" /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ALYacIntegrationAgent_is1" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\ALYac_IASrv" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\ALYac_RTSrv" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\ALYac_UpdSrv" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\ALYac_WSSrv" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\EscWfp" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\EstRtwIFDrv" /f
REG DELETE "HKLM\SYSTEM\ControlSet001\Services\trufos" /f
REG DELETE "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\ALYac_UpdSrv" /f
REG DELETE "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\ALYac_UpdSrv" /f
CLS
ECHO ● 백그라운드에서 동작 중인 알약 프로세스를 강제로 종료
ECHO ● 디렉토리 제거 시작
ECHO ● 바로가기 제거 완료
ECHO ● 레지스트리 제거 완료

:End
BCDEDIT /deletevalue {current} safeboot >nul
SHUTDOWN /r /t 5 /c "안전모드 해제 후, 다시 시작합니다." /f
DEL /s /q "%UserProfile%\desktop\저를 실행해주세요!.bat" 2>nul
