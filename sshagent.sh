#!/bin/bash

if ! ( ps aux | grep -v grep | grep ssh-agent ) &> /dev/null; then
  eval "$(ssh-agent -s)"
else
  echo "sshagent already running"
fi
