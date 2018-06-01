#! /bin/sh

(
    if [ "$#" -eq 0 ] || [ "$#" -ge 2 ] ; then
        echo 'You should specify one tag.'
        exit 1
    fi

    baseDir="$(dirname "$0")"
    ansible-playbook -K -i "$baseDir/hosts" -t "$1" "$baseDir/playbook.yml"
)
