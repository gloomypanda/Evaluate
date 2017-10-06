#!/usr/bin/env bash

# Creating the variables and arrays 
declare input="input.txt"                                                
declare answer="answer.txt"
declare -a extensions_to_be_allowed=("c" "cpp" "java" "py")
declare -a output_to_be_displayed=( "\x1B[92mWhoaa! Correct answer :)\x1B[39m" "\x1B[91mOopsie, Wrong answer :(\x1B[39m" "\x1B[94mCompile Error o.O\x1B[39m" )
# Applying bash colouring to the outputs. (Green for correct, Red for Wrong and Blue for Compile error, and resetting the colour back again)



# This function compares the generated output file with the given expected output file
function verdict(){
  difference="$(diff <(cat $outputfile) <(cat ./$answer))"                    #comparing using diff command
  if [ "$difference" != "" ]
    then echo 1
    else echo 0
  fi
}

# This function checks if the extension of the file sent as parameter is C, CPP, Java or Python. (Extension of a file is sent as parameter)
function extension_check(){
  for exten in "${extensions_to_be_allowed[@]}"        # Checks for all extensions in the array
  do
    if [ "$exten" = "$1" ]; then return 1                    # If the extension is C, CPP, Java or Python, return 1 else 0
    fi
  done
  return 0
}


# This function basically compiles the files according to their extension
function subscript_of_verdict(){
  compile_name=temp
  flag=0                 # The variable which will actually determine which output to show ( The subscript of the output_to_be_displayed )
	case "$extension" in
    cpp )               # If it is a CPP file
      g++ -o "$compile_name".out "$file" >& /dev/null || flag=2               #If you want to show compile time errors,  dump the  >& /dev/null  part
      if [ "$flag" -ne 2 ]
      then
        ./"$compile_name".out < ./"$input" > "$outputfile" 
      fi
      ;;

    c )                 # If it is a C file
			gcc -o "$compile_name".out "$file" >& /dev/null || flag=2               #If the file doesn't compile, com = 2
      if [ "$flag" -ne 2 ]
      then
        ./"$compile_name".out < ./"$input" > "$outputfile"               #If the file compiled, then check whether output is correct or not.
      fi
      ;;
    java )
      javac "$file" >& /dev/null || com=2
      if [ "$flag" -ne 2 ]
      then
        java "$filename" < ./"$input" > "$outputfile"
        mv "$filename".class "$compile_name".class
      fi
      ;;
    py )
      python "$file" < ./"$input" >& /dev/null || com=2
      if [ "$flag" -ne 2 ]
      then
        python "$file" < ./"$input" > "$outputfile"
      fi
      ;;
	esac
  if [ "$flag" -ne 2 ]                                                        # Enter the comparison loop only if it compiled successfully
  then
    test -e "$compile_name".* && rm "$compile_name".*                        #If a compiled file already exists, delete it.
    flag=`verdict`                                                            #Calling the verdict function ..
    test -e "$outputfile" && rm "$outputfile"                                #Remove the temporary output file created, if present
  fi
  echo "$flag"                                                                # Return com which actually represents the subscript of output_to_be_displayed
}


for file in *                                                               #Looping through all the files of the folder
do
	IFS='.' read filename extension <<< "$file"                               #IFS is the internal field seperator to seperate file name and extension
	if extension_check "$extension"; then                                      #sending just the extension as a parameter and skip the iteration if not c or cpp 
		continue
	fi
	outputfile=output.tmp
	subscript=`subscript_of_verdict`
  echo -e "$file\t\t${output_to_be_displayed[$subscript]}"	                 # Print the Verdict
done
