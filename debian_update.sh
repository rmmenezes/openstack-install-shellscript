#!/bin/bash
set -x #echo on

sudo DEBIAN_FRONTEND=noninteractive apt-get install gnupg -yq
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0B91000371B127C2FF62A62781DCD8423B6F61A6

mv /etc/apt/sources.list /etc/apt/sources.list.original
cat ./files/debian/sources.list > /etc/apt/sources.list 

sudo DEBIAN_FRONTEND=noninteractive apt-get install gnupg -yq
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0B91000371B127C2FF62A62781DCD8423B6F61A6

sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq