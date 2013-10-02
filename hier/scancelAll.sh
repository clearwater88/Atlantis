#!/bin/bash

a="myq | grep -e '[0-9]\{7\}' | cut -d ' ' -f 1"

eval cmd=\`${a}\` 

for i in $cmd
do
	echo 'Cancelling job: '$i
	scancel $i
done
