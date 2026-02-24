#!/usr/bin/env bash

cd ~/

mkdir control

cd control

curl -sSL https://raw.githubusercontent.com/rebienkrdns/control.sh/main/control.sh -o control.sh

chmod +x control.sh

sudo ln -s ~/control/control.sh /usr/local/bin/control

control --help
