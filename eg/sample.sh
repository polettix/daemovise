#!/bin/bash

trap -- '' SIGTERM
echo "hello I am $$"
for i in {1..10}; do
   echo $i
   echo err-$i >&2
   sleep 1
done
