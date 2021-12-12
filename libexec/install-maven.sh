#!/bin/bash
# vim:ts=2 sts=2 sw=2 tw=0 noet ft=sh fenc=utf-8 ff=unix:
PROG=$(basename "$0")
_dir=$(dirname "$0")

# default values
# Mavenのインストールもと
#'https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz'
#'https://dlcdn.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz'
_base_url='https://dlcdn.apache.org/maven/maven-3/%s/binaries/%s'
_url_36=$(printf "$_base_url" \
	'3.6.3' \
	'apache-maven-3.6.3-bin.tar.gz')
_url_38=$(printf "$_base_url" \
	'3.8.4' \
	'apache-maven-3.8.4-bin.tar.gz')

# usage
_usage() {
	local _USAGE=$(cat <<- EOF
		Usage: sudo ${0} [OPTION]...
		Download maven and store binary.
		
		Options:
		  -i	to install binary
		  -l	show install urls
		  -v	set store version (default 3.6, or 3.8)
		  -d	binary store destination (default ~/.local/lib)
		  -h	show this usage
		EOF
		)
	echo "$_USAGE"; exit 1;
}

# parse args
declare -i _install_flg=0
declare -l _show_flg=0
declare _version="3.6"
declare _dst="$HOME/.local/lib"
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
			_version="$OPTARG"
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
	echo "3.6: ${_url_36}"
	echo "3.8: ${_url_38}"
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
	"3.6") _src_url="$_url_36" ;;
	"3.8") _src_url="$_url_38" ;;
esac
_exec "$_src_url" "$_dst"
