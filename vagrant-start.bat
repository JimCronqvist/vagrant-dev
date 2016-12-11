@echo off

cd /d %~dp0
for /f "tokens=2* delims= " %%F IN ('vagrant status ^| find /I "default"') DO (SET "STATE=%%F%%G")

echo Current state: "%STATE%"

if "%STATE%" == "saved(virtualbox)" (
	echo Resuming Vagrant VM from saved state...
	vagrant resume
) else if "%STATE%" == "running(virtualbox)" (
	echo Vagrant VM is already running, a restart will be performed...
	vagrant halt
	vagrant up
) else (
	echo Starting Vagrant VM from powered down state...
	vagrant halt
	vagrant up
)

if errorlevel 1 (
  echo ERROR: Something went wrong with the Vagrant VM...
)

pause