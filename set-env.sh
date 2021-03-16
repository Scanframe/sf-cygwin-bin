#/bin/bash

# Get the location to the C drive in the unix environment.
if [[ -d "/cygdrive" ]] ; then
	echo "Cygwin detected.."
	C_DRIVE="/cygdrive/c"
else
	echo "WSL detected.."
	C_DRIVE="/mnt/c"
fi

# Make a copy of the original path to allow calling this script multiple times.
if [[ -z ${CYG_PATH_ORG} ]] ; then
	export CYG_PATH_ORG=${PATH}
fi

# Configuration Qt and Visual Studio
if [[ ! -z "$1" ]] ; then

# Set the source drives.
SRC_UNIX="${C_DRIVE}/Users/arjan/cygwin/src"
SRC_WINDOWS="C:/Users/arjan/cygwin/src"


export CVSROOT=${SRC_WINDOWS}
export QTDIR="${C_DRIVE}/Qt/5.12.4/msvc2017_64"
export QMAKESPEC="win32-msvc"
export FEASTDIR="${SRC_UNIX}/ExternalLibraries/Feast/2.9.2/"
export PATH=${CYG_PATH_ORG}\
":${C_DRIVE}/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/VC/Tools/MSVC/14.16.27023/bin/Hostx86/x86"\
":${QTDIR}/bin"\
":${FEASTDIR}/bin"\
":${SRC_UNIX}/ExternalLibraries/KDSoap/1.8.0-msvc2017/bin"

#alias cl="/mnt/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2017/Enterprise/VC/Tools/MSVC/14.16.27023/bin/Hostx86/x86/cl.exe"
alias vs="/cygdrive/c/Program\ Files\ \(x86\)/Microsoft\ Visual\ Studio/2017/Enterprise/Common7/IDE/devenv.exe"

# Configuration for MingW 
else

export PATH="${CYG_PATH_ORG}"\
":/cygdrive/p/Qt/Tools/CMake_64/bin"\
":/cygdrive/p/Qt/Tools/mingw810_64/bin"\
":/cygdrive/p/Qt/6.0.1/mingw81_64/bin"

fi