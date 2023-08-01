@echo off

:: Set the Display (port) to default ':0' tcp port 6000.
IF "%DISPLAY%"=="" set DISPLAY=:0

:: Execute the X-server using the correct options.
"%ProgramFiles%\VcXsrv\vcxsrv.exe" %DISPLAY% -dpi auto -ac -lesspointer -multiwindow -multimonitors -hostintitle -clipboard -noprimary +bs -wgl -swrastwgl -nounixkill -nowinkill -silent-dup-error -fp fonts/dejavu/,fonts/misc/,fonts/TTF/,fonts/OTF,fonts/Type1/,fonts/100dpi/,fonts/75dpi/,fonts/cyrillic/,fonts/Speedo/,built-ins

:: This options creates clipboard problems when selecting in Windows.
:: -noclipboardprimary

