#!/bin/bash

PID=`cat /var/run/ppn-spider-unicorn.pid`

# kill -USR2
kill -USR2 $PID

while true; do
  sleep 10 

  num=`ps -ef | grep unicorn | grep master | grep $PID | wc -l`

  if (( num > 1 )) ; then
    kill -QUIT $PID
    break
  fi
done

