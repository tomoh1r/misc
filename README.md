miscellaneous
=============

misc misc misc

```
$ sudo dnf install git-core ansible-core vim-enhanced tmux
$ cd ~
$ git clone git@github.com:tomoh1r/misc.git .misc
$ cd .misc
$ ansible-playbook --inventory=share/ansible/hosts --tags=setup --ask-become-pass share/ansible/playbook.yml
```
