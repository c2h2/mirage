#!/bin/bash
mkdir -p $1
res=1
j=1
while [ $res -gt 0 ] ; do
  cd ~/$1 && ~/youtube-dl -t http://www.youtube.com/watch?v=$1 && sha1sum * > $1-sha1.txt
  res=$?
  if [ $res -eq 0 ] ; then #if 0, exit, scuess
    exit 0
  else
    if [ $j -gt 2 ] ; then #if too many retries, return 10
      exit 10
    else #inc the retry times.
      j=`expr "$j" + 1` 
      echo "Retry"
    fi
  fi
done


