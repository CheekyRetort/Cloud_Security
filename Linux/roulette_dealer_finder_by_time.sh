#!/bin/bash



#cat "file name" | then search that for time | search that for "AM" or "PM" | Print relevant info
#cat *Dealer-schedule | grep 12:00 | grep "AM" or "PM" | print the dealers name

cat $1*_Dealer_schedule | grep $2 | grep $3 | awk -F" " '{print $5, $6}'
