#!/bin/bash

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This post-install script only supports Linux." >&2
  exit 1
fi

test -e ~/.ssh/authorized_keys && rm ~/.ssh/authorized_keys
test -e ~/.profile && rm ~/.profile
test -e ~/.bashrc && rm ~/.bashrc
test -e ~/.bash_logout && rm ~/.bash_logout
test -e ~/.bash_history && rm ~/.bash_history
test -e ~/.cloud-locale-test.skip && rm ~/.cloud-locale-test.skip
