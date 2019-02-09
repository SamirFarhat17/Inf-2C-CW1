
#=========================================================================
# Punctuation checker 
#=========================================================================
# Marks misspelled words and punctuation errors in a sentence according to a dictionary
# and punctuation rules
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
        
# You can add your data here!
elipsis:        .asciiz "..."
token2d:        .space 411849
dictionary2d:   .space 200001
max_word_size:  .byte 201
max_input_size: .byte 2049
max_word_size_dictionary: .byte 21
dictionary_word_max: .byte 10000
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
        lb   $t1, dictionary($t0)               
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\n')
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




        move $t0, $0
        add $t1, $t0, 1                                  #More specific comments on spell checker (with C)
        move $t2, $0                                    # Here you can find comments for punctuation checker extension only

        li $s7, 32
        li $s5, 65
        li $s4, 0
        li $s6, 201
        li $t3, 0
        li $t8, 33


INPUT_CHECK:
        la $a1, content($t0)
        lb $s0, 0($a1)
        la $a2, content($t1)
        lb $s1, 0($a2)

        blez $s0, VARIABLE_RESET

        beq $s0, $s7, ADD_CHAR_TOKEN

        slt $s2, $s0, $s5
        beq $s2, 1, CHECK_PUNCT

        j CHECK_ALPHA

CHECK_PUNCT:
        beq $s1, $s7, ADD_CHAR_TOKEN
        slt $s2, $s1, $s5
        beq $s2, 1, ADD_CHAR

        j ADD_CHAR_TOKEN

CHECK_ALPHA:
        slt $s2, $s1, $s5
        beq $s2, 0, ADD_CHAR

        j ADD_CHAR_TOKEN

ADD_CHAR:
        mul $t4, $t2, $s6
        add $t5, $t4, $t3
        sb $s0, token2d($t5)
       
        addi $t3, $t3, 1
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        
        j INPUT_CHECK

ADD_CHAR_TOKEN:
        mul $t4, $t2, $s6
        add $t5, $t4, $t3
        sb $s0, token2d($t5)
        
        li $t3, 0
        addi $t2, $t2, 1
        
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        
        j INPUT_CHECK
        
        
 VARIABLE_RESET:
       la $s2, newline
       lb $s7, 0($s2)
       move $t0, $0
       add $t1, $t0, 1
       move $t9, $0
       lb $s6, max_word_size_dictionary
       move $t8, $0
        
DICTIONARY_CHECK:
        la $a1, dictionary($t0)
        lb $s0, 0($a1)
        la $a2, dictionary($t1)
        lb $s1, 0($a2)

        blez $s0, VARIABLE_RESET2

        beq $s0, $s7, ADD_CHAR_TOKEN2

        j CHECK_ALPHA2


CHECK_ALPHA2:
        slt $s2, $s1, $s5
        beq $s2, 0, ADD_CHAR2

        j ADD_CHAR_TOKEN2


ADD_CHAR2:
        mul $t6, $t8, $s6
        add $t7, $t6, $t9
        sb $s0, dictionary2d($t7)
        
        addi $t9, $t9, 1
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        
        j DICTIONARY_CHECK


ADD_CHAR_TOKEN2:
        mul $t6, $t8, $s6
        add $t7, $t6, $t9
        sb $s0, dictionary2d($t7)
        
        li $t9, 0
        addi $t8, $t8, 1
        
        addi $t0, $t0, 1
        addi $t1, $t1, 1

        j DICTIONARY_CHECK
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
VARIABLE_RESET2:
        move $t0, $0
	move $t1, $0
	move $t2, $0
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
        
        lb $a1, token2d($t8)
        beq $a1, $s2, main_end
        beq $a1, 32, PRINT_SPACE
        slt $t8, $a1, $a3
        beq $t8, 1, IF_PUNCT
        

TOKEN_ITERATION:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        beq $a1, $s2, DICTIONARY_ITERATION
        slt $s7, $a1, $a3
        beq $s7, 1, PRINT_CORRECT
        
        j DICTIONARY_ITERATION

DICTIONARY_ITERATION:
        mul $t6, $t2, $s1
        add $t9, $t3, $t6
        
        lb $a2, dictionary2d($t9)
        
        
        j COMPARE
        
COMPARE:
        beq $a1, $a2, NEXT_ITERATION
        subi $t6, $a2, 32
        beq $t6, $a1, NEXT_ITERATION
        
        j UPDATE_DICTIONARY


        

NEXT_ITERATION:
        beq $a1, $s2, PRINT_CORRECT
        
        addi $t1, $t1, 1
        addi $t3, $t3, 1
        
        j TOKEN_ITERATION
        
        
UPDATE_DICTIONARY:
        move $t3, $0
        addi $t2, $t2, 1
        move $t1, $0
        
        mul $t6, $t2, $s1
        add $t9, $t3, $t6
        lb $a2, dictionary2d($t9)
        beq $a2, $s2, PRINT_UNDERSCORE1
        
        j TOKEN_ITERATION



PRINT_CORRECT:
        mul $t6, $t0, $s0
        add $t9, $s4, $t6
        
        
        lb $a0, token2d($t9)
        li $v0, 11
        syscall
        
        addi $s4, $s4, 1
        beq $t1, $s4, DONE_PRINTING
        
        j PRINT_CORRECT

PRINT_UNDERSCORE1:
        li $a0, 95
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
        syscall
       
        j DONE_PRINTING
        
IF_PUNCT:
        beq $a1, 46, DOT_ANALYSIS               # 46 is ASCII for '.' so branching out to handle special case of elipsis
        j NDOT_ANALYSIS
        
    
DONE_PRINTING:
     
       addi $t0, $t0, 1
       move $t1, $0
       move $t2, $0
       move $t3, $0
       move $s4, $0
       
       j CHECK_FIRST

NDOT_ANALYSIS:
        addi $t1, $t1, 1                  # update indexes  and load character next to current
        mul $t4, $t0, $s0
        add $t8, $t1, $t4                 
        
        lb $a1, token2d($t8)                    # if null only one character so not necessarily wrong and needs to be checked
        beq $a1, 0, NEIGHBORL
        
        j MULTIPLE_WRONG
        
NEIGHBORL:
        addi $t1, $t1, -1
        addi $t0, $t0, -1                      # check character to left according to rules 
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        beq $a1 0, NEIGHBORR                   # if rules not  violated check the right
        beq $a1, 32, WRONGL
        blt $a1, 65, WRONGL
        
        j NEIGHBORR
        
NEIGHBORR:
        addi $t0, $t0, 2
        mul $t4, $t0, $s0                  #load byte
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        bgt $a1, 32, WRONGR                     # check if punctuation or alphabetical character to right
        
        j RIGHT_1                            # if not correct use of punctuation
       
WRONGL:
        li $a0, 95
        li $v0, 11                           
        syscall
        
        addi $t0, $t0, 1
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)             # print underscore then charcter then underscore
        
        move $a0, $a1
        li $v0, 11
        syscall
        
        li $a0, 95
        li $v0, 11
        syscall
        
        j STOP_PRINT
        
WRONGR:
        li $a0, 95
        li $v0, 11
        syscall
        
        addi $t0, $t0, -1
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)                 # print underscore then charcter then underscore
        
        move $a0, $a1
        li $v0, 11
        syscall
        
        li $a0, 95
        li $v0, 11
        syscall
        
        j STOP_PRINT
         
RIGHT_1:
        addi $t0, $t0, -1
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)               # print character 
        move $a0, $a1
        li $v0, 11
        syscall
        
        j STOP_PRINT
        
MULTIPLE_WRONG:
        li $a0, 95                          #print underscore then proceed to loop
        li $v0, 11
        syscall                         
        
        addi $t1, $t1, -1
        
        j PRINT_M_WRONG

PRINT_M_WRONG:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4                    #loop until end of token reached 
        
        lb $a1, token2d($t8)
        
        move $a0, $a1
        li $v0, 11
        syscall
        
        addi $t1, $t1, 1
        
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        beq $a1, 0, MULTIPLE_WRONG2               # end of token reached exit
        
        j PRINT_M_WRONG
        
MULTIPLE_WRONG2:
        li $a0, 95
        li $v0, 11
        syscall                                  # print underscore
        
        j STOP_PRINT
        
DOT_ANALYSIS:
        addi $t1, $t1, 1
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)               #analysis for special elipsis cases
        addi $t1, $t1, -1
        beq $a1, 0, NDOT_ANALYSIS
        
        move $t6, $0
        
        j MULTIPLE_DOT
        
        
MULTIPLE_DOT:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)            #iterates through elipsis until all '.' have been counted, to then print 
        beq $a1, 46, PLUS_COUNT
        
        j FINAL_COUNT
        
PLUS_COUNT:
        addi $t1, $t1, 1
        addi $t6, $t6, 1               # count++
        j MULTIPLE_DOT
        
FINAL_COUNT:
        move $t1, $0
        beq $t6, 3, PRINT_ELIPSIS               # if elipsis print normally, if not print with underscores
        j UNDERSCORE1
        
PRINT_ELIPSIS:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        move $a0, $a1
        li $v0, 11                                  #iterate through until end of token reached then exit
        syscall
        
        beq $t1, $t6, STOP_PRINT
        addi $t1, $t1, 1
        
        j PRINT_ELIPSIS
        
UNDERSCORE1:
        li $a0, 95
        li $v0, 11
        syscall                                 # underscore
        
        j PRINT_ELIPSISW
        
PRINT_ELIPSISW:
        mul $t4, $t0, $s0
        add $t8, $t1, $t4
        
        lb $a1, token2d($t8)
        move $a0, $a1                         # iterate through till illegal elipsis is done
        li $v0, 11
        syscall
        
        beq $t1, $t6, UNDERSCORE2
        addi $t1, $t1, 1
        
        j PRINT_ELIPSISW
        
UNDERSCORE2:
        li $a0, 95
        li $v0, 11
        syscall                               #underscore

        
        j STOP_PRINT

STOP_PRINT:        
        addi $t0, $t0, 1
        move $t1, $0                    #reset column, update row
        
        j CHECK_FIRST
        
PRINT_SPACE:
       li $a0, 32
       li $v0, 11
       syscall
       
       addi $t0, $t0, 1
       move $t1, $0
       move $t2, $0                       # reset registers and repeat loop
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
