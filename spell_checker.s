
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL
elipsis:        .asciiz "..."
token2d:        .space 411849           # char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1]; # allocating space for  the largest possible input
dictionary2d:   .space 200001           # char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1]; # allocating space for largest possible dictionary
max_word_size:  .byte 201               # allocating space for largest posible input word
max_input_size: .byte 2049              # #define MAX_INPUT_SIZE 2048 # allocating space for 2048 + $zero input
max_word_size_dictionary: .byte 21      #allocating space for largest posible input word
dictionary_word_max: .byte 10000        # #define MAX_DICTIONARY_WORDS 10000 # allocating space for largest possible dictionary words
# You can add your data here!
        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------




        move $t0, $0        # settig index at $t0 #void twoD_creator (char dictionary[]) {int x = 0;
        add $t1, $t0, 1     # setting index for rightmost character for analysis
        move $t2, $0        # setting index for row in 2d array

        li $s7, 32          # constant equal to ASCII (sp)
        li $s5, 65          # constant equal to ASCII 'a'
        li $s4, 0           # constant equal to ASCII nul
        li $s6, 201         # Loading max word size of input array
        li $t3, 0           # constant equal to ASCII nul
        li $t8, 33          # constant equal to ASCII '!'


INPUT_CHECK:
        la $a1, content($t0)      # obtaining value at index
        lb $s0, 0($a1)            # dictionary2D[count][y] = dictionary[x];
        la $a2, content($t1)      # y++;
        lb $s1, 0($a2)            # obtaining value at index next to current character

        blez $s0, VARIABLE_RESET           # for (x =0; x < string_length_check(dictionary); x++) # at null the array has ended and can proceed

        beq $s0, $s7, ADD_CHAR_TOKEN       # count++; # adding token to 2d array

        slt $s2, $s0, $s5                  # if a punctuation mark proceed to check punctuation
        beq $s2, 1, CHECK_PUNCT      

        j CHECK_ALPHA                      #  if (tokens[x][0] >= 'A' && tokens[x][0] <= 'Z' || tokens[x][0] >= 'a' && tokens[x][0] <= 'z')

CHECK_PUNCT:
        beq $s1, $s7, ADD_CHAR_TOKEN       # if next character is space proceed to print final punctuation and start new token
        slt $s2, $s1, $s5                  # if next character is a punctuation then continue and add element to index in token
        beq $s2, 1, ADD_CHAR

        j ADD_CHAR_TOKEN                   # if next character is not punctuation print and start new token

CHECK_ALPHA:
        slt $s2, $s1, $s5                 # if next character is a punctuation then continue and add element to index in token
        beq $s2, 0, ADD_CHAR           

        j ADD_CHAR_TOKEN                  # if next character is not alphabetical print and add new token

ADD_CHAR:
        mul $t4, $t2, $s6                 # load character to be added 
        add $t5, $t4, $t3            
        sb $s0, token2d($t5)
       
        addi $t3, $t3, 1                  # proceed in index
        addi $t0, $t0, 1                  # y++;
        addi $t1, $t1, 1                  # dictionary2D[count][y] = dictionary[x];
        
        j INPUT_CHECK                     # loop again

ADD_CHAR_TOKEN:
        mul $t4, $t2, $s6                 #store final character of token
        add $t5, $t4, $t3
        sb $s0, token2d($t5)
        
        li $t3, 0                         # reset columns and add token
        addi $t2, $t2, 1
        
        addi $t0, $t0, 1                  # track index
        addi $t1, $t1, 1
        
        j INPUT_CHECK                     # loop again
        
        
 VARIABLE_RESET:
       la $s2, newline             # resetting variables for dictionary 2d
       lb $s7, 0($s2)
       move $t0, $0                # set indexes
       add $t1, $t0, 1
       move $t9, $0
       lb $s6, max_word_size_dictionary
       move $t8, $0
        
DICTIONARY_CHECK:
        la $a1, dictionary($t0)
        lb $s0, 0($a1)
        la $a2, dictionary($t1)              # load indexes as before
        lb $s1, 0($a2)

        blez $s0, VARIABLE_RESET2            # setting exit condition # for (x =0; x < string_length_check(dictionary); x++)

        beq $s0, $s7, ADD_CHAR_TOKEN2        # if space simply print and add token

        j CHECK_ALPHA2                      # if alphabetical proceed to analysis


CHECK_ALPHA2:
        slt $s2, $s1, $s5
        beq $s2, 0, ADD_CHAR2               # if next is alphabetical then just add the character

        j ADD_CHAR_TOKEN2                  # if next is non-alphabetical add to array and start new token


ADD_CHAR2:
        mul $t6, $t8, $s6
        add $t7, $t6, $t9
        sb $s0, dictionary2d($t7)           # store byte at updated index
        
        addi $t9, $t9, 1                    #update column and index
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        
        j DICTIONARY_CHECK


ADD_CHAR_TOKEN2:
        mul $t6, $t8, $s6
        add $t7, $t6, $t9
        sb $s0, dictionary2d($t7)                # store byte 
        
        li $t9, 0                                #update row and reset column
        addi $t8, $t8, 1
        
        addi $t0, $t0, 1
        addi $t1, $t1, 1

        j DICTIONARY_CHECK
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
VARIABLE_RESET2:
        move $t0, $0
	move $t1, $0
	move $t2, $0                                       #reset all registers in case of conflicts or unconsidered implications
	move $t3, $0
	move $t4, $0
        move $t6, $0
	move $t8, $0
	move $t9, $0
	
	addi $s0, $zero, 201
	addi $s1, $zero, 21
	li $s2, 0
	move $s3, $0
	move $s4, $0
	move $s5, $0
	move $s6, $0
	move $s7, $0
	
	move $a0, $0
	move $a1, $0
	move $a2, $0
	li $a3, 65
	
CHECK_FIRST:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)                     # check first element of each input2d token
        beq $a1, $s2, main_end                   # if nul, we are at the end of document and we can fulfill exit condition
        slt $t8, $a1, $a3                        
        beq $t8, 1, PRINT_ELIPSIS
        

TOKEN_ITERATION:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        beq $a1, $s2, DICTIONARY_ITERATION                 # looks at the character to be analyzed
        slt $s7, $a1, $a3                                  # if punctuation simply print it  
        beq $s7, 1, PRINT_CORRECT
        
        j DICTIONARY_ITERATION                            # go to dictionary reference

DICTIONARY_ITERATION:
        mul $t6, $t2, $s1
        add $t9, $t3, $t6                                 # retrieve dictionary character for comparison
        
        lb $a2, dictionary2d($t9)
        
        
        j COMPARE
        
COMPARE:
        beq $a1, $a2, NEXT_ITERATION
        subi $t6, $a2, 32                             #  if (string1[i] != string2[i] && (string1[i] + 32) != string2[i])
        beq $t6, $a1, NEXT_ITERATION                  # compare them and add ASCII 32 to make case insensitive
        
        j UPDATE_DICTIONARY


        

NEXT_ITERATION:
        beq $a1, $s2, PRINT_CORRECT                   # if character nul end of string reached and ready to print
        
        addi $t1, $t1, 1                            #update columns to check next character
        addi $t3, $t3, 1
        
        j TOKEN_ITERATION
        
        
UPDATE_DICTIONARY:
        move $t3, $0
        addi $t2, $t2, 1                             #reset columns, add row (token)
        move $t1, $0
        
        mul $t6, $t2, $s1
        add $t9, $t3, $t6
        lb $a2, dictionary2d($t9)
        beq $a2, $s2, PRINT_UNDERSCORE1                # if null means mispelt and spell check kicks in
        
        j TOKEN_ITERATION



PRINT_CORRECT:
        mul $t6, $t0, $s0
        add $t9, $s4, $t6
        
        
        lb $a0, token2d($t9)                          #retrieve and print character
        li $v0, 11
        syscall
        
        addi $s4, $s4, 1
        beq $t1, $s4, DONE_PRINTING
        
        j PRINT_CORRECT

PRINT_UNDERSCORE1:
        li $a0, 95                                    #print mistake
        li $v0, 11
        syscall
        
        move $t1, $0

        j PRINT_INCORRECT

PRINT_INCORRECT:
        
        mul $t6, $t0, $s0
        add $t8, $t6, $t1
        
        lb $a0, token2d($t8)
        li $v0, 11
        syscall
        
        lb $s4, token2d($t8)
        addi $t1, $t1, 1
        
        beq $s4, $s2, PRINT_UNDERSCORE2
        
        j PRINT_INCORRECT

PRINT_UNDERSCORE2:
        li $a0, 95
        li $v0, 11
        syscall                                   # finalise printing of mispelt token
       
        j DONE_PRINTING
        
PRINT_ELIPSIS:
        add $a0, $a1, $zero
        li $v0, 11
        syscall
        
        addi $t1, $t1, 1
    
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        lb $s4, token2d($t8)
        
        beq $s4, 46, PRINT_ELIPSIS                 # handle special case of elipsis
        

        move $t1, $0
        addi $t0, $t0, 1
        
        j CHECK_FIRST
        
    
DONE_PRINTING:
     
       addi $t0, $t0, 1
       move $t1, $0
       move $t2, $0                              #reset registers once printing is complete
       move $t3, $0
       move $s4, $0
       
       j CHECK_FIRST



        
        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
