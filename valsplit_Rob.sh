#!/bin/bash

# checks number of arguements
if [ "$#" -ne 3 ]; then
	exit "Illegal number of arguements"
fi 

# sucessful command array
declare -a successfulCommands

# unsucessful command array
declare -a unsuccessfulCommands

# read the file add all lines to an array
readarray arrayLines < $1
echo "#correct.txt" > $2
echo "#incorrect.txt" > $3

firstWordCheck(){
# skips the first line as that is the #input.txt
for lines in "${arrayLines[@]:1}"; do
	local wordArr=($lines)
		case "${wordArr[0]}" in
			add | sub)
				addSubCheck "${wordArr[@]}";;
			addi)	
				addiCheck "${wordArr[@]}";;
			lw | sw)
				lwCheck "${wordArr[@]}";; 
			*)
				local unsuccessfulsuccess=$(join , ${wordArr[@]})
				# add command to sucessful array
				unsuccessfulCommands+=( "$unsuccessful" )
				echo "${wordArr[0]}" "Is not a recognised command word cannot continue"
				echo "unsuccessful commands =" "${unsuccessfulCommands[@]}"
				echo "";;
		esac
done
}

# checks rest of add/sub commands
addSubCheck(){
# booleans that turns to false when one parameter isnt met when all 3 are true added to successfulCommands array
local firstReg=false
local secondReg=false
local thirdReg=false
local addCheckArr=("$@")
echo "${addCheckArr[@]}"
# need to check the size of the array first should equal 4
if [ "${#addCheckArr[@]}" -ne 4 ]; then
	echo "${addCheckArr[@]}" "doesnt have a valid number of registers"
else
	# check first register
	registerCheck "${addCheckArr[1]}"
	# exit status of last function
	local firstCheck=$?
	if [ "$firstCheck" -eq 1 ]; then
		firstReg=true
	fi
	# checks second register
	registerCheck "${addCheckArr[2]}"
	local secondCheck=$?
	if [ "$secondCheck" -eq 1 ] && [ "${addCheckArr[1]}" != "${addCheckArr[2]}" ]; then
		secondReg=true
	fi
	# checks third register
	registerCheck "${addCheckArr[3]}"
	local thirdCheck=$?
	if [ "$thirdCheck" -eq 1 ] && [ "${addCheckArr[1]}" != "${addCheckArr[2]}" ] && [ "${addCheckArr[1]}" != "${addCheckArr[3]}" ] && [ 		"${addCheckArr[2]}" != "${addCheckArr[3]}" ]; then
		thirdReg=true
	fi
	if [ "$firstReg" == "true" ] && [ "$secondReg" == "true" ] && [ "$thirdReg" == "true" ]; then
		local success=$(join , ${addCheckArr[@]})
		# add command to sucessful array
		successfulCommands+=( "$success" )
		echo "successful commands =" "${successfulCommands[@]}"
		echo
	else 
		local unsuccessful=$(join , ${addCheckArr[@]})
		# add command to unsucessful array
		unsuccessfulCommands+=( "$unsuccessful" )
		echo "unsuccessful commands =" "${unsuccessfulCommands[@]}"
		echo
	fi
fi
}

# checks rest of the addi command
addiCheck(){
# booleans that turns to false when one parameter isnt met when all 3 are true added to successfulCommands array
local firstReg=false
local secondReg=false
local thirdInt=false
local addiCheckArr=("$@")
echo "${addiCheckArr[@]}"
# need to check the size of the array first should equal 4
if [ "${#addiCheckArr[@]}" -ne 4 ]; then
	echo "${addiCheckArr[@]}" "doesnt have a valid number of registers"
else
	# check first register
	registerCheck "${addiCheckArr[1]}"
	# exit status of last function
	local firstCheck=$?
	if [ "$firstCheck" -eq 1 ]; then
		firstReg=true
	fi
	# checks second register
	registerCheck "${addiCheckArr[2]}"
	local secondCheck=$?
	if [ "$secondCheck" -eq 1 ] && [ "${addiCheckArr[1]}" != "${addiCheckArr[2]}" ]; then
		secondReg=true
	fi
	# checks final number
	local int="${addiCheckArr[3]}"
	if [[ $((int)) == $int ]]; then
		thirdInt=true
	fi
	if [ "$firstReg" == "true" ] && [ "$secondReg" == "true" ] && [ "$thirdInt" == "true" ]; then
		local success=$(join , ${addiCheckArr[@]})
		# add command to sucessful array
		successfulCommands+=( "$success" )
		echo "successful commands =" "${successfulCommands[@]}"
		echo
	else 
		local unsuccessful=$(join , ${addiCheckArr[@]})
		# add command to unsucessful array
		unsuccessfulCommands+=( "$unsuccessful" )
		echo "unsuccessful commands =" "${unsuccessfulCommands[@]}"
		echo
	fi
fi
}

lwCheck(){
# booleans that turns to false when one parameter isnt met when all 3 are true added to successfulCommands array
local firstReg=false
local secondInt=false
local thirdBracket=false
local fourthReg=false
local fifthBracket=false
local lwCheckArr=("$@")
echo "${lwCheckArr[@]}"
# need to check the size of the array first should equal 5 split like this lw,$t11,70000(,$s0,)
if [ "${#lwCheckArr[@]}" -ne 5 ]; then
	echo "${lwCheckArr[@]}" "doesnt have a valid size"
else
	# check first register
	registerCheck "${lwCheckArr[1]}"
	# exit status of last function
	local firstCheck=$?
	if [ "$firstCheck" -eq 1 ]; then
		firstReg=true
	fi
	# check int and bracket in the second position
	local word="${lwCheckArr[2]}"
	# gets the number before the bracket
	local numb="${word:0:-1}"
	# retrives the bracket at the end of the string
	local bracket="${word: -1}"
	# check if the offset is between the bounds
	if [ "$numb" -ge "-32768" ] && [ "$numb" -le "32767" ]; then
		secondInt=true
	else
		echo "Offset isn't valid must be between -32768 and 32767"
	fi
	# checks the bracket at the end of the offset
	if [ "$bracket" == "(" ]; then
		thirdBracket=true
	else 
		echo "Bracket before second register and infront of offset isn't valid"
	fi
	# check register in third postion
	registerCheck "${lwCheckArr[3]}"
	local fourthCheck=$?
	if [ "$fourthCheck" -eq 1 ] && [ "${lwCheckArr[1]}" != "${lwCheckArr[3]}" ]; then
		fourthReg=true
	fi
	# check bracket in fourth position
	if [ "${lwCheckArr[4]}" = ")" ]; then
		fifthBracket=true
	fi
	# checks if all parameters are met before adding the successful string to the successfulCommands array
	if [ "$firstReg" == "true" ] && [ "$secondInt" == "true" ] && [ "$thirdBracket" == "true" ] && [ "$fourthReg" == "true" ] && [ "$fifthBracket" == "true" ]; then
		local success=$(join , ${lwCheckArr[@]})
		# add command to sucessful array
		successfulCommands+=( "$success" )
		echo "successful commands =" "${successfulCommands[@]}"
		echo
	else 
		local unsuccessful=$(join , ${lwCheckArr[@]})
		# add command to unsucessful array
		unsuccessfulCommands+=( "$unsuccessful" )
		echo "unsuccessful commands =" "${unsuccessfulCommands[@]}"
		echo
	fi
fi
}

# joins array into one string using commas
function join { local IFS="$1"; shift; echo "$*"; }

registerCheck() {
# 1 is returned with a sucessful register
# 0 is returned with a unsucessful register
local word=("$1")
local symbol=("${word:0:1}")
local symbolCheck=false
local char=("${word:1:1}")
local length=("${#word}")
length=$((length-2))
local numb=("${word:2:length}")
if [ "$symbol" == "$" ]; then
	symbolCheck=true
else
	echo "$symbol" "is an invalid symbol please use $"
fi
if [ "$char" == "s" ]; then
	if [ "$numb" -ge 0 ] && [ "$numb" -le 7 ]; then
		echo "$word" "has a valid register middle character and register number."
		if [ "$symbolCheck" == "true" ]; then
			return 1
		else
			return 0
		fi
	else
		echo "$numb" "isn't a valid register as its a s register number must be from 0-7. But has valid register character" "$char""."
		return 0
	fi
elif [ "$char" == "t" ]; then
	if [ "$numb" -ge 0 ] && [ "$numb" -le 9 ]; then
		echo "$word" "has a valid register middle character and register number."
		if [ "$symbolCheck" == "true" ]; then
			return 1
		else
			return 0
		fi
	else
		echo "$numb" "isn't a valid register as its a t register number must be from 0-9. But has valid register character" "$char""."
		return 0
	fi	
else
	echo "$char" "isn't a valid register character try s or t."
	if [ "$numb" -lt 0 ] && [ "$numb" -gt 9 ]; then
		echo "$numb" " is invalid register number a s register should be between 0-7 and t between 0-9."
		return 0
	fi
	return 0
fi
}

firstWordCheck

# gotta remove the space from the array strings and print them to the file
for i in ${successfulCommands[@]}; do
	commands=${i//,/ }
	printf "%s\n" "$commands" >> $2
done
for n in ${unsuccessfulCommands[@]}; do
	commands=${n//,/ }
	printf "%s\n" "$commands" >> $3
done
