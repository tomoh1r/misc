#!/bin/bash
# vim:ts=2 sts=2 sw=2 tw=0 noet ft=sh fenc=utf-8 ff=unix:
PROG=$(basename "$0")
_dir=$(dirname "$0")

# default values
# Temurin Linux(x64)向けのtar.gz URLをリストアップする。
_base_url='https://github.com/adoptium/%s/releases/download/%s'
_url_08=$(printf "$_base_url" \
	'temurin8-binaries' \
	'jdk8u312-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz')
_url_11=$(printf "$_base_url" \
	'temurin11-binaries' \
	'jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz')
_url_17=$(printf "$_base_url" \
	'temurin17-binaries' \
	'jdk-17.0.1%2B12/OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz')

# usage
_usage() {
	local _USAGE=$(cat <<- EOF
		Usage: sudo ${0} [OPTION]...
		Download jdk and store binary.
		
		Options:
		  -i	to install binary
		  -l	show install urls
		  -v	set store jdk version (default 8, or 11, 17)
		  -d	binary store destination (default /usr/lib/jvm)
		  -h	show this usage
		
		JDKs:
		  8  Temurin8	8u312b07
		  11 Temurin11	11.0.13_8
		  17 Temurin17	17.0.1_12
		EOF
		)
	echo "$_USAGE"; exit 1;
}

# parse args
declare -i _install_flg=0
declare -i _show_flg=0
declare _version="08"
declare _dst="/usr/lib/jvm"
declare -i _cnt=0
while getopts 'ilv:d:h' flag; do
	case "${flag}" in
		i)
			_install_flg=1
			(( _cnt += 1 ))
			;;
		l)
			_show_flg=1
			(( _cnt += 1 ))
			;;
		v)
			_version=$(printf '%02d' "$OPTARG")
			(( _cnt += 2 ))
			;;
		d)
			_dst="$OPTARG"
			(( _cnt += 2 ))
			;;
		h) _usage ;;
		*) _usage ;;
	esac
done
[[ $(( "$#" - "$_cnt" )) -ne 0 ]] && _usage
if [[ $(( "$_install_flg" + "$_show_flg" )) -eq 0 ]] ; then
	echo $'Please set -i option\n'
	_usage
fi

# exec
_show_url() {
	echo "Urls:"
	echo "8: ${_url_08}"
	echo "11: ${_url_11}"
	echo "17: ${_url_17}"
	exit
}
[[ "$_show_flg" -eq 1 ]] && _show_url

_exec() {
	local readonly _lsrc="$1"
	local readonly _ldst="$2"
	local readonly _fname=$(basename "$_lsrc")
	local readonly _dstdname=$(echo "$_fname" | sed -e 's/\.tar\.gz$//')
	local readonly _targetdstpath="${_ldst}/${_dstdname}"
	local _expdname

	if [[ -e "$_targetdstpath" ]] ; then
		echo "There exists ${_targetdstpath}"
		exit
	fi

	echo "Download archive, and install binary to ${_ldst}"
	local _tmpd=$(mktemp -d)
	pushd "$_tmpd" > /dev/null
		curl -OL "$_lsrc"
		tar xf "$_fname"
		for name in "./"* ; do
			local _basename=$(basename "$name")
			[[ "$_basename" != "$_fname" ]] && _expdname="$_basename"
		done
		mv "$_fname" "$_expdname"
		mv "$_expdname" "$_dstdname"
		mv "$_dstdname" "$_ldst"
		cd ..
		rm -fr $(basename "$_tmpd")
	popd > /dev/null
}
declare _src_url
case "$_version" in
	08) _src_url="$_url_08" ;;
	11) _src_url="$_url_11" ;;
	17) _src_url="$_url_17" ;;
esac
_exec "$_src_url" "$_dst"
