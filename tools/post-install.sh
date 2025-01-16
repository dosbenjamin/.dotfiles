#!/bin/bash

test -e ~/.ssh/authorized_keys && rm ~/.ssh/authorized_keys
test -e ~/.profile && rm ~/.profile
test -e ~/.bashrc && rm ~/.bashrc
test -e ~/.bash_logout && rm ~/.bash_logout
test -e ~/.bash_history && rm ~/.bash_history
test -e ~/.cloud-locale-test.skip && rm ~/.cloud-locale-test.skip
