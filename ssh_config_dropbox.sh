#!/bin/bash
mkdir ~/Dropbox/configs
mv ~/.ssh/config ~/Dropbox/configs/ssh-config.txt
ln -s ~/Dropbox/configs/ssh-config.txt ~/.ssh/config