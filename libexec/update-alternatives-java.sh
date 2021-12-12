#!/bin/bash
# vim:ts=2 sts=2 sw=2 tw=0 noet ft=sh fenc=utf-8 ff=unix:
PROG=$(basename "$0")
_dir=$(dirname "$0")

_usage() {
	_USAGE=$(cat <<- EOF
		Usage: sudo ${0} java_home
		Mod java's update-alternatives rels.
		
		Java:
			java_home	a path to JAVA_HOME
		EOF
		)
	echo "$_USAGE"; exit 1;
}
[[ "$#" -ne 1 ]] && _usage

_java_home="$1"
for name in $(update-alternatives --get-selections | grep jvm | sed -e 's/ .*//g') ; do
	_bin_path="${_java_home}/bin/$name"
	if [[ -e "$_bin_path" ]] ; then
			PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin" _sym_path=$(which "$name")
		update-alternatives --install "$_sym_path" "$name" "$_bin_path" 10
		update-alternatives --set "$name" "$_bin_path"
	fi
done
