@echo off

"%ProgramFiles%\VcXsrv\vcxsrv.exe" :0 -dpi auto -ac -lesspointer -multiwindow -multimonitors -hostintitle -clipboard -noprimary +bs -wgl -swrastwgl -nounixkill -nowinkill -silent-dup-error -fp fonts/dejavu/,fonts/misc/,fonts/TTF/,fonts/OTF,fonts/Type1/,fonts/100dpi/,fonts/75dpi/,fonts/cyrillic/,fonts/Speedo/,built-ins

:: -noclipboardprimary