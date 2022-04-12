
#!/bin/bash

# For the script to execute you have to specify the date (which is found in the name of the schedule), the time, "AM" or "PM" (must be in capitol letters), and game
# i.e. ./roulette_dealer_by_time_and_game 0310 12 AM BlackJack

# For the BlackJack Dealers
# Read the schedule ($1) and then print so that we get: Time, AM/PM, AM/PM, Dealer_FName, Last (with spaces in between)
# cat $1 | awk -F" " '{print $1, $2, $2, $3, $4}'

# Replace first AM with the word BlackJack
# sed s/AM/BlackJack/

# Replace first PM with the word BlackJack
# sed s/PM/BlackJack/

# Print the file in a nicer looking order (Time AM/PM Game Dealer_name) and to display relevant info when outputed)
# awk -F" " '{print $1, $3, $2, $4, $5}'

# Append to a temp file
# >> dealer_tmp

# Same as above but for Roulette
# cat $1 | awk -F" " '{print $1, $2, $2, $5, $6}' | sed s/AM/Roulette/ | sed s/PM/Roulette/ | awk -F" " '{print $1, $3, $2, $4, $5}' >> dealer_tmp

# Same as above but for Texas_Hold_Em
# cat $1 | awk -F" " '{print $1, $2, $2, $7, $8}' | sed s/AM/Texas_Hold_Em/ | sed s/PM/Texas_Hold_Em/ | awk -F" " '{print $1, $3, $2, $4, $5}' >> dealer_tmp

# Search the tmp file for the time ($2), AM/PM ($3), Game ($4)
# grep '12' dealer_tmp | grep 'AM' | grep 'Texas'

# Remove the temp file
# rm dealer_tmp


#---------Executing script below---------#

cat $1*_Dealer_schedule | awk -F" " '{print $1, $2, $2, $3, $4}' | sed s/AM/BlackJack/ | sed s/PM/BlackJack/ | awk -F" " '{print $1, $3, $2, $4, $5}' >> dealer_tmp

cat $1*_Dealer_schedule | awk -F" " '{print $1, $2, $2, $5, $6}' | sed s/AM/Roulette/ | sed s/PM/Roulette/ | awk -F" " '{print $1, $3, $2, $4, $5}' >> dealer_tmp

cat $1*_Dealer_schedule | awk -F" " '{print $1, $2, $2, $7, $8}' | sed s/AM/Texas_Hold_Em/ | sed s/PM/Texas_Hold_Em/ | awk -F" " '{print $1, $3, $2, $4, $5}' >> dealer_tmp

grep $2 dealer_tmp | grep $3 | grep $4

rm dealer_tmp
