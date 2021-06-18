#!/bin/bash
set -x #echo on

mv /etc/apt/sources.list /etc/apt/sources.list.original

mv /files/debian/sources.list /etc/apt/sources.list 

apt-get install gnupg
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0B91000371B127C2FF62A62781DCD8423B6F61A6

apt-get update -y
apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y