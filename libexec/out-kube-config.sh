#!/bin/bash
tmp=`mktemp`
sudo /usr/local/bin/kind get kubeconfig > "${tmp}"
KUBECONFIG="${tmp}:${HOME}/.kube/config" kubectl config view --flatten > "${HOME}/.kube/config"
rm "${tmp}"
