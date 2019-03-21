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
# functions return "0" if the are successfull otherwise the return an error message
# erronous instructions will be written to error file in write_to_error_file called in validate_instruction only
# printing of error messages to stdout/terminal is done in validate_instruction

ADD="add"
SUB="sub"
ADDI="addi"
LW="lw"
SW="sw"
instruction_file="$1" # first arg
output_file="$2" # second arg
error_file="$3" # third arg


write_to_ouptut_file(){
  echo ""
}

write_to_error_file(){
  echo ""
}

validate_instruction(){
  instruction=("$@") # array of instructions elements
  ops=("${instruction[@]:1}") # oprand sublist

  # checks if operation is add or sub
  if [ "${instruction[0]}" == "$ADD" ] || [ "${instruction[0]}" == "$SUB" ]; then

    if [ "${#ops[@]}" == 3 ]; then # checks if it has 3 oprands
      for i in "${ops[@]}" # loops through oprands
      do
        func_result=$(validate_register "$i") # check each register is valid

        if [ "$func_result" != "0" ]; then
          write_to_error_file "$line" # write instruction line to error file
          echo "$func_result" # prints error message
          return 1 # return as no need to check rest
        fi

      done
    else # oprands != 3
      write_to_error_file "$line" # write instion line to error file
      echo "Not enough oparands look for 3" # print error message
    fi

# checks if operation is sw or lw
  elif [ "${instruction[0]}" == "$SW" ] || [ "${instruction[0]}" == "$LW" ]; then

      if [ "${#ops[@]}" == 4 ]; then   # checks if it has 4 oprands e.g [$s0, 4(, $t0, )]

        func1_result=$(validate_register "${ops[0]}") # checks if first oprand is a valid register
        func_result=$(validate_memlocation "${ops[@]:1}") # checks if second oprand is a valid memlocation

        if [ "$func1_result" != "0" ]; then
          write_to_error_file "$line" # write instruction line to error file
          echo "$func1_result" # prints error message
          return 1 # return as no need to check rest

        elif [ "$func2_result" != "0" ]; then
          write_to_error_file "$line" # write instruction line to error file
          echo "$func2_result" # prints error message
          return 1 # return as no need to check rest
        fi

      else # oprands != 2
        write_to_error_file "$line" # write instruction line to error file
        echo "Not enough oparands look for 2" # print error message
      fi

  elif [ "${instruction[0]}" == "$ADDI" ]; then
      if [ "${#ops[@]}" == 3 ]; then # checks if it has 2 oprands
        func1_result=$(validate_register "${ops[0]}") # checks if first oprand is a valid register
        func2_result=$(validate_register "${ops[1]}") # checks if second oprand is a valid register
        func3_result=$(validate_imediate "${ops[2]}") # checks if third oprand is a valid immediate
        if [ "$func1_result" != "0" ]; then
          write_to_error_file "$line" # write instruction line to error file
          echo "$func1_result" # prints error message
          return 1 # return as no need to check rest
        elif [ "$func2_result" != "0" ]; then
          write_to_error_file "$line" # write instruction line to error file
          echo "$func1_result" # prints error message
          return 1 # return as no need to check rest
        elif [ "$func2_result" != "0" ]; then
          write_to_error_file "$line" # write instruction line to error file
          echo "$func1_result" # prints error message
          return 1 # return as no need to check rest
        fi
      fi
  else # opration not recognised
    write_to_error_file "$line" # write instruction line to error file
    echo "Invalid operation" # print error message
    return 1
  fi
  # all correct
  return 0
}

validate_register(){
  echo 0
}

validate_imediate(){
  echo 0
}

validate_memlocation(){
  echo 0
}

while IFS= read line
do
  # split line by space
  IFS=' ' read -r -a array <<< "$line"

  # validate each instruction
  validate_instruction "${array[@]}"

	# echo "$line"
  # echo "${array[@]}"
done <"$instruction_file"
