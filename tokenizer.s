
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
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

input_file_name:        .asciiz  "test7.in"   
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL


tokens:                 .space 411849 #define MAX_INPUT_SIZE 2048
                                      #Allocating space for 2048 words + $zero of maximum of 200 characters (201 x 2049 = 411849)
        
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
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

        
        move $t0, $0           # int c_idx = 0; retrieving index to be used as reference
        add $t1, $t0, 1        # adding 1 to index to check what element is to the right of the character for later use
        
CHECK_CHAR:
        la $a1, content($t0)         # c = content[c_idx];
        lb $s0, 0($a1)               # loading byte from register $a1, $s0 now holds the character at index $t0
        la $a2, content($t1)
        lb $s1, 0($a2)          # loading byte from register $a2, $s1 now holds the character at index $t1
        
        li $s2, 32        # loads $s2 register with ASCII code for (sp)
        li $s3, 65        # loads $s3 register with ASCII code for 'A',that divides punctuation from alphabetical characters
        li $s5, 33        # loads $s5 register with ASCII code for '!' the starting point for punctuation characters
        
        slt $a2, $s0, $s2
        beq $a2, 1, main_end         # if(c == '\0'){ break;}
                                     # ASCII code for space, alphabetical characters, and punctuation is all greater than 31, so it tells us if the character is null and thus the end of the input file
        
        beq $s2, $s0 NEW_LINE        # else if(c == ' ')
                                     # ASCII code for (sp) is 32, and at spaces we simply print the space and newline
        
        slt $a2, $s0, $s3                 # else if(c == ',' || c == '.' || c == '!' || c == '?'). Checks if character ASCII code is less than 65 (not alphabetical)
        beq $a2, 1, PUNCT_NextChar        # if so instructs program to proceed to punctuation analysis label
         
        j ALPHABET_NextChar        # if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') 
                                   # if valid input file and no prior criteria met character must be alphabetical and proceeds to analysis
       
        
PUNCT_NextChar:
        slt $a3, $s1, $s3             # while(c == ',' || c == '.' || c == '!' || c == '?'); # sets a3 to 1 if character to the right of index ($s1) is not alphabetical
        slt $s4, $s1, $s5             # tokens[tokens_number][token_c_idx] = '\0'; # sets a4 to 1 to check if character to the right of index ($a1) is not space or null and thus also a punctuation
        beq $a3, $s4, NEW_LINE        # tokens_number += 1; # in which case proceeds to print new line
        j PRINT_CHAR                  # if next to a punctuation mark it just prints the character since token has not been complete
        

ALPHABET_NextChar:
        slt $a3, $s1, $s3             # while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z'); # sets $a3 to be 0 if charcter to the right's code is less than 65 (its not alphabetical)
        beq  $a3, 0, PRINT_CHAR       # if alphabetical proceed to print the charcter as the word is not complete
        j NEW_LINE                    #if not alphabetical token is complete and newline can be printed after adding the character

        
PRINT_CHAR:
        li $v0, 11        # allocate space for character
        move $a0, $s0     # print charcater
        syscall           # execute instruction
        
        addi $t0, $t0, 1        # token_c_idx += 1; # c_idx += 1; # change index to analyze next character
        addi $t1, $t1, 1        # change index of character to the right for next analysis loop 
        j CHECK_CHAR            # analyze next character returning to loop
        

NEW_LINE:
        li $v0, 11          # allocate space for character
        lb $a0, ($a1)       # print charcater
        syscall             # execute instruction
        
        li $v0, 11        # allocate space for character
        lb $a0, newline   #print newline
        syscall           #execute command
        
        addi $t0, $t0, 1        # token_c_idx += 1; # c_idx += 1; # change index to analyze next character
        addi $t1, $t1, 1        # change index of character to the right for next analysis loop 
        j CHECK_CHAR            # analyze next character returning to loop
        
        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
