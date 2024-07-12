#!/usr/bin/env bash

# List of WinGet packages to install.
declare -A wg_pkgs
wg_pkgs["CMake C++ build tool"]="Kitware.CMake"
wg_pkgs["Ninja build system"]="Ninja-build.Ninja"
wg_pkgs["Vulkan SDK"]="KhronosGroup.VulkanSDK"
wg_pkgs["AgentRansack file finder"]="Mythicsoft.AgentRansack"
#wg_pkgs["GNU Make"]="GnuWin32.Make"

# Iterate through the associative array of subdirectories (key) and remotes (value).
for name in "${!wg_pkgs[@]}"; do
	if winget list --disable-interactivity --accept-source-agreements --exact --id "${wg_pkgs["${name}"]}" >/dev/null; then
		echo "WinGet Package '${name}' already installed."
	else
		echo "Installing WinGet package'${name}' ..."
		winget install --disable-interactivity --accept-source-agreements --exact --id "${wg_pkgs["${name}"]}"
	fi
done

# List of Cygwin packages to install.
cg_pkgs=(
	"dialog"
	"recode"
	"doxygen"
	"perl-Image-ExifTool"
	"pcre"
	"jq"
)

for pkg in "${cg_pkgs[@]}"; do
	apt-cyg install $pkg
done
