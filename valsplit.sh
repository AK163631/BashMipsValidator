# Take two input files, if not provided create missing input.txt, correct.txt, incorrect.txt
# input.txt - mips instructions to validate
# correct.txt - valid instructions
# incorrect.txt - errounous instructions
#
#      ---- instruction specs (Things that need validation) ---
# Must be one of add, sub, addi, lw, sw
# add, sub, addi -> requires 3 args e.g add $s0 $s1 $s2
# lw, sw -> requires 2 args e.g lw $t1 8( $t2 )
# Register must start with $ and followed by sN ( 7 => N => 0) and tN ( 9 => N => 0)
# Immediates (the second source operand of the addi instruction and the offset in the lw and sw instructions) have a range N where 0 => N => 65535
# The second parameter for lw and sw instructions contains both an immediate and a register e.g8( $t2 )
#
#      ---- implementation details ---
# functions return nothing if the are successfull otherwise the return an error string
# erronous instructions will be written to error file only in the validation loop same with vaild instructions
# printing of error messages to stdout/terminal is done only in validatin loop

ADD="add"
SUB="sub"
ADDI="addi"
LW="lw"
SW="sw"
instruction_file="$1" # first arg
output_file="$2" # second arg
error_file="$3" # third arg


write_to_output_file(){
  :
}

write_to_error_file(){
  :
}

validate_instruction(){
  instruction=("$@") # array of instructions elements
  ops=("${instruction[@]:1}") # oprand sublist

  # checks if operation is add or sub
  if [ "${instruction[0]}" == "$ADD" ] || [ "${instruction[0]}" == "$SUB" ]; then

    if [ "${#ops[@]}" == 3 ]; then # checks if it has 3 oprands
      for i in "${ops[@]}" # loops through oprands
      do

        echo $(validate_register "$i") # check each register is valid

      done
    else # oprands != 3
      echo "Not enough oparands looking for 3" # print error message
      return # script breaking error if left
    fi


  elif [ "${instruction[0]}" == "$SW" ] || [ "${instruction[0]}" == "$LW" ]; then # checks if operation is sw or lw
      size="${#ops[@]}"
      if [ "$size" == 4 ]; then   # checks if it has 4 oprands e.g [$s0, 4(, $t0, )]

        echo $(validate_register "${ops[0]}") # checks if first oprand is a valid register
        echo $(validate_memlocation "${ops[@]:1}") # checks if second oprand is a valid memlocation

      else # oprands != 2
        echo "Not enough oparands looking for 2" # print error message
        return # script breaking
      fi

  elif [ "${instruction[0]}" == "$ADDI" ]; then # checks if operation is addi

      if [ "${#ops[@]}" == 3 ]; then # checks if it has 2 oprands

        echo $(validate_register "${ops[0]}") # checks if first oprand is a valid register
        echo $(validate_register "${ops[1]}") # checks if second oprand is a valid register
        echo $(validate_imediate "${ops[2]}") # checks if third oprand is a valid immediate
      fi

  else # operation not recognised

    echo "Invalid operation ${instruction[0]} in $line on line $line_count" # print error message
    return
  fi
}

validate_register(){
  local reg="$1"

  if [ "${#reg}" -lt 3 ]; then # checks if register is correct length > 3
    echo "Unexpected size expected (size > 3) got ${#reg} in $reg in $line on line $line_count"
    return # script breaking error must return
  fi

  if [ "${reg:0:1}" != \$ ]; then # checks for $ at start of register
    echo "Token not found \$ in $reg in $line on line $line_count"
    # return
  fi

  local name="${reg:1:1}"
  if [ "$name" == t ]; then

    if [ "${reg:2}" -gt 9 ] || [ "${reg:2}" -lt 0 ]; then
      echo "Invalid temp register range, expected between 0,9 got ${reg:2} in $reg in $line on line $line_count"
      # return
    fi

  elif [ "$name" == s ]; then

    if [ "${reg:2}" -gt 7 ] || [ "${reg:2}" -lt 0 ]; then
      echo "Invalid register range, expected between 0,7 got ${reg:2} in $reg in $line on line $line_count"
      # return
    fi

  else
    echo "Invalid register name, expected t or s got $name in $reg in $line on line $line_count"
    # return
  fi
}

validate_imediate(){ # takes one value
  local value="$1"
  if [ "$value" -gt 32767 ] || [ "$value" -lt -32768 ]; then
    echo "Invalid immediate range, expected between -32768,32767 got $value in $line on line $line_count"
    # return
  fi
}

validate_memlocation(){ # takes array e.g [4(, $t0, )]
  local parts=("$@") # array of elements

  if [ "${#parts[@]}" != 3 ] ; then
    echo "Invalid memory location format $parts in $line on line $line_count"
    return # script breaking
  fi

  local imediate_size="${#parts[0]}"
  local end=$((imediate_size - 1))

  echo $(validate_imediate "${parts[0]:0:$end}") # check if memory offset is valid
  echo $(validate_register "${parts[1]}") #  checks in register is valid

}

line_count=0
while IFS= read line
do

  IFS=' ' read -r -a array <<< "$line" # split line by space

  ret=$(validate_instruction "${array[@]}") # validate each instruction

  if [ ! -z "$ret" ]; then
    echo "$ret" # print excpetion message to terminal
    write_to_error_file "$line" # write err instruction to error file
  else
    write_to_output_file "$line" # write valid instruction to output file
  fi

  line_count=$((line_count + 1)) # increment line cout

done <"$instruction_file"
