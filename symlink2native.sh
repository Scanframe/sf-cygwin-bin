#!/usr/bin/env bash

# Bailout on first error.
set -e

# Show usage help when no argument is passed on the command line.
if [[ -z "$1" ]]; then
	echo "Convert a Cygwin JUNCTION symlinks into Windows native SYMLINK or SYMLINKD symlink types.
Usage: $0 <directory>
"
	exit 1
fi

target_dir="$1"
magic="-#symlink#"

# Check if the directory exists.
if [[ ! -d "${target_dir}" ]]; then 
	echo "Target directory '${target_dir}' does not exist!"
	exit 1
fi 

pushd "${target_dir}" >/dev/null
while read -r symlink; do
	if fsutil reparsepoint query "$(cygpath -w "$(dirname "${symlink}")")\\$(basename "${symlink}")" | 
		head -n 4 | grep 'Tag value: Symbolic Link' >/dev/null ; then
		continue
	fi
	echo "Converting: ${symlink}"
	dest="$(readlink "${symlink}")"
	echo "Destination: ${dest}"
	CYGWIN=winsymlinks:native ln -rs "${dest}" "${symlink}${magic}"
	# Finally replace the original symlink by renaming the original first.
	mv "${symlink}" "${symlink}${magic}org"
	# Renaming the new created one to the actual needed name.
	mv "${symlink}${magic}" "${symlink}"
	# Last step remove the renamed original one.
	rm "${symlink}${magic}org" 
done < <(find ./ -maxdepth 1 -type l)
popd >/dev/null

