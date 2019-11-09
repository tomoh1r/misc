miscellaneous
=============

misc misc misc

If you use RHEL 8, then you'll need to install `ansible-2-for-rhel-8-x86_64-rpms`.

```
$ sudo subscription-manager repos --enable=ansible-2-for-rhel-8-x86_64-rpms
```

```
$ sudo dnf install git-core ansible
$ cd ~
$ git clone git@github.com:tomoh1r/misc.git
$ cd misc
$ ./share/ansible/provision.py git python2 python3 vim
```
