@echo off
setlocal

set me=%~n0

rem # Uncomment the following line if gettext is not in your PATH.
rem # Value must be absolute and end in a backslash.
rem set gtprefix=C:\path\to\gettext\bin\

if "%1" == "" (
	echo Usage: %me% FILE... 1>&2
	exit 1
)

set xgettext=%gtprefix%xgettext.exe
set msgmerge=%gtprefix%msgmerge.exe

md locale > nul 2>&1
echo Generating template... 1>&2
echo %xgettext% --from-code=UTF-8 -kS -kNS:1,2 -k_ -o locale/template.pot %*
%xgettext% --from-code=UTF-8 -kS -kNS:1,2 -k_ -o locale/template.pot %*
if %ERRORLEVEL% neq 0 goto done

cd locale

for %%f in (*.po) do (
	echo Updating %%f... 1>&2
	%msgmerge% --update %%f template.pot
)

echo DONE! 1>&2

:done
