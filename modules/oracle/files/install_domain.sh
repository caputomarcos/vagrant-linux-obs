#!/usr/bin/env bash

export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom
rm -rf /home/vagrant/oracle/user_projects/domains/*
/home/vagrant/oracle/wlserver_10.3/common/bin/wlst.sh /tmp/install_domain.py
exit 0