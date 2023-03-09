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
:: ECHO 색상 설정

SET _elev=
IF /i "%~1"=="-el" SET _elev=1
FOR /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
SET "_null=1>nul 2>nul"
SET "_psc=powershell"
SET "EchoBlack=%_psc% write-host -back DarkGray -fore Black"
SET "EchoBlue=%_psc% write-host -back Black -fore DarkBlue"
SET "EchoGreen=%_psc% write-host -back Black -fore Darkgreen"
SET "EchoCyan=%_psc% write-host -back Black -fore DarkCyan"
SET "EchoRed=%_psc% write-host -back Black -fore DarkRed"
SET "EchoPurple=%_psc% write-host -back Black -fore DarkMagenta"
SET "EchoYellow=%_psc% write-host -back Black -fore DarkYellow"
SET "EchoWhite=%_psc% write-host -back Black -fore Gray"
SET "EchoGray=%_psc% write-host -back Black -fore DarkGray"
SET "EchoLightBlue=%_psc% write-host -back Black -fore Blue"
SET "EchoLightGreen=%_psc% write-host -back Black -fore Green"
SET "EchoLightCyan=%_psc% write-host -back Black -fore Cyan"
SET "EchoLightRed=%_psc% write-host -back Black -fore Red"
SET "EchoLightPurple=%_psc% write-host -back Black -fore Magenta"
SET "EchoLightYellow=%_psc% write-host -back Black -fore Yellow"
SET "EchoBrightWhite=%_psc% write-host -back Black -fore White"

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

ECHO ====================================================
%echored% 백그라운드에서 동작 중인 알약 프로세스를 강제로 종료
ECHO ====================================================
TASKKILL /im "AYCUpdSrv.ayc" /t /f 2> nul
TIMEOUT /t 2 > nul

CLS
ECHO ==================
%echoyellow% 디렉토리 제거 시작
ECHO ==================
TIMEOUT /t 2 > nul

CLS
RD /s /q "%Program Files%\ESTsoft"
RD /s /q "%ProgramData%\ESTsoft"
RD /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\이스트소프트"

CLS
ECHO ==================
%echogreen% 디렉토리 제거 완료
ECHO ==================
TIMEOUT /t 2 > nul

CLS
ECHO ==============
%echoyellow% 파일 제거 시작
ECHO ==============
TIMEOUT /t 2 > nul

CLS
DEL /s /q "%ProgramData%\Microsoft\Windows\Start menu\알약.lnk"
DEL /s /q "%UserProfile%\Desktop\알약.lnk"

CLS
ECHO ==============
%echogreen% 파일 제거 완료
ECHO ==============
TIMEOUT /t 2 > nul

CLS
ECHO ====================
%echoyellow% 레지스트리 제거 시작
ECHO ====================
TIMEOUT /t 2 > nul

CLS
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
ECHO ====================
%echogreen% 레지스트리 제거 완료
ECHO ====================
TIMEOUT /t 2 > nul

:End
CLS
BCDEDIT /deletevalue {current} safeboot > nul
SHUTDOWN /r /t 5 /c "안전모드 해제 후, 다시 시작합니다." /f
DEL /s /q "%UserProfile%\desktop\저를 실행해주세요!.bat" 2> nul
