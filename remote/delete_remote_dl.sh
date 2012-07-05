#!/bin/bash
if [ -z $2 ]; then
  echo "Missing remote dir name."
  exit 1
fi
ssh $1 rm -rf $2
