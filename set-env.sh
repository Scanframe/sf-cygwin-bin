#/bin/bash

# Get the location to the C drive in the unoix environment.
if [[ -d "/cygdrive" ]] ; then
	echo "Cygwin detected.."
	C_DRIVE="/cygdrive/c"
else
	echo "WSL detected.."
	C_DRIVE="/mnt/c"
fi

# Set the source drives.
SRC_UNIX="${C_DRIVE}/Users/arjan/cygwin/src"
SRC_WINDOWS="C:/Users/arjan/cygwin/src"

# Make a copy of the original path to allow calling this script multiple times.
if [[ -z ${PATH_ORG} ]] ; then
	export PATH_ORG=${PATH}
fi

export CVSROOT=${SRC_WINDOWS}
export QTDIR="${C_DRIVE}/Qt/5.12.4/msvc2017_64"
export QMAKESPEC="win32-msvc"
export FEASTDIR="${SRC_UNIX}/ExternalLibraries/Feast/2.9.2/"
export PATH=${PATH_ORG}\
":${C_DRIVE}/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Tools/MSVC/14.16.27023/bin/Hostx86/x86"\
":${QTDIR}/bin"\
":${FEASTDIR}/bin"\
":${SRC_UNIX}/ExternalLibraries/KDSoap/1.8.0-msvc2017/bin"



#alias cl="/mnt/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2017/Enterprise/VC/Tools/MSVC/14.16.27023/bin/Hostx86/x86/cl.exe"

alias vs="/cygdrive/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2017/Enterprise/Common7/IDE/devenv.exe"