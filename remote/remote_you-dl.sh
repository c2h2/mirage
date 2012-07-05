#!/bin/bash
mkdir -p $1
res=1
j=1
while [ $res -gt 0 ] ; do
  cd ~/$1 && ~/youtube-dl -t http://www.youtube.com/watch?v=$1 && sha1sum * > $1.sha1.txt
  res=$?
  if [ $j -gt 2 ] ; then
    exit 10
  else
    j=`expr "$j" + 1`
    echo "Retry"
    #nothing
  fi
done


