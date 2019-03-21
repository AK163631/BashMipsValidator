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

  # checks if operation is add or sub
  if [ "${instruction[0]}" == "$ADD" ] || [ "${instruction[0]}" == "$SUB" ]; then
    ops=("${instruction[@]:1}") # oprand sublist

    # checks if it has 3 oprands
    if [ "${#ops[@]}" == 3 ]; then
      for i in "${ops[@]}"
      do
        # check each register is valid 0 if invalid
        func_result=$(validate_register "$i")
        if [ "$func_result" == "0" ]; then
          :
        else
          # write instion line to error file
          write_to_error_file "$line"

          # print error message
          echo "$func_result"

          # return as no need to check rest
          return 1
        fi
      done
    else
      # write instion line to error file
      write_to_error_file "$line"

      # print error message
      echo "Not enough oparands look for 3"
    fi
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
