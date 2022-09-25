#!/bin/bash
PROG=$(basename "$0")
_dir=$(dirname "$0")

tmp=`mktemp`
"${_dir}/sudo-kind.sh" get kubeconfig > "${tmp}"
KUBECONFIG="${tmp}:${HOME}/.kube/config" kubectl config view --flatten > "${HOME}/.kube/config"
rm "${tmp}"
