# coding: utf-8
import platform
import shutil
import tempfile
from pathlib import Path

from .helper import get_settings, download_file, expand_file

# TODO: sudo で動いていなければ落とすようにする
# TODO: download
# TODO: extract
# TODO: update-alternatives

DL_SRC_MAPPING = None

# update-alternatives で更新するコマンドリスト
COMMANDS = []


def main(args):
    src_url = DL_SRC_MAPPING[args.version]["url"]
    name = DL_SRC_MAPPING[args.version]["name"]
    print(src_url)
    print(name)
    return

    install_dpath = calc_install_base_dpath()
    if install_dpath.exists() and not args.force:
        pass

    with tempfile.TemporaryDirectory() as tmpd:
        fpath = download_file(get_settings(src_url, tmpd)
        if install_dpath.exists():
            shutil.rmtree(install_dpath)
        expand_file(fpath, install_dpath, children=[])

    """
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
    """


def parse_args(parent, dl_src_mapping):
    global DL_SRC_MAPPING

    vers = sorted(dl_src_mapping.keys(), key=float)
    dst = calc_install_base_dpath()
    parser = parent.add_parser("jdk", help="Manage JDK")
    parser.add_argument("-l", "--list", action="store_true")
    parser.add_argument("--version", default=vers[0], choices=vers, help="インストールバージョン")
    parser.add_argument("--destination", default=str(dst), help="インストール先")
    parser.add_argument("--update-alternatives", help="update-alternatives を実行する。", action="store_true")

    parser.set_defaults(func=main)

    DL_SRC_MAPPING = dl_src_mapping


def calc_install_base_dpath():
    if platform.system().lower().startswith("win"):
        raise NotImplementedError("TODO")
    else:
        return Path("/usr") / "lib" / "jvm"
